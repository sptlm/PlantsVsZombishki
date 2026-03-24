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

--
-- Name: marketplace; Type: SCHEMA; Schema: -; Owner: admin
--

CREATE SCHEMA marketplace;


ALTER SCHEMA marketplace OWNER TO admin;

--
-- Name: pageinspect; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pageinspect WITH SCHEMA public;


--
-- Name: EXTENSION pageinspect; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pageinspect IS 'inspect the contents of database pages at a low level';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: buyers; Type: TABLE; Schema: marketplace; Owner: admin
--

CREATE TABLE marketplace.buyers (
    buyer_id integer NOT NULL,
    login character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    salt character varying(50) NOT NULL,
    email character varying(255)
);


ALTER TABLE marketplace.buyers OWNER TO admin;

--
-- Name: buyers_buyer_id_seq; Type: SEQUENCE; Schema: marketplace; Owner: admin
--

CREATE SEQUENCE marketplace.buyers_buyer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE marketplace.buyers_buyer_id_seq OWNER TO admin;

--
-- Name: buyers_buyer_id_seq; Type: SEQUENCE OWNED BY; Schema: marketplace; Owner: admin
--

ALTER SEQUENCE marketplace.buyers_buyer_id_seq OWNED BY marketplace.buyers.buyer_id;


--
-- Name: career_path; Type: TABLE; Schema: marketplace; Owner: admin
--

CREATE TABLE marketplace.career_path (
    path_id integer NOT NULL,
    current_profession_id integer NOT NULL,
    next_profession_id integer NOT NULL
);


ALTER TABLE marketplace.career_path OWNER TO admin;

--
-- Name: career_path_path_id_seq; Type: SEQUENCE; Schema: marketplace; Owner: admin
--

CREATE SEQUENCE marketplace.career_path_path_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE marketplace.career_path_path_id_seq OWNER TO admin;

--
-- Name: career_path_path_id_seq; Type: SEQUENCE OWNED BY; Schema: marketplace; Owner: admin
--

ALTER SEQUENCE marketplace.career_path_path_id_seq OWNED BY marketplace.career_path.path_id;


--
-- Name: category_of_item; Type: TABLE; Schema: marketplace; Owner: admin
--

CREATE TABLE marketplace.category_of_item (
    category_id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text
);


ALTER TABLE marketplace.category_of_item OWNER TO admin;

--
-- Name: category_of_item_category_id_seq; Type: SEQUENCE; Schema: marketplace; Owner: admin
--

CREATE SEQUENCE marketplace.category_of_item_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE marketplace.category_of_item_category_id_seq OWNER TO admin;

--
-- Name: category_of_item_category_id_seq; Type: SEQUENCE OWNED BY; Schema: marketplace; Owner: admin
--

ALTER SEQUENCE marketplace.category_of_item_category_id_seq OWNED BY marketplace.category_of_item.category_id;


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
-- Name: orders; Type: TABLE; Schema: marketplace; Owner: admin
--

CREATE TABLE marketplace.orders (
    order_id integer NOT NULL,
    purchase_id integer NOT NULL,
    pvz_id integer NOT NULL,
    status character varying(50) DEFAULT 'created'::character varying NOT NULL,
    order_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    delivery_slot tstzrange,
    delivered_at timestamp without time zone,
    CONSTRAINT orders_status_check CHECK (((status)::text = ANY ((ARRAY['created'::character varying, 'delivered'::character varying, 'cancelled'::character varying])::text[])))
);


ALTER TABLE marketplace.orders OWNER TO admin;

--
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: marketplace; Owner: admin
--

CREATE SEQUENCE marketplace.orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE marketplace.orders_order_id_seq OWNER TO admin;

--
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: marketplace; Owner: admin
--

ALTER SEQUENCE marketplace.orders_order_id_seq OWNED BY marketplace.orders.order_id;


--
-- Name: profession; Type: TABLE; Schema: marketplace; Owner: admin
--

CREATE TABLE marketplace.profession (
    profession_id integer NOT NULL,
    name character varying(255) NOT NULL,
    salary integer NOT NULL,
    CONSTRAINT profession_salary_check CHECK ((salary > 0))
);


ALTER TABLE marketplace.profession OWNER TO admin;

--
-- Name: profession_profession_id_seq; Type: SEQUENCE; Schema: marketplace; Owner: admin
--

