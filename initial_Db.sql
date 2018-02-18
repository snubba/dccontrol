--
-- PostgreSQL database dump
--

-- Dumped from database version 10.2
-- Dumped by pg_dump version 10.2

--
-- Name: hwtype; Type: TYPE; Schema: public
--

CREATE TYPE hwtype AS ENUM (
    'server',
    'switch',
    'storage',
    'free'
);

--
-- Name: nwport; Type: TYPE; Schema: public
--

CREATE TYPE nwport AS ENUM (
    '1G RJ45',
    '10G FSP+'
);

--
-- Name: dcid; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE dcid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

SET default_tablespace = '';

--
-- Name: datacenter; Type: TABLE; Schema: public
--

CREATE TABLE datacenter (
    id integer DEFAULT nextval('dcid'::regclass) NOT NULL,
    name text NOT NULL
);

--
-- Name: dcroomid; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE dcroomid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: dcrows; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE dcrows
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: hwid; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE hwid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: hardware; Type: TABLE; Schema: public
--

CREATE TABLE hardware (
    id integer DEFAULT nextval('hwid'::regclass) NOT NULL,
    required_slots integer,
    typ hwtype NOT NULL,
    name text
);

--
-- Name: heid; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE heid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: networkportid; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE networkportid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: networkport; Type: TABLE; Schema: public
--

CREATE TABLE networkport (
    id integer DEFAULT nextval('networkportid'::regclass) NOT NULL,
    hardware_id integer NOT NULL,
    incoming boolean DEFAULT false,
    typ nwport NOT NULL,
    portname text
);

--
-- Name: networkportconnection; Type: TABLE; Schema: public
--

CREATE TABLE networkportconnection (
    incoming integer,
    outgoing integer
);

--
-- Name: rackid; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE rackid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: rack; Type: TABLE; Schema: public
--

CREATE TABLE rack (
    id integer DEFAULT nextval('rackid'::regclass) NOT NULL,
    name text NOT NULL,
    row_id integer NOT NULL,
    owner text
);

--
-- Name: rooms; Type: TABLE; Schema: public
--

CREATE TABLE rooms (
    id integer DEFAULT nextval('dcroomid'::regclass) NOT NULL,
    name text,
    dc_id integer NOT NULL
);

--
-- Name: rows; Type: TABLE; Schema: public
--

CREATE TABLE rows (
    id integer DEFAULT nextval('dcrows'::regclass) NOT NULL,
    name text,
    room_id integer
);

--
-- Name: slot; Type: TABLE; Schema: public
--

CREATE TABLE slot (
    id integer NOT NULL,
    hardware_id integer DEFAULT '-1',
    rack_id integer NOT NULL
);

--
-- Name: switchvlans; Type: TABLE; Schema: public
--

CREATE TABLE switchvlans (
    vlan_id integer NOT NULL,
    hardware_id integer NOT NULL
);

--
-- Data for Name: datacenter; Type: TABLE DATA; Schema: public
--

COPY datacenter (id, name) FROM stdin;
1	testdc
\.


--
-- Data for Name: hardware; Type: TABLE DATA; Schema: public
--

COPY hardware (id, required_slots, typ, name) FROM stdin;
-1	1	free	\N
1	0	switch	testswitch
9	1	server	test2
10	1	server	test3
\.


--
-- Data for Name: networkport; Type: TABLE DATA; Schema: public
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
16	9	f	1G RJ45	eth0
17	10	f	1G RJ45	eth0
\.


--
-- Data for Name: networkportconnection; Type: TABLE DATA; Schema: public
--

COPY networkportconnection (incoming, outgoing) FROM stdin;
2	16
3	17
\.


--
-- Data for Name: rack; Type: TABLE DATA; Schema: public
--

COPY rack (id, name, row_id, owner) FROM stdin;
1	1	1	\N
2	2	1	\N
3	3	1	\N
\.


--
-- Data for Name: rooms; Type: TABLE DATA; Schema: public
--

COPY rooms (id, name, dc_id) FROM stdin;
1	R01	1
\.


--
-- Data for Name: rows; Type: TABLE DATA; Schema: public
--

COPY rows (id, name, room_id) FROM stdin;
1	S1	1
2	S2	1
\.


--
-- Data for Name: slot; Type: TABLE DATA; Schema: public
--

COPY slot (id, hardware_id, rack_id) FROM stdin;
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
2	9	1
3	10	1
1	1	1
\.


--
-- Data for Name: switchvlans; Type: TABLE DATA; Schema: public
--

