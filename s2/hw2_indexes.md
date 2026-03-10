-- EXPLAIN ANALYZE
  -- >
  EXPLAIN ANALYZE
  SELECT count(*)
  FROM marketplace.items
  WHERE price > 4900;

без индексов
Finalize Aggregate  (cost=12546.81..12546.82 rows=1 width=8) (actual time=418.254..422.321 rows=1 loops=1)
->  Gather  (cost=12546.59..12546.80 rows=2 width=8) (actual time=418.096..422.313 rows=3 loops=1)
Workers Planned: 2
Workers Launched: 2
->  Partial Aggregate  (cost=11546.59..11546.60 rows=1 width=8) (actual time=384.955..384.957 rows=1 loops=3)
->  Parallel Seq Scan on items  (cost=0.00..11541.08 rows=2203 width=0) (actual time=10.427..384.375 rows=1683 loops=3)
Filter: (price > '4900'::numeric)
Rows Removed by Filter: 81650
Planning Time: 0.393 ms
Execution Time: 422.491 ms

b-tree index
Aggregate  (cost=166.16..166.17 rows=1 width=8) (actual time=1.343..1.345 rows=1 loops=1)
->  Index Only Scan using idx_items_price_btree on items  (cost=0.42..152.94 rows=5287 width=0) (actual time=0.057..1.064 rows=5050 loops=1)
Index Cond: (price > '4900'::numeric)
Heap Fetches: 0
Planning Time: 0.346 ms
Execution Time: 1.367 ms

hash index
Finalize Aggregate  (cost=12546.42..12546.43 rows=1 width=8) (actual time=25.783..29.437 rows=1 loops=1)
->  Gather  (cost=12546.20..12546.41 rows=2 width=8) (actual time=25.550..29.430 rows=3 loops=1)
Workers Planned: 2
Workers Launched: 2
->  Partial Aggregate  (cost=11546.20..11546.21 rows=1 width=8) (actual time=19.922..19.924 rows=1 loops=3)
->  Parallel Seq Scan on items  (cost=0.00..11541.08 rows=2047 width=0) (actual time=0.116..19.778 rows=1683 loops=3)
Filter: (price > '4900'::numeric)
Rows Removed by Filter: 81650
Planning Time: 0.171 ms
Execution Time: 29.473 ms


-- <
EXPLAIN ANALYZE
SELECT count(*)
FROM marketplace.purchases
WHERE purchase_date < timestamp '2025-02-01';

без индексов
Finalize Aggregate  (cost=4950.32..4950.33 rows=1 width=8) (actual time=31.883..35.337 rows=1 loops=1)
->  Gather  (cost=4950.21..4950.32 rows=1 width=8) (actual time=31.717..35.327 rows=2 loops=1)
Workers Planned: 1
Workers Launched: 1
->  Partial Aggregate  (cost=3950.21..3950.22 rows=1 width=8) (actual time=26.788..26.790 rows=1 loops=2)
->  Parallel Seq Scan on purchases  (cost=0.00..3921.24 rows=11588 width=0) (actual time=0.052..26.085 rows=9881 loops=2)
Filter: (purchase_date < '2025-02-01 00:00:00'::timestamp without time zone)
Rows Removed by Filter: 115119
Planning Time: 0.147 ms
Execution Time: 35.377 ms

b-tree index
Aggregate  (cost=614.40..614.41 rows=1 width=8) (actual time=4.059..4.060 rows=1 loops=1)
->  Index Only Scan using idx_purchases_purchase_date_btree on purchases  (cost=0.42..565.15 rows=19699 width=0) (actual time=0.051..3.077 rows=19762 loops=1)
Index Cond: (purchase_date < '2025-02-01 00:00:00'::timestamp without time zone)
Heap Fetches: 0
Planning Time: 0.287 ms
Execution Time: 4.160 ms

hash index
Finalize Aggregate  (cost=4951.47..4951.48 rows=1 width=8) (actual time=12.917..16.647 rows=1 loops=1)
->  Gather  (cost=4951.36..4951.47 rows=1 width=8) (actual time=12.699..16.638 rows=2 loops=1)
Workers Planned: 1
Workers Launched: 1
->  Partial Aggregate  (cost=3951.36..3951.37 rows=1 width=8) (actual time=8.842..8.844 rows=1 loops=2)
->  Parallel Seq Scan on purchases  (cost=0.00..3921.24 rows=12049 width=0) (actual time=0.017..8.402 rows=9881 loops=2)
Filter: (purchase_date < '2025-02-01 00:00:00'::timestamp without time zone)
Rows Removed by Filter: 115119
Planning Time: 0.126 ms
Execution Time: 16.680 ms


