CREATE ROLE logical_repl WITH REPLICATION LOGIN PASSWORD 'logical_pass';

CREATE PUBLICATION pvz_publication FOR ALL TABLES;

INSERT INTO marketplace.profession(name, salary)
VALUES ('logical_replication_test', 77777);

ALTER TABLE marketplace.profession
    ADD COLUMN description TEXT;

SELECT * from marketplace.profession LIMIT 1;

CREATE TABLE marketplace.no_pk_table (
                                         value_text TEXT,
                                         updated_at TIMESTAMP DEFAULT now()
);

-- Не нужна, ибо на все таблицы публикация стоит
ALTER PUBLICATION pvz_publication
    ADD TABLE marketplace.no_pk_table;

INSERT INTO marketplace.no_pk_table(value_text)
VALUES ('before_update');

UPDATE marketplace.no_pk_table
SET value_text = 'after_update'
WHERE value_text = 'before_update';

ALTER TABLE marketplace.no_pk_table REPLICA IDENTITY FULL;

-- Проверки logical replication status

SHOW wal_level;
SHOW max_wal_senders;
SHOW max_replication_slots;
SELECT version();

SELECT pubname, puballtables, pubinsert, pubupdate, pubdelete, pubtruncate
FROM pg_publication;

SELECT pubname,
       schemaname,
       tablename
FROM pg_publication_tables
WHERE pubname = 'pvz_publication';

SELECT slot_name,
       plugin,
       slot_type,
       database,
       active
FROM pg_replication_slots;

SELECT pid, usename, application_name, client_addr, state, sync_state, write_lsn, flush_lsn, replay_lsn
FROM pg_stat_replication;

