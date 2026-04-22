--
-- PostgreSQL database dump
--

\restrict C0AXAKNsyzFErhdrtISzhlUPKkwXRk1GIclOvzcb0txKdzxaRYy52iK6lmBXcGA

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-04-22 19:12:14

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
-- TOC entry 232 (class 1255 OID 24772)
-- Name: fn_maas_log(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_maas_log() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
insert into maas_hareket(calisan_id, eski_maas, yeni_maas)
values (OLD.id, OLD.maas, NEW.maas);
return NEW;
end;
$$;


--
-- TOC entry 233 (class 1255 OID 24768)
-- Name: sp_calisan_ekle(character varying, character varying, integer, integer, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_calisan_ekle(IN p_ad character varying, IN p_soyad character varying, IN p_yas integer, IN p_maas integer, IN p_departman_id integer)
    LANGUAGE plpgsql
    AS $$
begin
insert into calisan(ad, soyad, yas, maas, departman_id)
values (p_ad, p_soyad, p_yas, p_maas, p_departman_id);
end;
$$;


--
-- TOC entry 231 (class 1255 OID 24770)
-- Name: sp_maas_guncelle(integer, integer); Type: PROCEDURE; Schema: public; Owner: -
--

CREATE PROCEDURE public.sp_maas_guncelle(IN p_calisan_id integer, IN p_yeni_maas integer)
    LANGUAGE plpgsql
    AS $$
declare eski int;
begin
select maas into eski from calisan where id=p_calisan_id;

update calisan
set maas=p_yeni_maas
where id=p_calisan_id;

insert into maas_hareket(calisan_id, eski_maas, yeni_maas)
values (p_calisan_id, eski, p_yeni_maas);
end;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 24702)
-- Name: calisan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calisan (
    id bigint NOT NULL,
    ad character varying(50),
    soyad character varying(50),
    yas integer,
    maas integer,
    departman_id integer,
    ise_giris_tarihi date DEFAULT CURRENT_DATE
);


--
-- TOC entry 221 (class 1259 OID 24701)
-- Name: calisan_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.calisan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5069 (class 0 OID 0)
-- Dependencies: 221
-- Name: calisan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.calisan_id_seq OWNED BY public.calisan.id;


--
-- TOC entry 227 (class 1259 OID 24738)
-- Name: calisan_proje; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calisan_proje (
    calisan_id integer NOT NULL,
    proje_id integer NOT NULL,
    gorev character varying(50)
);


--
-- TOC entry 220 (class 1259 OID 24691)
-- Name: departman; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.departman (
    id bigint NOT NULL,
    ad character varying(50) NOT NULL
);


--
-- TOC entry 219 (class 1259 OID 24690)
-- Name: departman_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.departman_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5070 (class 0 OID 0)
-- Dependencies: 219
-- Name: departman_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.departman_id_seq OWNED BY public.departman.id;


--
-- TOC entry 224 (class 1259 OID 24717)
-- Name: maas_hareket; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maas_hareket (
    id bigint NOT NULL,
    calisan_id integer,
    eski_maas integer,
    yeni_maas integer,
    degisim_tarihi timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- TOC entry 223 (class 1259 OID 24716)
-- Name: maas_hareket_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.maas_hareket_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5071 (class 0 OID 0)
-- Dependencies: 223
-- Name: maas_hareket_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.maas_hareket_id_seq OWNED BY public.maas_hareket.id;


--
-- TOC entry 226 (class 1259 OID 24731)
-- Name: proje; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.proje (
    id bigint NOT NULL,
    ad character varying(100),
    baslangic date,
    durum character varying(20)
);


--
-- TOC entry 225 (class 1259 OID 24730)
-- Name: proje_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.proje_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5072 (class 0 OID 0)
-- Dependencies: 225
-- Name: proje_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.proje_id_seq OWNED BY public.proje.id;


--
-- TOC entry 228 (class 1259 OID 24756)
-- Name: vw_calisan_detay; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_calisan_detay AS
 SELECT c.id,
    c.ad,
    c.soyad,
    c.maas,
    d.ad AS departman,
    c.ise_giris_tarihi
   FROM (public.calisan c
     JOIN public.departman d ON ((c.departman_id = d.id)));


--
-- TOC entry 230 (class 1259 OID 24764)
-- Name: vw_departman_maas; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_departman_maas AS
 SELECT d.ad,
    avg(c.maas) AS ortalama_maas
   FROM (public.calisan c
     JOIN public.departman d ON ((d.id = c.departman_id)))
  GROUP BY d.ad;


--
-- TOC entry 229 (class 1259 OID 24760)
-- Name: vw_proje_calisan; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.vw_proje_calisan AS
 SELECT p.ad AS proje,
    c.ad AS calisan,
    cp.gorev
   FROM ((public.calisan_proje cp
     JOIN public.calisan c ON ((c.id = cp.calisan_id)))
     JOIN public.proje p ON ((p.id = cp.proje_id)));


--
-- TOC entry 4891 (class 2604 OID 24705)
-- Name: calisan id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calisan ALTER COLUMN id SET DEFAULT nextval('public.calisan_id_seq'::regclass);


--
-- TOC entry 4890 (class 2604 OID 24694)
-- Name: departman id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departman ALTER COLUMN id SET DEFAULT nextval('public.departman_id_seq'::regclass);


--
-- TOC entry 4893 (class 2604 OID 24720)
-- Name: maas_hareket id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maas_hareket ALTER COLUMN id SET DEFAULT nextval('public.maas_hareket_id_seq'::regclass);


--
-- TOC entry 4895 (class 2604 OID 24734)
-- Name: proje id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proje ALTER COLUMN id SET DEFAULT nextval('public.proje_id_seq'::regclass);


--
-- TOC entry 4901 (class 2606 OID 24709)
-- Name: calisan calisan_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calisan
    ADD CONSTRAINT calisan_pkey PRIMARY KEY (id);


--
-- TOC entry 4908 (class 2606 OID 24744)
-- Name: calisan_proje calisan_proje_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calisan_proje
    ADD CONSTRAINT calisan_proje_pkey PRIMARY KEY (calisan_id, proje_id);


--
-- TOC entry 4897 (class 2606 OID 24700)
-- Name: departman departman_ad_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departman
    ADD CONSTRAINT departman_ad_key UNIQUE (ad);


--
-- TOC entry 4899 (class 2606 OID 24698)
-- Name: departman departman_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departman
    ADD CONSTRAINT departman_pkey PRIMARY KEY (id);


--
-- TOC entry 4904 (class 2606 OID 24724)
-- Name: maas_hareket maas_hareket_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maas_hareket
    ADD CONSTRAINT maas_hareket_pkey PRIMARY KEY (id);


--
-- TOC entry 4906 (class 2606 OID 24737)
-- Name: proje proje_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proje
    ADD CONSTRAINT proje_pkey PRIMARY KEY (id);


--
-- TOC entry 4902 (class 1259 OID 24755)
-- Name: idx_calisan_departman; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_calisan_departman ON public.calisan USING btree (departman_id);


--
-- TOC entry 4913 (class 2620 OID 24773)
-- Name: calisan trg_maas_degisim; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_maas_degisim AFTER UPDATE ON public.calisan FOR EACH ROW WHEN ((old.maas IS DISTINCT FROM new.maas)) EXECUTE FUNCTION public.fn_maas_log();


--
-- TOC entry 4909 (class 2606 OID 24710)
-- Name: calisan calisan_departman_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calisan
    ADD CONSTRAINT calisan_departman_id_fkey FOREIGN KEY (departman_id) REFERENCES public.departman(id);


--
-- TOC entry 4911 (class 2606 OID 24745)
-- Name: calisan_proje calisan_proje_calisan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calisan_proje
    ADD CONSTRAINT calisan_proje_calisan_id_fkey FOREIGN KEY (calisan_id) REFERENCES public.calisan(id);


--
-- TOC entry 4912 (class 2606 OID 24750)
-- Name: calisan_proje calisan_proje_proje_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calisan_proje
    ADD CONSTRAINT calisan_proje_proje_id_fkey FOREIGN KEY (proje_id) REFERENCES public.proje(id);


--
-- TOC entry 4910 (class 2606 OID 24725)
-- Name: maas_hareket maas_hareket_calisan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maas_hareket
    ADD CONSTRAINT maas_hareket_calisan_id_fkey FOREIGN KEY (calisan_id) REFERENCES public.calisan(id);


-- Completed on 2026-04-22 19:12:14

--
-- PostgreSQL database dump complete
--

\unrestrict C0AXAKNsyzFErhdrtISzhlUPKkwXRk1GIclOvzcb0txKdzxaRYy52iK6lmBXcGA