CREATE SEQUENCE marketplace.profession_profession_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE marketplace.profession_profession_id_seq OWNER TO admin;

--
-- Name: profession_profession_id_seq; Type: SEQUENCE OWNED BY; Schema: marketplace; Owner: admin
--

ALTER SEQUENCE marketplace.profession_profession_id_seq OWNED BY marketplace.profession.profession_id;


--
-- Name: purchases; Type: TABLE; Schema: marketplace; Owner: admin
--

CREATE TABLE marketplace.purchases (
    purchase_id integer NOT NULL,
    item_id integer NOT NULL,
    buyer_id integer NOT NULL,
    purchase_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(50) DEFAULT 'completed'::character varying,
    CONSTRAINT purchases_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'completed'::character varying, 'cancelled'::character varying])::text[])))
);


ALTER TABLE marketplace.purchases OWNER TO admin;

--
-- Name: purchases_purchase_id_seq; Type: SEQUENCE; Schema: marketplace; Owner: admin
--

CREATE SEQUENCE marketplace.purchases_purchase_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE marketplace.purchases_purchase_id_seq OWNER TO admin;

--
-- Name: purchases_purchase_id_seq; Type: SEQUENCE OWNED BY; Schema: marketplace; Owner: admin
--

ALTER SEQUENCE marketplace.purchases_purchase_id_seq OWNED BY marketplace.purchases.purchase_id;


--
-- Name: pvz; Type: TABLE; Schema: marketplace; Owner: admin
--

CREATE TABLE marketplace.pvz (
    pvz_id integer NOT NULL,
    address character varying(255) NOT NULL
);


ALTER TABLE marketplace.pvz OWNER TO admin;

--
-- Name: pvz_pvz_id_seq; Type: SEQUENCE; Schema: marketplace; Owner: admin
--

CREATE SEQUENCE marketplace.pvz_pvz_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE marketplace.pvz_pvz_id_seq OWNER TO admin;

--
-- Name: pvz_pvz_id_seq; Type: SEQUENCE OWNED BY; Schema: marketplace; Owner: admin
--

ALTER SEQUENCE marketplace.pvz_pvz_id_seq OWNED BY marketplace.pvz.pvz_id;


--
-- Name: reviews; Type: TABLE; Schema: marketplace; Owner: admin
--