COPY switchvlans (vlan_id, hardware_id) FROM stdin;
300	1
180	1
\.


--
-- Name: dcid; Type: SEQUENCE SET; Schema: public
--

SELECT pg_catalog.setval('dcid', 1, false);


--
-- Name: dcroomid; Type: SEQUENCE SET; Schema: public
--

SELECT pg_catalog.setval('dcroomid', 1, true);


--
-- Name: dcrows; Type: SEQUENCE SET; Schema: public
--

SELECT pg_catalog.setval('dcrows', 2, true);


--
-- Name: heid; Type: SEQUENCE SET; Schema: public
--

SELECT pg_catalog.setval('heid', 1, false);


--
-- Name: hwid; Type: SEQUENCE SET; Schema: public
--

SELECT pg_catalog.setval('hwid', 11, true);


--
-- Name: networkportid; Type: SEQUENCE SET; Schema: public
--

SELECT pg_catalog.setval('networkportid', 17, true);


--
-- Name: rackid; Type: SEQUENCE SET; Schema: public
--

SELECT pg_catalog.setval('rackid', 3, true);


--
-- Name: networkportconnection conport_incomint_unique; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY networkportconnection
    ADD CONSTRAINT conport_incomint_unique UNIQUE (incoming);


--
-- Name: networkportconnection conport_outgoing_unique; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY networkportconnection
    ADD CONSTRAINT conport_outgoing_unique UNIQUE (outgoing);


--
-- Name: datacenter datacenter_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY datacenter
    ADD CONSTRAINT datacenter_pkey PRIMARY KEY (id);


--
-- Name: hardware hardware_name_unique; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY hardware
    ADD CONSTRAINT hardware_name_unique UNIQUE (name);


--
-- Name: hardware hardware_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY hardware
    ADD CONSTRAINT hardware_pkey PRIMARY KEY (id);


--
-- Name: networkport networkport_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY networkport
    ADD CONSTRAINT networkport_pkey PRIMARY KEY (id);


--
-- Name: networkport networkportname_hardware_unique; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY networkport
    ADD CONSTRAINT networkportname_hardware_unique UNIQUE (portname, hardware_id);


--
-- Name: rack rack_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY rack
    ADD CONSTRAINT rack_pkey PRIMARY KEY (id);


--
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- Name: rows rows_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY rows
    ADD CONSTRAINT rows_pkey PRIMARY KEY (id);


--
-- Name: slot slot_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY slot
    ADD CONSTRAINT slot_pkey PRIMARY KEY (id, rack_id);


--
-- Name: switchvlans switchvlans_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY switchvlans
    ADD CONSTRAINT switchvlans_pkey PRIMARY KEY (vlan_id, hardware_id);


--
-- Name: networkport networkport_hardware_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY networkport
    ADD CONSTRAINT networkport_hardware_id_fkey FOREIGN KEY (hardware_id) REFERENCES hardware(id);


--
-- Name: networkportconnection networkportconnection_incoming_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY networkportconnection
    ADD CONSTRAINT networkportconnection_incoming_fkey FOREIGN KEY (incoming) REFERENCES networkport(id);


--
-- Name: networkportconnection networkportconnection_outgoing_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY networkportconnection
    ADD CONSTRAINT networkportconnection_outgoing_fkey FOREIGN KEY (outgoing) REFERENCES networkport(id);


--
-- Name: rack rack_row_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY rack
    ADD CONSTRAINT rack_row_id_fkey FOREIGN KEY (row_id) REFERENCES rows(id);


--
-- Name: rooms rooms_dc_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY rooms
    ADD CONSTRAINT rooms_dc_id_fkey FOREIGN KEY (dc_id) REFERENCES datacenter(id);


--
-- Name: rows rows_room_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY rows
    ADD CONSTRAINT rows_room_id_fkey FOREIGN KEY (room_id) REFERENCES rooms(id);


--
-- Name: slot slot_hardware_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY slot
    ADD CONSTRAINT slot_hardware_id_fkey FOREIGN KEY (hardware_id) REFERENCES hardware(id);


--
-- Name: slot slot_rack_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY slot
    ADD CONSTRAINT slot_rack_id_fkey FOREIGN KEY (rack_id) REFERENCES rack(id);


--
-- Name: switchvlans switchvlans_hardware_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY switchvlans
    ADD CONSTRAINT switchvlans_hardware_id_fkey FOREIGN KEY (hardware_id) REFERENCES hardware(id);

