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
RETURNING shop_id;  
  
COMMIT;
```
Результат: Новый работник и магазин с владельцем - этим работником успешно создались
<img width="757" height="132" alt="image" src="https://github.com/user-attachments/assets/4d7c01f1-aea8-4d28-9534-8f44d16ac771" />
<img width="615" height="129" alt="image" src="https://github.com/user-attachments/assets/4a4b6d6c-b22b-4efe-9f8d-ed8ea60826e1" />

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
RETURNING shop_id;  
  
ROLLBACK;
```
Результат: запросы транзакции откатились, ничего в таблице не поменялось
<img width="757" height="111" alt="image" src="https://github.com/user-attachments/assets/0799d77f-682a-453c-9018-13a15ede8377" />
<img width="598" height="110" alt="image" src="https://github.com/user-attachments/assets/f947a027-54c0-41fa-ac74-00a1864b7ff1" />

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
<img width="757" height="111" alt="image" src="https://github.com/user-attachments/assets/6c087f7d-7933-4826-87a2-42793f389491" />
<img width="598" height="110" alt="image" src="https://github.com/user-attachments/assets/717565e9-d86f-4dad-9bf8-bb08062045a6" />

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
<img width="811" height="113" alt="image" src="https://github.com/user-attachments/assets/7fd0a891-aebc-41e5-8821-d67298d57838" />
<img width="793" height="133" alt="yes car path" src="https://github.com/user-attachments/assets/224fc2ab-e2c1-45c7-b483-4da5fe58184a" />

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
<img width="809" height="97" alt="image" src="https://github.com/user-attachments/assets/47f65862-9313-44ab-bb01-9e7d32b89bf5" />
<img width="797" height="109" alt="no car path" src="https://github.com/user-attachments/assets/98b62217-30c9-4621-8b07-58add20dc552" />

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
<img width="809" height="97" alt="image" src="https://github.com/user-attachments/assets/1f7e25d6-5e00-4fae-ae73-fbca231811f6" />
<img width="797" height="109" alt="no car path" src="https://github.com/user-attachments/assets/fdc8e654-f17e-44c4-9223-284bac5bf0a4" />