CREATE TABLE marketplace.reviews (
    review_id integer NOT NULL,
    purchase_id integer NOT NULL,
    rating integer NOT NULL,
    description text,
    CONSTRAINT reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE marketplace.reviews OWNER TO admin;

--
-- Name: reviews_review_id_seq; Type: SEQUENCE; Schema: marketplace; Owner: admin
--

CREATE SEQUENCE marketplace.reviews_review_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE marketplace.reviews_review_id_seq OWNER TO admin;

--
-- Name: reviews_review_id_seq; Type: SEQUENCE OWNED BY; Schema: marketplace; Owner: admin
--

ALTER SEQUENCE marketplace.reviews_review_id_seq OWNED BY marketplace.reviews.review_id;


--
-- Name: shops; Type: TABLE; Schema: marketplace; Owner: admin
--

CREATE TABLE marketplace.shops (
    shop_id integer NOT NULL,
    owner_id integer,
    name character varying(255) NOT NULL
);


ALTER TABLE marketplace.shops OWNER TO admin;

--
-- Name: shops_shop_id_seq; Type: SEQUENCE; Schema: marketplace; Owner: admin
--

CREATE SEQUENCE marketplace.shops_shop_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE marketplace.shops_shop_id_seq OWNER TO admin;

--
-- Name: shops_shop_id_seq; Type: SEQUENCE OWNED BY; Schema: marketplace; Owner: admin
--

ALTER SEQUENCE marketplace.shops_shop_id_seq OWNED BY marketplace.shops.shop_id;


--
-- Name: worker_assignments; Type: TABLE; Schema: marketplace; Owner: admin
--

CREATE TABLE marketplace.worker_assignments (
    worker_id integer,
    place_type character varying(20),
    place_id integer,
    work_id integer,
    CONSTRAINT worker_assignments_place_type_check CHECK ((((place_type)::text = 'shop'::text) OR ((place_type)::text = 'pvz'::text)))
);


ALTER TABLE marketplace.worker_assignments OWNER TO admin;

--
-- Name: workers; Type: TABLE; Schema: marketplace; Owner: admin
--

CREATE TABLE marketplace.workers (
    worker_id integer NOT NULL,
    login character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    salt character varying(50) NOT NULL
);


ALTER TABLE marketplace.workers OWNER TO admin;

--
-- Name: workers_worker_id_seq; Type: SEQUENCE; Schema: marketplace; Owner: admin
--

CREATE SEQUENCE marketplace.workers_worker_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE marketplace.workers_worker_id_seq OWNER TO admin;

--
-- Name: workers_worker_id_seq; Type: SEQUENCE OWNED BY; Schema: marketplace; Owner: admin
--

ALTER SEQUENCE marketplace.workers_worker_id_seq OWNED BY marketplace.workers.worker_id;


--
-- Name: flyway_schema_history; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE public.flyway_schema_history OWNER TO admin;

--
-- Name: buyers buyer_id; Type: DEFAULT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.buyers ALTER COLUMN buyer_id SET DEFAULT nextval('marketplace.buyers_buyer_id_seq'::regclass);


--
-- Name: career_path path_id; Type: DEFAULT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.career_path ALTER COLUMN path_id SET DEFAULT nextval('marketplace.career_path_path_id_seq'::regclass);


--
-- Name: category_of_item category_id; Type: DEFAULT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.category_of_item ALTER COLUMN category_id SET DEFAULT nextval('marketplace.category_of_item_category_id_seq'::regclass);


--
-- Name: items item_id; Type: DEFAULT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.items ALTER COLUMN item_id SET DEFAULT nextval('marketplace.items_item_id_seq'::regclass);


--
-- Name: orders order_id; Type: DEFAULT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.orders ALTER COLUMN order_id SET DEFAULT nextval('marketplace.orders_order_id_seq'::regclass);


--
-- Name: profession profession_id; Type: DEFAULT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.profession ALTER COLUMN profession_id SET DEFAULT nextval('marketplace.profession_profession_id_seq'::regclass);


--
-- Name: purchases purchase_id; Type: DEFAULT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.purchases ALTER COLUMN purchase_id SET DEFAULT nextval('marketplace.purchases_purchase_id_seq'::regclass);


--
-- Name: pvz pvz_id; Type: DEFAULT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.pvz ALTER COLUMN pvz_id SET DEFAULT nextval('marketplace.pvz_pvz_id_seq'::regclass);


--
-- Name: reviews review_id; Type: DEFAULT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.reviews ALTER COLUMN review_id SET DEFAULT nextval('marketplace.reviews_review_id_seq'::regclass);


--
-- Name: shops shop_id; Type: DEFAULT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.shops ALTER COLUMN shop_id SET DEFAULT nextval('marketplace.shops_shop_id_seq'::regclass);


--
-- Name: workers worker_id; Type: DEFAULT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.workers ALTER COLUMN worker_id SET DEFAULT nextval('marketplace.workers_worker_id_seq'::regclass);


--
-- Name: buyers buyers_login_key; Type: CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.buyers
    ADD CONSTRAINT buyers_login_key UNIQUE (login);


--
-- Name: buyers buyers_pkey; Type: CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.buyers
    ADD CONSTRAINT buyers_pkey PRIMARY KEY (buyer_id);


--
-- Name: career_path career_path_pkey; Type: CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.career_path
    ADD CONSTRAINT career_path_pkey PRIMARY KEY (path_id);


--
-- Name: category_of_item category_of_item_name_key; Type: CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.category_of_item
    ADD CONSTRAINT category_of_item_name_key UNIQUE (name);


--
-- Name: category_of_item category_of_item_pkey; Type: CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.category_of_item
    ADD CONSTRAINT category_of_item_pkey PRIMARY KEY (category_id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (item_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: orders orders_purchase_id_key; Type: CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.orders
    ADD CONSTRAINT orders_purchase_id_key UNIQUE (purchase_id);


--
-- Name: profession profession_name_key; Type: CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.profession
    ADD CONSTRAINT profession_name_key UNIQUE (name);


--
-- Name: profession profession_pkey; Type: CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.profession
    ADD CONSTRAINT profession_pkey PRIMARY KEY (profession_id);


--
-- Name: purchases purchases_pkey; Type: CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.purchases
    ADD CONSTRAINT purchases_pkey PRIMARY KEY (purchase_id);


--
-- Name: pvz pvz_address_key; Type: CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.pvz
    ADD CONSTRAINT pvz_address_key UNIQUE (address);


--
-- Name: pvz pvz_pkey; Type: CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.pvz
    ADD CONSTRAINT pvz_pkey PRIMARY KEY (pvz_id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (review_id);


--
-- Name: reviews reviews_purchase_id_key; Type: CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.reviews
    ADD CONSTRAINT reviews_purchase_id_key UNIQUE (purchase_id);


--
-- Name: shops shops_name_key; Type: CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.shops
    ADD CONSTRAINT shops_name_key UNIQUE (name);


--
-- Name: shops shops_pkey; Type: CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.shops
    ADD CONSTRAINT shops_pkey PRIMARY KEY (shop_id);


--
-- Name: workers workers_login_key; Type: CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.workers
    ADD CONSTRAINT workers_login_key UNIQUE (login);


--
-- Name: workers workers_pkey; Type: CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.workers
    ADD CONSTRAINT workers_pkey PRIMARY KEY (worker_id);


--
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);


--
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX flyway_schema_history_s_idx ON public.flyway_schema_history USING btree (success);


--
-- Name: career_path career_path_current_profession_id_fkey; Type: FK CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.career_path
    ADD CONSTRAINT career_path_current_profession_id_fkey FOREIGN KEY (current_profession_id) REFERENCES marketplace.profession(profession_id);


--
-- Name: career_path career_path_next_profession_id_fkey; Type: FK CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.career_path
    ADD CONSTRAINT career_path_next_profession_id_fkey FOREIGN KEY (next_profession_id) REFERENCES marketplace.profession(profession_id);


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
-- Name: orders orders_purchase_id_fkey; Type: FK CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.orders
    ADD CONSTRAINT orders_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES marketplace.purchases(purchase_id);


--
-- Name: orders orders_pvz_id_fkey; Type: FK CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.orders
    ADD CONSTRAINT orders_pvz_id_fkey FOREIGN KEY (pvz_id) REFERENCES marketplace.pvz(pvz_id);


--
-- Name: purchases purchases_buyer_id_fkey; Type: FK CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.purchases
    ADD CONSTRAINT purchases_buyer_id_fkey FOREIGN KEY (buyer_id) REFERENCES marketplace.buyers(buyer_id);


--
-- Name: purchases purchases_item_id_fkey; Type: FK CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.purchases
    ADD CONSTRAINT purchases_item_id_fkey FOREIGN KEY (item_id) REFERENCES marketplace.items(item_id);


--
-- Name: reviews reviews_purchase_id_fkey; Type: FK CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.reviews
    ADD CONSTRAINT reviews_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES marketplace.purchases(purchase_id);


--
-- Name: shops shops_owner_id_fkey; Type: FK CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.shops
    ADD CONSTRAINT shops_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES marketplace.workers(worker_id);


--
-- Name: worker_assignments worker_assignments_work_id_fkey; Type: FK CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.worker_assignments
    ADD CONSTRAINT worker_assignments_work_id_fkey FOREIGN KEY (work_id) REFERENCES marketplace.profession(profession_id);


--
-- Name: worker_assignments worker_assignments_worker_id_fkey; Type: FK CONSTRAINT; Schema: marketplace; Owner: admin
--

ALTER TABLE ONLY marketplace.worker_assignments
    ADD CONSTRAINT worker_assignments_worker_id_fkey FOREIGN KEY (worker_id) REFERENCES marketplace.workers(worker_id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO app;
GRANT USAGE ON SCHEMA public TO readonly;


--
-- Name: TABLE flyway_schema_history; Type: ACL; Schema: public; Owner: admin
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.flyway_schema_history TO app;
GRANT SELECT ON TABLE public.flyway_schema_history TO readonly;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: marketplace; Owner: admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE admin IN SCHEMA marketplace GRANT SELECT,USAGE ON SEQUENCES TO app;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: marketplace; Owner: admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE admin IN SCHEMA marketplace GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES TO app;
ALTER DEFAULT PRIVILEGES FOR ROLE admin IN SCHEMA marketplace GRANT SELECT ON TABLES TO readonly;


--
-- PostgreSQL database dump complete
--

