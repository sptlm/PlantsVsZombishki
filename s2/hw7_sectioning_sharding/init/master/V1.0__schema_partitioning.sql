CREATE SCHEMA IF NOT EXISTS hw7;
SET search_path TO hw7, public;

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
