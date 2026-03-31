CREATE SCHEMA IF NOT EXISTS sharding;
SET search_path TO sharding, public;

CREATE EXTENSION IF NOT EXISTS postgres_fdw;

DROP SERVER IF EXISTS shard1_server CASCADE;
DROP SERVER IF EXISTS shard2_server CASCADE;

CREATE SERVER shard1_server FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'hw7-shard1', port '5432', dbname 'pvz_hw7');

CREATE SERVER shard2_server FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'hw7-shard2', port '5432', dbname 'pvz_hw7');

CREATE USER MAPPING FOR admin SERVER shard1_server
OPTIONS (user 'admin', password 'admin_pass');

CREATE USER MAPPING FOR admin SERVER shard2_server
OPTIONS (user 'admin', password 'admin_pass');

CREATE TABLE IF NOT EXISTS users_router (
                                            id         BIGINT,
                                            name       TEXT,
                                            country    TEXT,
                                            created_at TIMESTAMPTZ
) PARTITION BY LIST (country);

CREATE FOREIGN TABLE IF NOT EXISTS users_ru
PARTITION OF users_router FOR VALUES IN ('RU')
SERVER shard1_server
OPTIONS (schema_name 'sharding', table_name 'users_ru');

CREATE FOREIGN TABLE IF NOT EXISTS users_us
PARTITION OF users_router FOR VALUES IN ('US')
SERVER shard2_server
OPTIONS (schema_name 'sharding', table_name 'users_us');