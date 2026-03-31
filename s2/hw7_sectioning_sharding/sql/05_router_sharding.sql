-- Подключение: primary (порт 5556)
SET search_path TO sharding, public;

-- i) Запрос на все данные (оба шарда)
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM users_router;

-- ii) Точечный запрос на RU-шард (partition pruning)
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM users_router
WHERE country = 'RU';

-- ii) Точечный запрос на US-шард (partition pruning)
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM users_router
WHERE country = 'US';