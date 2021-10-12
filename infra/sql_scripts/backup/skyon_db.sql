--
-- PostgreSQL database dump
--

-- Dumped from database version 13.4
-- Dumped by pg_dump version 13.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE IF EXISTS skyon_db;
--
-- Name: skyon_db; Type: DATABASE; Schema: -; Owner: skyon_usr
--

CREATE DATABASE skyon_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.utf8';


ALTER DATABASE skyon_db OWNER TO skyon_usr;

\connect skyon_db

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
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
-- Name: item_instance; Type: TABLE; Schema: public; Owner: skyon_usr
--

CREATE TABLE public.item_instance (
    id bigint NOT NULL,
    resource_uuid text NOT NULL,
    tier smallint NOT NULL,
    quality smallint NOT NULL,
    required_proficiency smallint NOT NULL,
    stack_count smallint,
    consumable_action_effect_list jsonb,
    equipment_max_durability smallint,
    equipment_durability smallint,
    equipment_skills jsonb,
    equipment_attributes jsonb
);


ALTER TABLE public.item_instance OWNER TO skyon_usr;

--
-- Name: item_instance_id_seq; Type: SEQUENCE; Schema: public; Owner: skyon_usr
--

ALTER TABLE public.item_instance ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.item_instance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: item_instance item_instance_pkey; Type: CONSTRAINT; Schema: public; Owner: skyon_usr
--

ALTER TABLE ONLY public.item_instance
    ADD CONSTRAINT item_instance_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

