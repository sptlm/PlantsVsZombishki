# HW7 — Секционирование и шардирование

Ниже решение **со всеми ответами на вопросы из задания** и с дублированием команд, которые нужны для получения этих ответов.

---

## 0) Поднять окружение

```bash
cd s2/hw7_sectioning_sharding
docker compose up -d
```

Проверка:

```bash
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
```

Сервисы:
- `hw7-master` (порт `5551`) — секционирование + проверки для physical replication;
- `hw7-publisher` (порт `5552`) — logical replication publisher;
- `hw7-subscriber` (порт `5553`) — logical replication subscriber;
- `hw7-shard1` (порт `5554`) и `hw7-shard2` (порт `5555`) — шарды;
- `hw7-router` (порт `5556`) — router c `postgres_fdw`.

---

## 1) Секционирование: RANGE / LIST / HASH

Задание: для каждого типа дать ответы:
1. есть ли `partition pruning`
2. сколько партиций участвует в плане
3. используется ли индекс

### 1.1 RANGE

Команда (дублирует `sql/01_master_partitioning.sql`):

```sql
-- psql -h localhost -p 5551 -U admin -d pvz_hw7
SET search_path TO hw7, public;

EXPLAIN (ANALYZE, VERBOSE, BUFFERS)
SELECT *
FROM sales_range
WHERE sale_date BETWEEN DATE '2025-05-01' AND DATE '2025-05-31'
  AND customer_id = 1700;
```

**Ответы:**
- `partition pruning`: **да** (фильтр по `sale_date` оставляет только партицию 2025 года);
- партиций в плане: **1**;
- индекс: **да**, используется `idx_sales_range_2025_customer` (или может быть выбран planner-ом при достаточной селективности).

### 1.2 LIST

Команды (дублируют `sql/01_master_partitioning.sql`):

```sql
-- psql -h localhost -p 5551 -U admin -d pvz_hw7
SET search_path TO hw7, public;

DROP TABLE IF EXISTS orders_list CASCADE;
CREATE TABLE orders_list (
    order_id      BIGINT GENERATED ALWAYS AS IDENTITY,
    region        TEXT NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    total_amount  NUMERIC(12,2) NOT NULL,
    CONSTRAINT orders_list_pk PRIMARY KEY (order_id, region)
) PARTITION BY LIST (region);

CREATE TABLE orders_list_ru PARTITION OF orders_list FOR VALUES IN ('RU');
CREATE TABLE orders_list_kz PARTITION OF orders_list FOR VALUES IN ('KZ');
CREATE TABLE orders_list_by PARTITION OF orders_list FOR VALUES IN ('BY');
CREATE TABLE orders_list_other PARTITION OF orders_list DEFAULT;

CREATE INDEX idx_orders_list_ru_created_at ON orders_list_ru(created_at);

INSERT INTO orders_list(region, created_at, total_amount)
SELECT (ARRAY['RU', 'KZ', 'BY', 'AM', 'UZ'])[1 + (random() * 4)::int],
       now() - ((random() * 365)::int || ' days')::interval,
       round((100 + random() * 5000)::numeric, 2)
FROM generate_series(1, 20000);

EXPLAIN (ANALYZE, VERBOSE, BUFFERS)
SELECT *
FROM orders_list
WHERE region = 'RU'
  AND created_at >= now() - interval '14 days';
```

**Ответы:**
- `partition pruning`: **да** (по `region='RU'` читается только `orders_list_ru`);
- партиций в плане: **1**;
- индекс: **да**, `idx_orders_list_ru_created_at` релевантен фильтру по времени.

### 1.3 HASH

Команды (дублируют `sql/01_master_partitioning.sql`):

```sql
-- psql -h localhost -p 5551 -U admin -d pvz_hw7
SET search_path TO hw7, public;

DROP TABLE IF EXISTS events_hash CASCADE;
CREATE TABLE events_hash (
    event_id      BIGINT GENERATED ALWAYS AS IDENTITY,
    account_id    BIGINT NOT NULL,
    event_type    TEXT NOT NULL,
    payload       JSONB NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT events_hash_pk PRIMARY KEY (event_id, account_id)
) PARTITION BY HASH (account_id);

CREATE TABLE events_hash_p0 PARTITION OF events_hash FOR VALUES WITH (MODULUS 4, REMAINDER 0);
CREATE TABLE events_hash_p1 PARTITION OF events_hash FOR VALUES WITH (MODULUS 4, REMAINDER 1);
CREATE TABLE events_hash_p2 PARTITION OF events_hash FOR VALUES WITH (MODULUS 4, REMAINDER 2);
CREATE TABLE events_hash_p3 PARTITION OF events_hash FOR VALUES WITH (MODULUS 4, REMAINDER 3);

CREATE INDEX idx_events_hash_p2_created_at ON events_hash_p2(created_at);

INSERT INTO events_hash(account_id, event_type, payload)
SELECT (1 + (random() * 5000)::int),
       (ARRAY['view', 'click', 'checkout'])[1 + (random() * 2)::int],
       jsonb_build_object('source', 'hw7', 'i', g)
FROM generate_series(1, 50000) g;

EXPLAIN (ANALYZE, VERBOSE, BUFFERS)
SELECT *
FROM events_hash
WHERE account_id = 4242
  AND created_at >= now() - interval '10 days';
```

