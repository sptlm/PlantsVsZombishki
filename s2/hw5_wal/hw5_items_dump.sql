--
-- PostgreSQL database dump
--

-- Dumped from database version 15.17 (Debian 15.17-1.pgdg13+1)
-- Dumped by pg_dump version 17.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: items; Type: TABLE; Schema: marketplace; Owner: admin
--

CREATE TABLE marketplace.items (
    item_id integer NOT NULL,
    shop_id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    category_id integer NOT NULL,
    price numeric(10,2) NOT NULL,
    attributes jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT items_price_check CHECK ((price >= (0)::numeric))
);


ALTER TABLE marketplace.items OWNER TO admin;

--
-- Name: items_item_id_seq; Type: SEQUENCE; Schema: marketplace; Owner: admin
--

CREATE SEQUENCE marketplace.items_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE marketplace.items_item_id_seq OWNER TO admin;

--
-- Name: items_item_id_seq; Type: SEQUENCE OWNED BY; Schema: marketplace; Owner: admin
--

ALTER SEQUENCE marketplace.items_item_id_seq OWNED BY marketplace.items.item_id;


--
-- Name: items item_id; Type: DEFAULT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.items ALTER COLUMN item_id SET DEFAULT nextval('marketplace.items_item_id_seq'::regclass);


--
-- Data for Name: items; Type: TABLE DATA; Schema: marketplace; Owner: admin
--

