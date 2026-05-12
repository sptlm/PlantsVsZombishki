# HW8. Message broker на PostgreSQL и Java

## Что реализовано

В этой работе PostgreSQL используется как брокер сообщений для предметной области маркетплейса из `s2/db/migrations`: покупатели создают покупки/заказы, заказы доставляются в ПВЗ, а фоновые воркеры обрабатывают события доставки и проверки дорогих заказов.

Состав:

- `postgres` - база данных и таблица очереди `tasks`.
- `producer` - Java-сервис, генерирует задачи в цикле.
- `worker-1`, `worker-2` - два независимых Java-воркера, конкурируют за задачи.
- `monitor` - Java-сервис, печатает лаг очереди, throughput и среднее ожидание по приоритетам.

Запуск:

```bash
docker compose up -d --build
docker compose logs -f producer worker-1 worker-2 monitor
```

Подключение к базе с хоста:

```bash
psql "postgresql://admin:admin_pass@localhost:5548/marketplace_queue"
```

Остановка с очисткой данных:

```bash
docker compose down -v
```

## Схема БД

Таблица бизнес-событий:

```sql
CREATE TABLE marketplace_events (
    id bigserial PRIMARY KEY,
    buyer_id integer NOT NULL,
    shop_id integer NOT NULL,
    item_id integer NOT NULL,
    pvz_id integer NOT NULL,
    order_total numeric(10, 2) NOT NULL,
    event_type text NOT NULL,
    description text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);
```

Таблица очереди:

```sql
CREATE TABLE tasks (
    id bigserial PRIMARY KEY,
    task_type text NOT NULL,
    priority integer NOT NULL DEFAULT 0,
    status text NOT NULL DEFAULT 'Ready',
    payload jsonb NOT NULL,
    attempts integer NOT NULL DEFAULT 0,
    max_attempts integer NOT NULL DEFAULT 5,
    scheduled_at timestamptz NOT NULL DEFAULT now(),
    created_at timestamptz NOT NULL DEFAULT now(),
    started_at timestamptz,
    completed_at timestamptz,
    updated_at timestamptz NOT NULL DEFAULT now(),
    locked_by text,
    error_message text
);
```

Основной индекс для быстрого взятия задач:

```sql
CREATE INDEX idx_tasks_ready_pick
    ON tasks (priority DESC, scheduled_at, created_at, id)
    WHERE status = 'Ready';
```

Для таблицы `tasks` включены агрессивные параметры autovacuum:

```sql
WITH (
    fillfactor = 80,
    autovacuum_vacuum_scale_factor = 0.01,
    autovacuum_vacuum_threshold = 50,
    autovacuum_analyze_scale_factor = 0.005,
    autovacuum_analyze_threshold = 50
);
```

## Producer

Продьюсер генерирует поток задач с высокой интенсивностью:

- `PRODUCER_RATE_PER_SECOND=250`
- `PRODUCER_CRITICAL_PERCENT=20`
- обычные задачи доставки заказа получают `priority = 0`
- дорогие/критические заказы получают `priority = 100`

Каждая задача вставляется в одной транзакции вместе с фиктивной бизнес-логикой:

```sql
BEGIN;

INSERT INTO marketplace_events (...);
INSERT INTO tasks (...);
SELECT pg_notify('marketplace_tasks_ready', '<task_id>');

COMMIT;
```

`NOTIFY` отправляется только после `COMMIT`, поэтому воркер не увидит задачу раньше, чем она реально появится в очереди.

## Workers

Два воркера конкурируют за задачи через `FOR UPDATE SKIP LOCKED`:

```sql
WITH candidate AS (
    SELECT id
    FROM tasks
    WHERE status = 'Ready'
      AND scheduled_at <= clock_timestamp()
    ORDER BY priority DESC, scheduled_at, created_at, id
    FOR UPDATE SKIP LOCKED
    LIMIT 1
)
UPDATE tasks AS t
SET status = 'Running',
    started_at = clock_timestamp(),
    updated_at = clock_timestamp(),
    locked_by = 'worker-1'
FROM candidate
WHERE t.id = candidate.id
RETURNING t.*;
```

