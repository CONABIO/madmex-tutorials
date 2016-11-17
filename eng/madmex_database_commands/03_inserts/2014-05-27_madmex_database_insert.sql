--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.9
-- Dumped by pg_dump version 9.3.1
-- Started on 2014-05-27 13:30:59

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = eodata, pg_catalog;

--
-- TOC entry 3352 (class 0 OID 9650040)
-- Dependencies: 193
-- Data for Name: sensor; Type: TABLE DATA; Schema: eodata; Owner: madmex_user
--

INSERT INTO sensor VALUES (1, 'RE', 'RapidEye ');
INSERT INTO sensor VALUES (2, 'SPOT-5', 'SPOT 5 HRG multispectral');
INSERT INTO sensor VALUES (3, 'SPOT-5- P', 'SPOT 5 HRG panchromatic ');
INSERT INTO sensor VALUES (4, 'TM', 'Thematic mapper');
INSERT INTO sensor VALUES (5, 'ETM+', 'Enhanced Thematic Mapper Plus');
INSERT INTO sensor VALUES (6, 'MODIS', 'MODIS');
INSERT INTO sensor VALUES (8, 'AWF', 'AWF');
INSERT INTO sensor VALUES (9, 'L-3', 'L-3');
INSERT INTO sensor VALUES (10, 'WV02', 'WV02');
INSERT INTO sensor VALUES (11, 'SPOT-6', 'SPOT-6');
INSERT INTO sensor VALUES (12, 'OLI_TIRS', 'OLI_TIRS');


--
-- TOC entry 3358 (class 0 OID 9650055)
-- Dependencies: 199
-- Data for Name: unitofmeasure; Type: TABLE DATA; Schema: eodata; Owner: madmex_user
--

INSERT INTO unitofmeasure VALUES (1, 'nanometer', 'nm');
INSERT INTO unitofmeasure VALUES (2, 'micrometer', 'Âµm');
INSERT INTO unitofmeasure VALUES (3, 'percent', '%');
INSERT INTO unitofmeasure VALUES (4, 'digital number', 'dn');
INSERT INTO unitofmeasure VALUES (5, 'degree celsius', 'Â°C');


--
-- TOC entry 3340 (class 0 OID 9649989)
-- Dependencies: 179
-- Data for Name: bands; Type: TABLE DATA; Schema: eodata; Owner: madmex_user
--

INSERT INTO bands VALUES (1, 1, 1, 0.439999998, 0.50999999, 2);
INSERT INTO bands VALUES (2, 1, 2, 0.519999981, 0.589999974, 2);
INSERT INTO bands VALUES (3, 1, 3, 0.629999995, 0.685000002, 2);
INSERT INTO bands VALUES (4, 1, 4, 0.689999998, 0.730000019, 2);
INSERT INTO bands VALUES (5, 1, 5, 0.75999999, 0.850000024, 2);
INSERT INTO bands VALUES (6, 2, 1, 0.5, 0.589999974, 2);
INSERT INTO bands VALUES (7, 2, 2, 0.610000014, 0.680000007, 2);
INSERT INTO bands VALUES (8, 2, 3, 0.779999971, 0.889999986, 2);
INSERT INTO bands VALUES (9, 2, 4, 1.58000004, 1.75, 2);
INSERT INTO bands VALUES (10, 3, 1, 0.479999989, 0.709999979, 2);
INSERT INTO bands VALUES (11, 4, 1, 0.449999988, 0.519999981, 2);
INSERT INTO bands VALUES (12, 4, 2, 0.519999981, 0.600000024, 2);
INSERT INTO bands VALUES (13, 4, 3, 0.629999995, 0.689999998, 2);
INSERT INTO bands VALUES (14, 4, 4, 0.75999999, 0.899999976, 2);
INSERT INTO bands VALUES (15, 4, 5, 1.54999995, 1.75, 2);
INSERT INTO bands VALUES (16, 4, 6, 10.3999996, 12.5, 2);
INSERT INTO bands VALUES (17, 4, 7, 2.07999992, 2.3499999, 2);
INSERT INTO bands VALUES (18, 5, 1, 0.449999988, 0.514999986, 2);
INSERT INTO bands VALUES (19, 5, 2, 0.524999976, 0.605000019, 2);
INSERT INTO bands VALUES (20, 5, 3, 0.629999995, 0.689999998, 2);
INSERT INTO bands VALUES (21, 5, 4, 0.75, 0.899999976, 2);
INSERT INTO bands VALUES (22, 5, 5, 1.54999995, 1.75, 2);
INSERT INTO bands VALUES (23, 5, 6, 10.3999996, 12.5, 2);
INSERT INTO bands VALUES (24, 5, 7, 2.08999991, 2.3499999, 2);
INSERT INTO bands VALUES (25, 5, 8, 0.519999981, 0.899999976, 2);


--
-- TOC entry 3364 (class 0 OID 0)
-- Dependencies: 180
-- Name: bands_id_seq; Type: SEQUENCE SET; Schema: eodata; Owner: madmex_user
--

