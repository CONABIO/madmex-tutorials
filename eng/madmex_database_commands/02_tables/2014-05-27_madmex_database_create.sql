--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.9
-- Dumped by pg_dump version 9.3.1
-- Started on 2014-05-27 13:24:39

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

CREATE SCHEMA eodata;
CREATE SCHEMA classification;
CREATE SCHEMA products;
CREATE SCHEMA vectordata;

SET search_path = eodata, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 181 (class 1259 OID 9649994)
-- Name: dataset; Type: TABLE; Schema: eodata; Owner: madmex_user; Tablespace: 
--

CREATE TABLE dataset (
    id integer NOT NULL,
    identifier uuid,
    acq_date timestamp with time zone,
    gridid bigint,
    format integer,
    sensor integer,
    platform integer,
    product integer,
    rights integer,
    projection character varying,
    folder_url character varying,
    clouds double precision,
    nodata double precision,
    angle double precision,
    rows bigint,
    columns bigint,
    bands integer,
    resolution double precision,
    datatype character varying,
    the_geom public.geometry,
    proc_date timestamp with time zone,
    ingest_date timestamp with time zone DEFAULT now()
);


ALTER TABLE eodata.dataset OWNER TO madmex_user;

--
-- TOC entry 3355 (class 0 OID 0)
-- Dependencies: 181
-- Name: TABLE dataset; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON TABLE dataset IS 'registration of individual eo datasets / images';


--
-- TOC entry 3356 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN dataset.id; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN dataset.id IS 'unique identifier';


--
-- TOC entry 3357 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN dataset.identifier; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN dataset.identifier IS 'uuid identifier';


--
-- TOC entry 3358 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN dataset.acq_date; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN dataset.acq_date IS 'starting date of dataset';


--
-- TOC entry 3359 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN dataset.gridid; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN dataset.gridid IS 'identifier of reference system (like pathrow/ tileid / ...)';


--
-- TOC entry 3360 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN dataset.format; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN dataset.format IS 'format id';


--
-- TOC entry 3361 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN dataset.sensor; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN dataset.sensor IS 'sensor id';


--
-- TOC entry 3362 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN dataset.platform; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN dataset.platform IS 'platform id';


--
-- TOC entry 3363 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN dataset.product; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN dataset.product IS 'product id';


--
-- TOC entry 3364 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN dataset.rights; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN dataset.rights IS 'rights id';


--
-- TOC entry 3365 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN dataset.projection; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN dataset.projection IS 'projection as epsg / wkt';


--
-- TOC entry 3366 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN dataset.folder_url; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN dataset.folder_url IS 'url of dataset folder';


--
-- TOC entry 3367 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN dataset.clouds; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN dataset.clouds IS 'cloud percentage';


--
-- TOC entry 3368 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN dataset.nodata; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN dataset.nodata IS 'no data percentage';


--
-- TOC entry 3369 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN dataset.angle; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN dataset.angle IS 'sensor viewing angle';


--
-- TOC entry 3370 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN dataset.rows; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN dataset.rows IS 'number of image rows';


--
-- TOC entry 3371 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN dataset.columns; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN dataset.columns IS 'number of image columns';


--
-- TOC entry 3372 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN dataset.bands; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN dataset.bands IS 'number of image bands';


--
-- TOC entry 3373 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN dataset.resolution; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN dataset.resolution IS 'pixel size in meters';


--
-- TOC entry 3374 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN dataset.datatype; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN dataset.datatype IS 'image data type';


--
-- TOC entry 3375 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN dataset.the_geom; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN dataset.the_geom IS 'geometry of image extent';


--
-- TOC entry 179 (class 1259 OID 9649989)
-- Name: bands; Type: TABLE; Schema: eodata; Owner: madmex_user; Tablespace: 
--

CREATE TABLE bands (
    id integer NOT NULL,
    sensor integer NOT NULL,
    band integer NOT NULL,
    wl_min real NOT NULL,
    wl_max real NOT NULL,
    unitofmeasure integer NOT NULL
);


ALTER TABLE eodata.bands OWNER TO madmex_user;

