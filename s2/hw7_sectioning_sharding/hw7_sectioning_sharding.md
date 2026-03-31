# HW7 — Секционирование и шардирование

Сделано в формате как в `hw6`:
- отдельный `docker-compose.yml` для всех нужных БД;
- отдельные папки `init/<db>` с миграциями;
- отдельные SQL-скрипты в `sql/` для каждой БД/сценария.

## Структура

```text
hw7_sectioning_sharding/
  docker-compose.yml
  hw7_sectioning_sharding.md
  init/
    master/
      V1.0__schema_partitioning.sql
      V1.1__fill_data.sql
    publisher/
      V1.0__partitioned_table.sql
      V1.1__publications.sql
    subscriber/
      V1.0__partitioned_table.sql
    shard1/
      V1.0__customers_local.sql
    shard2/
      V1.0__customers_local.sql
    router/
      V1.0__fdw_setup.sql
  sql/
    01_master_partitioning.sql
    02_physical_replication.sql
    03_logical_publisher.sql
    04_logical_subscriber.sql
    05_router_sharding.sql
```

---

## Какие БД поднимаются

`docker-compose.yml` поднимает:
- `hw7-master` — секционирование + база для проверки physical replication;
- `hw7-publisher` — logical replication publisher;
- `hw7-subscriber` — logical replication subscriber;
- `hw7-shard1` и `hw7-shard2` — 2 шарда;
- `hw7-router` — router с `postgres_fdw`.

Порты:
- `5551` — master
- `5552` — publisher
- `5553` — subscriber
- `5554` — shard1
- `5555` — shard2
- `5556` — router

---

## Запуск

```bash
cd s2/hw7_sectioning_sharding
docker compose up -d
```

Проверка:

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
```

---

## Выполнение ДЗ по пунктам

### 1) Секционирование RANGE / LIST / HASH

Подключение к master:

```bash
psql -h localhost -p 5551 -U admin -d pvz_hw7 -f sql/01_master_partitioning.sql
```

Что смотреть в `EXPLAIN`:
- **partition pruning**;
- **сколько партиций** участвует;
- **используется ли индекс**.

### 2) Секционирование и physical replication

Скрипт проверки на master:

```bash
psql -h localhost -p 5551 -U admin -d pvz_hw7 -f sql/02_physical_replication.sql
```

Тот же запрос из `sql/02_physical_replication.sql` выполняется на standby-реплике (когда она настроена) — список секций должен совпасть.

### 3) Логическая репликация + `publish_via_partition_root`

На publisher:

```bash
psql -h localhost -p 5552 -U admin -d pvz_hw7 -f sql/03_logical_publisher.sql
```

На subscriber:

```bash
psql -h localhost -p 5553 -U admin -d pvz_hw7 -f sql/04_logical_subscriber.sql
```

Смысл параметра:
- `publish_via_partition_root = false` — публикация от дочерних секций;
- `publish_via_partition_root = true` — публикация от корневой таблицы.

### 4) Шардирование через `postgres_fdw`

Запросы на router:

```bash
psql -h localhost -p 5556 -U admin -d pvz_hw7 -f sql/05_router_sharding.sql
```

Смотрим планы:
- запрос на все данные (оба шарда);
- запросы по диапазону ID (целевой шард).

---

## Примечание

В этой версии physical standby (второй инстанс master-реплики) не поднимается автоматически в compose, чтобы не усложнять bootstrap через `pg_basebackup`.
Но всё разложено по файлам так, чтобы легко добавить standby-контейнер по аналогии с `hw6`.
