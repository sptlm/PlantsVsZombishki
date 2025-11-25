## Процедуры

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
## 2. Процедура получения самого популярного товара в магазине
```sql
CREATE or REPLACE Procedure marketplace.top_item(shop_id INT)
language plpgsql
AS $$
DECLARE
	popular_item VARCHAR;
BEGIN
	SELECT i.name into popular_item
	FROM marketplace.purchases p
	JOIN marketplace.items i on p.item_id = i.item_id
	WHERE i.shop_id = shop_id
	GROUP BY i.item_id, i.name
	ORDER BY COUNT(*) DESC
	LIMIT 1;
	RAISE NOTICE 'Популярный товар : %', popular_item;
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

## Функции

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
### 1.2 Функция для получения количества товаров в категории

```sql
CREATE OR REPLACE function marketplace.count_category_items(category_id INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (
        SELECT COUNT(*) 
        FROM marketplace.items i
        WHERE i.category_id = category_id
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

### 2.2 Функция (с переменной) для получения карьерного роста сотрудника (следующая должность)
```sql
CREATE or REPLACE function marketplace.get_next_profession(worker_id INT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
	current_prof VARCHAR;
	current_salary INT;
	next_prof VARCHAR;
	next_salary INT;
BEGIN
	SELECT p.name, p.salary INTO current_prof, current_salary
	FROM marketplace.worker_assignments wa
	JOIN marketplace.profession p ON wa.work_id = p.profession_id
	WHERE wa.worker_id = worker_id
	LIMIT 1;

	SELECT p.name, p.salary INTO next_prof, next_salary
    FROM marketplace.career_path cp
    JOIN marketplace.profession p ON cp.next_profession_id = p.profession_id
    WHERE cp.current_profession_id = (
        SELECT work_id FROM marketplace.worker_assignments 
        WHERE worker_id = worker_id LIMIT 1
    )
    LIMIT 1;

	IF next_prof IS NULL THEN
        RETURN current_prof || ' (карьерный рост недоступен)';
    ELSE
        RETURN current_prof || ' → ' || next_prof || ' (+' || (next_salary - current_salary) || ' руб.)';
	END IF;
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

### 2. Повышение цен на 10%
```sql
DO $$
DECLARE
    price_multiplier DECIMAL := 1.1; -- повышение на 10%
BEGIN
    UPDATE marketplace.items 
    SET price = price * price_multiplier
    WHERE price > 0;
      
    RAISE NOTICE 'Цены повышены в %. раз', price_multiplier;
END;
$$;
```
---
## IF
### Функция для определения ценовой категории товара
```sql
CREATE or REPLACE function marketplace.get_item_price_category(item_id INT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
	price_of INT;
BEGIN
	SELECT price into price_of FROM marketplace.items i WHERE i.item_id = item_id;
	IF price_of < 10000 THEN
		return 'NEDOROGO';
	ELSE
		return 'dorogo';
	end if;
END;
$$;
```
---
## CASE
### Получение более полного вида ценовой категории товара
```sql
CREATE or REPLACE function marketplace.get_item_price_fullcategory(item_id INT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
	price_of INT;
	category TEXT;
BEGIN
	SELECT price into price_of FROM marketplace.items i WHERE i.item_id = item_id;

	category := CASE
		WHEN price_of < 1000 then 'Бюджетно'
		WHEN price_of < 10000 then 'Средне'
		ELSE 'Дороговато'
	END;
	return category;
END;
$$;
```
---
## WHILE
### 1. Do-блок для добавления 100 покупателей в бд
```sql
DO $$
DECLARE
    i INT := 1;
BEGIN
    WHILE i <= 100 LOOP
        INSERT INTO marketplace.buyers (login, password_hash, salt)
        VALUES (
            'test_user_' || i,
            'hash_' || i,
            'salt_' || i
        );
        i := i + 1;
    END LOOP;
    
    RAISE NOTICE 'Создано 100 тестовых пользователей';
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