--
-- TOC entry 3376 (class 0 OID 0)
-- Dependencies: 179
-- Name: TABLE bands; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON TABLE bands IS 'definition of sensor specific band spectral properties';


--
-- TOC entry 3377 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN bands.sensor; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN bands.sensor IS 'foreign key referencing sensor table';


--
-- TOC entry 3378 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN bands.band; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN bands.band IS 'number of the band';


--
-- TOC entry 3379 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN bands.wl_min; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN bands.wl_min IS 'minimum wavelength in band';


--
-- TOC entry 3380 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN bands.wl_max; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN bands.wl_max IS 'maximum wavelength in band';


--
-- TOC entry 3381 (class 0 OID 0)
-- Dependencies: 179
-- Name: COLUMN bands.unitofmeasure; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN bands.unitofmeasure IS 'unit of measure referencing the uom table';


--
-- TOC entry 180 (class 1259 OID 9649992)
-- Name: bands_id_seq; Type: SEQUENCE; Schema: eodata; Owner: madmex_user
--

CREATE SEQUENCE bands_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE eodata.bands_id_seq OWNER TO madmex_user;

--
-- TOC entry 3382 (class 0 OID 0)
-- Dependencies: 180
-- Name: bands_id_seq; Type: SEQUENCE OWNED BY; Schema: eodata; Owner: madmex_user
--

ALTER SEQUENCE bands_id_seq OWNED BY bands.id;


--
-- TOC entry 182 (class 1259 OID 9650001)
-- Name: description; Type: TABLE; Schema: eodata; Owner: madmex_user; Tablespace: 
--

CREATE TABLE description (
    id integer NOT NULL,
    abstract character varying,
    creator character varying,
    publisher character varying,
    contributor character varying
);


ALTER TABLE eodata.description OWNER TO madmex_user;

--
-- TOC entry 3383 (class 0 OID 0)
-- Dependencies: 182
-- Name: TABLE description; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON TABLE description IS 'defintion of description for product / dataset groups';


--
-- TOC entry 3384 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN description.id; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN description.id IS 'unique identifier';


--
-- TOC entry 3385 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN description.abstract; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN description.abstract IS 'description of dataset / product';


--
-- TOC entry 3386 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN description.creator; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN description.creator IS 'person/organisation who created dataset';


--
-- TOC entry 3387 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN description.publisher; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN description.publisher IS 'person/organisation who published dataset';


--
-- TOC entry 3388 (class 0 OID 0)
-- Dependencies: 182
-- Name: COLUMN description.contributor; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN description.contributor IS 'person/organisation who contributed to dataset creation';


--
-- TOC entry 183 (class 1259 OID 9650007)
-- Name: dataset_description_id_seq; Type: SEQUENCE; Schema: eodata; Owner: madmex_user
--

CREATE SEQUENCE dataset_description_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE eodata.dataset_description_id_seq OWNER TO madmex_user;

--
-- TOC entry 3389 (class 0 OID 0)
-- Dependencies: 183
-- Name: dataset_description_id_seq; Type: SEQUENCE OWNED BY; Schema: eodata; Owner: madmex_user
--

ALTER SEQUENCE dataset_description_id_seq OWNED BY description.id;


--
-- TOC entry 184 (class 1259 OID 9650009)
-- Name: dataset_id_seq; Type: SEQUENCE; Schema: eodata; Owner: madmex_user
--

CREATE SEQUENCE dataset_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE eodata.dataset_id_seq OWNER TO madmex_user;

--
-- TOC entry 3390 (class 0 OID 0)
-- Dependencies: 184
-- Name: dataset_id_seq; Type: SEQUENCE OWNED BY; Schema: eodata; Owner: madmex_user
--

ALTER SEQUENCE dataset_id_seq OWNED BY dataset.id;


--
-- TOC entry 185 (class 1259 OID 9650011)
-- Name: format; Type: TABLE; Schema: eodata; Owner: madmex_user; Tablespace: 
--

CREATE TABLE format (
    id integer NOT NULL,
    name character varying,
    extension character varying,
    mimetype character varying
);


ALTER TABLE eodata.format OWNER TO madmex_user;

--
-- TOC entry 3391 (class 0 OID 0)
-- Dependencies: 185
-- Name: TABLE format; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON TABLE format IS 'definition of image formats';


