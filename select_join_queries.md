-- 1. Список всех покупателей
SELECT * FROM buyers;

-- 2. Список всех товаров с ценой
SELECT name, price FROM items;

-- 3. Метка для дорогих и дешевых товаров
SELECT name, price,
       CASE
         WHEN price > 10000 THEN 'Дорогой'
         ELSE 'Дешевый'
       END AS price_tag
FROM items;

-- 4. Категоризация отзывов по рейтингу
SELECT review_id, rating,
       CASE
         WHEN rating >= 4 THEN 'Положительный'
         WHEN rating = 3 THEN 'Нейтральный'
         ELSE 'Негативный'
       END AS review_type
FROM reviews;

-- 5. Заказы с логинами покупателей
SELECT orders.order_id, buyers.login
FROM orders
INNER JOIN buyers ON orders.buyer_id = buyers.buyer_id;

-- 6. Товары и их магазины
SELECT items.name, shops.name
FROM items
INNER JOIN shops ON items.shop_id = shops.shop_id;

-- 7. Все магазины и их владельцы (включая без владельца)
SELECT shops.name, workers.login
FROM shops
LEFT JOIN workers ON shops.owner_id = workers.worker_id;

-- 8. Все покупатели и их отзывы (даже если отзывов нет)
SELECT buyers.login, reviews.review_id
FROM buyers
LEFT JOIN purchases ON buyers.buyer_id = purchases.buyer_id
LEFT JOIN reviews ON purchases.purchase_id = reviews.purchase_id;

-- 9. Все работники и их назначения (даже если нет работника)
SELECT workers.login, worker_assignments.place_id
FROM workers
RIGHT JOIN worker_assignments ON workers.worker_id = worker_assignments.worker_id;

-- 10. Покупки и соответствующие заказы (покажет все покупки)
SELECT purchases.purchase_id, orders.order_id
FROM purchases
RIGHT JOIN orders ON purchases.purchase_id = orders.purchase_id;

-- 11. Все товары и все магазины (в том числе без пары)
SELECT items.name, shops.name
FROM items
FULL OUTER JOIN shops ON items.shop_id = shops.shop_id;

-- 12. Все отзывы и покупки (даже если не связаны)
SELECT reviews.review_id, purchases.purchase_id
FROM reviews
FULL OUTER JOIN purchases ON reviews.purchase_id = purchases.purchase_id;

-- 13. Все сочетания категорий и магазинов
SELECT category_of_item.name, shops.name
FROM category_of_item
CROSS JOIN shops;

-- 14. Все сочетания покупателей и товаров
SELECT buyers.login, items.name
FROM buyers
CROSS JOIN items;
