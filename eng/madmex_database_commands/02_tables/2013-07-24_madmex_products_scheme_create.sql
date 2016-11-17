--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.9
-- Dumped by pg_dump version 9.1.2
-- Started on 2014-07-23 18:10:40

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 10 (class 2615 OID 9732619)
-- Name: products; Type: SCHEMA; Schema: -; Owner: madmex_user
--

CREATE SCHEMA products;


ALTER SCHEMA products OWNER TO madmex_user;

SET search_path = products, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 232 (class 1259 OID 9732620)
-- Dependencies: 3759 10
-- Name: algorithm; Type: TABLE; Schema: products; Owner: madmex_user; Tablespace: 
--

CREATE TABLE algorithm (
    id integer NOT NULL,
    name character varying,
    description character varying,
    command character varying,
    supervised boolean DEFAULT true
);


ALTER TABLE products.algorithm OWNER TO madmex_user;

--
-- TOC entry 233 (class 1259 OID 9732627)
-- Dependencies: 10
-- Name: baseeodatasets; Type: TABLE; Schema: products; Owner: madmex_user; Tablespace: 
--

CREATE TABLE baseeodatasets (
    id integer NOT NULL,
    product bigint,
    dataset bigint
);


ALTER TABLE products.baseeodatasets OWNER TO madmex_user;

--
-- TOC entry 234 (class 1259 OID 9732630)
-- Dependencies: 10 233
-- Name: baseeodatasets_id_seq; Type: SEQUENCE; Schema: products; Owner: madmex_user
--

CREATE SEQUENCE baseeodatasets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE products.baseeodatasets_id_seq OWNER TO madmex_user;

--
-- TOC entry 3799 (class 0 OID 0)
-- Dependencies: 234
-- Name: baseeodatasets_id_seq; Type: SEQUENCE OWNED BY; Schema: products; Owner: madmex_user
--

ALTER SEQUENCE baseeodatasets_id_seq OWNED BY baseeodatasets.id;


--
-- TOC entry 235 (class 1259 OID 9732632)
-- Dependencies: 10
-- Name: baseproducts; Type: TABLE; Schema: products; Owner: madmex_user; Tablespace: 
--

CREATE TABLE baseproducts (
    id integer NOT NULL,
    product bigint,
    baseproduct bigint
);


ALTER TABLE products.baseproducts OWNER TO madmex_user;

--
-- TOC entry 236 (class 1259 OID 9732635)
-- Dependencies: 235 10
-- Name: baseproducts_id_seq; Type: SEQUENCE; Schema: products; Owner: madmex_user
--

CREATE SEQUENCE baseproducts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE products.baseproducts_id_seq OWNER TO madmex_user;

--
-- TOC entry 3800 (class 0 OID 0)
-- Dependencies: 236
-- Name: baseproducts_id_seq; Type: SEQUENCE OWNED BY; Schema: products; Owner: madmex_user
--

ALTER SEQUENCE baseproducts_id_seq OWNED BY baseproducts.id;


--
-- TOC entry 237 (class 1259 OID 9732637)
-- Dependencies: 10
-- Name: cantrain; Type: TABLE; Schema: products; Owner: madmex_user; Tablespace: 
--

CREATE TABLE cantrain (
    id integer NOT NULL,
    product bigint,
    algorithm integer
);


ALTER TABLE products.cantrain OWNER TO madmex_user;

--
-- TOC entry 238 (class 1259 OID 9732640)
-- Dependencies: 10 237
-- Name: cantrain_id_seq; Type: SEQUENCE; Schema: products; Owner: madmex_user
--

CREATE SEQUENCE cantrain_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE products.cantrain_id_seq OWNER TO madmex_user;

--
-- TOC entry 3801 (class 0 OID 0)
-- Dependencies: 238
-- Name: cantrain_id_seq; Type: SEQUENCE OWNED BY; Schema: products; Owner: madmex_user
--

ALTER SEQUENCE cantrain_id_seq OWNED BY cantrain.id;


--
-- TOC entry 239 (class 1259 OID 9732642)
-- Dependencies: 232 10
-- Name: classifier_id_seq; Type: SEQUENCE; Schema: products; Owner: madmex_user
--

CREATE SEQUENCE classifier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE products.classifier_id_seq OWNER TO madmex_user;

--
-- TOC entry 3802 (class 0 OID 0)
-- Dependencies: 239
-- Name: classifier_id_seq; Type: SEQUENCE OWNED BY; Schema: products; Owner: madmex_user
--

ALTER SEQUENCE classifier_id_seq OWNED BY algorithm.id;


--
-- TOC entry 240 (class 1259 OID 9732644)
-- Dependencies: 10
-- Name: legend; Type: TABLE; Schema: products; Owner: madmex_user; Tablespace: 
--

CREATE TABLE legend (
    id integer NOT NULL,
    name character varying,
    description character varying,
    sld character varying
);


