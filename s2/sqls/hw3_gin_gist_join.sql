-- Индекс под полнотекстовый поиск по name+description (expression GIN index на to_tsvector).
-- CREATE INDEX items_fts_gin
--     ON marketplace.items
--         USING GIN ((to_tsvector('russian', coalesce(name,'') || ' ' || coalesce(description,''))));





-- перед серией замеров
ANALYZE marketplace.items;

-- без индекса
DROP INDEX IF EXISTS marketplace.items_fts_gin;
DROP INDEX IF EXISTS marketplace.items_fts_gist;
DROP INDEX IF EXISTS marketplace.items_attr_gin;
DROP INDEX IF EXISTS marketplace.orders_delivery_slot_gist;

-- GIN для полнотекста
CREATE INDEX items_fts_gin
    ON marketplace.items
    USING GIN ((to_tsvector('russian', coalesce(name,'') || ' ' || coalesce(description,''))));

-- GiST для полнотекста
CREATE INDEX items_fts_gist
    ON marketplace.items
    USING GIST ((to_tsvector('russian', coalesce(name,'') || ' ' || coalesce(description,''))));

-- GIN для JSONB
CREATE INDEX items_attr_gin
    ON marketplace.items
    USING GIN (attributes jsonb_ops);

-- GIST для диапазона
CREATE INDEX orders_delivery_slot_gist
    ON marketplace.orders
    USING GIST (delivery_slot);

-- 1. GIN GIST Полнотекст, одно слово
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.items
WHERE to_tsvector('russian', coalesce(name,'') || ' ' || coalesce(description,'')) @@
    plainto_tsquery('russian', 'качество');

-- 2. GIN GIST Полнотекст, AND
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.items
WHERE to_tsvector('russian', coalesce(name,'') || ' ' || coalesce(description,'')) @@
    to_tsquery('russian', 'скидка & надёжный');

-- 3. GIN GIST Полнотекст, OR
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.items
WHERE to_tsvector('russian', coalesce(name,'') || ' ' || coalesce(description,'')) @@
    to_tsquery('russian', 'новинка | премиум');

-- 4. GIN JSONB containment
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.items
WHERE attributes @> '{"brand":"brand_1","color":"black"}';

-- 5. GIN JSONB path
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.items
WHERE attributes @? '$.warranty_months ? (@ >= 27 && @ <= 28)';

-- 6. GIST пересечение TSTZRANGE через &&
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.orders
WHERE delivery_slot &&
      tstzrange(
        timestamptz '2025-03-10 10:00:00+03',
        timestamptz '2025-03-10 18:00:00+03',
        '[)'
      );

-- 7. GIST @> для TSTZRANGE
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.orders
WHERE delivery_slot @> timestamptz '2025-03-10 12:30:00+03';

--- JOIN

ANALYZE marketplace.buyers;
ANALYZE marketplace.items;
ANALYZE marketplace.purchases;
ANALYZE marketplace.orders;
ANALYZE marketplace.shops;

-- 1. Маленький диапазон по PK, обычно удобно для Nested Loop
EXPLAIN (ANALYZE, BUFFERS)
SELECT p.purchase_id, o.order_id, o.status
FROM marketplace.purchases p
         JOIN marketplace.orders o
              ON o.purchase_id = p.purchase_id
WHERE p.purchase_id BETWEEN 1000 AND 1100;

-- 2. Большой equality join двух крупных таблиц, часто Hash Join
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.purchases p
         JOIN marketplace.items i
              ON i.item_id = p.item_id
WHERE p.status = 'completed';

-- 3. Ещё один крупный equality join, но с другой селективностью
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.items i
         JOIN marketplace.shops s
              ON s.shop_id = i.shop_id
WHERE i.price > 4000;

-- 4.Соединение с сортировкой по ключу join, кандидат на Merge Join
EXPLAIN (ANALYZE, BUFFERS)
SELECT p.purchase_id, o.order_id
FROM marketplace.purchases p
         JOIN marketplace.orders o
              ON o.purchase_id = p.purchase_id
ORDER BY p.purchase_id;

-- 5. Тройной join, чтобы посмотреть порядок соединений
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.buyers b
         JOIN marketplace.purchases p
              ON p.buyer_id = b.buyer_id
         JOIN marketplace.orders o
              ON o.purchase_id = p.purchase_id
WHERE b.email IS NOT NULL
  AND o.status = 'delivered';