--
-- TOC entry 3392 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN format.id; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN format.id IS 'unique identifier';


--
-- TOC entry 3393 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN format.name; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN format.name IS 'format name';


--
-- TOC entry 3394 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN format.extension; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN format.extension IS 'format extension';


--
-- TOC entry 3395 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN format.mimetype; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN format.mimetype IS 'format mimetype';


--
-- TOC entry 186 (class 1259 OID 9650017)
-- Name: format_id_seq; Type: SEQUENCE; Schema: eodata; Owner: madmex_user
--

CREATE SEQUENCE format_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE eodata.format_id_seq OWNER TO madmex_user;

--
-- TOC entry 3396 (class 0 OID 0)
-- Dependencies: 186
-- Name: format_id_seq; Type: SEQUENCE OWNED BY; Schema: eodata; Owner: madmex_user
--

ALTER SEQUENCE format_id_seq OWNED BY format.id;


--
-- TOC entry 187 (class 1259 OID 9650019)
-- Name: platform; Type: TABLE; Schema: eodata; Owner: madmex_user; Tablespace: 
--

CREATE TABLE platform (
    id integer NOT NULL,
    name character varying(25) NOT NULL,
    description character varying(250)
);


ALTER TABLE eodata.platform OWNER TO madmex_user;

--
-- TOC entry 3397 (class 0 OID 0)
-- Dependencies: 187
-- Name: TABLE platform; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON TABLE platform IS 'Table specifying earth observation sensor platforms, i.e. satellites';


--
-- TOC entry 3398 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN platform.id; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN platform.id IS 'unique platform identifier, primary key';


--
-- TOC entry 3399 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN platform.name; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN platform.name IS 'name of the platform/satellite';


--
-- TOC entry 188 (class 1259 OID 9650022)
-- Name: platform_id_seq; Type: SEQUENCE; Schema: eodata; Owner: madmex_user
--

CREATE SEQUENCE platform_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE eodata.platform_id_seq OWNER TO madmex_user;

--
-- TOC entry 3400 (class 0 OID 0)
-- Dependencies: 188
-- Name: platform_id_seq; Type: SEQUENCE OWNED BY; Schema: eodata; Owner: madmex_user
--

ALTER SEQUENCE platform_id_seq OWNED BY platform.id;


--
-- TOC entry 189 (class 1259 OID 9650024)
-- Name: product; Type: TABLE; Schema: eodata; Owner: madmex_user; Tablespace: 
--

CREATE TABLE product (
    id integer NOT NULL,
    level character varying NOT NULL,
    name character varying NOT NULL,
    shortname character varying,
    unitofmeasure integer,
    description integer
);


ALTER TABLE eodata.product OWNER TO madmex_user;

--
-- TOC entry 3401 (class 0 OID 0)
-- Dependencies: 189
-- Name: TABLE product; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON TABLE product IS 'imaging products and level definitions for a specific sensor (e.g. level 1b, 3a)';


--
-- TOC entry 3402 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN product.id; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN product.id IS 'unique identifier, primary key';


--
-- TOC entry 3403 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN product.level; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN product.level IS 'name of imagery processing level (L0, L1b, ...)';


--
-- TOC entry 3404 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN product.name; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN product.name IS 'description of imagery processing level';


--
-- TOC entry 3405 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN product.shortname; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN product.shortname IS 'short product level name';


--
-- TOC entry 3406 (class 0 OID 0)
-- Dependencies: 189
-- Name: COLUMN product.unitofmeasure; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN product.unitofmeasure IS 'unit of measure id';


--
-- TOC entry 190 (class 1259 OID 9650030)
-- Name: product_id_seq; Type: SEQUENCE; Schema: eodata; Owner: madmex_user
--

CREATE SEQUENCE product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE eodata.product_id_seq OWNER TO madmex_user;

--
-- TOC entry 3407 (class 0 OID 0)
-- Dependencies: 190
-- Name: product_id_seq; Type: SEQUENCE OWNED BY; Schema: eodata; Owner: madmex_user
--

ALTER SEQUENCE product_id_seq OWNED BY product.id;


