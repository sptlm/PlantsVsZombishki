SELECT *
FROM marketplace.profession
WHERE name = 'replication_test_profession';

INSERT INTO marketplace.profession(name, salary)
VALUES ('should_fail_on_replica', 1);

-- дошла ли она до последнего WAL:

SELECT pg_last_wal_receive_lsn(),
       pg_last_wal_replay_lsn(),
       now() - pg_last_xact_replay_timestamp() AS replay_delay;