SELECT pg_catalog.setval('bands_id_seq', 25, true);


--
-- TOC entry 3365 (class 0 OID 0)
-- Dependencies: 183
-- Name: dataset_description_id_seq; Type: SEQUENCE SET; Schema: eodata; Owner: madmex_user
--

SELECT pg_catalog.setval('dataset_description_id_seq', 4, true);


--
-- TOC entry 3342 (class 0 OID 9650001)
-- Dependencies: 182
-- Data for Name: description; Type: TABLE DATA; Schema: eodata; Owner: madmex_user
--

INSERT INTO description VALUES (1, 'Landsat raw imagery', 'USGS', 'USGS', 'USGS');
INSERT INTO description VALUES (2, 'Landsat LEDAPS calibrated products', 'MADMEX/CONABIO', 'CONABIO', NULL);
INSERT INTO description VALUES (3, 'Landsat FMASK derived data masks', 'MADMEX/CONABIO', 'CONABIO', NULL);
INSERT INTO description VALUES (4, 'RapidEye raw imagery', 'Blackbridge', 'Blackbridge', 'Blackbridge');


--
-- TOC entry 3344 (class 0 OID 9650011)
-- Dependencies: 185
-- Data for Name: format; Type: TABLE DATA; Schema: eodata; Owner: madmex_user
--

INSERT INTO format VALUES (1, 'TIFF / BigTIFF / GeoTIFF', 'tif', 'image/tiff');
INSERT INTO format VALUES (2, 'Hierarchical Data Format Release 4 (HDF4)', 'hdf', 'application/x-hdf');
INSERT INTO format VALUES (3, 'Hierarchical Data Format Release 5 (HDF5)', 'h5', 'application/x-hdf');
INSERT INTO format VALUES (4, 'Spot DIMAP (metadata.dim)', 'dim', NULL);


--
-- TOC entry 3366 (class 0 OID 0)
-- Dependencies: 186
-- Name: format_id_seq; Type: SEQUENCE SET; Schema: eodata; Owner: madmex_user
--

SELECT pg_catalog.setval('format_id_seq', 4, true);


--
-- TOC entry 3346 (class 0 OID 9650019)
-- Dependencies: 187
-- Data for Name: platform; Type: TABLE DATA; Schema: eodata; Owner: madmex_user
--

INSERT INTO platform VALUES (1, 'RE1', 'RapidEye 1 (Tachys)');
INSERT INTO platform VALUES (2, 'RE2', 'RapidEye 2 (Mati)');
INSERT INTO platform VALUES (3, 'RE3', 'RapidEye 3 (Choma)');
INSERT INTO platform VALUES (4, 'RE4', 'RapidEye 4 (Choros)');
INSERT INTO platform VALUES (5, 'RE5', 'RapidEye 5 (Trochia)');
INSERT INTO platform VALUES (6, 'SPOT-5', 'SPOT 5');
INSERT INTO platform VALUES (7, 'LS-4', 'Landsat 4');
INSERT INTO platform VALUES (8, 'LS-5', 'Landsat 5');
INSERT INTO platform VALUES (9, 'LS-6', 'Landsat 6');
INSERT INTO platform VALUES (10, 'LS-7', 'Landsat 7');
INSERT INTO platform VALUES (11, 'LS-8', 'Landsat 8');
INSERT INTO platform VALUES (13, 'Terra', 'MODIS Terra');
INSERT INTO platform VALUES (12, 'Aqua', 'MODIS Aqua');
INSERT INTO platform VALUES (14, 'P6', 'P6');
INSERT INTO platform VALUES (15, 'WV02', 'WV02');
INSERT INTO platform VALUES (16, 'SPOT-6', 'SPOT-6');


--
-- TOC entry 3367 (class 0 OID 0)
-- Dependencies: 188
-- Name: platform_id_seq; Type: SEQUENCE SET; Schema: eodata; Owner: madmex_user
--

SELECT pg_catalog.setval('platform_id_seq', 16, true);


--
-- TOC entry 3348 (class 0 OID 9650024)
-- Dependencies: 189
-- Data for Name: product; Type: TABLE DATA; Schema: eodata; Owner: madmex_user
--