--
-- TOC entry 191 (class 1259 OID 9650032)
-- Name: rights; Type: TABLE; Schema: eodata; Owner: madmex_user; Tablespace: 
--

CREATE TABLE rights (
    id integer NOT NULL,
    description character varying,
    holder character varying
);


ALTER TABLE eodata.rights OWNER TO madmex_user;

--
-- TOC entry 3408 (class 0 OID 0)
-- Dependencies: 191
-- Name: TABLE rights; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON TABLE rights IS 'definition of data access rights';


--
-- TOC entry 3409 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN rights.id; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN rights.id IS 'unique identifier';


--
-- TOC entry 3410 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN rights.description; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN rights.description IS 'description of access rights';


--
-- TOC entry 3411 (class 0 OID 0)
-- Dependencies: 191
-- Name: COLUMN rights.holder; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN rights.holder IS 'holder (person) of rights';


--
-- TOC entry 192 (class 1259 OID 9650038)
-- Name: rights_id_seq; Type: SEQUENCE; Schema: eodata; Owner: madmex_user
--

CREATE SEQUENCE rights_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE eodata.rights_id_seq OWNER TO madmex_user;

--
-- TOC entry 3412 (class 0 OID 0)
-- Dependencies: 192
-- Name: rights_id_seq; Type: SEQUENCE OWNED BY; Schema: eodata; Owner: madmex_user
--

ALTER SEQUENCE rights_id_seq OWNED BY rights.id;


--
-- TOC entry 193 (class 1259 OID 9650040)
-- Name: sensor; Type: TABLE; Schema: eodata; Owner: madmex_user; Tablespace: 
--

CREATE TABLE sensor (
    id integer NOT NULL,
    name character varying(25) NOT NULL,
    description character varying(250) NOT NULL
);


ALTER TABLE eodata.sensor OWNER TO madmex_user;

--
-- TOC entry 3413 (class 0 OID 0)
-- Dependencies: 193
-- Name: TABLE sensor; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON TABLE sensor IS 'table for eo sensor definitions';


--
-- TOC entry 3414 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN sensor.id; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN sensor.id IS 'unique sensor id, primary key';


--
-- TOC entry 3415 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN sensor.name; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN sensor.name IS 'sensor name, acronym';


--
-- TOC entry 3416 (class 0 OID 0)
-- Dependencies: 193
-- Name: COLUMN sensor.description; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN sensor.description IS 'sensor description';


--
-- TOC entry 194 (class 1259 OID 9650043)
-- Name: sensor2platform; Type: TABLE; Schema: eodata; Owner: madmex_user; Tablespace: 
--

CREATE TABLE sensor2platform (
    id integer NOT NULL,
    sensor integer,
    platform integer
);


ALTER TABLE eodata.sensor2platform OWNER TO madmex_user;

--
-- TOC entry 3417 (class 0 OID 0)
-- Dependencies: 194
-- Name: TABLE sensor2platform; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON TABLE sensor2platform IS 'cross table between sensors and platforms';


--
-- TOC entry 3418 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN sensor2platform.id; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN sensor2platform.id IS 'unique identifier';


--
-- TOC entry 3419 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN sensor2platform.sensor; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN sensor2platform.sensor IS 'sensor id';


--
-- TOC entry 3420 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN sensor2platform.platform; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN sensor2platform.platform IS 'platform id';


--
-- TOC entry 195 (class 1259 OID 9650046)
-- Name: sensor2platform_id_seq; Type: SEQUENCE; Schema: eodata; Owner: madmex_user
--

CREATE SEQUENCE sensor2platform_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE eodata.sensor2platform_id_seq OWNER TO madmex_user;

--
-- TOC entry 3421 (class 0 OID 0)
-- Dependencies: 195
-- Name: sensor2platform_id_seq; Type: SEQUENCE OWNED BY; Schema: eodata; Owner: madmex_user
--

ALTER SEQUENCE sensor2platform_id_seq OWNED BY sensor2platform.id;


--
-- TOC entry 196 (class 1259 OID 9650048)
-- Name: sensor2product; Type: TABLE; Schema: eodata; Owner: madmex_user; Tablespace: 
--

CREATE TABLE sensor2product (
    id integer NOT NULL,
    sensor integer,
    product integer
);


