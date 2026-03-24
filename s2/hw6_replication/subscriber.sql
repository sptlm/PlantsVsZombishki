CREATE SUBSCRIPTION pvz_subscription
CONNECTION 'host=pg_publisher port=5432 dbname=pvz user=logical_repl password=logical_pass'
PUBLICATION pvz_publication;


CREATE SUBSCRIPTION pvz_subscription
    CONNECTION 'host=pg_publisher port=5432 dbname=pvz user=admin password=admin_pass'
    PUBLICATION pvz_publication;


SELECT *
FROM marketplace.profession
WHERE name = 'logical_replication_test';

SELECT * from marketplace.profession LIMIT 1;

CREATE TABLE marketplace.no_pk_table (
                                         value_text TEXT,
                                         updated_at TIMESTAMP DEFAULT now()
);

SELECT * FROM marketplace.no_pk_table;

-- Проверки logical replication

SELECT subname, subenabled, subslotname, subsynccommit, subpublications
FROM pg_subscription;

SELECT subname,
       pid,
       relid::regclass,
       received_lsn,
       latest_end_lsn,
       latest_end_time
FROM pg_stat_subscription;

SELECT schemaname, tablename
FROM pg_tables
WHERE schemaname = 'marketplace'
ORDER BY tablename;

SELECT subname, subowner::regrole
FROM pg_subscription;