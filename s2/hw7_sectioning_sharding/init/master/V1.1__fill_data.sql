SET search_path TO hw7, public;

INSERT INTO sales_range (sale_date, customer_id, amount)
SELECT d::date,
       (1000 + (random() * 1500)::int),
       round((100 + random() * 10000)::numeric, 2)
FROM generate_series('2024-01-01'::date, '2026-12-31'::date, '1 day'::interval) AS g(d)
ON CONFLICT DO NOTHING;


INSERT INTO orders_list(region, created_at, total_amount)
SELECT (ARRAY['RU', 'KZ', 'BY', 'AM', 'UZ'])[1 + (random() * 4)::int],
       now() - ((random() * 365)::int || ' days')::interval,
       round((100 + random() * 5000)::numeric, 2)
FROM generate_series(1, 20000);


INSERT INTO events_hash(account_id, event_type, payload)
SELECT (1 + (random() * 5000)::int),
       (ARRAY['view', 'click', 'checkout'])[1 + (random() * 2)::int],
       jsonb_build_object('source', 'hw7', 'i', g)
FROM generate_series(1, 50000) g;