analyse marketplace.items;
analyse marketplace.purchases;

-- EXPLAIN ANALYZE
-- >
EXPLAIN ANALYZE
SELECT count(*)
FROM marketplace.items
WHERE price > 4900;

-- <
EXPLAIN ANALYZE
SELECT count(*)
FROM marketplace.purchases
WHERE purchase_date < timestamp '2025-02-01';

-- =
EXPLAIN ANALYZE
SELECT count(*)
FROM marketplace.purchases
WHERE buyer_id = 200000;

-- %like
EXPLAIN ANALYZE
SELECT count(*)
FROM marketplace.items
WHERE name LIKE '%123';

-- like%
EXPLAIN ANALYZE
SELECT count(*)
FROM marketplace.items
WHERE name LIKE 'item_12%';

-- EXPLAIN (ANALYZE, BUFFERS)
-- >
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.items
WHERE price > 4900;

-- <
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.purchases
WHERE purchase_date < timestamp '2025-02-01';

-- =
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.purchases
WHERE buyer_id = 200000;

-- %like
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.items
WHERE name LIKE '%123';

-- like%
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.items
WHERE name LIKE 'item_12%';


CREATE INDEX idx_items_price_btree
    ON marketplace.items (price);

CREATE INDEX idx_purchases_purchase_date_btree
    ON marketplace.purchases (purchase_date);

CREATE INDEX idx_purchases_buyer_id_btree
    ON marketplace.purchases (buyer_id);

CREATE INDEX idx_items_name_btree
    ON marketplace.items (name);


CREATE INDEX idx_items_price_hash
    ON marketplace.items USING hash (price);

CREATE INDEX idx_purchases_purchase_date_hash
    ON marketplace.purchases USING hash (purchase_date);

CREATE INDEX idx_purchases_buyer_id_hash
    ON marketplace.purchases USING hash (buyer_id);

CREATE INDEX idx_items_name_hash
    ON marketplace.items USING hash (name);


DROP INDEX IF EXISTS marketplace.idx_items_price_btree;
DROP INDEX IF EXISTS marketplace.idx_purchases_purchase_date_btree;
DROP INDEX IF EXISTS marketplace.idx_purchases_buyer_id_btree;
DROP INDEX IF EXISTS marketplace.idx_items_name_btree_tpo;