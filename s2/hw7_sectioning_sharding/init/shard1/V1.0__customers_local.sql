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
