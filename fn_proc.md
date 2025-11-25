## PROCEDURE

### 1. Процедура создания покупки и заказа
```sql
CREATE OR REPLACE PROCEDURE marketplace.create_purchase_order(
	p_item_id INT,
	p_buyer_id INT,
	p_pvz_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
	new_purchase_id INT;
BEGIN

 	INSERT INTO marketplace.purchases (item_id, buyer_id, purchase_date, status) VALUES 
	(p_item_id, p_buyer_id, NOW(), 'pending') RETURNING purchase_id INTO new_purchase_id;

	INSERT INTO marketplace.orders (purchase_id, pvz_id, status, order_date) VALUES
	(new_purchase_id, p_pvz_id, 'created', NOW());
END;
$$;
```

---

### Запрос просмотра всех процедур
```sql
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_type = 'PROCEDURE' and routine_schema = 'marketplace';
```

## FUNCTION

### 1.1 Функция для получения количества заказов для ПВЗ
```sql
CREATE OR REPLACE FUNCTION marketplace.count_pvz_orders (p_pvz_id INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN (
		SELECT COUNT(*) 
		FROM marketplace.orders o
		WHERE o.pvz_id = p_pvz_id
	);
END;
$$;
```

---

### 2.1 Функция (с переменной) для получения выручки магазина 
```sql
CREATE OR REPLACE FUNCTION marketplace.get_store_earnings (p_shop_id INT)
RETURNS DECIMAL(10,2)
LANGUAGE plpgsql
AS $$
DECLARE
	store_earnings DECIMAL(10,2);
BEGIN

	SELECT SUM(i.price) INTO store_earnings
	FROM marketplace.purchases p
	JOIN marketplace.items i ON p.item_id = i.item_id
	JOIN marketplace.shops sh ON i.shop_id = sh.shop_id
	WHERE p.status = 'completed' AND sh.shop_id = p_shop_id;

	IF store_earnings IS NULL THEN
		RETURN 0.0;
	END IF;
	
	RETURN store_earnings;
END;
$$;
```

---

### Запрос для просмотра всех функций
```sql
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_type = 'FUNCTION' and routine_schema = 'marketplace';
```

## DO
### 1. Повышение зарплаты на процент (10%)
```sql
DO $$
DECLARE
	increase_salary INT := 10;
BEGIN
	UPDATE marketplace.profession 
	SET salary = salary * (100 + increase_salary) /100;
END;
$$;
```

## RAISE
```sql
CREATE OR REPLACE FUNCTION marketplace.get_store_earnings (p_shop_id INT)
RETURNS DECIMAL(10,2)
LANGUAGE plpgsql
AS $$
DECLARE
	store_earnings DECIMAL(10,2);
BEGIN

	SELECT SUM(i.price) INTO store_earnings
	FROM marketplace.purchases p
	JOIN marketplace.items i ON p.item_id = i.item_id
	JOIN marketplace.shops sh ON i.shop_id = sh.shop_id
	WHERE p.status = 'completed' AND sh.shop_id = p_shop_id;

	IF store_earnings IS NULL THEN
		RAISE NOTICE 'Для магазина % нет завершенных заказов', p_shop_id;
		RETURN 0.0; 
	END IF;

	RAISE NOTICE 'Магазин % заработал % рублей', p_shop_id, store_earnings;
	RETURN store_earnings;
END;
$$;
```

---

```sql
DO $$
DECLARE
	increase_salary INT := 10;
BEGIN
	UPDATE marketplace.profession 
	SET salary = salary * (100 + increase_salary) /100;

	RAISE WARNING 'Зарплаты у профессий повысились на % процентов', increase_salary;
END;
$$;
```
