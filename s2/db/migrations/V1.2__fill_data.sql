BEGIN;

-- Если запускаешь повторно
TRUNCATE TABLE
    marketplace.orders,
    marketplace.reviews,
    marketplace.purchases,
    marketplace.items,
    marketplace.category_of_item,
    marketplace.shops,
    marketplace.pvz,
    marketplace.buyers,
    marketplace.worker_assignments,
    marketplace.career_path,
    marketplace.workers,
    marketplace.profession
    RESTART IDENTITY CASCADE;

-- Небольшие таблицы (для FK)

-- profession (30)
INSERT INTO marketplace.profession(name, salary)
SELECT
    'profession_' || g,
    (30000 + floor(random() * 170000))::int
FROM generate_series(1, 30) AS g;

-- career_path (60)
INSERT INTO marketplace.career_path(current_profession_id, next_profession_id)
SELECT
    (1 + floor(random() * 30))::int,
    (1 + floor(random() * 30))::int
FROM generate_series(1, 60);

-- workers (5 000)
INSERT INTO marketplace.workers(login, password_hash, salt)
SELECT
    'worker_'|| g,
    md5('pw_' || g),
    md5('salt_' || (g*17))
FROM generate_series(1, 5000) AS g;

-- pvz (300)
INSERT INTO marketplace.pvz(address)
SELECT
    format('NabChelny district %s, street %s, bld %s', (g % 25)+1, (g % 200)+1, (g % 80)+1)
FROM generate_series(1, 300) AS g;

-- shops (10 000)
INSERT INTO marketplace.shops(owner_id, name)
SELECT
    CASE WHEN random() < 0.80 THEN (1 + floor(random() * 5000))::int ELSE NULL END,
    format('shop_%s', g)
FROM generate_series(1, 10000) AS g;

-- categories (100)
INSERT INTO marketplace.category_of_item(name, description)
SELECT
    'category_' || g,
    CASE
        WHEN random() < 0.10 THEN NULL
        ELSE 'Категория для тестовых данных: ' || g || '. ' || repeat('описание ', 8)
        END
FROM generate_series(1, 100) AS g;


-- 4 большие таблицы (по 250k)

-- buyers
-- high-cardinality: login (unique), email (~unique, но 15% NULL)
INSERT INTO marketplace.buyers(login, password_hash, salt, email)
SELECT
    format('buyer_%s', g) AS login,
    md5('pw_' || g::text) AS password_hash,
    md5('salt_' || (g*31)::text) AS salt,
    CASE
        WHEN random() < 0.15 THEN NULL
        ELSE format('buyer_%s@example.com', g)
        END AS email
FROM generate_series(1, 250000) AS g;

-- items: перед массовой вставкой лучше убрать FTS-индекс и восстановить после
DROP INDEX IF EXISTS marketplace.items_fts_gin;

-- items
-- skewed: 70% товаров принадлежат top-10% shops (1000 из 10000), внутри top-диапазона Zipf-like через power(random(), 3)
-- uniform: price равномерно по диапазону
-- full-text data: description (TEXT)
-- JSONB: attributes
INSERT INTO marketplace.items(shop_id, name, description, category_id, price, attributes)
SELECT
    CASE
        WHEN random() < 0.70
            THEN 1 + floor(power(random(), 3) * (1000 - 1))::int          -- skewed/Zipf-like по магазинам
        ELSE 1 + floor(random() * 10000)::int                            -- остальное по всем магазинам
        END AS shop_id,

    format('item_%s', g) AS name,

    CASE
        WHEN random() < 0.10 THEN NULL                                   -- 10% NULL в тексте
        ELSE
            'Описание товара ' || g || ': ' ||
            (ARRAY['качество','доставка','скидка','гарантия','новинка','хит','акция','премиум'])[1+floor(random()*8)::int] || ' ' ||
            (ARRAY['удобный','надёжный','выгодный','популярный','лёгкий','прочный','универсальный','стильный'])[1+floor(random()*8)::int] || '. ' ||
            repeat('текст ', 10)
        END AS description,

    (1 + floor(random() * 100))::int AS category_id,

    round((50 + random() * 4950)::numeric, 2) AS price,

    jsonb_build_object(
            'brand', format('brand_%s', 1 + floor(power(random(), 2) * 200)::int),
            'color', (ARRAY['black','white','red','blue','green'])[1+floor(random()*5)::int],
            'warranty_months', (6 + floor(random() * 36))::int,
            'rating_bucket', (ARRAY['low','mid','high'])[1+floor(random()*3)::int]
    ) AS attributes
FROM generate_series(1, 250000) AS g;

-- восстановил FTS индекс
CREATE INDEX items_fts_gin
    ON marketplace.items
        USING GIN ((to_tsvector('russian', coalesce(name,'') || ' ' || coalesce(description,''))));

-- purchases
-- skewed 70/30: 70% покупок делают top-10% покупателей, плюс 70% покупок приходится на top-5% товаров
-- uniform: purchase_date равномерно по периоду
-- low selectivity: status (3 значения)
INSERT INTO marketplace.purchases(item_id, buyer_id, purchase_date, status)
SELECT
    CASE
        WHEN random() < 0.70
            THEN 1 + floor(power(random(), 3) * (12500 - 1))::int         -- top-5% items (12500)
        ELSE 1 + floor(random() * 250000)::int
        END AS item_id,

    CASE
        WHEN random() < 0.70
            THEN 1 + floor(power(random(), 3) * (25000 - 1))::int         -- top-10% buyers (25000)
        ELSE 1 + floor(random() * 250000)::int
        END AS buyer_id,

    (timestamp '2025-01-01' + (random() * interval '395 days')) AS purchase_date,  -- uniform по интервалу

    CASE
        WHEN r < 0.03 THEN 'pending'
        WHEN r < 0.10 THEN 'cancelled'
        ELSE 'completed'
        END AS status
FROM (
         SELECT g, random() AS r
         FROM generate_series(1, 250000) AS g
     ) s;

-- orders — 1:1 с purchases
-- range-type: delivery_slot (tstzrange)
-- NULL 20%: delivered_at NULL для created/cancelled (15% + 5%)
-- low selectivity: status (3 значения)
INSERT INTO marketplace.orders(purchase_id, pvz_id, status, order_date, delivery_slot, delivered_at)
SELECT
    p.purchase_id,
    x.pvz_id,
    CASE
        WHEN x.r < 0.05 THEN 'cancelled'
        WHEN x.r < 0.20 THEN 'created'
        ELSE 'delivered'
        END AS status,
    (p.purchase_date + x.order_delta) AS order_date,
    CASE
        WHEN x.r < 0.05 THEN NULL
        ELSE tstzrange(
                (p.purchase_date::timestamptz + x.slot_delta),
                (p.purchase_date::timestamptz + x.slot_delta + interval '4 hours'),
                '[)'
             )
        END AS delivery_slot,
    CASE
        WHEN x.r >= 0.20 THEN (p.purchase_date + x.delivered_delta)::timestamp
        ELSE NULL
        END AS delivered_at
FROM marketplace.purchases p
         CROSS JOIN LATERAL (
    SELECT
        random() AS r,
        (1 + floor(random() * 300))::int AS pvz_id,
        (random() * interval '2 days')  AS order_delta,
        (random() * interval '5 days')  AS slot_delta,
        (random() * interval '10 days') AS delivered_delta
    ) x;

COMMIT;