ALTER TABLE products.legend OWNER TO madmex_user;

--
-- TOC entry 241 (class 1259 OID 9732650)
-- Dependencies: 10 240
-- Name: legend_id_seq; Type: SEQUENCE; Schema: products; Owner: madmex_user
--

CREATE SEQUENCE legend_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE products.legend_id_seq OWNER TO madmex_user;

--
-- TOC entry 3803 (class 0 OID 0)
-- Dependencies: 241
-- Name: legend_id_seq; Type: SEQUENCE OWNED BY; Schema: products; Owner: madmex_user
--

ALTER SEQUENCE legend_id_seq OWNED BY legend.id;


--
-- TOC entry 242 (class 1259 OID 9732652)
-- Dependencies: 3766 1831 10
-- Name: product; Type: TABLE; Schema: products; Owner: madmex_user; Tablespace: 
--

CREATE TABLE product (
    id integer NOT NULL,
    uuid uuid,
    date_from date,
    date_to date,
    algorithm integer,
    legend integer,
    provider character varying,
    file_url character varying,
    proc_date timestamp with time zone,
    ingest_date timestamp with time zone DEFAULT now(),
    the_geom public.geometry,
    rows bigint,
    columns bigint,
    bands bigint,
    resolution double precision,
    projection character varying
);


ALTER TABLE products.product OWNER TO madmex_user;

--
-- TOC entry 243 (class 1259 OID 9732659)
-- Dependencies: 10 242
-- Name: products_id_seq; Type: SEQUENCE; Schema: products; Owner: madmex_user
--

CREATE SEQUENCE products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE products.products_id_seq OWNER TO madmex_user;

--
-- TOC entry 3804 (class 0 OID 0)
-- Dependencies: 243
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: products; Owner: madmex_user
--

ALTER SEQUENCE products_id_seq OWNED BY product.id;


--
-- TOC entry 3760 (class 2604 OID 9732661)
-- Dependencies: 239 232
-- Name: id; Type: DEFAULT; Schema: products; Owner: madmex_user
--

ALTER TABLE algorithm ALTER COLUMN id SET DEFAULT nextval('classifier_id_seq'::regclass);


--
-- TOC entry 3761 (class 2604 OID 9732662)
-- Dependencies: 234 233
-- Name: id; Type: DEFAULT; Schema: products; Owner: madmex_user
--

ALTER TABLE baseeodatasets ALTER COLUMN id SET DEFAULT nextval('baseeodatasets_id_seq'::regclass);


--
-- TOC entry 3762 (class 2604 OID 9732663)
-- Dependencies: 236 235
-- Name: id; Type: DEFAULT; Schema: products; Owner: madmex_user
--

ALTER TABLE baseproducts ALTER COLUMN id SET DEFAULT nextval('baseproducts_id_seq'::regclass);


--
-- TOC entry 3763 (class 2604 OID 9732664)
-- Dependencies: 238 237
-- Name: id; Type: DEFAULT; Schema: products; Owner: madmex_user
--

ALTER TABLE cantrain ALTER COLUMN id SET DEFAULT nextval('cantrain_id_seq'::regclass);


--
-- TOC entry 3764 (class 2604 OID 9732665)
-- Dependencies: 241 240
-- Name: id; Type: DEFAULT; Schema: products; Owner: madmex_user
--

ALTER TABLE legend ALTER COLUMN id SET DEFAULT nextval('legend_id_seq'::regclass);


--
-- TOC entry 3765 (class 2604 OID 9732666)
-- Dependencies: 243 242
-- Name: id; Type: DEFAULT; Schema: products; Owner: madmex_user
--

ALTER TABLE product ALTER COLUMN id SET DEFAULT nextval('products_id_seq'::regclass);


--
-- TOC entry 3770 (class 2606 OID 9732753)
-- Dependencies: 233 233 233
-- Name: baseeodatasets_ix1; Type: CONSTRAINT; Schema: products; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY baseeodatasets
    ADD CONSTRAINT baseeodatasets_ix1 UNIQUE (product, dataset);


--
-- TOC entry 3772 (class 2606 OID 9732755)
-- Dependencies: 233 233
-- Name: baseeodatasets_pkey; Type: CONSTRAINT; Schema: products; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY baseeodatasets
    ADD CONSTRAINT baseeodatasets_pkey PRIMARY KEY (id);


--
-- TOC entry 3774 (class 2606 OID 9732757)
-- Dependencies: 235 235 235
-- Name: baseproducts_ix1; Type: CONSTRAINT; Schema: products; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY baseproducts
    ADD CONSTRAINT baseproducts_ix1 UNIQUE (product, baseproduct);


--
-- TOC entry 3776 (class 2606 OID 9732759)
-- Dependencies: 235 235
-- Name: baseproducts_pkey; Type: CONSTRAINT; Schema: products; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY baseproducts
    ADD CONSTRAINT baseproducts_pkey PRIMARY KEY (id);


