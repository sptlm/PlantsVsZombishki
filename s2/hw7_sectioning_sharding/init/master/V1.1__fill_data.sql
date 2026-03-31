SET search_path TO hw7, public;

INSERT INTO sales_range (sale_date, customer_id, amount)
SELECT d::date,
       (1000 + (random() * 1500)::int),
       round((100 + random() * 10000)::numeric, 2)
FROM generate_series('2024-01-01'::date, '2026-12-31'::date, '1 day'::interval) AS g(d)
ON CONFLICT DO NOTHING;
