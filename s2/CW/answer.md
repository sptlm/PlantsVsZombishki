# Задание 1

```sql
Explain (analyze, buffers)
SELECT id, user_id, amount, created_at
FROM exam_events
WHERE user_id = 4242
  AND created_at >= TIMESTAMP '2025-03-10 00:00:00'
  AND created_at < TIMESTAMP '2025-03-11 00:00:00';
```
1.
```text
Seq Scan on exam_events  (cost=0.00..1617.07 rows=1 width=26) (actual time=6.551..6.553 rows=3 loops=1)
  Filter: ((created_at >= '2025-03-10 00:00:00'::timestamp without time zone) AND (created_at < '2025-03-11 00:00:00'::timestamp without time zone) AND (user_id = 4242))
  Rows Removed by Filter: 60001
  Buffers: shared hit=567
Planning:
  Buffers: shared hit=111
Planning Time: 0.534 ms
Execution Time: 6.589 ms
```
2.
выбран seq scan,
CREATE INDEX idx_exam_events_status ON exam_events (status);
CREATE INDEX idx_exam_events_amount_hash ON exam_events USING hash (amount);
оба индекса не использованы в запросе

3.
```sql
CREATE INDEX idx_items_price_btree
    ON exam_events (created_at);
```
4.
```text
Bitmap Heap Scan on exam_events  (cost=14.79..620.88 rows=1 width=26) (actual time=0.743..0.744 rows=3 loops=1)
  Recheck Cond: ((created_at >= '2025-03-10 00:00:00'::timestamp without time zone) AND (created_at < '2025-03-11 00:00:00'::timestamp without time zone))
  Filter: (user_id = 4242)
  Rows Removed by Filter: 666
  Heap Blocks: exact=567
  Buffers: shared hit=567 read=4
  ->  Bitmap Index Scan on idx_items_price_btree  (cost=0.00..14.79 rows=650 width=0) (actual time=0.117..0.117 rows=669 loops=1)
        Index Cond: ((created_at >= '2025-03-10 00:00:00'::timestamp without time zone) AND (created_at < '2025-03-11 00:00:00'::timestamp without time zone))
        Buffers: shared read=4
Planning:
  Buffers: shared hit=14 read=1 dirtied=1
Planning Time: 0.250 ms
Execution Time: 0.770 ms
```
5.
теперь планировщик использует bitmap index scan по новому индексу, 

6.
нужно, т.к. планировщик должен проанализировать, какие сканы эффективнее на бд после весенных изменений

# Задание 2

1.
```text
Hash Join  (cost=558.06..1697.40 rows=347 width=25) (actual time=36.215..41.756 rows=1000 loops=1)
  Hash Cond: (o.user_id = u.id)
  Buffers: shared hit=1165 read=21
  ->  Bitmap Heap Scan on exam_orders o  (cost=147.56..1268.68 rows=6941 width=22) (actual time=33.531..37.989 rows=7000 loops=1)
        Recheck Cond: ((created_at >= '2025-03-01 00:00:00'::timestamp without time zone) AND (created_at < '2025-03-08 00:00:00'::timestamp without time zone))
        Heap Blocks: exact=1017
        Buffers: shared hit=1017 read=21
        ->  Bitmap Index Scan on idx_exam_orders_created_at  (cost=0.00..145.83 rows=6941 width=0) (actual time=33.410..33.410 rows=7000 loops=1)
              Index Cond: ((created_at >= '2025-03-01 00:00:00'::timestamp without time zone) AND (created_at < '2025-03-08 00:00:00'::timestamp without time zone))
              Buffers: shared read=21
  ->  Hash  (cost=398.00..398.00 rows=1000 width=11) (actual time=2.663..2.664 rows=1000 loops=1)
        Buckets: 1024  Batches: 1  Memory Usage: 50kB
        Buffers: shared hit=148
        ->  Seq Scan on exam_users u  (cost=0.00..398.00 rows=1000 width=11) (actual time=0.057..2.431 rows=1000 loops=1)
              Filter: (country = 'JP'::text)
              Rows Removed by Filter: 19000
              Buffers: shared hit=148
Planning:
  Buffers: shared hit=100
Planning Time: 1.683 ms
Execution Time: 41.902 ms
```
2.
hash join
3.
оптимизатору удобно отфильтровать японских пользователей, построить по ним хеш-таблицу и затем соединить её с заказами, отобранными по диапазону даты
4.
idx_exam_users_name — не участвыет
idx_exam_orders_created_at — использован для диапазона дат

