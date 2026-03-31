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