INSERT INTO product VALUES (1, '1', 'Level 1B', 'L1B', 4, 4);
INSERT INTO product VALUES (2, '2', 'Level 3A', 'L3A', 4, 4);
INSERT INTO product VALUES (5, '3', 'LEDAPS TOA reflectance', 'lndcal', 5, 2);
INSERT INTO product VALUES (6, '4', 'LEDAPS Surface reflectance', 'lndsr', 5, 2);
INSERT INTO product VALUES (7, '5', 'LEDAPS Temperature', 'lndth', 3, 2);
INSERT INTO product VALUES (8, '6', 'LEDPAS Masks', 'lndcsm', 4, 2);
INSERT INTO product VALUES (9, '7', 'FMASK', 'fmask', 4, 3);
INSERT INTO product VALUES (3, '1', 'systematic radiometric and geometric corrected', 'L1G', 4, 1);
INSERT INTO product VALUES (4, '2', 'systematic radiometric and terrain corrected', 'L1T', 4, 1);
INSERT INTO product VALUES (15, '3', 'MODIS BRDF Corrected Reflectances MCD43A4', 'MCD43A4', 5, 2);
INSERT INTO product VALUES (13, '2', 'World View II Level 2A', 'LV2A-Multi', 4, 1);
INSERT INTO product VALUES (14, '2', 'World View II Level 2A Pan', 'LV2A-P', 4, 1);
INSERT INTO product VALUES (11, '2', 'World View II Level 2A Orthorectified', 'LV2A-Multi-ORTHO', 4, 1);
INSERT INTO product VALUES (12, '2', 'World View II Level 2A Pan Orthorectified', 'LV2A-P-ORTHO', 4, 1);


--
-- TOC entry 3368 (class 0 OID 0)
-- Dependencies: 190
-- Name: product_id_seq; Type: SEQUENCE SET; Schema: eodata; Owner: madmex_user
--

SELECT pg_catalog.setval('product_id_seq', 16, true);


--
-- TOC entry 3350 (class 0 OID 9650032)
-- Dependencies: 191
-- Data for Name: rights; Type: TABLE DATA; Schema: eodata; Owner: madmex_user
--

INSERT INTO rights VALUES (1, 'Do what you want. ', 'Hans Wurst');


--
-- TOC entry 3369 (class 0 OID 0)
-- Dependencies: 192
-- Name: rights_id_seq; Type: SEQUENCE SET; Schema: eodata; Owner: madmex_user
--

SELECT pg_catalog.setval('rights_id_seq', 1, true);


--
-- TOC entry 3353 (class 0 OID 9650043)
-- Dependencies: 194
-- Data for Name: sensor2platform; Type: TABLE DATA; Schema: eodata; Owner: madmex_user
--

INSERT INTO sensor2platform VALUES (1, 1, 1);
INSERT INTO sensor2platform VALUES (2, 1, 2);
INSERT INTO sensor2platform VALUES (3, 1, 3);
INSERT INTO sensor2platform VALUES (4, 1, 4);
INSERT INTO sensor2platform VALUES (5, 1, 5);
INSERT INTO sensor2platform VALUES (6, 2, 6);
INSERT INTO sensor2platform VALUES (7, 3, 6);
INSERT INTO sensor2platform VALUES (8, 4, 8);
INSERT INTO sensor2platform VALUES (9, 5, 10);


--
-- TOC entry 3370 (class 0 OID 0)
-- Dependencies: 195
-- Name: sensor2platform_id_seq; Type: SEQUENCE SET; Schema: eodata; Owner: madmex_user
--

SELECT pg_catalog.setval('sensor2platform_id_seq', 9, true);


--
-- TOC entry 3355 (class 0 OID 9650048)
-- Dependencies: 196
-- Data for Name: sensor2product; Type: TABLE DATA; Schema: eodata; Owner: madmex_user
--

INSERT INTO sensor2product VALUES (1, 1, 1);
INSERT INTO sensor2product VALUES (2, 1, 2);
INSERT INTO sensor2product VALUES (3, 4, 3);
INSERT INTO sensor2product VALUES (4, 4, 4);
INSERT INTO sensor2product VALUES (5, 4, 5);
INSERT INTO sensor2product VALUES (6, 4, 6);
INSERT INTO sensor2product VALUES (7, 4, 7);
INSERT INTO sensor2product VALUES (8, 4, 8);
INSERT INTO sensor2product VALUES (9, 5, 3);
INSERT INTO sensor2product VALUES (10, 5, 4);
INSERT INTO sensor2product VALUES (11, 5, 5);
INSERT INTO sensor2product VALUES (12, 5, 6);
INSERT INTO sensor2product VALUES (13, 5, 7);
INSERT INTO sensor2product VALUES (14, 5, 8);
INSERT INTO sensor2product VALUES (15, 4, 9);
INSERT INTO sensor2product VALUES (16, 5, 9);


--
-- TOC entry 3371 (class 0 OID 0)
-- Dependencies: 197
-- Name: sensor2product_id_seq; Type: SEQUENCE SET; Schema: eodata; Owner: madmex_user
--

SELECT pg_catalog.setval('sensor2product_id_seq', 16, true);


--
-- TOC entry 3372 (class 0 OID 0)
-- Dependencies: 198
-- Name: sensor_id_seq; Type: SEQUENCE SET; Schema: eodata; Owner: madmex_user
--

SELECT pg_catalog.setval('sensor_id_seq', 12, true);


--
-- TOC entry 3373 (class 0 OID 0)
-- Dependencies: 200
-- Name: unit_of_measure_id_seq; Type: SEQUENCE SET; Schema: eodata; Owner: madmex_user
--

SELECT pg_catalog.setval('unit_of_measure_id_seq', 5, true);


-- Completed on 2014-05-27 13:31:00

--
-- PostgreSQL database dump complete
--

