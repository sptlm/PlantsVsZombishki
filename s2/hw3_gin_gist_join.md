## GIN GIST
Для задания я решил сделать такие индексы 
```sql
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
```

Для проверки я написал 7 запросов(3 общих полнотекстовых и по 2 отдельных на jsonb для gin и tstzrange для gist)

### 1 запрос. GIN GIST Полнотекст, одно слово

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.items
WHERE to_tsvector('russian', coalesce(name,'') || ' ' || coalesce(description,'')) @@
    plainto_tsquery('russian', 'качество');
```
#### без индекса
```text
Finalize Aggregate  (cost=39105.10..39105.11 rows=1 width=8) (actual time=1350.233..1355.809 rows=1 loops=1)
  Buffers: shared hit=10489
  ->  Gather  (cost=39104.89..39105.10 rows=2 width=8) (actual time=1350.226..1355.803 rows=3 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        Buffers: shared hit=10489
        ->  Partial Aggregate  (cost=38104.89..38104.90 rows=1 width=8) (actual time=1339.554..1339.555 rows=1 loops=3)
              Buffers: shared hit=10489
              ->  Parallel Seq Scan on items  (cost=0.00..38103.58 rows=521 width=0) (actual time=5.984..1338.064 rows=9354 loops=3)
"                    Filter: (to_tsvector('russian'::regconfig, (((COALESCE(name, ''::character varying))::text || ' '::text) || COALESCE(description, ''::text))) @@ '''качеств'''::tsquery)"
                    Rows Removed by Filter: 73979
                    Buffers: shared hit=10489
Planning:
  Buffers: shared hit=2
Planning Time: 5.555 ms
Execution Time: 1356.176 ms

```

#### GIN
```text
Finalize Aggregate  (cost=14675.21..14675.22 rows=1 width=8) (actual time=20.608..25.527 rows=1 loops=1)
  Buffers: shared hit=9741
  ->  Gather  (cost=14674.99..14675.20 rows=2 width=8) (actual time=20.298..25.521 rows=3 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        Buffers: shared hit=9741
        ->  Partial Aggregate  (cost=13674.99..13675.00 rows=1 width=8) (actual time=12.744..12.746 rows=1 loops=3)
              Buffers: shared hit=9741
              ->  Parallel Bitmap Heap Scan on items  (cost=273.84..13645.71 rows=11712 width=0) (actual time=3.240..12.193 rows=9354 loops=3)
"                    Recheck Cond: (to_tsvector('russian'::regconfig, (((COALESCE(name, ''::character varying))::text || ' '::text) || COALESCE(description, ''::text))) @@ '''качеств'''::tsquery)"
                    Heap Blocks: exact=6366
                    Buffers: shared hit=9741
                    ->  Bitmap Index Scan on items_fts_gin  (cost=0.00..266.81 rows=28108 width=0) (actual time=7.758..7.758 rows=28063 loops=1)
"                          Index Cond: (to_tsvector('russian'::regconfig, (((COALESCE(name, ''::character varying))::text || ' '::text) || COALESCE(description, ''::text))) @@ '''качеств'''::tsquery)"
                          Buffers: shared hit=10
Planning:
  Buffers: shared hit=18
Planning Time: 0.527 ms
Execution Time: 26.279 ms

```

#### GIST
```text
Finalize Aggregate  (cost=15568.74..15568.75 rows=1 width=8) (actual time=204.086..216.684 rows=1 loops=1)
  Buffers: shared hit=11829 read=1
  ->  Gather  (cost=15568.53..15568.74 rows=2 width=8) (actual time=203.645..216.677 rows=3 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        Buffers: shared hit=11829 read=1
        ->  Partial Aggregate  (cost=14568.53..14568.54 rows=1 width=8) (actual time=184.241..184.242 rows=1 loops=3)
              Buffers: shared hit=11829 read=1
              ->  Parallel Bitmap Heap Scan on items  (cost=1087.61..14538.51 rows=12007 width=0) (actual time=10.504..183.401 rows=9354 loops=3)
"                    Recheck Cond: (to_tsvector('russian'::regconfig, (((COALESCE(name, ''::character varying))::text || ' '::text) || COALESCE(description, ''::text))) @@ '''качеств'''::tsquery)"
                    Heap Blocks: exact=3507
                    Buffers: shared hit=11829 read=1
                    ->  Bitmap Index Scan on items_fts_gist  (cost=0.00..1080.41 rows=28817 width=0) (actual time=27.087..27.088 rows=28063 loops=1)
"                          Index Cond: (to_tsvector('russian'::regconfig, (((COALESCE(name, ''::character varying))::text || ' '::text) || COALESCE(description, ''::text))) @@ '''качеств'''::tsquery)"
                          Buffers: shared hit=1848 read=1
Planning:
  Buffers: shared hit=5
Planning Time: 0.243 ms
Execution Time: 216.725 ms

```

### 2 запрос. GIN GIST Полнотекст, AND

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.items
WHERE to_tsvector('russian', coalesce(name,'') || ' ' || coalesce(description,'')) @@
    to_tsquery('russian', 'скидка & надёжный');
```
#### без индекса
```text
Finalize Aggregate  (cost=39103.80..39103.81 rows=1 width=8) (actual time=1354.685..1360.068 rows=1 loops=1)
  Buffers: shared hit=10489
  ->  Gather  (cost=39103.59..39103.80 rows=2 width=8) (actual time=1354.678..1360.062 rows=3 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        Buffers: shared hit=10489
        ->  Partial Aggregate  (cost=38103.59..38103.60 rows=1 width=8) (actual time=1349.081..1349.082 rows=1 loops=3)
              Buffers: shared hit=10489
              ->  Parallel Seq Scan on items  (cost=0.00..38103.58 rows=2 width=0) (actual time=1.285..1348.592 rows=1189 loops=3)
"                    Filter: (to_tsvector('russian'::regconfig, (((COALESCE(name, ''::character varying))::text || ' '::text) || COALESCE(description, ''::text))) @@ '''скидк'' & ''надежн'''::tsquery)"
                    Rows Removed by Filter: 82145
                    Buffers: shared hit=10489
Planning Time: 0.567 ms
Execution Time: 1360.099 ms

```

#### GIN
```text
Aggregate  (cost=7626.35..7626.36 rows=1 width=8) (actual time=7.387..7.388 rows=1 loops=1)
  Buffers: shared hit=3060
  ->  Bitmap Heap Scan on items  (cost=56.55..7618.43 rows=3168 width=0) (actual time=3.927..7.106 rows=3566 loops=1)
"        Recheck Cond: (to_tsvector('russian'::regconfig, (((COALESCE(name, ''::character varying))::text || ' '::text) || COALESCE(description, ''::text))) @@ '''скидк'' & ''надежн'''::tsquery)"
        Heap Blocks: exact=3039
        Buffers: shared hit=3060
        ->  Bitmap Index Scan on items_fts_gin  (cost=0.00..55.76 rows=3168 width=0) (actual time=3.571..3.571 rows=3566 loops=1)
"              Index Cond: (to_tsvector('russian'::regconfig, (((COALESCE(name, ''::character varying))::text || ' '::text) || COALESCE(description, ''::text))) @@ '''скидк'' & ''надежн'''::tsquery)"
              Buffers: shared hit=21
Planning:
  Buffers: shared hit=1
Planning Time: 0.116 ms
Execution Time: 7.420 ms

```

#### GIST
```text
Aggregate  (cost=7682.56..7682.57 rows=1 width=8) (actual time=81.913..81.915 rows=1 loops=1)
  Buffers: shared hit=4865
  ->  Bitmap Heap Scan on items  (cost=120.80..7674.65 rows=3163 width=0) (actual time=16.023..81.551 rows=3566 loops=1)
"        Recheck Cond: (to_tsvector('russian'::regconfig, (((COALESCE(name, ''::character varying))::text || ' '::text) || COALESCE(description, ''::text))) @@ '''скидк'' & ''надежн'''::tsquery)"
        Heap Blocks: exact=3039
        Buffers: shared hit=4865
        ->  Bitmap Index Scan on items_fts_gist  (cost=0.00..120.00 rows=3163 width=0) (actual time=15.601..15.602 rows=3566 loops=1)
"              Index Cond: (to_tsvector('russian'::regconfig, (((COALESCE(name, ''::character varying))::text || ' '::text) || COALESCE(description, ''::text))) @@ '''скидк'' & ''надежн'''::tsquery)"
              Buffers: shared hit=1826
Planning Time: 0.105 ms
Execution Time: 81.949 ms

```

### 3 запрос. GIN GIST Полнотекст, OR

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.items
WHERE to_tsvector('russian', coalesce(name,'') || ' ' || coalesce(description,'')) @@
    to_tsquery('russian', 'новинка | премиум');
```
#### без индекса
```text
Finalize Aggregate  (cost=39106.40..39106.41 rows=1 width=8) (actual time=1333.649..1338.930 rows=1 loops=1)
  Buffers: shared hit=10489
  ->  Gather  (cost=39106.18..39106.39 rows=2 width=8) (actual time=1333.439..1338.904 rows=3 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        Buffers: shared hit=10489
        ->  Partial Aggregate  (cost=38106.18..38106.19 rows=1 width=8) (actual time=1328.065..1328.066 rows=1 loops=3)
              Buffers: shared hit=10489
              ->  Parallel Seq Scan on items  (cost=0.00..38103.58 rows=1039 width=0) (actual time=0.479..1325.891 rows=18880 loops=3)
"                    Filter: (to_tsvector('russian'::regconfig, (((COALESCE(name, ''::character varying))::text || ' '::text) || COALESCE(description, ''::text))) @@ '''новинк'' | ''премиум'''::tsquery)"
                    Rows Removed by Filter: 64453
                    Buffers: shared hit=10489
Planning Time: 0.095 ms
Execution Time: 1338.986 ms

```

#### GIN
```text
Finalize Aggregate  (cost=17801.48..17801.49 rows=1 width=8) (actual time=25.892..31.205 rows=1 loops=1)
  Buffers: shared hit=10244
  ->  Gather  (cost=17801.26..17801.47 rows=2 width=8) (actual time=25.523..31.196 rows=3 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        Buffers: shared hit=10244
        ->  Partial Aggregate  (cost=16801.26..16801.27 rows=1 width=8) (actual time=19.069..19.070 rows=1 loops=3)
              Buffers: shared hit=10244
              ->  Parallel Bitmap Heap Scan on items  (cost=520.23..16745.32 rows=22378 width=0) (actual time=5.799..18.019 rows=18880 loops=3)
"                    Recheck Cond: (to_tsvector('russian'::regconfig, (((COALESCE(name, ''::character varying))::text || ' '::text) || COALESCE(description, ''::text))) @@ '''новинк'' | ''премиум'''::tsquery)"
                    Heap Blocks: exact=5743
                    Buffers: shared hit=10244
                    ->  Bitmap Index Scan on items_fts_gin  (cost=0.00..506.80 rows=53707 width=0) (actual time=9.872..9.872 rows=56640 loops=1)
"                          Index Cond: (to_tsvector('russian'::regconfig, (((COALESCE(name, ''::character varying))::text || ' '::text) || COALESCE(description, ''::text))) @@ '''новинк'' | ''премиум'''::tsquery)"
                          Buffers: shared hit=19
Planning:
  Buffers: shared hit=1
Planning Time: 0.116 ms
Execution Time: 31.245 ms

```

#### GIST
```text
Finalize Aggregate  (cost=19329.24..19329.25 rows=1 width=8) (actual time=398.901..410.488 rows=1 loops=1)
  Buffers: shared hit=12307 read=37
  ->  Gather  (cost=19329.03..19329.24 rows=2 width=8) (actual time=398.629..410.479 rows=3 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        Buffers: shared hit=12307 read=37
        ->  Partial Aggregate  (cost=18329.03..18329.04 rows=1 width=8) (actual time=392.367..392.369 rows=1 loops=3)
              Buffers: shared hit=12307 read=37
              ->  Parallel Bitmap Heap Scan on items  (cost=2029.77..18272.92 rows=22445 width=0) (actual time=21.492..390.454 rows=18880 loops=3)
"                    Recheck Cond: (to_tsvector('russian'::regconfig, (((COALESCE(name, ''::character varying))::text || ' '::text) || COALESCE(description, ''::text))) @@ '''новинк'' | ''премиум'''::tsquery)"
                    Heap Blocks: exact=3489
                    Buffers: shared hit=12307 read=37
                    ->  Bitmap Index Scan on items_fts_gist  (cost=0.00..2016.30 rows=53869 width=0) (actual time=24.711..24.712 rows=56640 loops=1)
"                          Index Cond: (to_tsvector('russian'::regconfig, (((COALESCE(name, ''::character varying))::text || ' '::text) || COALESCE(description, ''::text))) @@ '''новинк'' | ''премиум'''::tsquery)"
                          Buffers: shared hit=1869
Planning Time: 0.123 ms
Execution Time: 410.539 ms

```

### 4 запрос. GIN JSONB containment

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.items
WHERE attributes @> '{"brand":"brand_1","color":"black"}';
```
#### без индекса
```text
Finalize Aggregate  (cost=12543.29..12543.30 rows=1 width=8) (actual time=33.622..39.011 rows=1 loops=1)
  Buffers: shared hit=10239
  ->  Gather  (cost=12543.07..12543.28 rows=2 width=8) (actual time=33.490..39.004 rows=3 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        Buffers: shared hit=10239
        ->  Partial Aggregate  (cost=11543.07..11543.08 rows=1 width=8) (actual time=28.582..28.584 rows=1 loops=3)
              Buffers: shared hit=10239
              ->  Parallel Seq Scan on items  (cost=0.00..11541.08 rows=795 width=0) (actual time=0.073..28.466 rows=1170 loops=3)
"                    Filter: (attributes @> '{""brand"": ""brand_1"", ""color"": ""black""}'::jsonb)"
                    Rows Removed by Filter: 82164
                    Buffers: shared hit=10239
Planning:
  Buffers: shared hit=5
Planning Time: 0.226 ms
Execution Time: 39.043 ms

```

#### GIN
```text
Aggregate  (cost=3414.98..3414.99 rows=1 width=8) (actual time=10.352..10.354 rows=1 loops=1)
  Buffers: shared hit=3148
  ->  Bitmap Heap Scan on items  (cost=69.04..3412.07 rows=1166 width=0) (actual time=5.502..10.152 rows=3509 loops=1)
"        Recheck Cond: (attributes @> '{""brand"": ""brand_1"", ""color"": ""black""}'::jsonb)"
        Heap Blocks: exact=2983
        Buffers: shared hit=3148
        ->  Bitmap Index Scan on items_attr_gin  (cost=0.00..68.75 rows=1166 width=0) (actual time=5.124..5.124 rows=3509 loops=1)
"              Index Cond: (attributes @> '{""brand"": ""brand_1"", ""color"": ""black""}'::jsonb)"
              Buffers: shared hit=165
Planning:
  Buffers: shared hit=8
Planning Time: 0.157 ms
Execution Time: 10.384 ms

```


### 5 запрос. GIN JSONB path
 
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.items
WHERE attributes @? '$.warranty_months ? (@ >= 27 && @ <= 28)';
```
#### без индекса
```text
Finalize Aggregate  (cost=12559.78..12559.79 rows=1 width=8) (actual time=49.410..54.564 rows=1 loops=1)
  Buffers: shared hit=10239
  ->  Gather  (cost=12559.56..12559.77 rows=2 width=8) (actual time=49.274..54.556 rows=3 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        Buffers: shared hit=10239
        ->  Partial Aggregate  (cost=11559.56..11559.57 rows=1 width=8) (actual time=44.336..44.337 rows=1 loops=3)
              Buffers: shared hit=10239
              ->  Parallel Seq Scan on items  (cost=0.00..11541.08 rows=7391 width=0) (actual time=0.030..44.013 rows=4627 loops=3)
"                    Filter: (attributes @? '$.""warranty_months""?(@ >= 27 && @ <= 28)'::jsonpath)"
                    Rows Removed by Filter: 78707
                    Buffers: shared hit=10239
Planning Time: 0.269 ms
Execution Time: 54.598 ms

```


#### GIN
```text
Finalize Aggregate  (cost=12554.75..12554.76 rows=1 width=8) (actual time=48.649..53.967 rows=1 loops=1)
  Buffers: shared hit=10239
  ->  Gather  (cost=12554.53..12554.74 rows=2 width=8) (actual time=48.500..53.960 rows=3 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        Buffers: shared hit=10239
        ->  Partial Aggregate  (cost=11554.53..11554.54 rows=1 width=8) (actual time=42.871..42.872 rows=1 loops=3)
              Buffers: shared hit=10239
              ->  Parallel Seq Scan on items  (cost=0.00..11541.08 rows=5379 width=0) (actual time=0.028..42.536 rows=4627 loops=3)
"                    Filter: (attributes @? '$.""warranty_months""?(@ >= 27 && @ <= 28)'::jsonpath)"
                    Rows Removed by Filter: 78707
                    Buffers: shared hit=10239
Planning:
  Buffers: shared hit=1
Planning Time: 0.171 ms
Execution Time: 54.000 ms

```

### 6 запрос. GIST пересечение TSTZRANGE через &&

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.orders
WHERE delivery_slot &&
      tstzrange(
        timestamptz '2025-03-10 10:00:00+03',
        timestamptz '2025-03-10 18:00:00+03',
        '[)'
      );
```
#### без индекса
```text
Finalize Aggregate  (cost=5679.81..5679.82 rows=1 width=8) (actual time=154.255..159.102 rows=1 loops=1)
  Buffers: shared hit=2157 read=712
  ->  Gather  (cost=5679.70..5679.81 rows=1 width=8) (actual time=154.248..159.096 rows=2 loops=1)
        Workers Planned: 1
        Workers Launched: 1
        Buffers: shared hit=2157 read=712
        ->  Partial Aggregate  (cost=4679.70..4679.71 rows=1 width=8) (actual time=150.807..150.808 rows=1 loops=2)
              Buffers: shared hit=2157 read=712
              ->  Parallel Seq Scan on orders  (cost=0.00..4679.24 rows=185 width=0) (actual time=5.470..150.701 rows=162 loops=2)
"                    Filter: (delivery_slot && '[""2025-03-10 07:00:00+00"",""2025-03-10 15:00:00+00"")'::tstzrange)"
                    Rows Removed by Filter: 124838
                    Buffers: shared hit=2157 read=712
Planning:
  Buffers: shared hit=5
Planning Time: 1.522 ms
Execution Time: 159.234 ms

```

#### GIST
```text
Aggregate  (cost=18.58..18.59 rows=1 width=8) (actual time=0.217..0.218 rows=1 loops=1)
  Buffers: shared hit=6
  ->  Index Only Scan using orders_delivery_slot_gist on orders  (cost=0.28..17.79 rows=315 width=0) (actual time=0.130..0.193 rows=325 loops=1)
"        Index Cond: (delivery_slot && '[""2025-03-10 07:00:00+00"",""2025-03-10 15:00:00+00"")'::tstzrange)"
        Heap Fetches: 0
        Buffers: shared hit=6
Planning:
  Buffers: shared hit=16
Planning Time: 0.270 ms
Execution Time: 0.419 ms

```

### 7 запрос. GIST @> для TSTZRANGE

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.orders
WHERE delivery_slot @> timestamptz '2025-03-10 12:30:00+03';
```
#### без индекса
```text
Finalize Aggregate  (cost=5679.50..5679.51 rows=1 width=8) (actual time=21.098..25.792 rows=1 loops=1)
  Buffers: shared hit=2869
  ->  Gather  (cost=5679.39..5679.50 rows=1 width=8) (actual time=20.888..25.784 rows=2 loops=1)
        Workers Planned: 1
        Workers Launched: 1
        Buffers: shared hit=2869
        ->  Partial Aggregate  (cost=4679.39..4679.40 rows=1 width=8) (actual time=16.959..16.960 rows=1 loops=2)
              Buffers: shared hit=2869
              ->  Parallel Seq Scan on orders  (cost=0.00..4679.24 rows=62 width=0) (actual time=0.611..16.943 rows=50 loops=2)
                    Filter: (delivery_slot @> '2025-03-10 09:30:00+00'::timestamp with time zone)
                    Rows Removed by Filter: 124950
                    Buffers: shared hit=2869
Planning Time: 0.075 ms
Execution Time: 25.823 ms

```

#### GIST
```text
Aggregate  (cost=6.38..6.39 rows=1 width=8) (actual time=0.081..0.082 rows=1 loops=1)
  Buffers: shared hit=4
  ->  Index Only Scan using orders_delivery_slot_gist on orders  (cost=0.28..6.12 rows=105 width=0) (actual time=0.066..0.072 rows=99 loops=1)
        Index Cond: (delivery_slot @> '2025-03-10 09:30:00+00'::timestamp with time zone)
        Heap Fetches: 0
        Buffers: shared hit=4
Planning Time: 0.077 ms
Execution Time: 0.100 ms

```


## JOIN

### 1 запрос. Маленький диапазон по PK, обычно удобно для Nested Loop
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT p.purchase_id, o.order_id, o.status
FROM marketplace.purchases p
         JOIN marketplace.orders o
              ON o.purchase_id = p.purchase_id
WHERE p.purchase_id BETWEEN 1000 AND 1100;
```
Результат: 
```text
Nested Loop  (cost=0.84..860.46 rows=105 width=18) (actual time=2.710..5.464 rows=101 loops=1)
  Buffers: shared hit=403 read=6
  ->  Index Only Scan using purchases_pkey on purchases p  (cost=0.42..6.52 rows=105 width=4) (actual time=0.277..0.765 rows=101 loops=1)
        Index Cond: ((purchase_id >= 1000) AND (purchase_id <= 1100))
        Heap Fetches: 0
        Buffers: shared hit=3 read=2
  ->  Index Scan using orders_purchase_id_key on orders o  (cost=0.42..8.13 rows=1 width=18) (actual time=0.042..0.042 rows=1 loops=101)
        Index Cond: (purchase_id = p.purchase_id)
        Buffers: shared hit=400 read=4
Planning:
  Buffers: shared hit=198 read=18 dirtied=1
Planning Time: 41.496 ms
Execution Time: 6.848 ms

```
### 2 запрос. Большой equality join двух крупных таблиц, часто Hash Join
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.purchases p
         JOIN marketplace.items i
              ON i.item_id = p.item_id
WHERE p.status = 'completed';
```
Результат:
```text
Finalize Aggregate  (cost=11942.77..11942.78 rows=1 width=8) (actual time=520.982..529.989 rows=1 loops=1)
  Buffers: shared hit=67 read=2764
  ->  Gather  (cost=11942.66..11942.77 rows=1 width=8) (actual time=520.219..529.956 rows=2 loops=1)
        Workers Planned: 1
        Workers Launched: 1
        Buffers: shared hit=67 read=2764
        ->  Partial Aggregate  (cost=10942.66..10942.67 rows=1 width=8) (actual time=505.614..505.617 rows=1 loops=2)
              Buffers: shared hit=67 read=2764
              ->  Parallel Hash Join  (cost=6342.17..10611.32 rows=132534 width=0) (actual time=200.492..499.013 rows=112562 loops=2)
                    Hash Cond: (p.item_id = i.item_id)
                    Buffers: shared hit=67 read=2764
                    ->  Parallel Seq Scan on purchases p  (cost=0.00..3921.24 rows=132534 width=4) (actual time=0.799..247.915 rows=112562 loops=2)
                          Filter: ((status)::text = 'completed'::text)
                          Rows Removed by Filter: 12438
                          Buffers: shared read=2083
                    ->  Parallel Hash  (cost=5040.09..5040.09 rows=104167 width=4) (actual time=194.778..194.779 rows=125000 loops=2)
                          Buckets: 262144  Batches: 1  Memory Usage: 11840kB
                          Buffers: shared hit=6 read=681
                          ->  Parallel Index Only Scan using items_pkey on items i  (cost=0.42..5040.09 rows=104167 width=4) (actual time=0.132..148.030 rows=125000 loops=2)
                                Heap Fetches: 0
                                Buffers: shared hit=6 read=681
Planning:
  Buffers: shared hit=44 read=7
Planning Time: 8.850 ms
Execution Time: 531.452 ms

```
### 3 запрос. Ещё один крупный equality join, но с другой селективностью
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.items i
         JOIN marketplace.shops s
              ON s.shop_id = i.shop_id
WHERE i.price > 4000;
```
Результат:
```text
Finalize Aggregate  (cost=12936.95..12936.96 rows=1 width=8) (actual time=345.346..351.229 rows=1 loops=1)
  Buffers: shared hit=10485 read=62
  ->  Gather  (cost=12936.74..12936.95 rows=2 width=8) (actual time=345.045..351.222 rows=3 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        Buffers: shared hit=10485 read=62
        ->  Partial Aggregate  (cost=11936.74..11936.75 rows=1 width=8) (actual time=339.611..339.612 rows=1 loops=3)
              Buffers: shared hit=10485 read=62
              ->  Hash Join  (cost=287.00..11883.75 rows=21196 width=0) (actual time=11.899..336.915 rows=16709 loops=3)
                    Hash Cond: (i.shop_id = s.shop_id)
                    Buffers: shared hit=10485 read=62
                    ->  Parallel Seq Scan on items i  (cost=0.00..11541.08 rows=21196 width=4) (actual time=0.240..313.147 rows=16709 loops=3)
                          Filter: (price > '4000'::numeric)
                          Rows Removed by Filter: 66625
                          Buffers: shared hit=10239
                    ->  Hash  (cost=162.00..162.00 rows=10000 width=4) (actual time=11.422..11.423 rows=10000 loops=3)
                          Buckets: 16384  Batches: 1  Memory Usage: 480kB
                          Buffers: shared hit=124 read=62
                          ->  Seq Scan on shops s  (cost=0.00..162.00 rows=10000 width=4) (actual time=0.213..9.360 rows=10000 loops=3)
                                Buffers: shared hit=124 read=62
Planning:
  Buffers: shared hit=51 read=9 dirtied=1
Planning Time: 6.566 ms
Execution Time: 351.482 ms

```
### 4 запрос. Соединение с сортировкой по ключу join, кандидат на Merge Join
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT p.purchase_id, o.order_id
FROM marketplace.purchases p
         JOIN marketplace.orders o
              ON o.purchase_id = p.purchase_id
ORDER BY p.purchase_id;
```
Результат:
```text
Merge Join  (cost=1.12..19590.36 rows=250000 width=8) (actual time=0.863..395.853 rows=250000 loops=1)
  Merge Cond: (p.purchase_id = o.purchase_id)
  Buffers: shared hit=839 read=3373
  ->  Index Only Scan using purchases_pkey on purchases p  (cost=0.42..6498.42 rows=250000 width=4) (actual time=0.018..69.953 rows=250000 loops=1)
        Heap Fetches: 0
        Buffers: shared hit=7 read=679
  ->  Index Scan using orders_purchase_id_key on orders o  (cost=0.42..9342.42 rows=250000 width=8) (actual time=0.764..263.187 rows=250000 loops=1)
        Buffers: shared hit=832 read=2694
Planning:
  Buffers: shared hit=16
Planning Time: 0.178 ms
Execution Time: 409.207 ms

```
### 5 запрос. Тройной join
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*)
FROM marketplace.buyers b
         JOIN marketplace.purchases p
              ON p.buyer_id = b.buyer_id
         JOIN marketplace.orders o
              ON o.purchase_id = p.purchase_id
WHERE b.email IS NOT NULL
  AND o.status = 'delivered';
```
Результат:
```text
Finalize Aggregate  (cost=18450.40..18450.41 rows=1 width=8) (actual time=415.719..431.694 rows=1 loops=1)
  Buffers: shared hit=3314 read=5871
  ->  Gather  (cost=18450.29..18450.40 rows=1 width=8) (actual time=414.412..431.686 rows=2 loops=1)
        Workers Planned: 1
        Workers Launched: 1
        Buffers: shared hit=3314 read=5871
        ->  Partial Aggregate  (cost=17450.29..17450.30 rows=1 width=8) (actual time=409.744..409.748 rows=1 loops=2)
              Buffers: shared hit=3314 read=5871
              ->  Parallel Hash Join  (cost=12868.51..17137.05 rows=125294 width=0) (actual time=279.061..403.177 rows=107192 loops=2)
                    Hash Cond: (p.purchase_id = o.purchase_id)
                    Buffers: shared hit=3314 read=5871
                    ->  Parallel Hash Join  (cost=6351.04..10290.67 rows=125294 width=4) (actual time=197.186..274.671 rows=107192 loops=2)
                          Hash Cond: (p.buyer_id = b.buyer_id)
                          Buffers: shared hit=835 read=5448
                          ->  Parallel Seq Scan on purchases p  (cost=0.00..3553.59 rows=147059 width=8) (actual time=0.006..17.883 rows=125000 loops=2)
                                Buffers: shared hit=835 read=1248
                          ->  Parallel Hash  (cost=5241.67..5241.67 rows=88750 width=4) (actual time=189.115..189.115 rows=106282 loops=2)
                                Buckets: 262144  Batches: 1  Memory Usage: 10400kB
                                Buffers: shared read=4200
                                ->  Parallel Seq Scan on buyers b  (cost=0.00..5241.67 rows=88750 width=4) (actual time=1.292..137.347 rows=106282 loops=2)
                                      Filter: (email IS NOT NULL)
                                      Rows Removed by Filter: 18718
                                      Buffers: shared read=4200
                    ->  Parallel Hash  (cost=4679.24..4679.24 rows=147059 width=4) (actual time=77.436..77.437 rows=125000 loops=2)
                          Buckets: 262144  Batches: 1  Memory Usage: 11872kB
                          Buffers: shared hit=2418 read=423
                          ->  Parallel Seq Scan on orders o  (cost=0.00..4679.24 rows=147059 width=4) (actual time=0.057..32.744 rows=125000 loops=2)
                                Filter: ((status)::text = 'delivered'::text)
                                Buffers: shared hit=2418 read=423
Planning:
  Buffers: shared hit=63 read=8
Planning Time: 6.579 ms
Execution Time: 431.737 ms
```