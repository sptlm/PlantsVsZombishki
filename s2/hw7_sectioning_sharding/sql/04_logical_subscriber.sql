-- Подключение: hw7-subscriber (порт 5553)
SET search_path TO hw7, public;

-- Вариант A: подписка на pub_sales_off
DROP SUBSCRIPTION IF EXISTS sub_sales_off;
CREATE SUBSCRIPTION sub_sales_off
CONNECTION 'host=hw7-publisher port=5432 dbname=pvz_hw7 user=admin password=admin_pass'
PUBLICATION pub_sales_off
WITH (copy_data = true, create_slot = true, enabled = true);

-- Проверка, что строки пришли
SELECT * FROM sales_logical ORDER BY sale_id;

-- Для теста pub_sales_on можно удалить sub_sales_off и создать sub_sales_on
-- CREATE SUBSCRIPTION sub_sales_on ... PUBLICATION pub_sales_on;
