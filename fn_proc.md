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
### 2. Процедура получения самого популярного товара в магазине
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
### 3. Процедура: понизить цены в категории на процент

```sql
CREATE OR REPLACE PROCEDURE marketplace.discount_category_items(
    p_category_id INT,
    p_percent NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- проверка, что процент положительный
    IF p_percent <= 0 THEN
        RAISE EXCEPTION 'Процент скидки должен быть > 0. Получено: %', p_percent;
    END IF;

    -- обновляем цены: уменьшаем на p_percent процентов
    UPDATE marketplace.items
    SET price = price * (1 - p_percent / 100.0)
    WHERE category_id = p_category_id;

    -- можно вывести служебное сообщение
    RAISE NOTICE 'Цены в категории % понижены на % %%', p_category_id, p_percent;
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
### 1.3 Функция: средний рейтинг магазина

```sql
CREATE OR REPLACE FUNCTION marketplace.get_shop_avg_rating(
    p_shop_id INT
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (
        SELECT AVG(r.rating)::NUMERIC
        FROM marketplace.reviews r
        JOIN marketplace.purchases p ON r.purchase_id = p.purchase_id
        JOIN marketplace.items i       ON p.item_id = i.item_id
        WHERE i.shop_id = p_shop_id
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

### 2.3 Функция (с переменной): последний карьерный рост для профессии

```sql
CREATE OR REPLACE FUNCTION marketplace.get_last_career_step(
    p_start_profession_id INT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_id INT := p_start_profession_id;
    v_next_id    INT;
BEGIN
    LOOP
        SELECT cp.next_profession_id
        INTO v_next_id
        FROM marketplace.career_path cp
        WHERE cp.current_profession_id = v_current_id
        LIMIT 1;
        -- если продолжения нет — текущая профессия последняя
        IF v_next_id IS NULL THEN
            RETURN v_current_id;
        END IF;
        -- двигаемся дальше по цепочке
        v_current_id := v_next_id;
    END LOOP;
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
### 3. DO‑блок: всем товарам без категории присвоить категорию `прочее` (id = 16)

Важно: предполагается, что категория с `category_id = 16` уже существует и соответствует «прочее». Если её нет — нужно создать заранее.

```sql
DO $$
BEGIN
    -- проверяем, что категория 16 существует
    IF NOT EXISTS (
        SELECT 1 FROM marketplace.category_of_item WHERE category_id = 16
    ) THEN
        RAISE EXCEPTION 'Категория с id = 16 (\"прочее\") не найдена. Создайте её заранее.';
    END IF;

    -- обновляем все товары без категории
    UPDATE marketplace.items
    SET category_id = 16
    WHERE category_id IS NULL;

    RAISE NOTICE 'Всем товарам без категории присвоена категория id = 16 (\"прочее\")';
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
### 2. WHILE (та же функция с переменной: последний карьерный рост для профессии, но с использованием while loop)

```sql
CREATE OR REPLACE FUNCTION marketplace.get_last_career_step(
    p_start_profession_id INT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_id INT := p_start_profession_id;
    v_next_id    INT;
BEGIN
    -- первый поиск следующей профессии
    SELECT cp.next_profession_id
    INTO v_next_id
    FROM marketplace.career_path cp
    WHERE cp.current_profession_id = v_current_id
    LIMIT 1;

    WHILE v_next_id IS NOT NULL 
        SELECT cp.next_profession_id
        INTO v_next_id
        FROM marketplace.career_path cp
        WHERE cp.current_profession_id = v_current_id
        LIMIT 1;
    END LOOP;

    RETURN v_current_id;
END;
$$;
```
## EXCEPTION
### 1. EXCEPTION (та же Процедура: скидка по категории с проверкой через exception)

Проверяем существование категории через `SELECT ... INTO`, при отсутствии ловим `NO_DATA_FOUND` и выбрасываем  ошибку

```sql
CREATE OR REPLACE PROCEDURE marketplace.discount_category_items(
    p_category_id INT,
    p_percent NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_dummy INT;
    v_rows_updated INT;
BEGIN
    IF p_percent <= 0 THEN
        RAISE EXCEPTION 'Процент скидки должен быть > 0. Получено: %', p_percent;
    END IF;

    -- Проверяем, что категория существует
    BEGIN
        SELECT 1
        INTO STRICT v_dummy
        FROM marketplace.category_of_item
        WHERE category_id = p_category_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE EXCEPTION 'Категория с id = % не найдена', p_category_id;
    END;

    -- Само обновление цен
    UPDATE marketplace.items
    SET price = price * (1 - p_percent / 100.0)
    WHERE category_id = p_category_id;

    GET DIAGNOSTICS v_rows_updated = ROW_COUNT;

    IF v_rows_updated = 0 THEN
        RAISE NOTICE 'В категории % нет товаров для обновления цен', p_category_id;
    ELSE
        RAISE NOTICE 'Цены понижены на %%% для % товаров категории %',
                     p_percent, v_rows_updated, p_category_id;
    END IF;
END;
$$;
```

### 2. EXCEPTION (та же Функция с переменной: последний карьерный рост для профессии, но с EXCEPTION)

Используем `WHILE` и добавляем обработку ситуации, когда стартовая профессия не найдена: ловим `NO_DATA_FOUND` и возвращаем `NULL` с `NOTICE`

```sql
CREATE OR REPLACE FUNCTION marketplace.get_last_career_step(
    p_start_profession_id INT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_id INT;
    v_next_id    INT;
BEGIN
    -- Проверяем, что стартовая профессия существует
    BEGIN
        SELECT profession_id
        INTO STRICT v_current_id
        FROM marketplace.profession
        WHERE profession_id = p_start_profession_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE NOTICE 'Стартовая профессия с id = % не найдена', p_start_profession_id;
            RETURN NULL;
    END;

    -- Двигаемся по цепочке career_path, пока есть следующий шаг
    WHILE TRUE LOOP
        SELECT cp.next_profession_id
        INTO v_next_id
        FROM marketplace.career_path cp
        WHERE cp.current_profession_id = v_current_id
        LIMIT 1;

        IF v_next_id IS NULL THEN
            RETURN v_current_id; -- последняя профессия в цепочке
        END IF;

        v_current_id := v_next_id;
    END LOOP;
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
