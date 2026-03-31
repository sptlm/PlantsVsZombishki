CREATE SCHEMA IF NOT EXISTS hw7;
SET search_path TO hw7, public;

-- RANGE

CREATE TABLE IF NOT EXISTS sales_range (
    sale_id      BIGINT GENERATED ALWAYS AS IDENTITY,
    sale_date    DATE NOT NULL,
    customer_id  BIGINT NOT NULL,
    amount       NUMERIC(12,2) NOT NULL,
    CONSTRAINT sales_range_pk PRIMARY KEY (sale_id, sale_date)
) PARTITION BY RANGE (sale_date);

CREATE TABLE IF NOT EXISTS sales_range_2024 PARTITION OF sales_range
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
CREATE TABLE IF NOT EXISTS sales_range_2025 PARTITION OF sales_range
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
CREATE TABLE IF NOT EXISTS sales_range_2026 PARTITION OF sales_range
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

CREATE INDEX IF NOT EXISTS idx_sales_range_2025_customer ON sales_range_2025(customer_id);

--LIST

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