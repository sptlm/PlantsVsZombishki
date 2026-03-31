-- Подключение: hw7-router (порт 5556)
SET search_path TO hw7, public;

-- Запрос на все данные (оба шарда)
EXPLAIN (VERBOSE, COSTS)
SELECT * FROM customers_all;

-- Запрос в диапазон shard1
EXPLAIN (VERBOSE, COSTS)
SELECT *
FROM customers_all
WHERE customer_id < 1000000;

-- Запрос в диапазон shard2
EXPLAIN (VERBOSE, COSTS)
SELECT *
FROM customers_all
WHERE customer_id >= 1000000;
