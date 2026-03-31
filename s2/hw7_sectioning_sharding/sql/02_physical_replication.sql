-- Подключение: hw7-master (порт 5551)
-- Проверить список секций на реплике/мастере
SELECT inhparent::regclass AS parent_table,
       inhrelid::regclass AS partition_table
FROM pg_inherits
WHERE inhparent = 'sales_range'::regclass;

-- После настройки standby на отдельном узле:
-- подключиться к реплике и выполнить тот же запрос.
-- DDL секций должен совпадать с мастером.

-- Опционально на мастере: проверить статус реплики
SELECT application_name, state, sync_state
FROM pg_stat_replication;
