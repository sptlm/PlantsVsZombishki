-- Подключение: hw7-publisher (порт 5552)
SET search_path TO hw7, public;

INSERT INTO sales_logical (sale_date, customer_id, amount)
VALUES
    ('2025-04-01', 101, 1500.00),
    ('2026-07-10', 202, 2500.00);

SELECT pubname, pubviaroot
FROM pg_publication
WHERE pubname IN ('pub_sales_off', 'pub_sales_on');