5.
```sql
CREATE INDEX idx_exam_users_country ON exam_users(country);
```

6.
```text
Hash Join  (cost=333.68..1474.86 rows=352 width=25) (actual time=0.952..3.405 rows=1000 loops=1)
  Hash Cond: (o.user_id = u.id)
  Buffers: shared hit=1186 read=3
  ->  Bitmap Heap Scan on exam_orders o  (cost=148.64..1271.33 rows=7046 width=22) (actual time=0.439..2.006 rows=7000 loops=1)
        Recheck Cond: ((created_at >= '2025-03-01 00:00:00'::timestamp without time zone) AND (created_at < '2025-03-08 00:00:00'::timestamp without time zone))
        Heap Blocks: exact=1017
        Buffers: shared hit=1038
        ->  Bitmap Index Scan on idx_exam_orders_created_at  (cost=0.00..146.88 rows=7046 width=0) (actual time=0.324..0.324 rows=7000 loops=1)
              Index Cond: ((created_at >= '2025-03-01 00:00:00'::timestamp without time zone) AND (created_at < '2025-03-08 00:00:00'::timestamp without time zone))
              Buffers: shared hit=21
  ->  Hash  (cost=172.54..172.54 rows=1000 width=11) (actual time=0.505..0.506 rows=1000 loops=1)
        Buckets: 1024  Batches: 1  Memory Usage: 50kB
        Buffers: shared hit=148 read=3
        ->  Bitmap Heap Scan on exam_users u  (cost=12.04..172.54 rows=1000 width=11) (actual time=0.133..0.392 rows=1000 loops=1)
              Recheck Cond: (country = 'JP'::text)
              Heap Blocks: exact=148
              Buffers: shared hit=148 read=3
              ->  Bitmap Index Scan on idx_exam_users_country  (cost=0.00..11.79 rows=1000 width=0) (actual time=0.116..0.116 rows=1000 loops=1)
                    Index Cond: (country = 'JP'::text)
                    Buffers: shared read=3
Planning:
  Buffers: shared hit=27 read=1
Planning Time: 0.616 ms
Execution Time: 3.477 ms
```
7.
Улучшился, теперь читаются только пользователи из нужной страны, а не все

8.
преобладание shared hit означает, что страницы в основном читались из буфера памяти;
преобладание read означает, что их пришлось дочитывать с диска, то есть доступ дороже.

# Задание 3

1.
После UPDATE строка с id = 1 PostgreSQL создаёт новую версию строки. У новой версии новый xmin, изменился ctid, а старая версия станет устаревшей и получит служебные признаки, указывающие, что она больше не является актуальной для новых снимков.

2. 
PostgreSQL создаёт новую версию строки, не удаляя старую, а добавляя ей xmax, который указывает, что строка изменена, или удалена

3.
После DELETE строка физически не исчезает мгновенно, а помечается как удалённая. В обычном SELECT она больше не видна, потому что текущий снимок считает её удалённой; окончательная очистка мёртвых версий выполняется позднее механизмом VACUUM.

4.
VACUUM — очищает мёртвые версии строк и освобождает место внутри таблицы для повторного использования, но не возвращает место ОС.
autovacuum — автоматический запуск похожей очистки, чтобы таблицы не разрастались и статистика оставалась актуальной.
VACUUM FULL — переписывает таблицу целиком, компактно упаковывает данные и может реально уменьшить размер файла таблицы.
Отдельный ответ
5.
Полностью блокировать таблицу может VACUUM FULL.


