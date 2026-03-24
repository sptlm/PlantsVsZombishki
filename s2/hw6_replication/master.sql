SELECT * FROM pg_create_physical_replication_slot('replica1_slot');
SELECT * FROM pg_create_physical_replication_slot('replica2_slot');

SELECT application_name,
       client_addr,
       state,
       sync_state,
       write_lag,
       flush_lag,
       replay_lag
FROM pg_stat_replication;

INSERT INTO marketplace.profession(name, salary)
VALUES ('replication_test_profession', 123456);

CREATE TABLE IF NOT EXISTS marketplace.replication_lag_test (
                                                                id BIGSERIAL PRIMARY KEY,
                                                                payload TEXT,
                                                                created_at TIMESTAMP DEFAULT now()
);

INSERT INTO marketplace.replication_lag_test(payload)
SELECT md5(random()::text)
FROM generate_series(1, 1000000);

SELECT application_name,
       state,
       sent_lsn,
       write_lsn,
       flush_lsn,
       replay_lsn,
       write_lag,
       flush_lag,
       replay_lag
FROM pg_stat_replication;

-- Размер отставания в байтах
SELECT application_name,
       pg_wal_lsn_diff(sent_lsn, replay_lsn) AS byte_lag
FROM pg_stat_replication;