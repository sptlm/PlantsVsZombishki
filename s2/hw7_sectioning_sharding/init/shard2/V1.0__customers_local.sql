CREATE SCHEMA IF NOT EXISTS sharding;
SET search_path TO sharding, public;

CREATE TABLE IF NOT EXISTS users_us (
                                        id         BIGINT PRIMARY KEY,
                                        name       TEXT NOT NULL,
                                        country    TEXT NOT NULL CHECK (country = 'US'),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
    );

INSERT INTO users_us(id, name, country)
SELECT g + 100000, 'us_user_' || g, 'US'
FROM generate_series(1, 5000) g
    ON CONFLICT (id) DO NOTHING;