# Задание 4.
1.
В первом эксперименте UPDATE в сессии B ждет, потому что FOR SHARE берёт блокировку строки, несовместимую с изменением этой строки. Во втором эксперименте ожидание тоже есть, но блокировка FOR UPDATE сильнее по смыслу: она явно резервирует строку под возможное изменение и конфликтует с другими попытками обновления ещё жёстче.
2.
Разница между ними в том, что FOR SHARE предназначен для защищённого чтения строки без её изменения в текущей транзакции, а FOR UPDATE — для сценария, где строку собираются изменять или хотят заблокировать ее перед изменением.
3.
Обычный SELECT без FOR SHARE/FOR UPDATE ведёт себя иначе, потому что в PostgreSQL простое чтение по MVCC не ставит строковую блокировку на изменение. Оно читает согласованную версию строки из снимка транзакции и не мешает другим транзакциям выполнять UPDATE.
4.
FOR UPDATE уместен там, где нужно предотвратить гонки: списание товара со склада, захват задачи воркером, изменение остатка, бронирование слота, повторная проверка и последующее изменение одной и той же строки в рамках транзакции.

# Задание 5

```sql
-- 1
CREATE TABLE exam_measurements (
    city_id INTEGER NOT NULL,
    log_date DATE NOT NULL,
    peaktemp INTEGER,
    unitsales INTEGER
) PARTITION BY RANGE (log_date);
-- 2
CREATE TABLE exam_measurements_2025_01
    PARTITION OF exam_measurements
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE exam_measurements_2025_02
    PARTITION OF exam_measurements
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

CREATE TABLE exam_measurements_2025_03
    PARTITION OF exam_measurements
    FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');

CREATE TABLE exam_measurements_default
    PARTITION OF exam_measurements DEFAULT;
-- 3
INSERT INTO exam_measurements (city_id, log_date, peaktemp, unitsales)
SELECT city_id, log_date, peaktemp, unitsales
FROM exam_measurements_src;

ANALYZE exam_measurements;

EXPLAIN (ANALYZE, BUFFERS)
SELECT city_id, log_date, unitsales
FROM exam_measurements
WHERE log_date >= DATE '2025-02-01'
  AND log_date < DATE '2025-03-01';

EXPLAIN (ANALYZE, BUFFERS)
SELECT city_id, log_date, unitsales
FROM exam_measurements
WHERE city_id = 10;
```

1.
```text
Seq Scan on exam_measurements_2025_02 exam_measurements  (cost=0.00..25.00 rows=1200 width=12) (actual time=0.015..0.219 rows=1200 loops=1)
  Filter: ((log_date >= '2025-02-01'::date) AND (log_date < '2025-03-01'::date))
  Buffers: shared hit=7
Planning:
  Buffers: shared hit=56
Planning Time: 1.800 ms
Execution Time: 0.300 ms
```
```text
Append  (cost=0.00..68.62 rows=74 width=12) (actual time=0.016..0.238 rows=74 loops=1)
  Buffers: shared hit=22
  ->  Seq Scan on exam_measurements_2025_01 exam_measurements_1  (cost=0.00..22.00 rows=24 width=12) (actual time=0.015..0.091 rows=24 loops=1)
        Filter: (city_id = 10)
        Rows Removed by Filter: 1176
        Buffers: shared hit=7
  ->  Seq Scan on exam_measurements_2025_02 exam_measurements_2  (cost=0.00..22.00 rows=24 width=12) (actual time=0.005..0.066 rows=24 loops=1)
        Filter: (city_id = 10)
        Rows Removed by Filter: 1176
        Buffers: shared hit=7
  ->  Seq Scan on exam_measurements_2025_03 exam_measurements_3  (cost=0.00..22.00 rows=24 width=12) (actual time=0.005..0.067 rows=24 loops=1)
        Filter: (city_id = 10)
        Rows Removed by Filter: 1176
        Buffers: shared hit=7
  ->  Seq Scan on exam_measurements_default exam_measurements_4  (cost=0.00..2.25 rows=2 width=12) (actual time=0.004..0.007 rows=2 loops=1)
        Filter: (city_id = 10)
        Rows Removed by Filter: 98
        Buffers: shared hit=1
Planning:
  Buffers: shared hit=51
Planning Time: 8.277 ms
Execution Time: 0.260 ms
```

2.
Запрос по февралю:
pruning есть
в плане участвует 1 секция
Запрос по city_id = 10:
pruning нет
в плане участвуют все 4 секции
3.
pruning работает по ключу секционирования log_date, а не по любому произвольному столбцу
4.
нет. runing работает из-за того, что предикат запроса сопоставим с ключом секционирования; индекс может помочь уже внутри конкретной секции
5.
для строк вне заданных диапазонов, здесь — прежде всего для апреля 2025