ALTER TABLE eodata.sensor2product OWNER TO madmex_user;

--
-- TOC entry 197 (class 1259 OID 9650051)
-- Name: sensor2product_id_seq; Type: SEQUENCE; Schema: eodata; Owner: madmex_user
--

CREATE SEQUENCE sensor2product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE eodata.sensor2product_id_seq OWNER TO madmex_user;

--
-- TOC entry 3422 (class 0 OID 0)
-- Dependencies: 197
-- Name: sensor2product_id_seq; Type: SEQUENCE OWNED BY; Schema: eodata; Owner: madmex_user
--

ALTER SEQUENCE sensor2product_id_seq OWNED BY sensor2product.id;


--
-- TOC entry 198 (class 1259 OID 9650053)
-- Name: sensor_id_seq; Type: SEQUENCE; Schema: eodata; Owner: madmex_user
--

CREATE SEQUENCE sensor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE eodata.sensor_id_seq OWNER TO madmex_user;

--
-- TOC entry 3423 (class 0 OID 0)
-- Dependencies: 198
-- Name: sensor_id_seq; Type: SEQUENCE OWNED BY; Schema: eodata; Owner: madmex_user
--

ALTER SEQUENCE sensor_id_seq OWNED BY sensor.id;


--
-- TOC entry 199 (class 1259 OID 9650055)
-- Name: unitofmeasure; Type: TABLE; Schema: eodata; Owner: madmex_user; Tablespace: 
--

CREATE TABLE unitofmeasure (
    id integer NOT NULL,
    name character varying NOT NULL,
    unit character varying(15) NOT NULL
);


ALTER TABLE eodata.unitofmeasure OWNER TO madmex_user;

--
-- TOC entry 3424 (class 0 OID 0)
-- Dependencies: 199
-- Name: TABLE unitofmeasure; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON TABLE unitofmeasure IS 'definition of measuring units';


--
-- TOC entry 3425 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN unitofmeasure.id; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN unitofmeasure.id IS 'unique identifier, primary key';


--
-- TOC entry 3426 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN unitofmeasure.name; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN unitofmeasure.name IS 'name for unit';


--
-- TOC entry 3427 (class 0 OID 0)
-- Dependencies: 199
-- Name: COLUMN unitofmeasure.unit; Type: COMMENT; Schema: eodata; Owner: madmex_user
--

COMMENT ON COLUMN unitofmeasure.unit IS 'abbreviation for the unit of measure';


--
-- TOC entry 200 (class 1259 OID 9650061)
-- Name: unit_of_measure_id_seq; Type: SEQUENCE; Schema: eodata; Owner: madmex_user
--

CREATE SEQUENCE unit_of_measure_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE eodata.unit_of_measure_id_seq OWNER TO madmex_user;

--
-- TOC entry 3428 (class 0 OID 0)
-- Dependencies: 200
-- Name: unit_of_measure_id_seq; Type: SEQUENCE OWNED BY; Schema: eodata; Owner: madmex_user
--

ALTER SEQUENCE unit_of_measure_id_seq OWNED BY unitofmeasure.id;


--
-- TOC entry 3194 (class 2604 OID 9650063)
-- Name: id; Type: DEFAULT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY bands ALTER COLUMN id SET DEFAULT nextval('bands_id_seq'::regclass);


--
-- TOC entry 3195 (class 2604 OID 9650064)
-- Name: id; Type: DEFAULT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY dataset ALTER COLUMN id SET DEFAULT nextval('dataset_id_seq'::regclass);


--
-- TOC entry 3197 (class 2604 OID 9650065)
-- Name: id; Type: DEFAULT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY description ALTER COLUMN id SET DEFAULT nextval('dataset_description_id_seq'::regclass);


--
-- TOC entry 3198 (class 2604 OID 9650066)
-- Name: id; Type: DEFAULT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY format ALTER COLUMN id SET DEFAULT nextval('format_id_seq'::regclass);


--
-- TOC entry 3199 (class 2604 OID 9650067)
-- Name: id; Type: DEFAULT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY platform ALTER COLUMN id SET DEFAULT nextval('platform_id_seq'::regclass);


