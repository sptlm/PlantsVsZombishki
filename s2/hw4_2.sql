-- 3
-- Транзакция B:
BEGIN;

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
ORDER BY lp;

COMMIT;

-- 4
-- Транзакция B:
BEGIN;

UPDATE marketplace.items
SET price = price + 20
WHERE item_id = 2;

-- Транзакция B:
UPDATE marketplace.items
SET price = price + 20
WHERE item_id = 1;

ROLLBACK;