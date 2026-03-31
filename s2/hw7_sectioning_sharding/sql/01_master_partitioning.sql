-- Подключение: hw7-master (порт 5551)
SET search_path TO hw7, public;

-- RANGE
EXPLAIN (ANALYZE, VERBOSE, BUFFERS)
SELECT *
FROM sales_range
WHERE sale_date BETWEEN DATE '2025-05-01' AND DATE '2025-05-31'
  AND customer_id = 1700;

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

-- HASH
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