--
-- TOC entry 3200 (class 2604 OID 9650068)
-- Name: id; Type: DEFAULT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY product ALTER COLUMN id SET DEFAULT nextval('product_id_seq'::regclass);


--
-- TOC entry 3201 (class 2604 OID 9650069)
-- Name: id; Type: DEFAULT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY rights ALTER COLUMN id SET DEFAULT nextval('rights_id_seq'::regclass);


--
-- TOC entry 3202 (class 2604 OID 9650070)
-- Name: id; Type: DEFAULT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY sensor ALTER COLUMN id SET DEFAULT nextval('sensor_id_seq'::regclass);


--
-- TOC entry 3203 (class 2604 OID 9650071)
-- Name: id; Type: DEFAULT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY sensor2platform ALTER COLUMN id SET DEFAULT nextval('sensor2platform_id_seq'::regclass);


--
-- TOC entry 3204 (class 2604 OID 9650072)
-- Name: id; Type: DEFAULT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY sensor2product ALTER COLUMN id SET DEFAULT nextval('sensor2product_id_seq'::regclass);


--
-- TOC entry 3205 (class 2604 OID 9650073)
-- Name: id; Type: DEFAULT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY unitofmeasure ALTER COLUMN id SET DEFAULT nextval('unit_of_measure_id_seq'::regclass);


--
-- TOC entry 3207 (class 2606 OID 9650075)
-- Name: bands_id; Type: CONSTRAINT; Schema: eodata; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY bands
    ADD CONSTRAINT bands_id PRIMARY KEY (id);


--
-- TOC entry 3213 (class 2606 OID 9650077)
-- Name: dataset_description_pkey; Type: CONSTRAINT; Schema: eodata; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY description
    ADD CONSTRAINT dataset_description_pkey PRIMARY KEY (id);


--
-- TOC entry 3209 (class 2606 OID 9662223)
-- Name: dataset_ix1; Type: CONSTRAINT; Schema: eodata; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY dataset
    ADD CONSTRAINT dataset_ix1 UNIQUE (acq_date, gridid, sensor, platform, product, the_geom, proc_date);


--
-- TOC entry 3211 (class 2606 OID 9650081)
-- Name: dataset_pkey; Type: CONSTRAINT; Schema: eodata; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY dataset
    ADD CONSTRAINT dataset_pkey PRIMARY KEY (id);


--
-- TOC entry 3215 (class 2606 OID 9650083)
-- Name: format_pkey; Type: CONSTRAINT; Schema: eodata; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY format
    ADD CONSTRAINT format_pkey PRIMARY KEY (id);


--
-- TOC entry 3217 (class 2606 OID 9650085)
-- Name: platform_id; Type: CONSTRAINT; Schema: eodata; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY platform
    ADD CONSTRAINT platform_id PRIMARY KEY (id);


--
-- TOC entry 3219 (class 2606 OID 9650087)
-- Name: product_pk; Type: CONSTRAINT; Schema: eodata; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY product
    ADD CONSTRAINT product_pk PRIMARY KEY (id);


--
-- TOC entry 3221 (class 2606 OID 9650089)
-- Name: rights_pkey; Type: CONSTRAINT; Schema: eodata; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY rights
    ADD CONSTRAINT rights_pkey PRIMARY KEY (id);


--
-- TOC entry 3225 (class 2606 OID 9650091)
-- Name: sensor2platform_pkey; Type: CONSTRAINT; Schema: eodata; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY sensor2platform
    ADD CONSTRAINT sensor2platform_pkey PRIMARY KEY (id);


--
-- TOC entry 3227 (class 2606 OID 9650093)
-- Name: sensor2product_pkey; Type: CONSTRAINT; Schema: eodata; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY sensor2product
    ADD CONSTRAINT sensor2product_pkey PRIMARY KEY (id);


--
-- TOC entry 3223 (class 2606 OID 9650095)
-- Name: sensor_id; Type: CONSTRAINT; Schema: eodata; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY sensor
    ADD CONSTRAINT sensor_id PRIMARY KEY (id);


