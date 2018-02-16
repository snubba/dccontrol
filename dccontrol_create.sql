--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';

--
-- Name: hwtype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE hwtype AS ENUM (
    'server',
    'switch',
    'storage',
    'free'
);

--
-- Name: nwport; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE nwport AS ENUM (
    '1G RJ45',
    '10G FSP+'
);

--
-- Name: dc_id; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE dcid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: datacenter; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE datacenter (
    id integer DEFAULT nextval('dcid'::regclass) NOT NULL,
    name text
);

--
-- Name: dcroomid; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE dcroomid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: dcrows; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE dcrows
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: hwid; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE hwid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: hardware; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE hardware (
    id integer DEFAULT nextval('hwid'::regclass) NOT NULL,
    required_slots integer,
    typ hwtype,
    name text
);

--
-- Name: heid; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE heid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: networkportid; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE networkportid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: networkport; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE networkport (
    id integer DEFAULT nextval('networkportid'::regclass) NOT NULL,
    hardware_id integer,
    incoming boolean DEFAULT false,
    typ nwport,
    portname text
);

--
-- Name: networkportconnection; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE networkportconnection (
    incoming integer,
    outgoing integer
);

--
-- Name: protvlan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE protvlan (
    vlan_id integer NOT NULL,
    network_port integer NOT NULL
);

--
-- Name: rackid; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE rackid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: rack; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE rack (
    id integer DEFAULT nextval('rackid'::regclass) NOT NULL,
    name text,
    row_id integer,
    owner text
);

--
-- Name: rooms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE rooms (
    id integer DEFAULT nextval('dcroomid'::regclass) NOT NULL,
    name text,
    dc_id integer
);

--
-- Name: rows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE rows (
    id integer DEFAULT nextval('dcrows'::regclass) NOT NULL,
    name text,
    room_id integer
);

--
-- Name: slot; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE slot (
    id integer NOT NULL,
    hardware_id integer,
    rack_id integer NOT NULL
);

--
-- Data for Name: datacenter; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY datacenter (id, name) FROM stdin;
1	testdc
\.


--
-- Name: dc_id; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('dc_id', 1, true);


--
-- Name: dcroomid; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('dcroomid', 1, true);


--
-- Name: dcrows; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('dcrows', 2, true);


--
-- Data for Name: hardware; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY hardware (id, required_slots, typ, name) FROM stdin;
-1	1	free	\N
1	0	switch	testswitch
\.


--
-- Name: hwid; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('hwid', 1, true);


--
-- Data for Name: networkport; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY networkport (id, hardware_id, incoming, typ, portname) FROM stdin;
1	1	t	1G RJ45	Eth 1
2	1	t	1G RJ45	Eth 2
3	1	t	1G RJ45	Eth 3
4	1	t	1G RJ45	Eth 4
5	1	t	1G RJ45	Eth 5
6	1	t	1G RJ45	Eth 6
7	1	t	1G RJ45	Eth 7
8	1	t	1G RJ45	Eth 8
9	1	t	1G RJ45	Eth 9
10	1	t	1G RJ45	Eth 10
11	1	t	1G RJ45	Eth 11
12	1	t	1G RJ45	Eth 12
\.


--
-- Data for Name: networkportconnection; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY networkportconnection (incoming, outgoing) FROM stdin;
\.


--
-- Name: networkportid; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('networkportid', 12, true);


--
-- Name: portvlanid; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('portvlanid', 1, false);


--
-- Data for Name: protvlan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY protvlan (vlan_id, network_port) FROM stdin;
120	1
300	2
\.


--
-- Data for Name: rack; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY rack (id, name, row_id, owner) FROM stdin;
1	1	1	\N
2	2	1	\N
3	3	1	\N
\.


--
-- Name: rackid; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('rackid', 3, true);


--
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY rooms (id, name, dc_id) FROM stdin;
1	R01	1
\.


--
-- Data for Name: rows; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY rows (id, name, room_id) FROM stdin;
1	S1	1
2	S2	1
\.


--
-- Data for Name: slot; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY slot (id, hardware_id, rack_id) FROM stdin;
2	-1	1
3	-1	1
4	-1	1
5	-1	1
6	-1	1
7	-1	1
8	-1	1
9	-1	1
10	-1	1
11	-1	1
12	-1	1
13	-1	1
14	-1	1
15	-1	1
16	-1	1
17	-1	1
18	-1	1
19	-1	1
20	-1	1
21	-1	1
22	-1	1
23	-1	1
24	-1	1
25	-1	1
26	-1	1
27	-1	1
28	-1	1
29	-1	1
30	-1	1
31	-1	1
32	-1	1
33	-1	1
34	-1	1
35	-1	1
36	-1	1
37	-1	1
38	-1	1
1	1	1
\.


--
-- Name: datacenter_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY datacenter
    ADD CONSTRAINT datacenter_pkey PRIMARY KEY (id);


--
-- Name: hardware_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hardware
    ADD CONSTRAINT hardware_pkey PRIMARY KEY (id);


--
-- Name: networkport_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY networkport
    ADD CONSTRAINT networkport_pkey PRIMARY KEY (id);


--
-- Name: protvlan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY protvlan
    ADD CONSTRAINT protvlan_pkey PRIMARY KEY (vlan_id, network_port);


--
-- Name: rack_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rack
    ADD CONSTRAINT rack_pkey PRIMARY KEY (id);


--
-- Name: rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- Name: rows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rows
    ADD CONSTRAINT rows_pkey PRIMARY KEY (id);


--
-- Name: slot_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY slot
    ADD CONSTRAINT slot_pkey PRIMARY KEY (id, rack_id);


--
-- Name: networkport_hardware_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY networkport
    ADD CONSTRAINT networkport_hardware_id_fkey FOREIGN KEY (hardware_id) REFERENCES hardware(id);


--
-- Name: networkportconnection_incoming_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY networkportconnection
    ADD CONSTRAINT networkportconnection_incoming_fkey FOREIGN KEY (incoming) REFERENCES networkport(id);


--
-- Name: networkportconnection_outgoing_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY networkportconnection
    ADD CONSTRAINT networkportconnection_outgoing_fkey FOREIGN KEY (outgoing) REFERENCES networkport(id);


--
-- Name: protvlan_network_port_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY protvlan
    ADD CONSTRAINT protvlan_network_port_fkey FOREIGN KEY (network_port) REFERENCES networkport(id);


--
-- Name: rack_row_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rack
    ADD CONSTRAINT rack_row_id_fkey FOREIGN KEY (row_id) REFERENCES rows(id);


--
-- Name: rooms_dc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rooms
    ADD CONSTRAINT rooms_dc_id_fkey FOREIGN KEY (dc_id) REFERENCES datacenter(id);


--
-- Name: rows_room_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY rows
    ADD CONSTRAINT rows_room_id_fkey FOREIGN KEY (room_id) REFERENCES rooms(id);


--
-- Name: slot_hardware_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY slot
    ADD CONSTRAINT slot_hardware_id_fkey FOREIGN KEY (hardware_id) REFERENCES hardware(id);


--
-- Name: slot_rack_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY slot
    ADD CONSTRAINT slot_rack_id_fkey FOREIGN KEY (rack_id) REFERENCES rack(id);