-- =
EXPLAIN ANALYZE
SELECT count(*)
FROM marketplace.purchases
WHERE buyer_id = 200000;

без индексов
Finalize Aggregate  (cost=4921.36..4921.37 rows=1 width=8) (actual time=11.655..14.762 rows=1 loops=1)
->  Gather  (cost=4921.25..4921.36 rows=1 width=8) (actual time=11.462..14.753 rows=2 loops=1)
Workers Planned: 1
Workers Launched: 1
->  Partial Aggregate  (cost=3921.25..3921.26 rows=1 width=8) (actual time=7.349..7.350 rows=1 loops=2)
->  Parallel Seq Scan on purchases  (cost=0.00..3921.24 rows=4 width=0) (actual time=7.345..7.345 rows=0 loops=2)
Filter: (buyer_id = 200000)
Rows Removed by Filter: 125000
Planning Time: 0.073 ms
Execution Time: 14.792 ms

b-tree index
Aggregate  (cost=4.54..4.55 rows=1 width=8) (actual time=0.037..0.037 rows=1 loops=1)
->  Index Only Scan using idx_purchases_buyer_id_btree on purchases  (cost=0.42..4.52 rows=6 width=0) (actual time=0.033..0.033 rows=0 loops=1)
Index Cond: (buyer_id = 200000)
Heap Fetches: 0
Planning Time: 0.086 ms
Execution Time: 0.057 ms

hash index
Aggregate  (cost=30.94..30.95 rows=1 width=8) (actual time=0.011..0.012 rows=1 loops=1)
->  Bitmap Heap Scan on purchases  (cost=4.05..30.92 rows=7 width=0) (actual time=0.008..0.008 rows=0 loops=1)
Recheck Cond: (buyer_id = 200000)
->  Bitmap Index Scan on idx_purchases_buyer_id_hash  (cost=0.00..4.05 rows=7 width=0) (actual time=0.006..0.007 rows=0 loops=1)
Index Cond: (buyer_id = 200000)
Planning Time: 0.115 ms
Execution Time: 0.032 ms


-- %like
EXPLAIN ANALYZE
SELECT count(*)
FROM marketplace.items
WHERE name LIKE '%123';

без индексов
Finalize Aggregate  (cost=12543.93..12543.94 rows=1 width=8) (actual time=33.861..37.890 rows=1 loops=1)
->  Gather  (cost=12543.71..12543.92 rows=2 width=8) (actual time=33.663..37.882 rows=3 loops=1)
Workers Planned: 2
Workers Launched: 2
->  Partial Aggregate  (cost=11543.71..11543.72 rows=1 width=8) (actual time=28.237..28.239 rows=1 loops=3)
->  Parallel Seq Scan on items  (cost=0.00..11541.08 rows=1052 width=0) (actual time=0.286..28.206 rows=83 loops=3)
Filter: ((name)::text ~~ '%123'::text)
Rows Removed by Filter: 83250
Planning Time: 0.130 ms
Execution Time: 37.926 ms

b-tree index
Finalize Aggregate  (cost=7415.35..7415.36 rows=1 width=8) (actual time=72.903..76.766 rows=1 loops=1)
->  Gather  (cost=7415.13..7415.34 rows=2 width=8) (actual time=72.790..76.744 rows=3 loops=1)
Workers Planned: 2
Workers Launched: 2
->  Partial Aggregate  (cost=6415.13..6415.14 rows=1 width=8) (actual time=66.708..66.709 rows=1 loops=3)
->  Parallel Index Only Scan using idx_items_name_btree on items  (cost=0.42..6412.50 rows=1052 width=0) (actual time=0.286..66.646 rows=83 loops=3)
Filter: ((name)::text ~~ '%123'::text)
Rows Removed by Filter: 83250
Heap Fetches: 0
Planning Time: 0.142 ms
Execution Time: 76.800 ms