COPY marketplace.items (item_id, shop_id, name, description, category_id, price, attributes) FROM stdin;
2	757	item_2	Описание товара 2: скидка популярный. текст текст текст текст текст текст текст текст текст текст 	10	472.69	{"brand": "brand_25", "color": "red", "rating_bucket": "high", "warranty_months": 36}
3	5314	item_3	Описание товара 3: хит стильный. текст текст текст текст текст текст текст текст текст текст 	18	3487.69	{"brand": "brand_191", "color": "blue", "rating_bucket": "low", "warranty_months": 24}
4	1	item_4	Описание товара 4: новинка удобный. текст текст текст текст текст текст текст текст текст текст 	86	2012.95	{"brand": "brand_119", "color": "green", "rating_bucket": "mid", "warranty_months": 18}
5	862	item_5	Описание товара 5: премиум универсальный. текст текст текст текст текст текст текст текст текст текст 	35	1657.87	{"brand": "brand_157", "color": "red", "rating_bucket": "mid", "warranty_months": 12}
6	1	item_6	Описание товара 6: качество популярный. текст текст текст текст текст текст текст текст текст текст 	16	4232.28	{"brand": "brand_1", "color": "green", "rating_bucket": "high", "warranty_months": 35}
7	2977	item_7	Описание товара 7: новинка надёжный. текст текст текст текст текст текст текст текст текст текст 	70	3521.42	{"brand": "brand_31", "color": "white", "rating_bucket": "mid", "warranty_months": 36}
8	262	item_8	Описание товара 8: доставка популярный. текст текст текст текст текст текст текст текст текст текст 	69	1200.98	{"brand": "brand_135", "color": "white", "rating_bucket": "low", "warranty_months": 21}
9	5967	item_9	Описание товара 9: акция прочный. текст текст текст текст текст текст текст текст текст текст 	42	1776.94	{"brand": "brand_40", "color": "black", "rating_bucket": "low", "warranty_months": 17}
10	9169	item_10	Описание товара 10: доставка прочный. текст текст текст текст текст текст текст текст текст текст 	74	1349.44	{"brand": "brand_9", "color": "green", "rating_bucket": "high", "warranty_months": 24}
11	209	item_11	Описание товара 11: качество универсальный. текст текст текст текст текст текст текст текст текст текст 	41	2991.43	{"brand": "brand_58", "color": "red", "rating_bucket": "mid", "warranty_months": 13}
12	142	item_12	Описание товара 12: качество удобный. текст текст текст текст текст текст текст текст текст текст 	97	266.53	{"brand": "brand_133", "color": "white", "rating_bucket": "mid", "warranty_months": 28}
13	833	item_13	Описание товара 13: премиум универсальный. текст текст текст текст текст текст текст текст текст текст 	67	2538.38	{"brand": "brand_3", "color": "blue", "rating_bucket": "low", "warranty_months": 20}
14	933	item_14	Описание товара 14: скидка стильный. текст текст текст текст текст текст текст текст текст текст 	92	4745.98	{"brand": "brand_27", "color": "blue", "rating_bucket": "mid", "warranty_months": 31}
15	1	item_15	Описание товара 15: хит популярный. текст текст текст текст текст текст текст текст текст текст 	61	821.78	{"brand": "brand_1", "color": "red", "rating_bucket": "mid", "warranty_months": 37}
16	1	item_16	Описание товара 16: хит удобный. текст текст текст текст текст текст текст текст текст текст 	91	3558.70	{"brand": "brand_6", "color": "white", "rating_bucket": "high", "warranty_months": 29}
17	106	item_17	Описание товара 17: премиум лёгкий. текст текст текст текст текст текст текст текст текст текст 	69	353.44	{"brand": "brand_8", "color": "red", "rating_bucket": "mid", "warranty_months": 32}
18	778	item_18	Описание товара 18: качество прочный. текст текст текст текст текст текст текст текст текст текст 	77	210.45	{"brand": "brand_192", "color": "white", "rating_bucket": "low", "warranty_months": 16}
19	21	item_19	\N	31	3322.87	{"brand": "brand_19", "color": "black", "rating_bucket": "mid", "warranty_months": 7}
20	224	item_20	Описание товара 20: хит надёжный. текст текст текст текст текст текст текст текст текст текст 	18	278.99	{"brand": "brand_34", "color": "blue", "rating_bucket": "high", "warranty_months": 41}
21	5008	item_21	Описание товара 21: акция популярный. текст текст текст текст текст текст текст текст текст текст 	86	1681.77	{"brand": "brand_165", "color": "black", "rating_bucket": "mid", "warranty_months": 24}
22	800	item_22	Описание товара 22: качество удобный. текст текст текст текст текст текст текст текст текст текст 	59	1269.91	{"brand": "brand_43", "color": "black", "rating_bucket": "mid", "warranty_months": 7}
23	5981	item_23	Описание товара 23: доставка удобный. текст текст текст текст текст текст текст текст текст текст 	80	3077.52	{"brand": "brand_3", "color": "red", "rating_bucket": "low", "warranty_months": 10}
24	5697	item_24	Описание товара 24: скидка надёжный. текст текст текст текст текст текст текст текст текст текст 	14	1727.83	{"brand": "brand_94", "color": "blue", "rating_bucket": "mid", "warranty_months": 14}
731	1906	item_731	\N	59	1774.60	{"brand": "brand_23", "color": "white", "rating_bucket": "high", "warranty_months": 27}
25	5	item_25	Описание товара 25: скидка прочный. текст текст текст текст текст текст текст текст текст текст 	63	945.02	{"brand": "brand_60", "color": "red", "rating_bucket": "low", "warranty_months": 39}
26	3462	item_26	Описание товара 26: новинка лёгкий. текст текст текст текст текст текст текст текст текст текст 	4	1949.43	{"brand": "brand_11", "color": "green", "rating_bucket": "low", "warranty_months": 33}
27	8	item_27	Описание товара 27: хит удобный. текст текст текст текст текст текст текст текст текст текст 	24	1658.78	{"brand": "brand_164", "color": "blue", "rating_bucket": "high", "warranty_months": 15}
28	61	item_28	Описание товара 28: премиум выгодный. текст текст текст текст текст текст текст текст текст текст 	45	1348.26	{"brand": "brand_122", "color": "white", "rating_bucket": "low", "warranty_months": 40}
29	2182	item_29	Описание товара 29: качество популярный. текст текст текст текст текст текст текст текст текст текст 	20	2554.66	{"brand": "brand_143", "color": "red", "rating_bucket": "high", "warranty_months": 28}
30	399	item_30	Описание товара 30: хит лёгкий. текст текст текст текст текст текст текст текст текст текст 	68	1993.77	{"brand": "brand_59", "color": "blue", "rating_bucket": "low", "warranty_months": 34}
31	37	item_31	Описание товара 31: гарантия лёгкий. текст текст текст текст текст текст текст текст текст текст 	83	2329.78	{"brand": "brand_30", "color": "green", "rating_bucket": "low", "warranty_months": 40}
32	8158	item_32	Описание товара 32: новинка популярный. текст текст текст текст текст текст текст текст текст текст 	2	1658.50	{"brand": "brand_103", "color": "green", "rating_bucket": "high", "warranty_months": 18}
33	11	item_33	Описание товара 33: доставка прочный. текст текст текст текст текст текст текст текст текст текст 	78	4824.16	{"brand": "brand_24", "color": "blue", "rating_bucket": "high", "warranty_months": 24}
34	12	item_34	Описание товара 34: скидка стильный. текст текст текст текст текст текст текст текст текст текст 	11	2431.98	{"brand": "brand_16", "color": "green", "rating_bucket": "high", "warranty_months": 30}
35	286	item_35	Описание товара 35: доставка надёжный. текст текст текст текст текст текст текст текст текст текст 	8	1875.96	{"brand": "brand_1", "color": "red", "rating_bucket": "low", "warranty_months": 35}
36	19	item_36	Описание товара 36: доставка лёгкий. текст текст текст текст текст текст текст текст текст текст 	78	4651.23	{"brand": "brand_133", "color": "green", "rating_bucket": "mid", "warranty_months": 35}
37	7904	item_37	Описание товара 37: премиум универсальный. текст текст текст текст текст текст текст текст текст текст 	56	3346.58	{"brand": "brand_33", "color": "green", "rating_bucket": "low", "warranty_months": 22}
...
...
...
249991	758	item_249991	Описание товара 249991: доставка удобный. текст текст текст текст текст текст текст текст текст текст 	21	2655.01	{"brand": "brand_81", "color": "red", "rating_bucket": "low", "warranty_months": 25}
249992	207	item_249992	Описание товара 249992: акция универсальный. текст текст текст текст текст текст текст текст текст текст 	86	108.49	{"brand": "brand_72", "color": "blue", "rating_bucket": "high", "warranty_months": 18}
249993	5912	item_249993	Описание товара 249993: качество прочный. текст текст текст текст текст текст текст текст текст текст 	58	3284.79	{"brand": "brand_30", "color": "blue", "rating_bucket": "high", "warranty_months": 10}
249994	105	item_249994	Описание товара 249994: хит лёгкий. текст текст текст текст текст текст текст текст текст текст 	29	1260.82	{"brand": "brand_50", "color": "black", "rating_bucket": "mid", "warranty_months": 7}
249995	610	item_249995	Описание товара 249995: доставка популярный. текст текст текст текст текст текст текст текст текст текст 	34	2018.50	{"brand": "brand_47", "color": "white", "rating_bucket": "high", "warranty_months": 31}
249996	334	item_249996	Описание товара 249996: новинка прочный. текст текст текст текст текст текст текст текст текст текст 	23	2729.33	{"brand": "brand_155", "color": "red", "rating_bucket": "low", "warranty_months": 29}
249997	2781	item_249997	Описание товара 249997: гарантия надёжный. текст текст текст текст текст текст текст текст текст текст 	56	1944.11	{"brand": "brand_32", "color": "blue", "rating_bucket": "high", "warranty_months": 16}
249998	785	item_249998	Описание товара 249998: хит прочный. текст текст текст текст текст текст текст текст текст текст 	65	2878.76	{"brand": "brand_105", "color": "blue", "rating_bucket": "low", "warranty_months": 34}
249999	268	item_249999	\N	12	2015.57	{"brand": "brand_163", "color": "white", "rating_bucket": "high", "warranty_months": 37}
250000	7055	item_250000	Описание товара 250000: премиум стильный. текст текст текст текст текст текст текст текст текст текст 	62	1803.18	{"brand": "brand_1", "color": "red", "rating_bucket": "low", "warranty_months": 38}
1	2318	item_1	Описание товара 1: хит удобный. текст текст текст текст текст текст текст текст текст текст 	32	1137.14	{"brand": "brand_156", "color": "black", "rating_bucket": "high", "warranty_months": 13}
\.


--
-- Name: items_item_id_seq; Type: SEQUENCE SET; Schema: marketplace; Owner: admin
--

SELECT pg_catalog.setval('marketplace.items_item_id_seq', 250000, true);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (item_id);


--
-- Name: items items_category_id_fkey; Type: FK CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.items
    ADD CONSTRAINT items_category_id_fkey FOREIGN KEY (category_id) REFERENCES marketplace.category_of_item(category_id);


--
-- Name: items items_shop_id_fkey; Type: FK CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.items
    ADD CONSTRAINT items_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES marketplace.shops(shop_id);


--
-- PostgreSQL database dump complete
--

