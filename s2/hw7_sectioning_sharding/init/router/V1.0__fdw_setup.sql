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