hash index
Finalize Aggregate  (cost=12543.93..12543.94 rows=1 width=8) (actual time=25.948..29.255 rows=1 loops=1)
->  Gather  (cost=12543.71..12543.92 rows=2 width=8) (actual time=25.789..29.247 rows=3 loops=1)
Workers Planned: 2
Workers Launched: 2
->  Partial Aggregate  (cost=11543.71..11543.72 rows=1 width=8) (actual time=19.579..19.581 rows=1 loops=3)
->  Parallel Seq Scan on items  (cost=0.00..11541.08 rows=1052 width=0) (actual time=0.381..19.552 rows=83 loops=3)
Filter: ((name)::text ~~ '%123'::text)
Rows Removed by Filter: 83250
Planning Time: 0.130 ms
Execution Time: 29.288 ms


-- like%
EXPLAIN ANALYZE
SELECT count(*)
FROM marketplace.items
WHERE name LIKE 'item_12%';

без индексов
Finalize Aggregate  (cost=12554.45..12554.46 rows=1 width=8) (actual time=22.141..25.249 rows=1 loops=1)
->  Gather  (cost=12554.24..12554.45 rows=2 width=8) (actual time=21.948..25.237 rows=3 loops=1)
Workers Planned: 2
Workers Launched: 2
->  Partial Aggregate  (cost=11554.24..11554.25 rows=1 width=8) (actual time=17.252..17.254 rows=1 loops=3)
->  Parallel Seq Scan on items  (cost=0.00..11541.08 rows=5261 width=0) (actual time=3.458..17.063 rows=3704 loops=3)
Filter: ((name)::text ~~ 'item_12%'::text)
Rows Removed by Filter: 79630
Planning Time: 0.076 ms
Execution Time: 25.291 ms

b-tree index
Finalize Aggregate  (cost=7425.87..7425.88 rows=1 width=8) (actual time=19.149..23.719 rows=1 loops=1)
->  Gather  (cost=7425.66..7425.87 rows=2 width=8) (actual time=19.039..23.710 rows=3 loops=1)
Workers Planned: 2
Workers Launched: 2
->  Partial Aggregate  (cost=6425.66..6425.67 rows=1 width=8) (actual time=13.045..13.046 rows=1 loops=3)
->  Parallel Index Only Scan using idx_items_name_btree on items  (cost=0.42..6412.50 rows=5261 width=0) (actual time=7.587..12.874 rows=3704 loops=3)
Filter: ((name)::text ~~ 'item_12%'::text)
Rows Removed by Filter: 79630
Heap Fetches: 0
Planning Time: 0.115 ms
Execution Time: 23.769 ms

hash index
Finalize Aggregate  (cost=12554.45..12554.46 rows=1 width=8) (actual time=39.376..42.081 rows=1 loops=1)
->  Gather  (cost=12554.24..12554.45 rows=2 width=8) (actual time=28.268..42.067 rows=3 loops=1)
Workers Planned: 2
Workers Launched: 2
->  Partial Aggregate  (cost=11554.24..11554.25 rows=1 width=8) (actual time=15.919..15.920 rows=1 loops=3)
->  Parallel Seq Scan on items  (cost=0.00..11541.08 rows=5261 width=0) (actual time=1.964..15.717 rows=3704 loops=3)
Filter: ((name)::text ~~ 'item_12%'::text)
Rows Removed by Filter: 79630
Planning Time: 0.077 ms
Execution Time: 42.110 ms


-- EXPLAIN (ANALYZE, BUFFERS)
-- >
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.items
WHERE price > 4900;

без индексов
Finalize Aggregate  (cost=12546.81..12546.82 rows=1 width=8) (actual time=24.748..28.054 rows=1 loops=1)
Buffers: shared hit=672 read=9567
->  Gather  (cost=12546.59..12546.80 rows=2 width=8) (actual time=24.561..28.046 rows=3 loops=1)
Workers Planned: 2
Workers Launched: 2
Buffers: shared hit=672 read=9567
->  Partial Aggregate  (cost=11546.59..11546.60 rows=1 width=8) (actual time=19.797..19.799 rows=1 loops=3)
Buffers: shared hit=672 read=9567
->  Parallel Seq Scan on items  (cost=0.00..11541.08 rows=2203 width=0) (actual time=0.075..19.621 rows=1683 loops=3)
Filter: (price > '4900'::numeric)
Rows Removed by Filter: 81650
Buffers: shared hit=672 read=9567
Planning Time: 0.296 ms
Execution Time: 28.093 ms