**Ответы:**
- `partition pruning`: **да**, при `account_id = const` выбирается одна hash-партиция;
- партиций в плане: **1**;
- индекс: **зависит от remainder**. В примере индекс создан только на `events_hash_p2`, поэтому будет использован только если `4242` попадает в эту партицию.

---

## 2) Секционирование и physical replication

### 2.a Проверить, что секционирование есть на репликах

Команды (дублируют `sql/02_physical_replication.sql`):

```sql
-- на master (и затем тот же запрос на standby-реплике)
SELECT inhparent::regclass AS parent_table,
       inhrelid::regclass AS partition_table
FROM pg_inherits
WHERE inhparent = 'hw7.sales_range'::regclass
ORDER BY 2;
```

Проверка состояния стриминга на master:

```sql
SELECT application_name, state, sync_state
FROM pg_stat_replication;
```

**Ответ:** при physical replication дерево секций на standby совпадает с primary, потому что реплика получает WAL на уровне страниц/каталогов.

### 2.b Почему репликация «не знает» про секции?

**Ответ:** это формулировка про **logical replication**, не про physical.
- В **physical replication** секции «известны» (каталоги копируются).
- В **logical replication** передаются изменения строк и подписчик применяет их к своей схеме таблиц/секций.

---

## 3) Логическая репликация и `publish_via_partition_root = on / off`

### Команды на publisher (дублируют init + `sql/03_logical_publisher.sql`)

```sql
-- psql -h localhost -p 5552 -U admin -d pvz_hw7
CREATE SCHEMA IF NOT EXISTS hw7;
SET search_path TO hw7, public;

CREATE TABLE IF NOT EXISTS sales_logical (
    sale_id      BIGINT GENERATED ALWAYS AS IDENTITY,
    sale_date    DATE NOT NULL,
    customer_id  BIGINT NOT NULL,
    amount       NUMERIC(12,2) NOT NULL,
    CONSTRAINT sales_logical_pk PRIMARY KEY (sale_id, sale_date)
) PARTITION BY RANGE (sale_date);

CREATE TABLE IF NOT EXISTS sales_logical_2025 PARTITION OF sales_logical
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
CREATE TABLE IF NOT EXISTS sales_logical_2026 PARTITION OF sales_logical
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

DROP PUBLICATION IF EXISTS pub_sales_off;
DROP PUBLICATION IF EXISTS pub_sales_on;

CREATE PUBLICATION pub_sales_off FOR TABLE hw7.sales_logical
    WITH (publish_via_partition_root = false);

CREATE PUBLICATION pub_sales_on FOR TABLE hw7.sales_logical
    WITH (publish_via_partition_root = true);

INSERT INTO sales_logical (sale_date, customer_id, amount)
VALUES
    ('2025-04-01', 101, 1500.00),
    ('2026-07-10', 202, 2500.00);

SELECT pubname, pubviaroot
FROM pg_publication
WHERE pubname IN ('pub_sales_off', 'pub_sales_on');
```

### Команды на subscriber (дублируют `sql/04_logical_subscriber.sql`)

```sql
-- psql -h localhost -p 5553 -U admin -d pvz_hw7
CREATE SCHEMA IF NOT EXISTS hw7;
SET search_path TO hw7, public;

CREATE TABLE IF NOT EXISTS sales_logical (
    sale_id      BIGINT GENERATED BY DEFAULT AS IDENTITY,
    sale_date    DATE NOT NULL,
    customer_id  BIGINT NOT NULL,
    amount       NUMERIC(12,2) NOT NULL,
    CONSTRAINT sales_logical_pk PRIMARY KEY (sale_id, sale_date)
) PARTITION BY RANGE (sale_date);

CREATE TABLE IF NOT EXISTS sales_logical_2025 PARTITION OF sales_logical
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
CREATE TABLE IF NOT EXISTS sales_logical_2026 PARTITION OF sales_logical
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

DROP SUBSCRIPTION IF EXISTS sub_sales_off;
CREATE SUBSCRIPTION sub_sales_off
CONNECTION 'host=hw7-publisher port=5432 dbname=pvz_hw7 user=admin password=admin_pass'
PUBLICATION pub_sales_off
WITH (copy_data = true, create_slot = true, enabled = true);

SELECT * FROM sales_logical ORDER BY sale_id;
```

