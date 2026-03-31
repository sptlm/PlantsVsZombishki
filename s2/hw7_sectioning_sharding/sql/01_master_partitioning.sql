-- Подключение: hw7-master (порт 5551)
SET search_path TO hw7, public;

-- RANGE
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM sales_range
WHERE sale_date BETWEEN DATE '2025-05-01' AND DATE '2025-05-31'
  AND customer_id = 1700;

-- LIST

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM orders_list
WHERE region = 'RU'
  AND created_at >= now() - interval '14 days';

-- HASH

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM events_hash
WHERE account_id = 4242
  AND created_at >= now() - interval '10 days';