b-tree index
Aggregate  (cost=166.16..166.17 rows=1 width=8) (actual time=0.949..0.951 rows=1 loops=1)
Buffers: shared hit=18
->  Index Only Scan using idx_items_price_btree on items  (cost=0.42..152.94 rows=5287 width=0) (actual time=0.071..0.683 rows=5050 loops=1)
Index Cond: (price > '4900'::numeric)
Heap Fetches: 0
Buffers: shared hit=18
Planning Time: 0.125 ms
Execution Time: 0.974 ms

hash index
Finalize Aggregate  (cost=12546.42..12546.43 rows=1 width=8) (actual time=346.236..350.541 rows=1 loops=1)
Buffers: shared hit=1696 read=8543
->  Gather  (cost=12546.20..12546.41 rows=2 width=8) (actual time=346.012..350.530 rows=3 loops=1)
Workers Planned: 2
Workers Launched: 2
Buffers: shared hit=1696 read=8543
->  Partial Aggregate  (cost=11546.20..11546.21 rows=1 width=8) (actual time=321.133..321.135 rows=1 loops=3)
Buffers: shared hit=1696 read=8543
->  Parallel Seq Scan on items  (cost=0.00..11541.08 rows=2047 width=0) (actual time=10.288..320.487 rows=1683 loops=3)
Filter: (price > '4900'::numeric)
Rows Removed by Filter: 81650
Buffers: shared hit=1696 read=8543
Planning Time: 0.236 ms
Execution Time: 350.584 ms


-- <
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.purchases
WHERE purchase_date < timestamp '2025-02-01';

без индексов
Finalize Aggregate  (cost=4950.32..4950.33 rows=1 width=8) (actual time=13.968..17.369 rows=1 loops=1)
Buffers: shared hit=2083
->  Gather  (cost=4950.21..4950.32 rows=1 width=8) (actual time=13.798..17.359 rows=2 loops=1)
Workers Planned: 1
Workers Launched: 1
Buffers: shared hit=2083
->  Partial Aggregate  (cost=3950.21..3950.22 rows=1 width=8) (actual time=9.521..9.523 rows=1 loops=2)
Buffers: shared hit=2083
->  Parallel Seq Scan on purchases  (cost=0.00..3921.24 rows=11588 width=0) (actual time=0.040..8.952 rows=9881 loops=2)
Filter: (purchase_date < '2025-02-01 00:00:00'::timestamp without time zone)
Rows Removed by Filter: 115119
Buffers: shared hit=2083
Planning Time: 0.083 ms
Execution Time: 17.445 ms

b-tree index
Aggregate  (cost=614.40..614.41 rows=1 width=8) (actual time=2.915..2.916 rows=1 loops=1)
Buffers: shared hit=57
->  Index Only Scan using idx_purchases_purchase_date_btree on purchases  (cost=0.42..565.15 rows=19699 width=0) (actual time=0.045..1.874 rows=19762 loops=1)
Index Cond: (purchase_date < '2025-02-01 00:00:00'::timestamp without time zone)
Heap Fetches: 0
Buffers: shared hit=57
Planning Time: 0.074 ms
Execution Time: 2.936 ms

hash index
Finalize Aggregate  (cost=4951.47..4951.48 rows=1 width=8) (actual time=14.715..18.077 rows=1 loops=1)
Buffers: shared hit=2083
->  Gather  (cost=4951.36..4951.47 rows=1 width=8) (actual time=14.561..18.068 rows=2 loops=1)
Workers Planned: 1
Workers Launched: 1
Buffers: shared hit=2083
->  Partial Aggregate  (cost=3951.36..3951.37 rows=1 width=8) (actual time=10.731..10.732 rows=1 loops=2)
Buffers: shared hit=2083
->  Parallel Seq Scan on purchases  (cost=0.00..3921.24 rows=12049 width=0) (actual time=0.013..10.131 rows=9881 loops=2)
Filter: (purchase_date < '2025-02-01 00:00:00'::timestamp without time zone)
Rows Removed by Filter: 115119
Buffers: shared hit=2083
Planning Time: 0.083 ms
Execution Time: 18.114 ms


-- =
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.purchases
WHERE buyer_id = 200000;

