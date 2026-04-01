ANALYZE;

Explain (analyze, buffers)
SELECT id, user_id, amount, created_at
FROM exam_events
WHERE user_id = 4242
  AND created_at >= TIMESTAMP '2025-03-10 00:00:00'
  AND created_at < TIMESTAMP '2025-03-11 00:00:00';

CREATE INDEX idx_items_price_btree
    ON exam_events (created_at);

Explain (analyze, buffers)
SELECT u.id, u.country, o.amount, o.created_at
FROM exam_users u
         JOIN exam_orders o ON o.user_id = u.id
WHERE u.country = 'JP'
  AND o.created_at >= TIMESTAMP '2025-03-01 00:00:00'
  AND o.created_at < TIMESTAMP '2025-03-08 00:00:00';

CREATE INDEX idx_exam_users_country ON exam_users(country);


SELECT xmin, xmax, ctid, id, title, qty
FROM exam_mvcc_items
ORDER BY id;

UPDATE exam_mvcc_items
SET qty = qty + 5
WHERE id = 1;

SELECT xmin, xmax, ctid, id, title, qty
FROM exam_mvcc_items
ORDER BY id;

DELETE FROM exam_mvcc_items
WHERE id = 2;

SELECT xmin, xmax, ctid, id, title, qty
FROM exam_mvcc_items
ORDER BY id;


-- 1
CREATE TABLE exam_measurements (
                                   city_id INTEGER NOT NULL,
                                   log_date DATE NOT NULL,
                                   peaktemp INTEGER,
                                   unitsales INTEGER
) PARTITION BY RANGE (log_date);
-- 2
CREATE TABLE exam_measurements_2025_01
    PARTITION OF exam_measurements
        FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE exam_measurements_2025_02
    PARTITION OF exam_measurements
        FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

CREATE TABLE exam_measurements_2025_03
    PARTITION OF exam_measurements
        FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');

CREATE TABLE exam_measurements_default
    PARTITION OF exam_measurements DEFAULT;
-- 3
INSERT INTO exam_measurements (city_id, log_date, peaktemp, unitsales)
SELECT city_id, log_date, peaktemp, unitsales
FROM exam_measurements_src;

ANALYZE exam_measurements;

EXPLAIN (ANALYZE, BUFFERS)
SELECT city_id, log_date, unitsales
FROM exam_measurements
WHERE log_date >= DATE '2025-02-01'
  AND log_date < DATE '2025-03-01';

EXPLAIN (ANALYZE, BUFFERS)
SELECT city_id, log_date, unitsales
FROM exam_measurements
WHERE city_id = 10;