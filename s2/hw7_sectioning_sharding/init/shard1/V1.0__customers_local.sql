CREATE SCHEMA IF NOT EXISTS sharding;
SET search_path TO sharding, public;

CREATE TABLE IF NOT EXISTS users_ru (
                                        id         BIGINT PRIMARY KEY,
                                        name       TEXT NOT NULL,
                                        country    TEXT NOT NULL CHECK (country = 'RU'),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
    );

INSERT INTO users_ru(id, name, country)
SELECT g, 'ru_user_' || g, 'RU'
FROM generate_series(1, 5000) g
    ON CONFLICT (id) DO NOTHING;