без индексов
Finalize Aggregate  (cost=4921.36..4921.37 rows=1 width=8) (actual time=12.211..15.896 rows=1 loops=1)
Buffers: shared hit=2083
->  Gather  (cost=4921.25..4921.36 rows=1 width=8) (actual time=12.032..15.886 rows=2 loops=1)
Workers Planned: 1
Workers Launched: 1
Buffers: shared hit=2083
->  Partial Aggregate  (cost=3921.25..3921.26 rows=1 width=8) (actual time=8.061..8.062 rows=1 loops=2)
Buffers: shared hit=2083
->  Parallel Seq Scan on purchases  (cost=0.00..3921.24 rows=4 width=0) (actual time=8.057..8.057 rows=0 loops=2)
Filter: (buyer_id = 200000)
Rows Removed by Filter: 125000
Buffers: shared hit=2083
Planning Time: 0.095 ms
Execution Time: 15.943 ms

b-tree index
Aggregate  (cost=4.54..4.55 rows=1 width=8) (actual time=0.019..0.019 rows=1 loops=1)
Buffers: shared hit=3
->  Index Only Scan using idx_purchases_buyer_id_btree on purchases  (cost=0.42..4.52 rows=6 width=0) (actual time=0.015..0.016 rows=0 loops=1)
Index Cond: (buyer_id = 200000)
Heap Fetches: 0
Buffers: shared hit=3
Planning Time: 0.090 ms
Execution Time: 0.037 ms

hash index
Aggregate  (cost=30.94..30.95 rows=1 width=8) (actual time=0.016..0.017 rows=1 loops=1)
Buffers: shared hit=2
->  Bitmap Heap Scan on purchases  (cost=4.05..30.92 rows=7 width=0) (actual time=0.012..0.013 rows=0 loops=1)
Recheck Cond: (buyer_id = 200000)
Buffers: shared hit=2
->  Bitmap Index Scan on idx_purchases_buyer_id_hash  (cost=0.00..4.05 rows=7 width=0) (actual time=0.011..0.011 rows=0 loops=1)
Index Cond: (buyer_id = 200000)
Buffers: shared hit=2
Planning Time: 0.079 ms
Execution Time: 0.040 ms


-- %like
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.items
WHERE name LIKE '%123';

без индексов
Finalize Aggregate  (cost=12543.93..12543.94 rows=1 width=8) (actual time=27.363..30.962 rows=1 loops=1)
Buffers: shared hit=768 read=9471
->  Gather  (cost=12543.71..12543.92 rows=2 width=8) (actual time=27.153..30.953 rows=3 loops=1)
Workers Planned: 2
Workers Launched: 2
Buffers: shared hit=768 read=9471
->  Partial Aggregate  (cost=11543.71..11543.72 rows=1 width=8) (actual time=21.837..21.839 rows=1 loops=3)
Buffers: shared hit=768 read=9471
->  Parallel Seq Scan on items  (cost=0.00..11541.08 rows=1052 width=0) (actual time=0.455..21.802 rows=83 loops=3)
Filter: ((name)::text ~~ '%123'::text)
Rows Removed by Filter: 83250
Buffers: shared hit=768 read=9471
Planning Time: 0.074 ms
Execution Time: 30.996 ms

b-tree index
Finalize Aggregate  (cost=7415.35..7415.36 rows=1 width=8) (actual time=25.333..29.712 rows=1 loops=1)
Buffers: shared hit=963
->  Gather  (cost=7415.13..7415.34 rows=2 width=8) (actual time=25.218..29.704 rows=3 loops=1)
Workers Planned: 2
Workers Launched: 2
Buffers: shared hit=963
->  Partial Aggregate  (cost=6415.13..6415.14 rows=1 width=8) (actual time=19.047..19.048 rows=1 loops=3)
Buffers: shared hit=963
->  Parallel Index Only Scan using idx_items_name_btree on items  (cost=0.42..6412.50 rows=1052 width=0) (actual time=0.221..19.001 rows=83 loops=3)
Filter: ((name)::text ~~ '%123'::text)
Rows Removed by Filter: 83250
Heap Fetches: 0
Buffers: shared hit=963
Planning Time: 0.089 ms
Execution Time: 29.748 ms