--
-- TOC entry 3778 (class 2606 OID 9732761)
-- Dependencies: 237 237 237
-- Name: cantrain_ix1; Type: CONSTRAINT; Schema: products; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY cantrain
    ADD CONSTRAINT cantrain_ix1 UNIQUE (product, algorithm);


--
-- TOC entry 3780 (class 2606 OID 9732763)
-- Dependencies: 237 237
-- Name: cantrain_pkey; Type: CONSTRAINT; Schema: products; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY cantrain
    ADD CONSTRAINT cantrain_pkey PRIMARY KEY (id);


--
-- TOC entry 3768 (class 2606 OID 9732765)
-- Dependencies: 232 232
-- Name: classifier_pkey; Type: CONSTRAINT; Schema: products; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY algorithm
    ADD CONSTRAINT classifier_pkey PRIMARY KEY (id);


--
-- TOC entry 3782 (class 2606 OID 9732767)
-- Dependencies: 240 240
-- Name: legend_ix1; Type: CONSTRAINT; Schema: products; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY legend
    ADD CONSTRAINT legend_ix1 UNIQUE (name);


--
-- TOC entry 3784 (class 2606 OID 9732769)
-- Dependencies: 240 240
-- Name: legend_pkey; Type: CONSTRAINT; Schema: products; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY legend
    ADD CONSTRAINT legend_pkey PRIMARY KEY (id);


--
-- TOC entry 3787 (class 2606 OID 9732784)
-- Dependencies: 242 242 242 242 242
-- Name: product_ix1; Type: CONSTRAINT; Schema: products; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY product
    ADD CONSTRAINT product_ix1 UNIQUE (date_from, date_to, algorithm, proc_date);


--
-- TOC entry 3789 (class 2606 OID 9732773)
-- Dependencies: 242 242
-- Name: products_pkey; Type: CONSTRAINT; Schema: products; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY product
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- TOC entry 3785 (class 1259 OID 9732774)
-- Dependencies: 242
-- Name: fki_products_trainingraster_fkey; Type: INDEX; Schema: products; Owner: madmex_user; Tablespace: 
--

CREATE INDEX fki_products_trainingraster_fkey ON product USING btree (legend);


--
-- TOC entry 3790 (class 2606 OID 9732816)
-- Dependencies: 242 3788 233
-- Name: baseeodatasets_fk1; Type: FK CONSTRAINT; Schema: products; Owner: madmex_user
--

ALTER TABLE ONLY baseeodatasets
    ADD CONSTRAINT baseeodatasets_fk1 FOREIGN KEY (product) REFERENCES product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3791 (class 2606 OID 9732806)
-- Dependencies: 235 3788 242
-- Name: baseproducts_fk1; Type: FK CONSTRAINT; Schema: products; Owner: madmex_user
--

ALTER TABLE ONLY baseproducts
    ADD CONSTRAINT baseproducts_fk1 FOREIGN KEY (product) REFERENCES product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3792 (class 2606 OID 9732811)
-- Dependencies: 3788 242 235
-- Name: baseproducts_fk2; Type: FK CONSTRAINT; Schema: products; Owner: madmex_user
--

ALTER TABLE ONLY baseproducts
    ADD CONSTRAINT baseproducts_fk2 FOREIGN KEY (baseproduct) REFERENCES product(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 3793 (class 2606 OID 9732791)
-- Dependencies: 237 242 3788
-- Name: cantrain_fk1; Type: FK CONSTRAINT; Schema: products; Owner: madmex_user
--

ALTER TABLE ONLY cantrain
    ADD CONSTRAINT cantrain_fk1 FOREIGN KEY (product) REFERENCES product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3794 (class 2606 OID 9732796)
-- Dependencies: 3767 232 237
-- Name: cantrain_fk2; Type: FK CONSTRAINT; Schema: products; Owner: madmex_user
--

ALTER TABLE ONLY cantrain
    ADD CONSTRAINT cantrain_fk2 FOREIGN KEY (algorithm) REFERENCES algorithm(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3795 (class 2606 OID 9732778)
-- Dependencies: 242 3767 232
-- Name: product_fk1; Type: FK CONSTRAINT; Schema: products; Owner: madmex_user
--

ALTER TABLE ONLY product
    ADD CONSTRAINT product_fk1 FOREIGN KEY (algorithm) REFERENCES algorithm(id);


--
-- TOC entry 3796 (class 2606 OID 9732786)
-- Dependencies: 240 3783 242
-- Name: product_fk2; Type: FK CONSTRAINT; Schema: products; Owner: madmex_user
--

ALTER TABLE ONLY product
    ADD CONSTRAINT product_fk2 FOREIGN KEY (legend) REFERENCES legend(id);


-- Completed on 2014-07-23 18:10:40

--
-- PostgreSQL database dump complete
--