--
-- TOC entry 3229 (class 2606 OID 9650097)
-- Name: unit_of_measure_pk; Type: CONSTRAINT; Schema: eodata; Owner: madmex_user; Tablespace: 
--

ALTER TABLE ONLY unitofmeasure
    ADD CONSTRAINT unit_of_measure_pk PRIMARY KEY (id);


--
-- TOC entry 3232 (class 2606 OID 9650098)
-- Name: dataset_format_fkey; Type: FK CONSTRAINT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY dataset
    ADD CONSTRAINT dataset_format_fkey FOREIGN KEY (format) REFERENCES format(id);


--
-- TOC entry 3233 (class 2606 OID 9650103)
-- Name: dataset_platform_fkey; Type: FK CONSTRAINT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY dataset
    ADD CONSTRAINT dataset_platform_fkey FOREIGN KEY (platform) REFERENCES platform(id);


--
-- TOC entry 3234 (class 2606 OID 9650108)
-- Name: dataset_product_fkey; Type: FK CONSTRAINT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY dataset
    ADD CONSTRAINT dataset_product_fkey FOREIGN KEY (product) REFERENCES product(id);


--
-- TOC entry 3235 (class 2606 OID 9650113)
-- Name: dataset_rights_fkey; Type: FK CONSTRAINT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY dataset
    ADD CONSTRAINT dataset_rights_fkey FOREIGN KEY (rights) REFERENCES rights(id);


--
-- TOC entry 3236 (class 2606 OID 9650118)
-- Name: dataset_sensor_fkey; Type: FK CONSTRAINT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY dataset
    ADD CONSTRAINT dataset_sensor_fkey FOREIGN KEY (sensor) REFERENCES sensor(id);


--
-- TOC entry 3237 (class 2606 OID 9650123)
-- Name: product_description_fkey; Type: FK CONSTRAINT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY product
    ADD CONSTRAINT product_description_fkey FOREIGN KEY (description) REFERENCES description(id);


--
-- TOC entry 3238 (class 2606 OID 9650128)
-- Name: product_unitofmeasure_fkey; Type: FK CONSTRAINT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY product
    ADD CONSTRAINT product_unitofmeasure_fkey FOREIGN KEY (unitofmeasure) REFERENCES unitofmeasure(id);


--
-- TOC entry 3239 (class 2606 OID 9650133)
-- Name: sensor2platform_platform_fkey; Type: FK CONSTRAINT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY sensor2platform
    ADD CONSTRAINT sensor2platform_platform_fkey FOREIGN KEY (platform) REFERENCES platform(id);


--
-- TOC entry 3240 (class 2606 OID 9650138)
-- Name: sensor2platform_sensor_fkey; Type: FK CONSTRAINT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY sensor2platform
    ADD CONSTRAINT sensor2platform_sensor_fkey FOREIGN KEY (sensor) REFERENCES sensor(id);


--
-- TOC entry 3241 (class 2606 OID 9650143)
-- Name: sensor2product_product_fkey; Type: FK CONSTRAINT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY sensor2product
    ADD CONSTRAINT sensor2product_product_fkey FOREIGN KEY (product) REFERENCES product(id);


--
-- TOC entry 3242 (class 2606 OID 9650148)
-- Name: sensor2product_sensor_fkey; Type: FK CONSTRAINT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY sensor2product
    ADD CONSTRAINT sensor2product_sensor_fkey FOREIGN KEY (sensor) REFERENCES sensor(id);


--
-- TOC entry 3230 (class 2606 OID 9650153)
-- Name: sensor_bands_fk; Type: FK CONSTRAINT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY bands
    ADD CONSTRAINT sensor_bands_fk FOREIGN KEY (sensor) REFERENCES sensor(id);


--
-- TOC entry 3231 (class 2606 OID 9650158)
-- Name: unit_of_measure_bands_fk; Type: FK CONSTRAINT; Schema: eodata; Owner: madmex_user
--

ALTER TABLE ONLY bands
    ADD CONSTRAINT unit_of_measure_bands_fk FOREIGN KEY (unitofmeasure) REFERENCES unitofmeasure(id);


-- Completed on 2014-05-27 13:24:39

--
-- PostgreSQL database dump complete
--