hash index
Finalize Aggregate  (cost=12543.93..12543.94 rows=1 width=8) (actual time=31.788..35.661 rows=1 loops=1)
Buffers: shared hit=1792 read=8447
->  Gather  (cost=12543.71..12543.92 rows=2 width=8) (actual time=31.618..35.653 rows=3 loops=1)
Workers Planned: 2
Workers Launched: 2
Buffers: shared hit=1792 read=8447
->  Partial Aggregate  (cost=11543.71..11543.72 rows=1 width=8) (actual time=26.315..26.316 rows=1 loops=3)
Buffers: shared hit=1792 read=8447
->  Parallel Seq Scan on items  (cost=0.00..11541.08 rows=1052 width=0) (actual time=0.598..26.281 rows=83 loops=3)
Filter: ((name)::text ~~ '%123'::text)
Rows Removed by Filter: 83250
Buffers: shared hit=1792 read=8447
Planning Time: 0.088 ms
Execution Time: 35.694 ms


-- like%
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.items
WHERE name LIKE 'item_12%';

без индексов
Finalize Aggregate  (cost=12554.45..12554.46 rows=1 width=8) (actual time=25.327..28.756 rows=1 loops=1)
Buffers: shared hit=864 read=9375
->  Gather  (cost=12554.24..12554.45 rows=2 width=8) (actual time=25.133..28.742 rows=3 loops=1)
Workers Planned: 2
Workers Launched: 2
Buffers: shared hit=864 read=9375
->  Partial Aggregate  (cost=11554.24..11554.25 rows=1 width=8) (actual time=19.306..19.308 rows=1 loops=3)
Buffers: shared hit=864 read=9375
->  Parallel Seq Scan on items  (cost=0.00..11541.08 rows=5261 width=0) (actual time=3.492..19.067 rows=3704 loops=3)
Filter: ((name)::text ~~ 'item_12%'::text)
Rows Removed by Filter: 79630
Buffers: shared hit=864 read=9375
Planning Time: 0.096 ms
Execution Time: 28.798 ms

b-tree index
Finalize Aggregate  (cost=7425.87..7425.88 rows=1 width=8) (actual time=17.983..21.035 rows=1 loops=1)
Buffers: shared hit=963
->  Gather  (cost=7425.66..7425.87 rows=2 width=8) (actual time=17.809..21.025 rows=3 loops=1)
Workers Planned: 2
Workers Launched: 2
Buffers: shared hit=963
->  Partial Aggregate  (cost=6425.66..6425.67 rows=1 width=8) (actual time=13.064..13.065 rows=1 loops=3)
Buffers: shared hit=963
->  Parallel Index Only Scan using idx_items_name_btree on items  (cost=0.42..6412.50 rows=5261 width=0) (actual time=7.954..12.824 rows=3704 loops=3)
Filter: ((name)::text ~~ 'item_12%'::text)
Rows Removed by Filter: 79630
Heap Fetches: 0
Buffers: shared hit=963
Planning Time: 0.085 ms
Execution Time: 21.071 ms

hash index
Finalize Aggregate  (cost=12554.45..12554.46 rows=1 width=8) (actual time=25.545..29.845 rows=1 loops=1)
Buffers: shared hit=1888 read=8351
->  Gather  (cost=12554.24..12554.45 rows=2 width=8) (actual time=25.383..29.835 rows=3 loops=1)
Workers Planned: 2
Workers Launched: 2
Buffers: shared hit=1888 read=8351
->  Partial Aggregate  (cost=11554.24..11554.25 rows=1 width=8) (actual time=20.240..20.241 rows=1 loops=3)
Buffers: shared hit=1888 read=8351
->  Parallel Seq Scan on items  (cost=0.00..11541.08 rows=5261 width=0) (actual time=3.746..19.984 rows=3704 loops=3)
Filter: ((name)::text ~~ 'item_12%'::text)
Rows Removed by Filter: 79630
Buffers: shared hit=1888 read=8351
Planning Time: 0.093 ms
Execution Time: 29.921 ms



СОСТАВНОЙ ON marketplace.purchases (buyer_id, purchase_date)

EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.purchases
WHERE buyer_id = 200000
AND purchase_date < timestamp '2025-02-01';

без
Aggregate  (cost=5288.98..5288.99 rows=1 width=8) (actual time=15.209..20.152 rows=1 loops=1)
Buffers: shared hit=2083
->  Gather  (cost=1000.00..5288.98 rows=1 width=0) (actual time=15.204..20.146 rows=0 loops=1)
Workers Planned: 1
Workers Launched: 1
Buffers: shared hit=2083
->  Parallel Seq Scan on purchases  (cost=0.00..4288.88 rows=1 width=0) (actual time=10.716..10.717 rows=0 loops=2)
Filter: ((purchase_date < '2025-02-01 00:00:00'::timestamp without time zone) AND (buyer_id = 200000))
Rows Removed by Filter: 125000
Buffers: shared hit=2083
Planning Time: 0.076 ms
Execution Time: 20.183 ms

