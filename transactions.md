# Базовые операции с транзакциями
## Набор 1: new worker → new shop (owner = new worker)

### 1.1. `BEGIN ... COMMIT`: 

```sql
BEGIN;  
  
-- 1) Создаём нового worker  
WITH new_worker as (  
    INSERT INTO marketplace.workers (login, password_hash, salt)  
        VALUES ('new_worker', 'hash_w', 'salt_w')  
        RETURNING worker_id)  
  
-- 2) Создаём новый shop, owner_id = только что созданный worker  
INSERT INTO marketplace.shops (owner_id, name)  
SELECT new_worker.worker_id, 'Новый магазин'  
FROM new_worker  
RETURNING shop_id  
  
COMMIT;
```
Результат: Новый работник и магазин с владельцем - этим работником успешно создались
### 1.2. Та же логика, но с `ROLLBACK`

```sql
BEGIN;  
  
-- 1) Создаём нового worker  
WITH new_worker as (  
    INSERT INTO marketplace.workers (login, password_hash, salt)  
        VALUES ('new_worker', 'hash_w', 'salt_w')  
        RETURNING worker_id)  
  
-- 2) Создаём новый shop, owner_id = только что созданный worker  
INSERT INTO marketplace.shops (owner_id, name)  
SELECT new_worker.worker_id, 'Новый магазин'  
FROM new_worker  
RETURNING shop_id  
  
ROLLBACK;
```
Результат: запросы транзакции откатились, ничего в таблице не поменялось
### 1.3. Транзакция с ошибкой (деление на 0)

```sql
BEGIN;  
  
-- 1) Создаём нового worker с ошибкой: деление на 0 в логине  
WITH new_worker as (  
    INSERT INTO marketplace.workers (login, password_hash, salt)  
        VALUES (1/0, 'hash_w', 'salt_w')  
        RETURNING worker_id),  
  
-- 2) Создаём новый shop, owner_id = только что созданный worker  
    new_shop as (INSERT INTO marketplace.shops (owner_id, name)  
    SELECT new_worker.worker_id, 'Новый магазин'  
    FROM new_worker  
    RETURNING shop_id)  
  
-- Эта команда уже не выполнится, транзакция в состоянии aborted  
UPDATE marketplace.shops  
SET name = 'Переименованный магазин'  
FROM  new_shop  
WHERE shops.shop_id = new_shop.shop_id;  
  
COMMIT;
```
Результат: запросы транзакции откатились, ничего в таблице не поменялось
***
## Набор 2: new profession → добавление в career_path для уже существующей

### 2.1. `BEGIN ... COMMIT`: создаём profession и добавляем в career_path

```sql
BEGIN;  
  
-- 1) Создаём новую профессию  
WITH new_profession as (  
    INSERT INTO marketplace.profession (name, salary)  
        VALUES ('Мега разработчик 3000', 420000)  
        RETURNING profession_id)  
  
-- 2) Добавляем запись в career_path:  
INSERT INTO marketplace.career_path (current_profession_id, next_profession_id)  
SELECT 4, new_profession.profession_id  
FROM new_profession;  
  
COMMIT;
```
Результат: Новая профессия и карьерный рост до нее от старой профессии успешно создались
### 2.2. Та же логика, но с `ROLLBACK`

```sql
BEGIN;  
  
-- 1) Создаём новую профессию  
WITH new_profession as (  
    INSERT INTO marketplace.profession (name, salary)  
        VALUES ('Мега разработчик 3000', 420000)  
        RETURNING profession_id)  
  
-- 2) Добавляем запись в career_path:  
INSERT INTO marketplace.career_path (current_profession_id, next_profession_id)  
SELECT 4, new_profession.profession_id  
FROM new_profession;  
  
ROLLBACK;
```
Результат: запросы транзакции откатились, ничего в таблице не поменялось
### 2.3. Транзакция с ошибкой

```sql
BEGIN;  
  
-- 1) Создаём новую профессию  
WITH new_profession as (  
    INSERT INTO marketplace.profession (name, salary)  
        VALUES ('Мега разработчик 3000', 420000)  
        RETURNING profession_id)  
  
-- 2) Добавляем запись в career_path:  
INSERT INTO marketplace.career_path (current_profession_id, next_profession_id)  
SELECT 4, new_profession.profession_id  
FROM new_profession;  
  
-- 3) Намеренная ошибка  
SELECT 1 / 0;  
  
-- Эта команда уже не выполнится, транзакция в состоянии aborted  
UPDATE marketplace.profession  
SET salary = salary - 10000  
WHERE profession_id = 4;  
  
COMMIT;
```
Результат: запросы транзакции откатились, ничего в таблице не поменялось