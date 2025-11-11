# ROWS
## 1. Cкользящее среднее зарплаты по профессиям
```sql
SELECT 
    profession_id,
    name,
    salary,
    AVG(salary) OVER (
        ORDER BY salary
        ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING
    ) AS avg_salary_5_rows
FROM marketplace.profession
ORDER BY salary;
```
<img width="656" height="172" alt="image" src="https://github.com/user-attachments/assets/d4e121b9-522b-45fd-b4cd-1dbdb573a5ee" />

## 2. Накопленная сумма цен товаров по магазинам
```sql
SELECT 
    shop_id,
    name,
    price,
    SUM(price) OVER (
        PARTITION BY shop_id
        ORDER BY price
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_price
FROM marketplace.items
ORDER BY shop_id, price;
```
<img width="634" height="299" alt="image" src="https://github.com/user-attachments/assets/2b42d965-5003-4dde-b313-9b68b05dc9fe" />

# RANGE
## 1. Профессии в диапазоне ±5000 от текущей зарплаты
```sql
SELECT 
    profession_id,
    name,
    salary,
    COUNT(*) OVER (
        ORDER BY salary
        RANGE BETWEEN 5000 PRECEDING AND 5000 FOLLOWING
    ) AS similar_salary_count
FROM marketplace.profession
ORDER BY salary;
```
<img width="648" height="169" alt="image" src="https://github.com/user-attachments/assets/79e7ead2-3bb8-4fe8-b575-2fe7988b47d8" />

## 2. Средние рейтинги в пределах ±1 балла
```sql
SELECT 
    review_id,
    rating,
    description,
    AVG(rating) OVER (
        ORDER BY rating
        RANGE BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS avg_rating_range
FROM marketplace.reviews
ORDER BY rating;
```
<img width="651" height="302" alt="image" src="https://github.com/user-attachments/assets/bf006675-5fa2-4815-99fb-c40ad5c3992e" />

# LAG
## Сравнение зарплаты с предыдущими по зарплате + сортировка для удобного вывода
```sql
SELECT 
    p.profession_id,
    p.name,
    p.salary,
    LAG(p.salary) OVER (ORDER BY p.salary) AS prev_salary,
    p.salary - LAG(p.salary) OVER (ORDER BY p.salary) AS salary_diff_prev
FROM marketplace.profession p
ORDER BY p.salary;
```
<img width="739" height="177" alt="image" src="https://github.com/user-attachments/assets/70490682-178e-4f31-94af-4ba1128095d5" />

# LEAD
## Следующая покупка пользователя
```sql
SELECT 
    purchase_id,
    buyer_id,
    item_id,
    purchase_date,
    LEAD(purchase_date) OVER (
        PARTITION BY buyer_id 
        ORDER BY purchase_date
    ) AS next_purchase_date,
    LEAD(item_id) OVER (
        PARTITION BY buyer_id 
        ORDER BY purchase_date
    ) AS next_purchased_item
FROM marketplace.purchases
ORDER BY buyer_id, purchase_date;
```
<img width="1014" height="301" alt="image" src="https://github.com/user-attachments/assets/dbd4f002-4c4f-437f-bdc9-ca6e6536ad4c" />

# FIRST_VALUE
## Самый дешевый товар в категории
```sql
SELECT 
    item_id,
    name,
    category_id,
    price,
    FIRST_VALUE(name) OVER (
        PARTITION BY category_id 
        ORDER BY price
    ) AS cheapest_item_name,
    FIRST_VALUE(price) OVER (
        PARTITION BY category_id 
        ORDER BY price
    ) AS cheapest_item_price
FROM marketplace.items
ORDER BY category_id, price;
```
<img width="997" height="298" alt="image" src="https://github.com/user-attachments/assets/b7a3be61-c3b6-4021-8f66-52f2a67679ad" />

# LAST_VALUE
## Самый дорогой товар в категории
```sql
SELECT 
    item_id,
    name,
    category_id,
    price,
    LAST_VALUE(name) OVER (
        PARTITION BY category_id 
        ORDER BY price
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS most_expensive_item_name,
    LAST_VALUE(price) OVER (
        PARTITION BY category_id 
        ORDER BY price
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS most_expensive_item_price
FROM marketplace.items
ORDER BY category_id, price;
```
<img width="1087" height="299" alt="image" src="https://github.com/user-attachments/assets/e48e5155-f076-4de0-933b-022d45535efc" />