Почему это работает:

- `FOR UPDATE` блокирует выбранную строку.
- `SKIP LOCKED` позволяет второму воркеру не ждать первый, а взять другую задачу.
- `ORDER BY priority DESC` гарантирует, что `priority = 100` идет раньше `priority = 0`.

После обработки воркер ставит:

```sql
UPDATE tasks
SET status = 'Completed',
    completed_at = clock_timestamp(),
    locked_by = NULL
WHERE id = :id;
```

Если обработка упала, включается retry:

```sql
UPDATE tasks
SET status = 'Ready',
    attempts = attempts + 1,
    scheduled_at = clock_timestamp() + make_interval(secs => :backoff_seconds),
    locked_by = NULL,
    error_message = 'transient marketplace processing failure, retry scheduled'
WHERE id = :id;
```

Базовая задержка `WORKER_BACKOFF_SECONDS=300`, дальше применяется exponential backoff:

```text
1-я ошибка: 5 минут
2-я ошибка: 10 минут
3-я ошибка: 20 минут
```

После `max_attempts = 5` задача переводится в `Failed`.

## LISTEN / NOTIFY

Воркер подписан на канал:

```sql
LISTEN marketplace_tasks_ready;
```

Если задач нет, он ждет уведомления через `LISTEN/NOTIFY`. В compose задан `WORKER_LISTEN_TIMEOUT_MS=60000`: это не основной polling-интервал, а редкая страховка, чтобы воркер раз в минуту перепроверил очередь, если соединение пережило сбой или уведомление было пропущено во время рестарта. В нормальном сценарии воркер просыпается сразу от `NOTIFY`, который продьюсер отправляет в той же транзакции, где вставляет задачу.

## Лаг очереди

SQL-запрос для лага:

```sql
SELECT
    COALESCE(EXTRACT(EPOCH FROM now() - MIN(created_at)), 0) AS ready_lag_seconds
FROM tasks
WHERE status = 'Ready';
```

Расширенный запрос:

```sql
SELECT
    count(*) FILTER (WHERE status = 'Ready') AS ready,
    count(*) FILTER (WHERE status = 'Running') AS running,
    count(*) FILTER (WHERE status = 'Completed') AS completed,
    count(*) FILTER (WHERE status = 'Failed') AS failed,
    COALESCE(EXTRACT(EPOCH FROM now() - MIN(created_at) FILTER (WHERE status = 'Ready')), 0) AS ready_lag_seconds
FROM tasks;
```

Пример лога monitor при `250` задачах/сек и двух воркерах:

```text
monitor ready=985 running=2 completed=255 failed=0 lag_oldest_ready_s=5.03 throughput=50.93 tasks/s waits=[p100 completed=248 avg_wait_s=0.099; p0 completed=7 avg_wait_s=2.105]
monitor ready=1990 running=2 completed=502 failed=0 lag_oldest_ready_s=10.04 throughput=49.34 tasks/s waits=[p100 completed=484 avg_wait_s=0.095; p0 completed=18 avg_wait_s=5.865]
monitor ready=3011 running=0 completed=723 failed=0 lag_oldest_ready_s=15.04 throughput=44.14 tasks/s waits=[p100 completed=689 avg_wait_s=0.085; p0 completed=34 avg_wait_s=8.465]
```

По этому логу видно, что очередь растет: продьюсер вставляет быстрее, чем два воркера успевают обработать.

График в текстовом виде:

```text
seconds:  5    10    15
lag:      5.0  10.0  15.0
ready:    985  1990  3011
```

## Throughput

Запрос для пропускной способности за последнюю минуту:

```sql
SELECT
    count(*) / 60.0 AS completed_per_second
FROM tasks
WHERE status = 'Completed'
  AND completed_at >= now() - interval '60 seconds';
```

Запрос по секундам:

```sql
SELECT
    date_trunc('second', completed_at) AS second,
    count(*) AS completed
FROM tasks
WHERE status = 'Completed'
GROUP BY 1
ORDER BY 1 DESC
LIMIT 20;
```