с
Aggregate  (cost=4.44..4.45 rows=1 width=8) (actual time=0.030..0.031 rows=1 loops=1)
Buffers: shared hit=3
->  Index Only Scan using idx_purchases_buyer_date_btree on purchases  (cost=0.42..4.44 rows=1 width=0) (actual time=0.025..0.026 rows=0 loops=1)
Index Cond: ((buyer_id = 200000) AND (p
urchase_date < '2025-02-01 00:00:00'::timestamp without time zone))
Heap Fetches: 0
Buffers: shared hit=3
Planning Time: 0.161 ms
Execution Time: 0.061 ms

EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.purchases
WHERE buyer_id = 200000;

без
Finalize Aggregate  (cost=4921.36..4921.37 rows=1 width=8) (actual time=19.193..23.248 rows=1 loops=1)
Buffers: shared hit=2083
->  Gather  (cost=4921.25..4921.36 rows=1 width=8) (actual time=18.941..23.232 rows=2 loops=1)
Workers Planned: 1
Workers Launched: 1
Buffers: shared hit=2083
->  Partial Aggregate  (cost=3921.25..3921.26 rows=1 width=8) (actual time=13.572..13.574 rows=1 loops=2)
Buffers: shared hit=2083
->  Parallel Seq Scan on purchases  (cost=0.00..3921.24 rows=4 width=0) (actual time=13.563..13.563 rows=0 loops=2)
Filter: (buyer_id = 200000)
Rows Removed by Filter: 125000
Buffers: shared hit=2083
Planning Time: 0.095 ms
Execution Time: 23.290 ms

с
Aggregate  (cost=4.56..4.57 rows=1 width=8) (actual time=0.026..0.027 rows=1 loops=1)
Buffers: shared hit=3
->  Index Only Scan using idx_purchases_buyer_date_btree on purchases  (cost=0.42..4.54 rows=7 width=0) (actual time=0.022..0.022 rows=0 loops=1)
Index Cond: (buyer_id = 200000)
Heap Fetches: 0
Buffers: shared hit=3
Planning Time: 0.100 ms
Execution Time: 0.054 ms


EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.purchases
WHERE purchase_date > timestamp '2025-02-01';

без
Finalize Aggregate  (cost=5258.87..5258.88 rows=1 width=8) (actual time=33.128..37.801 rows=1 loops=1)
Buffers: shared hit=2083
->  Gather  (cost=5258.76..5258.87 rows=1 width=8) (actual time=32.912..37.790 rows=2 loops=1)
Workers Planned: 1
Workers Launched: 1
Buffers: shared hit=2083
->  Partial Aggregate  (cost=4258.76..4258.77 rows=1 width=8) (actual time=27.809..27.810 rows=1 loops=2)
Buffers: shared hit=2083
->  Parallel Seq Scan on purchases  (cost=0.00..3921.24 rows=135009 width=0) (actual time=0.023..18.499 rows=115119 loops=2)
Filter: (purchase_date > '2025-02-01 00:00:00'::timestamp without time zone)
Rows Removed by Filter: 9881
Buffers: shared hit=2083
Planning Time: 0.186 ms
Execution Time: 37.852 ms

с
Finalize Aggregate  (cost=5258.87..5258.88 rows=1 width=8) (actual time=39.857..45.900 rows=1 loops=1)
Buffers: shared hit=2083
->  Gather  (cost=5258.76..5258.87 rows=1 width=8) (actual time=39.641..45.882 rows=2 loops=1)
Workers Planned: 1
Workers Launched: 1
Buffers: shared hit=2083
->  Partial Aggregate  (cost=4258.76..4258.77 rows=1 width=8) (actual time=33.447..33.449 rows=1 loops=2)
Buffers: shared hit=2083
->  Parallel Seq Scan on purchases  (cost=0.00..3921.24 rows=135009 width=0) (actual time=0.021..22.557 rows=115119 loops=2)
Filter: (purchase_date > '2025-02-01 00:00:00'::timestamp without time zone)
Rows Removed by Filter: 9881
Buffers: shared hit=2083
Planning Time: 0.091 ms
Execution Time: 45.952 ms