**Ответ по `publish_via_partition_root`:**
- `false` — изменения публикуются от дочерних секций;
- `true` — изменения публикуются как от корневой таблицы (удобно, если на subscriber другая структура дочерних секций, но совместимый root).

---

## 4) Шардирование через `postgres_fdw`

### 4.a Самостоятельно реализовать: 2 шарда + router

Команды для `shard1` (дублируют `init/shard1/V1.0__customers_local.sql`):

```sql
-- psql -h localhost -p 5554 -U admin -d pvz_hw7
CREATE SCHEMA IF NOT EXISTS hw7;
SET search_path TO hw7, public;

CREATE TABLE IF NOT EXISTS customers_local (
    customer_id BIGINT PRIMARY KEY,
    full_name   TEXT NOT NULL,
    city        TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO customers_local(customer_id, full_name, city)
VALUES
    (100001, 'Ivan Petrov', 'Moscow'),
    (200002, 'Olga Smirnova', 'Kazan'),
    (300003, 'Pavel Sidorov', 'Ufa')
ON CONFLICT (customer_id) DO NOTHING;
```

Команды для `shard2` (дублируют `init/shard2/V1.0__customers_local.sql`):

```sql
-- psql -h localhost -p 5555 -U admin -d pvz_hw7
CREATE SCHEMA IF NOT EXISTS hw7;
SET search_path TO hw7, public;

CREATE TABLE IF NOT EXISTS customers_local (
    customer_id BIGINT PRIMARY KEY,
    full_name   TEXT NOT NULL,
    city        TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO customers_local(customer_id, full_name, city)
VALUES
    (1000001, 'Anna Volkova', 'Novosibirsk'),
    (1200002, 'Dmitry Kozlov', 'Yekaterinburg'),
    (1400003, 'Maria Frolova', 'Samara')
ON CONFLICT (customer_id) DO NOTHING;
```

Команды для `router` (дублируют `init/router/V1.0__fdw_setup.sql`):

```sql
-- psql -h localhost -p 5556 -U admin -d pvz_hw7
CREATE SCHEMA IF NOT EXISTS hw7;
SET search_path TO hw7, public;

CREATE EXTENSION IF NOT EXISTS postgres_fdw;

DROP SERVER IF EXISTS shard1_srv CASCADE;
DROP SERVER IF EXISTS shard2_srv CASCADE;

CREATE SERVER shard1_srv FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'hw7-shard1', port '5432', dbname 'pvz_hw7');

CREATE SERVER shard2_srv FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'hw7-shard2', port '5432', dbname 'pvz_hw7');

CREATE USER MAPPING FOR admin SERVER shard1_srv
OPTIONS (user 'admin', password 'admin_pass');

CREATE USER MAPPING FOR admin SERVER shard2_srv
OPTIONS (user 'admin', password 'admin_pass');

CREATE FOREIGN TABLE IF NOT EXISTS customers_shard_1 (
    customer_id BIGINT,
    full_name   TEXT,
    city        TEXT,
    created_at  TIMESTAMPTZ
) SERVER shard1_srv OPTIONS (schema_name 'hw7', table_name 'customers_local');

CREATE FOREIGN TABLE IF NOT EXISTS customers_shard_2 (
    customer_id BIGINT,
    full_name   TEXT,
    city        TEXT,
    created_at  TIMESTAMPTZ
) SERVER shard2_srv OPTIONS (schema_name 'hw7', table_name 'customers_local');

CREATE OR REPLACE VIEW customers_all AS
SELECT * FROM customers_shard_1
UNION ALL
SELECT * FROM customers_shard_2;
```

### 4.b Сделать запросы и посмотреть план

Команды (дублируют `sql/05_router_sharding.sql`):

```sql
-- psql -h localhost -p 5556 -U admin -d pvz_hw7
SET search_path TO hw7, public;

-- i) Простой запрос на все данные
EXPLAIN (VERBOSE, COSTS)
SELECT * FROM customers_all;

-- ii) Простой запрос на шард (диапазон shard1)
EXPLAIN (VERBOSE, COSTS)
SELECT *
FROM customers_all
WHERE customer_id < 1000000;

-- ii) Простой запрос на шард (диапазон shard2)
EXPLAIN (VERBOSE, COSTS)
SELECT *
FROM customers_all
WHERE customer_id >= 1000000;
```

**Ответы:**
- для `SELECT * FROM customers_all` в плане участвуют оба шарда (`Foreign Scan` + `Append/UNION ALL`);
- для фильтра по диапазону ID план должен обращаться к целевому шарду (или минимизировать удаленные сканы, в зависимости от pushdown planner-а).

---

## Примечание по physical standby

В этом варианте compose физическая standby-реплика для `hw7-master` не поднимается автоматически (чтобы не усложнять bootstrap через `pg_basebackup`).
Для пункта 2 подготовлены команды проверки, а standby можно добавить отдельным контейнером по аналогии с `hw6`.