`monitor` считает throughput по дельте общего количества `Completed` между двумя замерами:

```text
throughput = (completed_now - completed_previous) / seconds_between_measurements
```

## Демонстрация приоритетов

Запрос показывает, что критические задачи начинают выполняться быстрее обычных:

```sql
SELECT
    priority,
    count(*) FILTER (WHERE status = 'Completed') AS completed,
    round(avg(EXTRACT(EPOCH FROM started_at - created_at)) FILTER (WHERE started_at IS NOT NULL)::numeric, 3) AS avg_wait_seconds
FROM tasks
GROUP BY priority
ORDER BY priority DESC;
```

Ожидаемый результат:

```text
 priority | completed | avg_wait_seconds
----------+-----------+------------------
      100 |      1777 |            0.308
        0 |        39 |            9.621
```

Несмотря на то, что часть `priority = 100` была создана позже обычных задач, воркеры берут ее раньше из-за сортировки:

```sql
ORDER BY priority DESC, scheduled_at, created_at, id
```

Дополнительная проверка "критическая задача создана позже, но стартовала раньше обычной":

```sql
SELECT
    critical.id AS critical_id,
    round(EXTRACT(EPOCH FROM critical.created_at - normal.created_at)::numeric, 3) AS created_later_by_s,
    round(EXTRACT(EPOCH FROM normal.started_at - critical.started_at)::numeric, 3) AS started_earlier_by_s,
    normal.id AS normal_id
FROM tasks critical
         JOIN tasks normal
              ON critical.priority = 100
                  AND normal.priority = 0
                  AND critical.created_at > normal.created_at
                  AND critical.started_at < normal.started_at
WHERE critical.started_at IS NOT NULL
  AND normal.started_at IS NOT NULL
ORDER BY critical.started_at DESC
LIMIT 10;
```

Пример результата с тестового прогона:

```text
 critical_id | created_later_by_s | started_earlier_by_s | normal_id
-------------+--------------------+----------------------+-----------
       14936 |             59.132 |                0.006 |       152
       14923 |             59.080 |                0.034 |       152
       14909 |             59.024 |                0.035 |       152
```

## Bloat и VACUUM

Очередь активно обновляет строки: `Ready -> Running -> Completed`, а при ошибках еще и `Running -> Ready`. Это создает dead tuples.

Посмотреть статистику:

```sql
SELECT
    relname,
    n_live_tup,
    n_dead_tup,
    last_autovacuum,
    vacuum_count,
    autovacuum_count
FROM pg_stat_user_tables
WHERE relname = 'tasks';
```

Ручной запуск:

```sql
VACUUM ANALYZE tasks;
```

Проверка плана выбора задачи:

```sql
EXPLAIN (ANALYZE, BUFFERS)
WITH candidate AS (
    SELECT id
    FROM tasks
    WHERE status = 'Ready'
      AND scheduled_at <= clock_timestamp()
    ORDER BY priority DESC, scheduled_at, created_at, id
    FOR UPDATE SKIP LOCKED
    LIMIT 1
)
UPDATE tasks AS t
SET status = 'Running'
FROM candidate
WHERE t.id = candidate.id;
```

После `VACUUM ANALYZE` план обычно стабильнее, а чтение индекса `idx_tasks_ready_pick` требует меньше лишних буферов при длительном тесте.

## Настройки нагрузки

Можно быстро менять интенсивность в `docker-compose.yml`:

```yaml
PRODUCER_RATE_PER_SECOND: 250
WORKER_NORMAL_MIN_MS: 55
WORKER_NORMAL_MAX_MS: 90
WORKER_CRITICAL_MIN_MS: 20
WORKER_CRITICAL_MAX_MS: 35
```

Чтобы очередь росла, нужно сделать:

```text
producer_rate > суммарный worker throughput
```

В текущей конфигурации продьюсер генерирует примерно `250/s`, а два воркера обрабатывают примерно `55-70/s`, поэтому лаг должен расти.
