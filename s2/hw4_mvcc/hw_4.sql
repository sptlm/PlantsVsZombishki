CREATE EXTENSION IF NOT EXISTS pageinspect;

SELECT item_id, price, xmin, xmax, ctid
FROM marketplace.items
WHERE item_id = 1;

SELECT
    lp,
    t_xmin AS xmin,
    t_xmax AS xmax,
    t_ctid AS ctid,
    t_infomask,
    t_infomask2,
    raw_flags,
    combined_flags
FROM heap_page_items(get_raw_page('marketplace.items', 0)) h
         CROSS JOIN LATERAL heap_tuple_infomask_flags(h.t_infomask, h.t_infomask2) f
WHERE t_ctid = (SELECT ctid
               FROM marketplace.items
               WHERE item_id = 1);


-- 3
-- Транзакция A:

BEGIN;

UPDATE marketplace.items
SET price = price + 100
WHERE item_id = 1;

SELECT item_id, price, xmin, xmax, ctid
FROM marketplace.items
WHERE item_id = 1;

COMMIT;


-- 4

-- Транзакция A:
BEGIN;

UPDATE marketplace.items
SET price = price + 10
WHERE item_id = 1;

-- Транзакция A:

UPDATE marketplace.items
SET price = price + 10
WHERE item_id = 2;

ROLLBACK;


VACUUM (VERBOSE) marketplace.items;