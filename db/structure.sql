--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: app_settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE app_settings (
    id integer NOT NULL,
    featured_set_id integer,
    splashscreen_slideshow_set_id integer,
    catalog_set_id integer,
    dropbox_root_dir character varying(255),
    ftp_dropbox_server character varying(255),
    ftp_dropbox_user character varying(255),
    ftp_dropbox_password character varying(255),
    title character varying(255),
    support_url character varying(255),
    welcome_title character varying(255),
    welcome_subtitle character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    logo_url character varying(255) DEFAULT '/assets/inserts/image-logo-zhdk.png'::character varying NOT NULL,
    brand character varying(255) DEFAULT 'Zürcher Hochschule der Künste'::character varying NOT NULL,
    footer_links text,
    second_displayed_meta_context_name character varying(255),
    third_displayed_meta_context_name character varying(255),
    CONSTRAINT oneandonly CHECK ((id = 0))
);


--
-- Name: copyrights; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE copyrights (
    id integer NOT NULL,
    is_default boolean DEFAULT false,
    is_custom boolean DEFAULT false,
    label character varying(255),
    parent_id integer,
    lft integer,
    rgt integer,
    usage character varying(255),
    url character varying(255)
);


--
-- Name: copyrights_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE copyrights_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: copyrights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE copyrights_id_seq OWNED BY copyrights.id;


--
-- Name: copyrights_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('copyrights_id_seq', 14, true);


--
-- Name: edit_sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE edit_sessions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    media_resource_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: edit_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE edit_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: edit_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE edit_sessions_id_seq OWNED BY edit_sessions.id;


--
-- Name: edit_sessions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('edit_sessions_id_seq', 116, true);


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites (
    user_id integer NOT NULL,
    media_resource_id integer NOT NULL
);


--
-- Name: full_texts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE full_texts (
    id integer NOT NULL,
    media_resource_id integer NOT NULL,
    text text
);


--
-- Name: full_texts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE full_texts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: full_texts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE full_texts_id_seq OWNED BY full_texts.id;


--
-- Name: full_texts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('full_texts_id_seq', 116, true);


--
-- Name: grouppermissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE grouppermissions (
    id integer NOT NULL,
    media_resource_id integer NOT NULL,
    group_id integer NOT NULL,
    download boolean DEFAULT false NOT NULL,
    view boolean DEFAULT false NOT NULL,
    edit boolean DEFAULT false NOT NULL,
    manage boolean DEFAULT false NOT NULL
);


--
-- Name: grouppermissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE grouppermissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: grouppermissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE grouppermissions_id_seq OWNED BY grouppermissions.id;


--
-- Name: grouppermissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('grouppermissions_id_seq', 35, true);


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE groups (
    id integer NOT NULL,
    name character varying(255),
    ldap_id character varying(255),
    ldap_name character varying(255),
    type character varying(255) DEFAULT 'Group'::character varying NOT NULL
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE groups_id_seq OWNED BY groups.id;


--
-- Name: groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('groups_id_seq', 851, true);


--
-- Name: groups_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE groups_users (
    group_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: keywords; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE keywords (
    id integer NOT NULL,
    meta_term_id integer NOT NULL,
    user_id integer,
    meta_datum_id integer NOT NULL,
    created_at timestamp without time zone
);


--
-- Name: keywords_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE keywords_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: keywords_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE keywords_id_seq OWNED BY keywords.id;


--
-- Name: keywords_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('keywords_id_seq', 307, true);


--
-- Name: media_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_files (
    id integer NOT NULL,
    height integer,
    size bigint,
    width integer,
    content_type character varying(255),
    filename character varying(255),
    guid character varying(255),
    access_hash text,
    meta_data text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    extension character varying(255),
    media_type character varying(255)
);


--
-- Name: media_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE media_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: media_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE media_files_id_seq OWNED BY media_files.id;


--
-- Name: media_files_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('media_files_id_seq', 115, true);


--
-- Name: media_resource_arcs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_resource_arcs (
    id integer NOT NULL,
    parent_id integer NOT NULL,
    child_id integer NOT NULL,
    highlight boolean DEFAULT false,
    cover boolean,
    CONSTRAINT media_resource_arcs_check CHECK ((parent_id <> child_id))
);


--
-- Name: media_resource_arcs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE media_resource_arcs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: media_resource_arcs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE media_resource_arcs_id_seq OWNED BY media_resource_arcs.id;


--
-- Name: media_resource_arcs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('media_resource_arcs_id_seq', 63, true);


--
-- Name: media_resources; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_resources (
    id integer NOT NULL,
    download boolean DEFAULT false NOT NULL,
    edit boolean DEFAULT false NOT NULL,
    manage boolean DEFAULT false NOT NULL,
    view boolean DEFAULT false NOT NULL,
    media_entry_id integer,
    media_file_id integer,
    user_id integer NOT NULL,
    settings text,
    type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: media_resources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE media_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: media_resources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE media_resources_id_seq OWNED BY media_resources.id;


--
-- Name: media_resources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('media_resources_id_seq', 116, true);


--
-- Name: media_sets_meta_contexts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_sets_meta_contexts (
    media_set_id integer NOT NULL,
    meta_context_name character varying(255)
);


--
-- Name: meta_context_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_context_groups (
    id integer NOT NULL,
    name character varying(255),
    "position" integer NOT NULL
);


--
-- Name: meta_context_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE meta_context_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meta_context_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE meta_context_groups_id_seq OWNED BY meta_context_groups.id;


--
-- Name: meta_context_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('meta_context_groups_id_seq', 3, true);


--
-- Name: meta_contexts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_contexts (
    label_id integer NOT NULL,
    description_id integer,
    meta_context_group_id integer,
    is_user_interface boolean DEFAULT false,
    "position" integer,
    name character varying(255) NOT NULL
);


--
-- Name: meta_data; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_data (
    id integer NOT NULL,
    copyright_id integer,
    media_resource_id integer NOT NULL,
    type character varying(255),
    string text,
    meta_key_id character varying(255)
);


--
-- Name: meta_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE meta_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meta_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE meta_data_id_seq OWNED BY meta_data.id;


--
-- Name: meta_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('meta_data_id_seq', 1182, true);


--
-- Name: meta_data_meta_departments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_data_meta_departments (
    meta_datum_id integer NOT NULL,
    meta_department_id integer NOT NULL
);


--
-- Name: meta_data_meta_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_data_meta_terms (
    meta_datum_id integer NOT NULL,
    meta_term_id integer NOT NULL
);


--
-- Name: meta_data_people; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_data_people (
    meta_datum_id integer NOT NULL,
    person_id integer NOT NULL
);


--
-- Name: meta_data_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_data_users (
    meta_datum_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: meta_key_definitions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_key_definitions (
    id integer NOT NULL,
    description_id integer,
    hint_id integer,
    label_id integer,
    is_required boolean DEFAULT false,
    length_max integer,
    length_min integer,
    "position" integer NOT NULL,
    key_map character varying(255),
    key_map_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    meta_key_id character varying(255),
    meta_context_name character varying(255)
);


--
-- Name: meta_key_definitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE meta_key_definitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meta_key_definitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE meta_key_definitions_id_seq OWNED BY meta_key_definitions.id;


--
-- Name: meta_key_definitions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('meta_key_definitions_id_seq', 837, true);


--
-- Name: meta_keys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_keys (
    is_extensible_list boolean,
    id character varying(255) NOT NULL,
    meta_datum_object_type character varying(255) DEFAULT 'MetaDatumString'::character varying NOT NULL
);


--
-- Name: meta_keys_meta_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_keys_meta_terms (
    id integer NOT NULL,
    meta_term_id integer NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    meta_key_id character varying(255)
);


--
-- Name: meta_keys_meta_terms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE meta_keys_meta_terms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meta_keys_meta_terms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE meta_keys_meta_terms_id_seq OWNED BY meta_keys_meta_terms.id;


--
-- Name: meta_keys_meta_terms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('meta_keys_meta_terms_id_seq', 548, true);


--
-- Name: meta_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_terms (
    id integer NOT NULL,
    en_gb character varying(255),
    de_ch character varying(255)
);


--
-- Name: meta_terms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE meta_terms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meta_terms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE meta_terms_id_seq OWNED BY meta_terms.id;


--
-- Name: meta_terms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('meta_terms_id_seq', 4616, true);


--
-- Name: people; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE people (
    id integer NOT NULL,
    is_group boolean DEFAULT false,
    date_of_birth date,
    date_of_death date,
    first_name character varying(255),
    last_name character varying(255),
    pseudonym character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: people_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE people_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: people_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE people_id_seq OWNED BY people.id;


--
-- Name: people_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('people_id_seq', 34, true);


--
-- Name: permission_presets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE permission_presets (
    id integer NOT NULL,
    name character varying(255),
    download boolean DEFAULT false NOT NULL,
    view boolean DEFAULT false NOT NULL,
    edit boolean DEFAULT false NOT NULL,
    manage boolean DEFAULT false NOT NULL
);


--
-- Name: permission_presets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE permission_presets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permission_presets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE permission_presets_id_seq OWNED BY permission_presets.id;


--
-- Name: permission_presets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('permission_presets_id_seq', 5, true);


--
-- Name: previews; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE previews (
    id integer NOT NULL,
    media_file_id integer NOT NULL,
    height integer,
    width integer,
    content_type character varying(255),
    filename character varying(255),
    thumbnail character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: previews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE previews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: previews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE previews_id_seq OWNED BY previews.id;


--
-- Name: previews_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('previews_id_seq', 562, true);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: usage_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE usage_terms (
    id integer NOT NULL,
    title character varying(255),
    version character varying(255),
    intro text,
    body text,
    updated_at timestamp without time zone
);


--
-- Name: usage_terms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE usage_terms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usage_terms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE usage_terms_id_seq OWNED BY usage_terms.id;


--
-- Name: usage_terms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('usage_terms_id_seq', 1, true);


--
-- Name: userpermissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE userpermissions (
    id integer NOT NULL,
    media_resource_id integer NOT NULL,
    user_id integer NOT NULL,
    download boolean DEFAULT false NOT NULL,
    view boolean DEFAULT false NOT NULL,
    edit boolean DEFAULT false NOT NULL,
    manage boolean DEFAULT false NOT NULL
);


--
-- Name: userpermissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE userpermissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: userpermissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE userpermissions_id_seq OWNED BY userpermissions.id;


--
-- Name: userpermissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('userpermissions_id_seq', 31, true);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    person_id integer NOT NULL,
    zhdkid integer,
    email character varying(100),
    login character varying(40),
    notes text,
    usage_terms_accepted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    password_digest character varying(255)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('users_id_seq', 7, true);


--
-- Name: visualizations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE visualizations (
    user_id integer NOT NULL,
    resource_identifier character varying(255) NOT NULL,
    control_settings text,
    layout text
);


--
-- Name: zencoder_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE zencoder_jobs (
    id uuid NOT NULL,
    media_file_id integer NOT NULL,
    zencoder_id integer,
    comment text,
    state character varying(255) DEFAULT 'initialized'::character varying NOT NULL,
    error text,
    notification text,
    request text,
    response text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY copyrights ALTER COLUMN id SET DEFAULT nextval('copyrights_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY edit_sessions ALTER COLUMN id SET DEFAULT nextval('edit_sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY full_texts ALTER COLUMN id SET DEFAULT nextval('full_texts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY grouppermissions ALTER COLUMN id SET DEFAULT nextval('grouppermissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY keywords ALTER COLUMN id SET DEFAULT nextval('keywords_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_files ALTER COLUMN id SET DEFAULT nextval('media_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_resource_arcs ALTER COLUMN id SET DEFAULT nextval('media_resource_arcs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_resources ALTER COLUMN id SET DEFAULT nextval('media_resources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_context_groups ALTER COLUMN id SET DEFAULT nextval('meta_context_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data ALTER COLUMN id SET DEFAULT nextval('meta_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_key_definitions ALTER COLUMN id SET DEFAULT nextval('meta_key_definitions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_keys_meta_terms ALTER COLUMN id SET DEFAULT nextval('meta_keys_meta_terms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_terms ALTER COLUMN id SET DEFAULT nextval('meta_terms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY people ALTER COLUMN id SET DEFAULT nextval('people_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY permission_presets ALTER COLUMN id SET DEFAULT nextval('permission_presets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY previews ALTER COLUMN id SET DEFAULT nextval('previews_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY usage_terms ALTER COLUMN id SET DEFAULT nextval('usage_terms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY userpermissions ALTER COLUMN id SET DEFAULT nextval('userpermissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Data for Name: app_settings; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO app_settings VALUES (0, 101, 32, 39, '/tmp', 'ftp.dropbox.test', 'test', 'password', NULL, 'http://wiki.zhdk.ch/madek-hilfe', NULL, NULL, '2013-05-14 12:40:05.670692', '2013-06-24 07:53:59.019841', '/assets/inserts/image-logo-zhdk.png', 'Zürcher Hochschule der Künste', '{"About the project":"http://www.zhdk.ch/?madek","Impressum":"http://www.zhdk.ch/index.php?id=12970","Contact":"http://www.zhdk.ch/index.php?id=49591","Help":"http://wiki.zhdk.ch/madek-hilfe","Terms of Use":"https://wiki.zhdk.ch/madek-hilfe/doku.php?id=terms","Archivierungsrichtlinien ZHdK":"http://www.zhdk.ch/?archivierung"}', NULL, NULL);


--
-- Data for Name: copyrights; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO copyrights VALUES (1, false, false, 'Unbekannt', NULL, 1, 2, NULL, NULL);
INSERT INTO copyrights VALUES (2, false, false, 'Urheberrechtlich geschützt (standardisierte Lizenz)', NULL, 3, 24, NULL, NULL);
INSERT INTO copyrights VALUES (3, true, false, 'Alle Rechte vorbehalten', 2, 4, 5, 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'http://www.copyright.ch');
INSERT INTO copyrights VALUES (4, false, false, 'Creative Commons Licence', 2, 6, 19, NULL, NULL);
INSERT INTO copyrights VALUES (5, false, false, 'CC-By-CH: Attribution', 4, 7, 8, 'Bitte jeweils die angegebenen Nutzungsmodifikationen beachten.', 'http://creativecommons.org/licenses/by/2.5/ch/');
INSERT INTO copyrights VALUES (6, false, false, 'CC-By-SA-CH: Attribution Share Alike', 4, 9, 10, 'Bitte jeweils die angegebenen Nutzungsmodifikationen beachten.', 'http://creativecommons.org/licenses/by-sa/2.5/ch/');
INSERT INTO copyrights VALUES (7, false, false, 'CC-By-ND-CH: Attribution No Derivates', 4, 11, 12, 'Bitte jeweils die angegebenen Nutzungsmodifikationen beachten.', 'http://creativecommons.org/licenses/by-nd/2.5/ch/');
INSERT INTO copyrights VALUES (8, false, false, 'CC-By-NC-CH: Attribution Non-Commercial', 4, 13, 14, 'Bitte jeweils die angegebenen Nutzungsmodifikationen beachten.', 'http://creativecommons.org/licenses/by-nc/2.5/ch/');
INSERT INTO copyrights VALUES (9, false, false, 'CC-By-NC-SA-CH: Attribution Non-Commercial Share Alike', 4, 15, 16, 'Bitte jeweils die angegebenen Nutzungsmodifikationen beachten.', 'http://creativecommons.org/licenses/by-nc-sa/2.5/ch/');
INSERT INTO copyrights VALUES (10, false, false, 'CC-By-NC-ND-CH: Attribution Non-Commercial No Derivates', 4, 17, 18, 'Bitte jeweils die angegebenen Nutzungsmodifikationen beachten.', 'http://creativecommons.org/licenses/by-nc-nd/2.5/ch/');
INSERT INTO copyrights VALUES (11, false, false, 'ZHdK-Lizenzen', 2, 20, 23, NULL, NULL);
INSERT INTO copyrights VALUES (12, false, false, 'Studio Publikation', 11, 21, 22, 'Alle Rechte dem Studio Publikation der ZHdK vorbehalten. Freie Verwendung im Rahmen von Ankündigung und Berichterstattung der ZHdK.', 'http://www.zhdk.ch/index.php?id=1033');
INSERT INTO copyrights VALUES (13, false, true, 'Urheberrechtlich geschützt (individuelle Lizenz)', NULL, 25, 26, '', '');
INSERT INTO copyrights VALUES (14, false, false, 'Public Domain / Gemeinfrei', NULL, 27, 28, 'Freie Nutzung ohne Einschränkung.', 'http://de.wikipedia.org/wiki/Public_Domain');


--
-- Data for Name: edit_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO edit_sessions VALUES (1, 6, 33, '2012-08-31 11:55:41', '2012-08-31 11:55:41');
INSERT INTO edit_sessions VALUES (3, 6, 33, '2012-08-31 11:56:00', '2012-08-31 11:56:00');
INSERT INTO edit_sessions VALUES (5, 6, 33, '2012-08-31 11:56:03', '2012-08-31 11:56:03');
INSERT INTO edit_sessions VALUES (7, 6, 33, '2012-08-31 11:56:55', '2012-08-31 11:56:55');
INSERT INTO edit_sessions VALUES (9, 6, 33, '2012-08-31 11:58:17', '2012-08-31 11:58:17');
INSERT INTO edit_sessions VALUES (11, 6, 33, '2012-08-31 11:58:29', '2012-08-31 11:58:29');
INSERT INTO edit_sessions VALUES (13, 6, 33, '2012-08-31 11:59:08', '2012-08-31 11:59:08');
INSERT INTO edit_sessions VALUES (15, 6, 35, '2012-08-31 12:00:23', '2012-08-31 12:00:23');
INSERT INTO edit_sessions VALUES (17, 6, 35, '2012-08-31 12:00:32', '2012-08-31 12:00:32');
INSERT INTO edit_sessions VALUES (19, 6, 35, '2012-08-31 12:00:43', '2012-08-31 12:00:43');
INSERT INTO edit_sessions VALUES (21, 6, 35, '2012-08-31 12:01:18', '2012-08-31 12:01:18');
INSERT INTO edit_sessions VALUES (23, 6, 35, '2012-08-31 12:01:23', '2012-08-31 12:01:23');
INSERT INTO edit_sessions VALUES (25, 6, 35, '2012-08-31 12:01:27', '2012-08-31 12:01:27');
INSERT INTO edit_sessions VALUES (27, 6, 35, '2012-08-31 12:01:31', '2012-08-31 12:01:31');
INSERT INTO edit_sessions VALUES (29, 6, 35, '2012-08-31 12:01:35', '2012-08-31 12:01:35');
INSERT INTO edit_sessions VALUES (31, 6, 35, '2012-08-31 12:01:39', '2012-08-31 12:01:39');
INSERT INTO edit_sessions VALUES (33, 6, 35, '2012-08-31 12:01:43', '2012-08-31 12:01:43');
INSERT INTO edit_sessions VALUES (35, 6, 35, '2012-08-31 12:01:47', '2012-08-31 12:01:47');
INSERT INTO edit_sessions VALUES (37, 6, 35, '2012-08-31 12:01:59', '2012-08-31 12:01:59');
INSERT INTO edit_sessions VALUES (39, 6, 35, '2012-08-31 12:01:59', '2012-08-31 12:01:59');
INSERT INTO edit_sessions VALUES (42, 6, 33, '2012-10-12 11:56:30.17128', '2012-10-12 11:56:30.17128');
INSERT INTO edit_sessions VALUES (43, 3, 6, '2012-10-12 11:57:52.218157', '2012-10-12 11:57:52.218157');
INSERT INTO edit_sessions VALUES (44, 1, 39, '2012-10-16 11:51:57.205762', '2012-10-16 11:51:57.205762');
INSERT INTO edit_sessions VALUES (45, 1, 39, '2012-10-16 13:13:01.609833', '2012-10-16 13:13:01.609833');
INSERT INTO edit_sessions VALUES (46, 1, 40, '2012-10-16 13:14:48.393395', '2012-10-16 13:14:48.393395');
INSERT INTO edit_sessions VALUES (47, 1, 40, '2012-10-16 13:15:11.8621', '2012-10-16 13:15:11.8621');
INSERT INTO edit_sessions VALUES (48, 7, 65, '2012-10-16 13:48:53.483237', '2012-10-16 13:48:53.483237');
INSERT INTO edit_sessions VALUES (49, 7, 65, '2012-10-16 13:49:02.344225', '2012-10-16 13:49:02.344225');
INSERT INTO edit_sessions VALUES (50, 7, 93, '2012-10-16 13:59:30.832161', '2012-10-16 13:59:30.832161');
INSERT INTO edit_sessions VALUES (51, 7, 93, '2012-10-16 13:59:33.809195', '2012-10-16 13:59:33.809195');
INSERT INTO edit_sessions VALUES (52, 7, 71, '2012-10-16 13:59:37.119585', '2012-10-16 13:59:37.119585');
INSERT INTO edit_sessions VALUES (53, 7, 71, '2012-10-16 13:59:41.272446', '2012-10-16 13:59:41.272446');
INSERT INTO edit_sessions VALUES (54, 1, 99, '2012-10-25 13:18:09.386852', '2012-10-25 13:18:09.386852');
INSERT INTO edit_sessions VALUES (55, 7, 100, '2012-11-07 16:39:04.955852', '2012-11-07 16:39:04.955852');
INSERT INTO edit_sessions VALUES (56, 7, 100, '2012-11-07 16:39:23.095202', '2012-11-07 16:39:23.095202');
INSERT INTO edit_sessions VALUES (57, 7, 92, '2012-11-09 14:10:36.960997', '2012-11-09 14:10:36.960997');
INSERT INTO edit_sessions VALUES (58, 6, 105, '2013-03-07 08:42:33.108237', '2013-03-07 08:42:33.108237');
INSERT INTO edit_sessions VALUES (59, 6, 105, '2013-03-07 08:42:35.25835', '2013-03-07 08:42:35.25835');
INSERT INTO edit_sessions VALUES (60, 6, 105, '2013-03-07 08:42:36.412141', '2013-03-07 08:42:36.412141');
INSERT INTO edit_sessions VALUES (61, 6, 105, '2013-03-07 08:42:40.071991', '2013-03-07 08:42:40.071991');
INSERT INTO edit_sessions VALUES (62, 6, 105, '2013-03-07 08:42:42.670829', '2013-03-07 08:42:42.670829');
INSERT INTO edit_sessions VALUES (63, 6, 105, '2013-03-07 08:42:45.837746', '2013-03-07 08:42:45.837746');
INSERT INTO edit_sessions VALUES (64, 6, 105, '2013-03-07 08:42:46.79798', '2013-03-07 08:42:46.79798');
INSERT INTO edit_sessions VALUES (65, 6, 105, '2013-03-07 08:42:48.204823', '2013-03-07 08:42:48.204823');
INSERT INTO edit_sessions VALUES (66, 6, 105, '2013-03-07 08:42:49.132988', '2013-03-07 08:42:49.132988');
INSERT INTO edit_sessions VALUES (67, 6, 105, '2013-03-07 08:42:50.009373', '2013-03-07 08:42:50.009373');
INSERT INTO edit_sessions VALUES (68, 6, 105, '2013-03-07 08:42:50.681919', '2013-03-07 08:42:50.681919');
INSERT INTO edit_sessions VALUES (69, 6, 105, '2013-03-07 08:42:51.88368', '2013-03-07 08:42:51.88368');
INSERT INTO edit_sessions VALUES (70, 6, 105, '2013-03-07 08:42:53.130669', '2013-03-07 08:42:53.130669');
INSERT INTO edit_sessions VALUES (71, 6, 105, '2013-03-07 08:42:58.112565', '2013-03-07 08:42:58.112565');
INSERT INTO edit_sessions VALUES (72, 6, 105, '2013-03-07 08:43:02.592543', '2013-03-07 08:43:02.592543');
INSERT INTO edit_sessions VALUES (73, 6, 105, '2013-03-07 08:43:04.850532', '2013-03-07 08:43:04.850532');
INSERT INTO edit_sessions VALUES (74, 6, 105, '2013-03-07 08:43:06.238102', '2013-03-07 08:43:06.238102');
INSERT INTO edit_sessions VALUES (75, 6, 105, '2013-03-07 08:43:08.914089', '2013-03-07 08:43:08.914089');
INSERT INTO edit_sessions VALUES (76, 6, 105, '2013-03-07 08:43:09.956966', '2013-03-07 08:43:09.956966');
INSERT INTO edit_sessions VALUES (77, 6, 105, '2013-03-07 08:43:13.027607', '2013-03-07 08:43:13.027607');
INSERT INTO edit_sessions VALUES (78, 6, 105, '2013-03-07 08:43:14.86166', '2013-03-07 08:43:14.86166');
INSERT INTO edit_sessions VALUES (79, 6, 105, '2013-03-07 08:43:17.135086', '2013-03-07 08:43:17.135086');
INSERT INTO edit_sessions VALUES (80, 6, 105, '2013-03-07 08:43:17.143183', '2013-03-07 08:43:17.143183');
INSERT INTO edit_sessions VALUES (81, 6, 105, '2013-03-07 08:43:19.942299', '2013-03-07 08:43:19.942299');
INSERT INTO edit_sessions VALUES (82, 6, 105, '2013-03-07 08:43:21.497545', '2013-03-07 08:43:21.497545');
INSERT INTO edit_sessions VALUES (83, 6, 105, '2013-03-07 08:43:22.574628', '2013-03-07 08:43:22.574628');
INSERT INTO edit_sessions VALUES (84, 6, 105, '2013-03-07 08:43:27.392217', '2013-03-07 08:43:27.392217');
INSERT INTO edit_sessions VALUES (85, 6, 105, '2013-03-07 08:43:29.684258', '2013-03-07 08:43:29.684258');
INSERT INTO edit_sessions VALUES (86, 6, 105, '2013-03-07 08:43:31.269562', '2013-03-07 08:43:31.269562');
INSERT INTO edit_sessions VALUES (87, 6, 105, '2013-03-07 08:43:33.791086', '2013-03-07 08:43:33.791086');
INSERT INTO edit_sessions VALUES (88, 6, 105, '2013-03-07 08:43:37.995121', '2013-03-07 08:43:37.995121');
INSERT INTO edit_sessions VALUES (89, 6, 106, '2013-03-07 08:46:08.608728', '2013-03-07 08:46:08.608728');
INSERT INTO edit_sessions VALUES (90, 6, 106, '2013-03-07 08:46:11.080438', '2013-03-07 08:46:11.080438');
INSERT INTO edit_sessions VALUES (91, 6, 106, '2013-03-07 08:46:12.77107', '2013-03-07 08:46:12.77107');
INSERT INTO edit_sessions VALUES (92, 6, 105, '2013-03-07 08:47:27.011853', '2013-03-07 08:47:27.011853');
INSERT INTO edit_sessions VALUES (93, 6, 106, '2013-03-07 08:49:31.205351', '2013-03-07 08:49:31.205351');
INSERT INTO edit_sessions VALUES (94, 6, 106, '2013-03-07 08:50:28.334772', '2013-03-07 08:50:28.334772');
INSERT INTO edit_sessions VALUES (95, 6, 106, '2013-03-07 08:51:40.78778', '2013-03-07 08:51:40.78778');
INSERT INTO edit_sessions VALUES (96, 1, 107, '2013-03-07 09:03:35.012546', '2013-03-07 09:03:35.012546');
INSERT INTO edit_sessions VALUES (98, 2, 113, '2013-05-21 06:54:42.732973', '2013-05-21 06:54:42.732973');
INSERT INTO edit_sessions VALUES (99, 2, 113, '2013-05-21 06:54:45.056752', '2013-05-21 06:54:45.056752');
INSERT INTO edit_sessions VALUES (100, 2, 113, '2013-05-21 06:54:48.592782', '2013-05-21 06:54:48.592782');
INSERT INTO edit_sessions VALUES (101, 2, 113, '2013-05-21 06:54:51.28035', '2013-05-21 06:54:51.28035');
INSERT INTO edit_sessions VALUES (102, 2, 113, '2013-05-21 06:54:55.658044', '2013-05-21 06:54:55.658044');
INSERT INTO edit_sessions VALUES (103, 2, 113, '2013-05-21 06:55:01.936445', '2013-05-21 06:55:01.936445');
INSERT INTO edit_sessions VALUES (104, 2, 113, '2013-05-21 06:55:05.391595', '2013-05-21 06:55:05.391595');
INSERT INTO edit_sessions VALUES (105, 2, 113, '2013-05-21 06:55:06.215003', '2013-05-21 06:55:06.215003');
INSERT INTO edit_sessions VALUES (106, 1, 114, '2013-07-08 08:27:21.788896', '2013-07-08 08:27:21.788896');
INSERT INTO edit_sessions VALUES (107, 1, 114, '2013-07-08 08:27:25.163783', '2013-07-08 08:27:25.163783');
INSERT INTO edit_sessions VALUES (108, 1, 114, '2013-07-08 08:27:25.248168', '2013-07-08 08:27:25.248168');
INSERT INTO edit_sessions VALUES (109, 1, 115, '2013-07-08 08:42:01.962727', '2013-07-08 08:42:01.962727');
INSERT INTO edit_sessions VALUES (110, 1, 115, '2013-07-08 08:42:03.058582', '2013-07-08 08:42:03.058582');
INSERT INTO edit_sessions VALUES (111, 1, 115, '2013-07-08 08:42:03.894148', '2013-07-08 08:42:03.894148');
INSERT INTO edit_sessions VALUES (112, 1, 115, '2013-07-08 08:42:03.937524', '2013-07-08 08:42:03.937524');


--
-- Data for Name: favorites; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO favorites VALUES (2, 95);


--
-- Data for Name: full_texts; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO full_texts VALUES (1, 1, 'Landschaften Admin, Adam');
INSERT INTO full_texts VALUES (2, 2, 'Zett Admin, Adam');
INSERT INTO full_texts VALUES (3, 3, 'Zett über Landschaften Admin, Adam');
INSERT INTO full_texts VALUES (4, 4, 'Abgabe zum Kurs Product Design Normalo, Normin');
INSERT INTO full_texts VALUES (5, 5, 'Mein Test Set Paula, Petra');
INSERT INTO full_texts VALUES (7, 7, 'Abgabe Normalo, Normin');
INSERT INTO full_texts VALUES (8, 8, 'Konzepte Normalo, Normin');
INSERT INTO full_texts VALUES (9, 9, 'Fotografie Kurs HS 2010 Normalo, Normin');
INSERT INTO full_texts VALUES (10, 10, 'Portrait Normalo, Normin');
INSERT INTO full_texts VALUES (11, 11, 'Stilleben Normalo, Normin');
INSERT INTO full_texts VALUES (12, 12, 'Meine Ausstellungen Normalo, Normin');
INSERT INTO full_texts VALUES (13, 13, 'Meine Highlights 2012 Normalo, Normin');
INSERT INTO full_texts VALUES (14, 14, 'Dropbox Normalo, Normin');
INSERT INTO full_texts VALUES (15, 15, 'Diplomarbeit 2012 Normalo, Normin');
INSERT INTO full_texts VALUES (16, 16, 'Präsentation Normalo, Normin');
INSERT INTO full_texts VALUES (17, 17, 'Ausstellungen Normalo, Normin');
INSERT INTO full_texts VALUES (18, 18, 'Ausstellung Photo 1 Normalo, Normin');
INSERT INTO full_texts VALUES (19, 19, 'Ausstellung Photo 2 Normalo, Normin');
INSERT INTO full_texts VALUES (20, 20, 'Ausstellung Photo 3 Normalo, Normin');
INSERT INTO full_texts VALUES (22, 22, 'Ausstellung ZHdK Normalo, Normin');
INSERT INTO full_texts VALUES (23, 23, 'Ausstellung Museum Zürich Normalo, Normin');
INSERT INTO full_texts VALUES (24, 24, 'Ausstellung Photo 5 Normalo, Normin');
INSERT INTO full_texts VALUES (25, 25, 'Ausstellung Gallerie Limatquai Normalo, Normin');
INSERT INTO full_texts VALUES (26, 26, 'Konzepte Normalo, Normin');
INSERT INTO full_texts VALUES (28, 28, 'Zweiter Entwurf Normalo, Normin');
INSERT INTO full_texts VALUES (29, 29, 'Schweizer Panorama Landschaft, Liselotte');
INSERT INTO full_texts VALUES (30, 30, 'Deutsches Panorama Landschaft, Liselotte');
INSERT INTO full_texts VALUES (31, 31, 'Chinese Temple Landschaft, Liselotte');
INSERT INTO full_texts VALUES (32, 32, 'Splashscreen Admin, Adam');
INSERT INTO full_texts VALUES (35, 35, 'Virgin and Child with Saints Catherine and Barbara; Memling, Hans; 1470/1500; Dunkelheit vorne; Durchgang; Farbigkeit vorne; Figur Grund; Helligkeit hinten; Kontrast vorne; Schaerfe vorne; Strukturreichtum vorne; unbekannt; Alle Rechte vorbehalten; Landschaft, Liselotte Landschaft, Liselotte');
INSERT INTO full_texts VALUES (37, 37, 'Abgaben Landschaft, Liselotte');
INSERT INTO full_texts VALUES (38, 38, 'Fotografie Admin, Adam');
INSERT INTO full_texts VALUES (33, 33, 'Alle Rechte vorbehalten; Landschaft, Liselotte; Deutzer Hafen in Köln; 2002; Schulte, Wilhelm; Wilhlem Schulte; Architektur; Tusche und Aquarell auf Bütenpapier; Forschung; im Studienverlauf entstanden; Recherche; Reine Fotografie; Konzeptkunst Landschaft, Liselotte');
INSERT INTO full_texts VALUES (6, 6, 'Mein Erstes Photo (mit der neuen Nikon); Konzeptkunst Paula, Petra');
INSERT INTO full_texts VALUES (47, 47, 'Osodi, George; 22.12.2005; http://www.georgeosodi.co.uk/portfolio/permalink/75935/16dfab77b9dcf9; 22.12.2005; XGO105; Osodi, George; villagers who are evaquating drive pass smoke and flames from a burning oil pipeline belonging to Shell Petroleum Development Company across the Opobo Channel in Asagba Okwan Asarama about 50km south-west of Port Harcourt, Nigeria, Thursday, Dec. 22 2005.( Photo/George Osodi); Osodi, George; oil; niger delta; Oil Rich Niger Delta; Fotografie; Photographer; Schumacher, Susanne; I; ASAGBA OKWAN; Nigeria; Forschungsprojekt "Supply Lines"; Niger Delta; AP; Nigerdelta; NG; Nigeria / GB; www.georgeosodi.co.uk; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Schumacher, Susanne; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (39, 39, 'Katalog; Der Katalog bietet Ihnen die Möglichkeit das Medienarchiv der Künste nach Überraschendem zu erkunden. Admin, Adam');
INSERT INTO full_texts VALUES (40, 40, 'Schlagworte; Erkunden Sie Medieneinträge mit unterschiedlichsten Schlagworten. Admin, Adam');
INSERT INTO full_texts VALUES (41, 41, 'Flurina Gradin; landjäger1_zett 11_3; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (42, 42, 'Flurina Gradin; landjäger2_zett 11_3; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (43, 43, 'Hauptstudium Diplom; Tillessen, Peter; 1998; ; 1998; Original: Kleinbilddia Farbe; Digitalisat: TIFF; Abschlussarbeit; es erscheint die Publikation:
Peter Tillessen - Gold, [Text: Ulf Erdmann Ziegler] Baden, Lars Müller, 2000 ; Tillessen, Peter; Zürcher Hochschule der Künste ZHdK; Konzeptkunst; Stadt; Fotografie; Diplomarbeit; Zu?rich; Hefte; Beobachtung; Bild-Text; Konsumkultur; Persiflage; Bildserie; Spaziergang; Fotografie; Jungo, Felix; Zürcher Hochschule der Künste Vertiefung Fotografie; Diplomarbeit; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Jungo, Felix; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (44, 44, 'Hauptstudium Diplom; Tillessen, Peter; 1998; ; 1998; Original: Kleinbilddia Farbe; Digitalisat: TIFF; Abschlussarbeit; es erscheint die Publikation:
Peter Tillessen - Gold, [Text: Ulf Erdmann Ziegler] Baden, Lars Müller, 2000 ; Tillessen, Peter; Zürcher Hochschule der Künste ZHdK; Konzeptkunst; Stadt; Fotografie; Diplomarbeit; Zu?rich; Hefte; Beobachtung; Bild-Text; Konsumkultur; Persiflage; Bildserie; Spaziergang; Fotografie; Jungo, Felix; Zürcher Hochschule der Künste Vertiefung Fotografie; Diplomarbeit; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Jungo, Felix; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (45, 45, 'Osodi, George; 10.07.2007; image/jpeg; http://www.georgeosodi.co.uk/portfolio/permalink/75935/16dfab77b9dcf9; 10.07.2007; Osodi, George; Osodi, George; oil; niger delta; Oil Rich Niger Delta; Fotografie; Photographer; Schumacher, Susanne; RGB; Nigeria; Forschungsprojekt "Supply Lines"; Niger Delta; Nigerdelta; NG; Nigeria / GB; www.georgeosodi.co.uk; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Schumacher, Susanne; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (46, 46, 'Hauptstudium Diplom; Bangerter, Andrea; Thal, Andrea; 1999; ; 1999; Original: Kleinbilddia Farbe; Digitalisat: TIFF; Abschlussarbeit; Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.; Bangerter, Andrea; Zürcher Hochschule der Künste ZHdK; Inszenierung; Landschaft; Natur; Fotografie; Diplomarbeit; Sport; Sportbekleidung; Outdoor; Mode; Freizeit; Diplom; Fotografie; Jungo, Felix; Zürcher Hochschule der Künste Vertiefung Fotografie; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Jungo, Felix; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (48, 48, 'Flurina Gradin; landjäger2_zett 11_3; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (49, 49, 'Flurina Gradin; landjäger1_zett 11_3; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (50, 50, 'Hauptstudium Diplom; Bangerter, Andrea; Thal, Andrea; 1999; ; 1999; Original: Kleinbilddia Farbe; Digitalisat: TIFF; Abschlussarbeit; Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.; Bangerter, Andrea; Zürcher Hochschule der Künste ZHdK; Inszenierung; Landschaft; Natur; Fotografie; Diplomarbeit; Sport; Sportbekleidung; Outdoor; Mode; Freizeit; Diplom; Fotografie; Jungo, Felix; Zürcher Hochschule der Künste Vertiefung Fotografie; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Jungo, Felix; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (51, 51, 'Bachelor; Leo, Maja; 2012; image/tiff; 2012; Ausstellung; ZHdK DKM VMK; suche_system[xx,y]; Kunst; RGB; Eine kollektive Suchbewegung.; Vertiefung Mediale Künste, Sihlquai 131, 8005 Zürich; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (52, 52, 'Osodi, George; 22.12.2005; http://www.georgeosodi.co.uk/portfolio/permalink/75935/16dfab77b9dcf9; 22.12.2005; XGO105; Osodi, George; villagers who are evaquating drive pass smoke and flames from a burning oil pipeline belonging to Shell Petroleum Development Company across the Opobo Channel in Asagba Okwan Asarama about 50km south-west of Port Harcourt, Nigeria, Thursday, Dec. 22 2005.( Photo/George Osodi); Osodi, George; oil; niger delta; Oil Rich Niger Delta; Fotografie; Photographer; Schumacher, Susanne; I; ASAGBA OKWAN; Nigeria; Forschungsprojekt "Supply Lines"; Niger Delta; AP; Nigerdelta; NG; Nigeria / GB; www.georgeosodi.co.uk; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Schumacher, Susanne; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (53, 53, '2012:09:26 11:49:27.032; image/jpeg; ZHdK; Z+; RGB; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (54, 54, 'Hauptstudium Diplom; Bangerter, Andrea; Thal, Andrea; 1999; ; 1999; Original: Kleinbilddia Farbe; Digitalisat: TIFF; Abschlussarbeit; Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.; Bangerter, Andrea; Zürcher Hochschule der Künste ZHdK; Inszenierung; Landschaft; Natur; Fotografie; Diplomarbeit; Sport; Sportbekleidung; Outdoor; Mode; Freizeit; Diplom; Fotografie; Jungo, Felix; Zürcher Hochschule der Künste Vertiefung Fotografie; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Jungo, Felix; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (55, 55, 'ZHdK; Design Artikel, Michael Krohn; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (56, 56, 'Ausstellung; Etter, Jon; ZHdK DKM VMK; Klanginstallation; Audio; Audioinstallation; Klang; Bachelor; Treier, Max; 2012; image/tiff; ; 2012; 5 Min., Loop; 8-Kanal Audio; stimme-sprach-raum-teil3; Kunst; RGB; Vertiefung Mediale Künste, Sihlquai 131, 8005 Zürich; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (57, 57, 'Hauptstudium Diplom; Bangerter, Andrea; Thal, Andrea; 1999; ; 1999; Original: Kleinbilddia Farbe; Digitalisat: TIFF; Abschlussarbeit; Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.; Bangerter, Andrea; Zürcher Hochschule der Künste ZHdK; Inszenierung; Landschaft; Natur; Fotografie; Diplomarbeit; Sport; Sportbekleidung; Outdoor; Mode; Freizeit; Diplom; Fotografie; Jungo, Felix; Zürcher Hochschule der Künste Vertiefung Fotografie; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Jungo, Felix; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (58, 58, '2012:05:30 23:57:41.005; image/jpeg; Die Gartenküche canorta erlaubt spontane Öffentlichkeit.; Reto Togni und Dominique Schmutz ; Canorta; RGB; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (59, 59, 'Kistler, Melanie M.; 2012:06:06 11:41:53.059; image/tiff; 2012; 18:13 Min.; ZHdK DKM VMK; Videoinstallation; stribog_13_meets_electra; Kunst; RGB; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (60, 60, 'Diplom; Bangerter, Andrea; Thal, Andrea; ; 1999; Inszenierung; Landschaft; Natur; Fotografie; Diplomarbeit; Sport; Sportbekleidung; Outdoor; Mode; Freizeit; Hauptstudium Diplom; Abschlussarbeit; Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.; Fotografie; Bangerter, Andrea; Zürcher Hochschule der Künste ZHdK; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Zürcher Hochschule der Künste Vertiefung Fotografie; Original: Kleinbilddia Farbe; Digitalisat: TIFF; Knacknuss, Karen; Jungo, Felix; 1999; Jungo, Felix Knacknuss, Karen');
INSERT INTO full_texts VALUES (61, 61, 'Arbeitsraum mit unbestimmten Ausgängen; Asa, Shima; Clavadetscher, Jann; Filiz, Aylin; Müller, Manuela; Schaffner, Lea; Stemmle, Joris; 2012; Installation; Vertiefung Mediale Künste, Sihlquai 131, 8005 Zürich; Kunst; ZHdK DKM VMK; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen; image/tiff; 2012; RGB Knacknuss, Karen');
INSERT INTO full_texts VALUES (62, 62, 'Seerosen; Der schwimmende Garten; 2011; Pflanzen; Natur; Wasser; Blumen; Seerosen; Scheiber Dahou, Judith; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (63, 63, 'Spaziergang; Diplomarbeit; Tillessen, Peter; ; 1998; Konzeptkunst; Stadt; Fotografie; Diplomarbeit; Zu?rich; Hefte; Beobachtung; Bild-Text; Konsumkultur; Persiflage; Bildserie; Hauptstudium Diplom; Abschlussarbeit; es erscheint die Publikation:
Peter Tillessen - Gold, [Text: Ulf Erdmann Ziegler] Baden, Lars Müller, 2000 ; Fotografie; Tillessen, Peter; Zürcher Hochschule der Künste ZHdK; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Zürcher Hochschule der Künste Vertiefung Fotografie; Original: Kleinbilddia Farbe; Digitalisat: TIFF; Knacknuss, Karen; Jungo, Felix; 1998; Jungo, Felix Knacknuss, Karen');
INSERT INTO full_texts VALUES (64, 64, 'Diplom; Bangerter, Andrea; Thal, Andrea; ; 1999; Inszenierung; Landschaft; Natur; Fotografie; Diplomarbeit; Sport; Sportbekleidung; Outdoor; Mode; Freizeit; Hauptstudium Diplom; Abschlussarbeit; Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.; Fotografie; Bangerter, Andrea; Zürcher Hochschule der Künste ZHdK; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Zürcher Hochschule der Künste Vertiefung Fotografie; Original: Kleinbilddia Farbe; Digitalisat: TIFF; Knacknuss, Karen; Jungo, Felix; 1999; Jungo, Felix Knacknuss, Karen');
INSERT INTO full_texts VALUES (66, 66, 'Leerschlag [ ]; Vernissage; ; 2012; Vertiefung Mediale Künste, Sihlquai 131, 8005 Zürich; Bachelor; Ausstellung; Kunst; Etter, Jon; ZHdK DKM VMK; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen; image/tiff; 2012; RGB Knacknuss, Karen');
INSERT INTO full_texts VALUES (65, 65, 'Water Oil; unbekannt; Alle Rechte vorbehalten; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (71, 71, 'Alle Rechte vorbehalten; Knacknuss, Karen; Plan; unbekannt Knacknuss, Karen');
INSERT INTO full_texts VALUES (83, 83, 'Hauptstudium Diplom; Bangerter, Andrea; Thal, Andrea; 1999; ; 1999; Original: Kleinbilddia Farbe; Digitalisat: TIFF; Abschlussarbeit; Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.; Bangerter, Andrea; Zürcher Hochschule der Künste ZHdK; Inszenierung; Landschaft; Natur; Fotografie; Diplomarbeit; Sport; Sportbekleidung; Outdoor; Mode; Freizeit; Diplom; Fotografie; Jungo, Felix; Zürcher Hochschule der Künste Vertiefung Fotografie; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Jungo, Felix; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (84, 84, 'Flurina Gradin; landjäger1_zett 11_3; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (85, 85, 'Bachelor; Leo, Maja; 2012; image/tiff; 2012; Ausstellung; ZHdK DKM VMK; suche_system[xx,y]; Kunst; RGB; Eine kollektive Suchbewegung.; Vertiefung Mediale Künste, Sihlquai 131, 8005 Zürich; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (86, 86, '2011; Scheiber Dahou, Judith; Pflanzen; Natur; Wasser; Blumen; Seerosen; Seerosen; Der schwimmende Garten; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (87, 87, 'Bachelor; Treier, Max; 2012; image/tiff; ; 2012; 5 Min., Loop; 8-Kanal Audio; Ausstellung; Etter, Jon; ZHdK DKM VMK; Klanginstallation; Audio; Audioinstallation; Klang; stimme-sprach-raum-teil3; Kunst; RGB; Vertiefung Mediale Künste, Sihlquai 131, 8005 Zürich; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (88, 88, 'Kistler, Melanie M.; 2012:06:06 11:41:53.059; image/tiff; 2012; 18:13 Min.; ZHdK DKM VMK; Videoinstallation; stribog_13_meets_electra; Kunst; RGB; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (89, 89, 'http://www.ige.ch; Flurina Gradin; landjäger2_zett 11_3; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (90, 90, 'Asa, Shima; Clavadetscher, Jann; Filiz, Aylin; Müller, Manuela; Schaffner, Lea; Stemmle, Joris; 2012; image/tiff; 2012; ZHdK DKM VMK; Installation; Arbeitsraum mit unbestimmten Ausgängen; Kunst; RGB; Vertiefung Mediale Künste, Sihlquai 131, 8005 Zürich; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (91, 91, 'Hauptstudium Diplom; Tillessen, Peter; 1998; ; 1998; Original: Kleinbilddia Farbe; Digitalisat: TIFF; Abschlussarbeit; es erscheint die Publikation:
Peter Tillessen - Gold, [Text: Ulf Erdmann Ziegler] Baden, Lars Müller, 2000 ; Tillessen, Peter; Zürcher Hochschule der Künste ZHdK; Konzeptkunst; Stadt; Fotografie; Diplomarbeit; Zu?rich; Hefte; Beobachtung; Bild-Text; Konsumkultur; Persiflage; Bildserie; Spaziergang; Fotografie; Jungo, Felix; Zürcher Hochschule der Künste Vertiefung Fotografie; Diplomarbeit; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Jungo, Felix; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (78, 78, '2012:09:26 11:49:27.032; image/jpeg; ZHdK; Z+; RGB; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (94, 94, 'Bachelor; 2012; image/tiff; ; 2012; Ausstellung; Etter, Jon; ZHdK DKM VMK; Leerschlag [ ]; Kunst; RGB; Vernissage; Vertiefung Mediale Künste, Sihlquai 131, 8005 Zürich; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (67, 67, 'Caraco, Françoise; 1995; Caraco, Françoise; Zürcher Hochschule der Künste ZHdK; Fotografie; Letten it be; Jungo, Felix; Zürcher Hochschule der Künste Vertiefung Fotografie; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Jungo, Felix; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (68, 68, 'Hauptstudium Diplom; Tillessen, Peter; 1998; ; 1998; Original: Kleinbilddia Farbe; Digitalisat: TIFF; Abschlussarbeit; es erscheint die Publikation:
Peter Tillessen - Gold, [Text: Ulf Erdmann Ziegler] Baden, Lars Müller, 2000 ; Tillessen, Peter; Zürcher Hochschule der Künste ZHdK; Konzeptkunst; Stadt; Fotografie; Diplomarbeit; Zu?rich; Hefte; Beobachtung; Bild-Text; Konsumkultur; Persiflage; Bildserie; Spaziergang; Fotografie; Jungo, Felix; Zürcher Hochschule der Künste Vertiefung Fotografie; Diplomarbeit; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Jungo, Felix; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (69, 69, 'Birkhäuser, Peter; image/jpeg; 1934; Zürcher Hochschule der Künste, ZHdK; PKZ; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (70, 70, '1995; Stierli, Derek; Zürcher Hochschule der Künste ZHdK; Fotografie; Inkognito; Jungo, Felix; Zürcher Hochschule der Künste Vertiefung Fotografie; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Jungo, Felix; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (72, 72, 'Hauptstudium Diplom; Tillessen, Peter; 1998; ; 1998; Original: Kleinbilddia Farbe; Digitalisat: TIFF; Abschlussarbeit; es erscheint die Publikation:
Peter Tillessen - Gold, [Text: Ulf Erdmann Ziegler] Baden, Lars Müller, 2000 ; Tillessen, Peter; Zürcher Hochschule der Künste ZHdK; Konzeptkunst; Stadt; Fotografie; Diplomarbeit; Zu?rich; Hefte; Beobachtung; Bild-Text; Konsumkultur; Persiflage; Bildserie; Spaziergang; Fotografie; Jungo, Felix; Zürcher Hochschule der Künste Vertiefung Fotografie; Diplomarbeit; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Jungo, Felix; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (73, 73, 'Osodi, George; 10.07.2007; image/jpeg; http://www.georgeosodi.co.uk/portfolio/permalink/75935/16dfab77b9dcf9; 10.07.2007; Osodi, George; Osodi, George; oil; niger delta; Oil Rich Niger Delta; Fotografie; Photographer; Schumacher, Susanne; RGB; Nigeria; Forschungsprojekt "Supply Lines"; Niger Delta; Nigerdelta; NG; Nigeria / GB; www.georgeosodi.co.uk; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Schumacher, Susanne; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (74, 74, 'Hauptstudium Diplom; Bangerter, Andrea; Thal, Andrea; 1999; ; 1999; Original: Kleinbilddia Farbe; Digitalisat: TIFF; Abschlussarbeit; Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.; Bangerter, Andrea; Zürcher Hochschule der Künste ZHdK; Inszenierung; Landschaft; Natur; Fotografie; Diplomarbeit; Sport; Sportbekleidung; Outdoor; Mode; Freizeit; Diplom; Fotografie; Jungo, Felix; Zürcher Hochschule der Künste Vertiefung Fotografie; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Jungo, Felix; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (75, 75, 'Osodi, George; 22.12.2005; http://www.georgeosodi.co.uk/portfolio/permalink/75935/16dfab77b9dcf9; 22.12.2005; XGO105; Osodi, George; villagers who are evaquating drive pass smoke and flames from a burning oil pipeline belonging to Shell Petroleum Development Company across the Opobo Channel in Asagba Okwan Asarama about 50km south-west of Port Harcourt, Nigeria, Thursday, Dec. 22 2005.( Photo/George Osodi); Osodi, George; oil; niger delta; Oil Rich Niger Delta; Fotografie; Photographer; Schumacher, Susanne; I; ASAGBA OKWAN; Nigeria; Forschungsprojekt "Supply Lines"; Niger Delta; AP; Nigerdelta; NG; Nigeria / GB; www.georgeosodi.co.uk; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Schumacher, Susanne; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (76, 76, 'Hauptstudium Diplom; Bangerter, Andrea; Thal, Andrea; 1999; ; 1999; Original: Kleinbilddia Farbe; Digitalisat: TIFF; Abschlussarbeit; Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.; Bangerter, Andrea; Zürcher Hochschule der Künste ZHdK; Inszenierung; Landschaft; Natur; Fotografie; Diplomarbeit; Sport; Sportbekleidung; Outdoor; Mode; Freizeit; Diplom; Fotografie; Jungo, Felix; Zürcher Hochschule der Künste Vertiefung Fotografie; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Jungo, Felix; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (77, 77, 'Osodi, George; 22.12.2005; http://www.georgeosodi.co.uk/portfolio/permalink/75935/16dfab77b9dcf9; 22.12.2005; XGO105; Osodi, George; villagers who are evaquating drive pass smoke and flames from a burning oil pipeline belonging to Shell Petroleum Development Company across the Opobo Channel in Asagba Okwan Asarama about 50km south-west of Port Harcourt, Nigeria, Thursday, Dec. 22 2005.( Photo/George Osodi); Osodi, George; oil; niger delta; Oil Rich Niger Delta; Fotografie; Photographer; Schumacher, Susanne; I; ASAGBA OKWAN; Nigeria; Forschungsprojekt "Supply Lines"; Niger Delta; AP; Nigerdelta; NG; Nigeria / GB; www.georgeosodi.co.uk; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Schumacher, Susanne; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (79, 79, 'Hauptstudium Diplom; Bangerter, Andrea; Thal, Andrea; 1999; ; 1999; Original: Kleinbilddia Farbe; Digitalisat: TIFF; Abschlussarbeit; Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.; Bangerter, Andrea; Zürcher Hochschule der Künste ZHdK; Inszenierung; Landschaft; Natur; Fotografie; Diplomarbeit; Sport; Sportbekleidung; Outdoor; Mode; Freizeit; Diplom; Fotografie; Jungo, Felix; Zürcher Hochschule der Künste Vertiefung Fotografie; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Jungo, Felix; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (80, 80, 'ZHdK; Design Artikel, Michael Krohn; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (81, 81, 'Hauptstudium Diplom; Bangerter, Andrea; Thal, Andrea; 1999; ; 1999; Original: Kleinbilddia Farbe; Digitalisat: TIFF; Abschlussarbeit; Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.; Bangerter, Andrea; Zürcher Hochschule der Künste ZHdK; Inszenierung; Landschaft; Natur; Fotografie; Diplomarbeit; Sport; Sportbekleidung; Outdoor; Mode; Freizeit; Diplom; Fotografie; Jungo, Felix; Zürcher Hochschule der Künste Vertiefung Fotografie; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Jungo, Felix; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (82, 82, '2012:05:30 23:57:41.005; image/jpeg; Die Gartenküche canorta erlaubt spontane Öffentlichkeit.; Reto Togni und Dominique Schmutz ; Canorta; RGB; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (93, 93, 'Alle Rechte vorbehalten; Knacknuss, Karen; Water with oil; unbekannt Knacknuss, Karen');
INSERT INTO full_texts VALUES (97, 97, 'Bachelor; 2012; image/tiff; ; 2012; Ausstellung; Etter, Jon; ZHdK DKM VMK; Leerschlag [ ]; Kunst; RGB; Vernissage; Vertiefung Mediale Künste, Sihlquai 131, 8005 Zürich; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Normalo, Normin Normalo, Normin');
INSERT INTO full_texts VALUES (99, 99, 'Gattung; Erkunden Sie Medieneinträge mit unterschiedlichen Gattungen. Admin, Adam');
INSERT INTO full_texts VALUES (105, 105, '--- 
- isom
- avc1
; 2012:04:02 10:02:06; 0 s; 5.07 s; MP4  Base Media v1 [IS0 14496-12:2003]; 1 0 0 0 1 0 0 0 1; 0.0.1; 2012:04:02 10:02:06; 920203; 0; 3; 0 s; 1; 100.00%; 0 s; 0 s; 0 s; 0 s; 600; 24; avc1; srcCopy; GPAC ISO Video Handler; Video Track; 720; 1280; 2012:04:02 10:02:00; 5.07 s; 0; und; 2012:04:02 10:02:06; 30; 0 0 0; 720; 1280; 2012:04:02 10:02:00; 5.07 s; 0; 1; 0; 2012:04:02 10:02:06; 0.00%; 30; 72; 72; 16; 2; mp4a; 22050; 0; 1.45 Mbps; 1280x720; 0; Alle Rechte vorbehalten; Landschaft, Liselotte; Zencoder Test Movie; 2010; Film; Flugzeug; Wolken; ???; Film; Himmel; Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.copyright.ch Landschaft, Liselotte');
INSERT INTO full_texts VALUES (100, 100, 'Alle Rechte vorbehalten; Knacknuss, Karen; Arabic; Unbekannt Knacknuss, Karen');
INSERT INTO full_texts VALUES (92, 92, 'Hauptstudium Diplom; Bangerter, Andrea; Thal, Andrea; 1999; ; 1999; Original: Kleinbilddia Farbe; Digitalisat: TIFF; Abschlussarbeit; Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.; Bangerter, Andrea; Zürcher Hochschule der Künste ZHdK; Inszenierung; Landschaft; Natur; Fotografie; Diplomarbeit; Sport; Sportbekleidung; Outdoor; Mode; Freizeit; Diplom; Kunst; Jungo, Felix; Zürcher Hochschule der Künste Vertiefung Fotografie; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Jungo, Felix; Knacknuss, Karen Knacknuss, Karen');
INSERT INTO full_texts VALUES (101, 101, 'Beispielhafte-Sets Admin, Adam');
INSERT INTO full_texts VALUES (102, 102, 'Beispiele1 Admin, Adam');
INSERT INTO full_texts VALUES (103, 103, 'Diplomarbeiten Admin, Adam');
INSERT INTO full_texts VALUES (106, 106, '128 kbps; 3; Joint Stereo; None; LAME3.96r; Off; 128 kbps; 17.5 kHz; CBR; 3; Joint Stereo; 4; 1; On; t; 44100; 2052; Shit in my Head; Bit-Tuner and Kurt Kuene; //wipking.krungkuene.org and; Punk Rock; Shit in my Head; 1; 2007; 2007; 0:02:54 (approx); Alle Rechte vorbehalten; Landschaft, Liselotte; ???; Audioinstallation; Klang; Musik; Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.copyright.ch; Vorbildung Landschaft, Liselotte');
INSERT INTO full_texts VALUES (107, 107, 'Set in SQ6 Context; Admin, Adam; sq6; Set im Kontext SQ6  Admin, Adam');
INSERT INTO full_texts VALUES (108, 108, 'Pape, Sebastian; 2011:03:15 15:02:22+01:00; image/jpeg; Sebastian Pape; Flakon Variante 1; RGB; CH; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Paula, Petra Paula, Petra');
INSERT INTO full_texts VALUES (109, 109, 'Stil- und Kunstrichtung Normalo, Normin');
INSERT INTO full_texts VALUES (111, 111, 'FilterSet including all public accessible resources Normalo, Normin');
INSERT INTO full_texts VALUES (113, 113, '---
- isom
- avc1
; 2012:04:02 10:02:06; 0 s; 5.07 s; MP4  Base Media v1 [IS0 14496-12:2003]; 1 0 0 0 1 0 0 0 1; 0.0.1; 2012:04:02 10:02:06; 920203; 0; 3; 0 s; 1; 100.00%; 0 s; 0 s; 0 s; 0 s; 600; 24; avc1; srcCopy; GPAC ISO Video Handler; Video Track; 720; 1280; 2012:04:02 10:02:00; 5.07 s; 0; und; 2012:04:02 10:02:06; 30; 0 0 0; 720; 1280; 2012:04:02 10:02:00; 5.07 s; 0; 1; 0; 2012:04:02 10:02:06; 0.00%; 30; 72; 72; 16; 2; mp4a; 22050; 0; 1.45 Mbps; 1280x720; 0; Alle Rechte vorbehalten; Normalo, Normin; A public movie to test public viewing; Who knows? Normalo, Normin');
INSERT INTO full_texts VALUES (114, 114, 'Alle Rechte vorbehalten; Admin, Adam; some pdf; asdfasdf Admin, Adam');
INSERT INTO full_texts VALUES (115, 115, 'Alle Rechte vorbehalten; Admin, Adam; blah; asdfa Admin, Adam');
INSERT INTO full_texts VALUES (95, 95, 'Asa, Shima; Clavadetscher, Jann; Filiz, Aylin; Müller, Manuela; Schaffner, Lea; Stemmle, Joris; 2012; image/tiff; 2012; ZHdK DKM VMK; Installation; Arbeitsraum mit unbestimmten Ausgängen; Kunst; RGB; Vertiefung Mediale Künste, Sihlquai 131, 8005 Zürich; Urheberrechtlich geschützt (individuelle Lizenz); Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.; http://www.ige.ch; Normalo, Normin Admin, Adam');


--
-- Data for Name: grouppermissions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO grouppermissions VALUES (1, 2, 3, false, true, false, false);
INSERT INTO grouppermissions VALUES (2, 4, 4, true, true, false, false);
INSERT INTO grouppermissions VALUES (3, 13, 3, false, true, false, false);
INSERT INTO grouppermissions VALUES (4, 15, 4, false, true, false, false);
INSERT INTO grouppermissions VALUES (5, 15, 3, false, true, false, false);
INSERT INTO grouppermissions VALUES (6, 41, 8, false, true, false, false);
INSERT INTO grouppermissions VALUES (7, 42, 8, false, true, false, false);
INSERT INTO grouppermissions VALUES (8, 67, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (9, 68, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (10, 69, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (11, 70, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (12, 71, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (13, 72, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (14, 73, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (15, 74, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (16, 75, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (17, 76, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (18, 77, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (19, 78, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (20, 79, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (21, 80, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (22, 81, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (23, 82, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (24, 83, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (25, 84, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (26, 85, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (27, 86, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (28, 87, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (29, 88, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (30, 89, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (31, 90, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (32, 91, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (33, 92, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (34, 93, 1, true, true, false, false);
INSERT INTO grouppermissions VALUES (35, 94, 1, true, true, false, false);


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO groups VALUES (1, 'ZHdK (Zürcher Hochschule der Künste)', NULL, NULL, 'Group');
INSERT INTO groups VALUES (2, 'Admin', NULL, NULL, 'Group');
INSERT INTO groups VALUES (3, 'ZHdK', NULL, NULL, 'Group');
INSERT INTO groups VALUES (4, 'Diplomarbeitsgruppe', NULL, NULL, 'Group');
INSERT INTO groups VALUES (5, 'Expert', NULL, NULL, 'Group');
INSERT INTO groups VALUES (7, 'MIZ-Archiv', NULL, NULL, 'Group');
INSERT INTO groups VALUES (8, 'Zett', NULL, NULL, 'Group');
INSERT INTO groups VALUES (9, 'Vertiefung Theorie - Studien zur Medien-, Kunst- und Designpraxis', '56673.mittelbau', 'DKM_FMK_VTH.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (10, 'MAS Szenografie', '3652.studierende', 'DDE_FDE_MASSZ.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (11, 'Z-Module', '68794.mittelbau', 'DKV_FTR_ZMO.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (12, 'Fachrichtung Musik', '14664.mittelbau', 'DMU_FMU.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (13, 'Fachrichtung Tanz', '14665.studierende', 'DDK_FTA.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (14, 'Institute for Cultural Studies in the Arts', '14675.personal', 'DKV_ICS.personal', 'MetaDepartment');
INSERT INTO groups VALUES (15, 'Services, Abteilung Hochschuladministration', '15424.alle', 'SER_MAN_HAD.alle', 'MetaDepartment');
INSERT INTO groups VALUES (16, 'Lehrberufe für Gestaltung und Kunst MB WS 2004', '2367.studierende', 'DKV_FAE_GVE_LGK_MB_04W.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (17, 'Propädeutikum - Gestalterische Orientierungsstufe Teilzeit HS 2012', '115598.studierende', 'DKV_XPP_XGO_T_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (18, 'Bachelor Theater - Vertiefung Regie', '15344.mittelbau', 'DDK_FTH_BTH_VRE.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (19, 'Fachrichtung Transdisziplinarität', '68796.mittelbau', 'DKV_FTR.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (20, 'Fachrichtung Tanz', '14665.alle', 'DDK_FTA.alle', 'MetaDepartment');
INSERT INTO groups VALUES (21, 'Bachelor Theater - Vertiefung Dramaturgie', '15347.studierende', 'DDK_FTH_BTH_VDR.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (22, 'Services, Support Services', '75441.dozierende', 'SER_SUP.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (23, 'Studierende FTM (auch von HKB) > Komposition für Film, Theater und Medien', '65228.', 'Verteilerliste.FTM_Studierende', 'MetaDepartment');
INSERT INTO groups VALUES (24, 'Bachelor Theater - Vertiefung Schauspiel', '56657.mittelbau', 'DDK_FTH_BTH_VSC.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (25, 'Master in Transdisziplinarität', '68797.mittelbau', 'DKV_FTR_MTR.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (26, 'Bühnentanz EFZ', '77742.studierende', 'DDK_FTA_XBT.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (27, 'Bachelor Theater - Vertiefung Dramaturgie', '15347.alle', 'DDK_FTH_BTH_VDR.alle', 'MetaDepartment');
INSERT INTO groups VALUES (28, 'Master Composition and Theory - Komposition - Komposition - HS 2009', '76889.studierende', 'DMU_FMU_MKT_VKO_SKO4_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (29, 'Services, Informations-Technologie-Zentrum', '14647.dozierende', 'SER_SUP_ITZ.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (30, 'Bachelor Theater - Vertiefung Theaterpädagogik', '15345.mittelbau', 'DDK_FTH_BTH_VTP.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (31, 'Bühnentanz EFZ', '77742.alle', 'DDK_FTA_XBT.alle', 'MetaDepartment');
INSERT INTO groups VALUES (32, 'Bachelor Medien & Kunst - Vertiefung Bildende Kunst - HS 2011', '102655.studierende', 'DKM_FMK_BMK_VBK_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (33, 'Services, Verwaltungsdirektion', '56699.personal', 'SER_VD.personal', 'MetaDepartment');
INSERT INTO groups VALUES (34, 'Administratoren der Studiosession-Applikation für Film-/Theater- und Medienstudis (FTM)', '83628.', 'Verteilerliste.FTM_Studiosession_Superadmin', 'MetaDepartment');
INSERT INTO groups VALUES (35, 'Bachelor Medien & Kunst - Vertiefung Fotografie - HS 2011', '102656.studierende', 'DKM_FMK_BMK_VFO_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (36, 'Bachelor Medien & Kunst - Vertiefung Mediale Künste - HS 2011', '102657.studierende', 'DKM_FMK_BMK_VMK_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (37, 'FSP Transdisziplinarität', '107710.dozierende', 'DKV_FSPTR.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (38, 'Profil Bühnenbild', '64577.mittelbau', 'DDK_FTH_MTH_VLK_PBN.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (39, 'Services, Verwaltungsdirektion', '56699.alle', 'SER_VD.alle', 'MetaDepartment');
INSERT INTO groups VALUES (40, 'Vertiefung Game Design', '56666.mittelbau', 'DDE_FDE_VGD.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (41, 'Bachelor Design - Vertiefung Cast / Audiovisuelle Medien - HS 2010', '90730.studierende', 'DDE_FDE_BDE_VCA_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (42, 'Bachelor Medien & Kunst - Vertiefung Theorie - HS 2011', '102658.studierende', 'DKM_FMK_BMK_VTH_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (43, 'FSP Transdisziplinarität', '107710.alle', 'DKV_FSPTR.alle', 'MetaDepartment');
INSERT INTO groups VALUES (44, 'Master Fine Arts HS 2011', '103526.studierende', 'DKM_FMK_MAF_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (45, 'Forschungskonferenz', '113437.', 'Verteilerliste.Forschungskonferenz', 'MetaDepartment');
INSERT INTO groups VALUES (46, 'Master Music Pedagogy - instrumentale/vokale Musikpädagogik - Jazz - HS 2012', '114491.studierende', 'DMU_FMU_MMP_VIV_SJAZ_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (47, 'Services, Hochschulcontrolling', '75444.personal', 'SER_VD_HSC.personal', 'MetaDepartment');
INSERT INTO groups VALUES (48, 'Grafikatelier', '14649.', 'Verteilerliste.Grafikatelier', 'MetaDepartment');
INSERT INTO groups VALUES (49, 'Bachelor Medien & Kunst - Vertiefung Theorie - HS 2010', '90742.studierende', 'DKM_FMK_BMK_VTH_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (50, 'Bachelor Musik - Komposition und Musiktheorie - Theorie - HS 2011', '102570.studierende', 'DMU_FMU_BMU_VKOT_STH_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (51, 'Master Music Pedagogy - instrumentale/vokale Musikpädagogik - Pop - HS 2012', '114494.studierende', 'DMU_FMU_MMP_VIV_SPOP_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (52, 'Bachelor Design', '15289.dozierende', 'DDE_FDE_BDE.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (53, 'Bachelor Musik - Dirigieren - Orchesterleitung - HS 2011', '102563.studierende', 'DMU_FMU_BMU_VDI_SOL_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (54, 'Bachelor Film HS 2012', '116063.studierende', 'DDK_FFI_BFI_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (55, 'Services, Hochschulcontrolling', '75444.alle', 'SER_VD_HSC.alle', 'MetaDepartment');
INSERT INTO groups VALUES (56, 'Institutsleitungen', '14543.', 'Verteilerliste.Institutsleitungen', 'MetaDepartment');
INSERT INTO groups VALUES (57, 'Master Composition and Theory - Komposition - Elektroakustische Komposition - HS 2010', '90311.studierende', 'DMU_FMU_MKT_VKO_SEAK_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (58, 'MAS in klinischer Musiktherapie HS 2010', '94967.studierende', 'DMU_FMU_MASMTH_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (59, 'Gaststudierende in der Vertiefung Fotografie', '102472.', 'Verteilerliste.DKM_VFO_Gaststudierende', 'MetaDepartment');
INSERT INTO groups VALUES (60, 'Personen, die die Webapplikationen "ClickEnroll" pflegen.', '94904.', 'Verteilerliste.App_ClickEnroll_Admin', 'MetaDepartment');
INSERT INTO groups VALUES (61, 'ITZ_Hardware', '63006.', 'Verteilerliste.ITZ_Hardware', 'MetaDepartment');
INSERT INTO groups VALUES (62, 'Master Theater', '64570.mittelbau', 'DDK_FTH_MTH.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (63, 'Master Design - Vertiefung Ereignis', '121298.studierende', 'DDE_FDE_MDE_VER.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (64, 'Projekt Amsterdam - Vertiefung Fotografie', '58373.', 'Verteilerliste.Amsterdam_VFO', 'MetaDepartment');
INSERT INTO groups VALUES (65, 'Bachelor Tanz', '82832.dozierende', 'DDK_FTA_BTA.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (66, 'Fachrichtung Theater', '14666.dozierende', 'DDK_FTH.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (67, 'Master Design - Vertiefung Produkt', '121301.studierende', 'DDE_FDE_MDE_VPR.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (68, 'ITZ_Ra', '14648.', 'Verteilerliste.ITZ_Ra', 'MetaDepartment');
INSERT INTO groups VALUES (69, 'Master Design - Vertiefung Produkt', '121301.alle', 'DDE_FDE_MDE_VPR.alle', 'MetaDepartment');
INSERT INTO groups VALUES (70, 'Bachelor Theater', '15302.dozierende', 'DDK_FTH_BTH.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (71, 'Master Design - Vertiefung Trends', '121302.studierende', 'DDE_FDE_MDE_VTR.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (72, 'ITZ_Security', '14596.', 'Verteilerliste.ITZ_Security', 'MetaDepartment');
INSERT INTO groups VALUES (73, 'Diplomstudium (DaP) Bühnentanz', '15348.alle', 'DDK_FTA_GBT.alle', 'MetaDepartment');
INSERT INTO groups VALUES (74, 'Museum', '14660.alle', 'DKV_Museum.alle', 'MetaDepartment');
INSERT INTO groups VALUES (75, 'MAS Curating HS 2011', '107549.studierende', 'DKV_MASCUR_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (76, 'Master Design - Vertiefung Trends', '121302.alle', 'DDE_FDE_MDE_VTR.alle', 'MetaDepartment');
INSERT INTO groups VALUES (77, 'Bachelor Theater - Vertiefung Dramaturgie', '15347.dozierende', 'DDK_FTH_BTH_VDR.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (78, 'Bachelor Musik - Instrument/Gesang - Jazz - HS 2010', '90312.studierende', 'DMU_FMU_BMU_VIG_SJAZ_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (79, 'Master Design - Vertiefung Ereignis', '121298.alle', 'DDE_FDE_MDE_VER.alle', 'MetaDepartment');
INSERT INTO groups VALUES (80, 'Departement Kulturanalysen und Vermittlung', '14676.personal', 'DKV.personal', 'MetaDepartment');
INSERT INTO groups VALUES (81, 'Master Fine Arts HS 2010', '94725.studierende', 'DKM_FMK_MAF_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (82, 'Master Design - Vertiefung Interaktion', '121299.studierende', 'DDE_FDE_MDE_VIA.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (83, 'Personen, die Low-Level-Zugang zu wichtigen Datenbanken (z.B. Evento) benötigen.', '76400.', 'Verteilerliste.App_DB_Admins', 'MetaDepartment');
INSERT INTO groups VALUES (84, 'Personen im Bereich der Öffentlichkeitsarbeit', '75904.', 'Verteilerliste.Kommunikation', 'MetaDepartment');
INSERT INTO groups VALUES (85, 'Bachelor Theater - Vertiefung Regie', '15344.dozierende', 'DDK_FTH_BTH_VRE.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (86, 'Bachelor Theater - Vertiefung Regie - HS 2009', '78237.studierende', 'DDK_FTH_BTH_VRE_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (87, 'Master Art Education - Vertiefung ausstellen & vermitteln - HS 2010', '90795.studierende', 'DKV_FAE_MAE_VAV_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (88, 'Master Design - Vertiefung Interaktion', '121299.alle', 'DDE_FDE_MDE_VIA.alle', 'MetaDepartment');
INSERT INTO groups VALUES (89, 'Institut für Theorie', '57158.mittelbau', 'DKV_ITH.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (90, 'Museum', '14660.personal', 'DKV_Museum.personal', 'MetaDepartment');
INSERT INTO groups VALUES (91, 'Master Art Education - Vertiefung bilden & vermitteln - HS 2010', '90797.studierende', 'DKV_FAE_MAE_VBV_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (92, 'Master Design - Vertiefung Kommunikation', '121300.studierende', 'DDE_FDE_MDE_VKK.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (93, 'Mitarbeiter des Konservatorium Winterthurs, die die ZHdK-Intranetzugänge des Konservatoriums verwalten', '88541.', 'Verteilerliste.Konsi_Winterthur_Intranet_Admins', 'MetaDepartment');
INSERT INTO groups VALUES (94, 'Bachelor Theater - Vertiefung Schauspiel', '56657.dozierende', 'DDK_FTH_BTH_VSC.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (95, 'Fachrichtung Theater', '14666.studierende', 'DDK_FTH.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (96, 'Master Art Education - Vertiefung bilden & vermitteln - Schwerpunkt Erwachsenenbildung - HS 2010', '90796.studierende', 'DKV_FAE_MAE_VBV_SEB_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (97, 'Master Design - Vertiefung Kommunikation', '121300.alle', 'DDE_FDE_MDE_VKK.alle', 'MetaDepartment');
INSERT INTO groups VALUES (98, 'Institut für Theorie', '57158.alle', 'DKV_ITH.alle', 'MetaDepartment');
INSERT INTO groups VALUES (99, 'Hochschulleitung', '14544.', 'Verteilerliste.Hochschulleitung', 'MetaDepartment');
INSERT INTO groups VALUES (100, 'Personal Museum Au60', '64175.personal', 'personal.DKV_Museum_Au60.personal', 'MetaDepartment');
INSERT INTO groups VALUES (101, 'Master Art Education - Vertiefung publizieren & vermitteln - HS 2010', '90798.studierende', 'DKV_FAE_MAE_VPV_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (102, 'Personen mit Einsicht in alle Budgets der Online-Kostenstellenabfrage', '75903.', 'Verteilerliste.KSA_Generalzugriff', 'MetaDepartment');
INSERT INTO groups VALUES (103, 'Bachelor Theater - Vertiefung Theaterpädagogik', '15345.dozierende', 'DDK_FTH_BTH_VTP.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (104, 'Fachrichtung Theater', '14666.alle', 'DDK_FTH.alle', 'MetaDepartment');
INSERT INTO groups VALUES (105, 'MAS Bilden Künste Gesellschaft HS 2011', '107551.studierende', 'DKV_MASBKG_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (106, 'Personal Museum Au60', '64175.alle', 'personal.DKV_Museum_Au60.alle', 'MetaDepartment');
INSERT INTO groups VALUES (107, 'Bachelor Theater - Vertiefung Dramaturgie - HS 2009', '78235.studierende', 'DDK_FTH_BTH_VDR_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (108, 'Leitung der Finanzabteilung', '75902.', 'Verteilerliste.Leitung_Finanzen', 'MetaDepartment');
INSERT INTO groups VALUES (109, 'Bachelor Theater', '15302.studierende', 'DDK_FTH_BTH.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (110, 'Museum Au60', '64181.alle', 'DKV_Museum_Au60.alle', 'MetaDepartment');
INSERT INTO groups VALUES (111, 'Master Art Education - Vertiefung bilden & vermitteln - HS2008', '68707.studierende', 'DKV_FAE_MAE_VBV_08H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (112, 'Bachelor Theater', '15302.alle', 'DDK_FTH_BTH.alle', 'MetaDepartment');
INSERT INTO groups VALUES (113, 'Personen, die die Applikation Intranet-News (inkl. Infobildschirme) pflegen.', '75922.', 'Verteilerliste.App_Intranetnews_Admin', 'MetaDepartment');
INSERT INTO groups VALUES (114, 'Bachelor Musik - Tonmeister - Jazz - HS 2010', '90331.studierende', 'DMU_FMU_BMU_VTO_SJAZ_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (115, 'Museum Au60', '64181.personal', 'DKV_Museum_Au60.personal', 'MetaDepartment');
INSERT INTO groups VALUES (116, 'Bachelor Theater - Vertiefung Regie', '15344.studierende', 'DDK_FTH_BTH_VRE.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (117, 'Personen, die die Webapplikation "Jahreskalender" pflegen.', '75917.', 'Verteilerliste.App_Jahreskalender_Admin', 'MetaDepartment');
INSERT INTO groups VALUES (118, 'Institute for Cultural Studies in the Arts', '14675.dozierende', 'DKV_ICS.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (119, 'Bachelor Theater - Vertiefung Regie', '15344.alle', 'DDK_FTH_BTH_VRE.alle', 'MetaDepartment');
INSERT INTO groups VALUES (120, 'Bachelor Musik - Tonmeister - Pop - HS 2011', '102989.studierende', 'DMU_FMU_BMU_VTO_SPOP_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (121, 'Personen, die die Webapplikationen "Links" pflegen.', '75920.', 'Verteilerliste.App_Links_Admin', 'MetaDepartment');
INSERT INTO groups VALUES (122, 'Master Music Pedagogy - instrumentale/vokale Musikpädagogik - Pop - HS 2011', '102511.studierende', 'DMU_FMU_MMP_VIV_SPOP_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (123, 'Forschung und Entwicklung', '14644.dozierende', 'F_E.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (124, 'Regie', '64572.studierende', 'DDK_FTH_VRE.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (125, 'Personen, die die News-Applikation mit Inhalt versorgen.', '75926.', 'Verteilerliste.App_News_Admin', 'MetaDepartment');
INSERT INTO groups VALUES (126, 'Institut für Gegenwartskunst', '66212.mittelbau', 'DKM_IFCAR.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (127, 'Master Fine Arts HS 2009', '78192.studierende', 'DKM_FMK_MAF_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (128, 'Bachelor Musik - Kunst- und Sportgymnasium - Jazz - HS 2009', '77896.studierende', 'DMU_FMU_BMU_VKS_SJAZ_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (129, 'Regie', '64572.alle', 'DDK_FTH_VRE.alle', 'MetaDepartment');
INSERT INTO groups VALUES (130, 'NDK / CAS Theaterpädagogik', '15417.studierende', 'DDK_FTH_CASTP.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (131, 'Master Fine Arts', '64989.studierende', 'DKM_FMK_MAF.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (132, 'NDK / CAS Theaterpädagogik', '15417.alle', 'DDK_FTH_CASTP.alle', 'MetaDepartment');
INSERT INTO groups VALUES (133, 'Master Fine Arts', '64989.alle', 'DKM_FMK_MAF.alle', 'MetaDepartment');
INSERT INTO groups VALUES (134, 'Bachelor Musik und Bewegung HS 2011', '102562.studierende', 'DMU_FMU_BMB_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (135, 'Propädeutikum - Gestalterische Orientierungsstufe Vollzeit HS 2012', '115597.studierende', 'DKV_XPP_XGO_V_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (136, 'Personen, die das Projektarchiv pflegen.', '75928.', 'Verteilerliste.App_Projektarchiv_Admin', 'MetaDepartment');
INSERT INTO groups VALUES (137, 'Leitung Studiengänge/Vertiefungen/Schwerpunkte/Profile - Dozierende mit Leitungsfunktionen', '3876.', 'Verteilerliste.Leitung_Studiengaenge', 'MetaDepartment');
INSERT INTO groups VALUES (138, 'Dieser Gruppe gehören diejenigen Pseudobenutzer an, die standardmässig im Kioskbetrieb angemeldet werden.', '75929.', 'Verteilerliste.App_Raumverwaltung_Kioskbetrieb', 'MetaDepartment');
INSERT INTO groups VALUES (139, 'Leitung Vertiefung Neue Medien', '14594.', 'Verteilerliste.Leitung_VNM', 'MetaDepartment');
INSERT INTO groups VALUES (140, 'Bachelor Musik - Komposition und Musiktheorie - Elektroakustische Komposition - HS 2010', '90427.studierende', 'DMU_FMU_BMU_VKOT_SEAK_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (141, 'Departement Darstellende Künste und Film', '14677.studierende', 'DDK.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (142, 'Departementsleitungen', '14542.', 'Verteilerliste.Departementsleitungen', 'MetaDepartment');
INSERT INTO groups VALUES (143, 'MAE Externe Dozierende', '75896.', 'Verteilerliste.MAE_externe_Dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (144, 'MAS in Type Design/Typography HS 2009', '83922.studierende', 'DDE_FDE_MASTDT_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (145, 'Master Music Pedagogy - Musik und Bewegung - Elementare Musikerziehung - HS 2010', '90276.studierende', 'DMU_FMU_MMP_VMB_SEM_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (146, 'Departement Darstellende Künste und Film', '14677.alle', 'DDK.alle', 'MetaDepartment');
INSERT INTO groups VALUES (147, 'Bachelor Theater - Vertiefung Dramaturgie - HS 2010', '90805.studierende', 'DDK_FTH_BTH_VDR_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (148, 'CAS Orchesterleitung basic HS 2012', '113702.studierende', 'DMU_FMU_CASOCB_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (149, 'Master Music Pedagogy - instrumentale/vokale Musikpädagogik - Klassik - FS 2013', '120724.studierende', 'DMU_FMU_MMP_VIV_SKLA_13F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (150, 'Vertiefung Mediale Künste', '56671.mittelbau', 'DKM_FMK_VMK.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (151, 'Vertiefung Cast', '14669.studierende', 'DDE_FDE_BDE_VCA.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (152, 'Bachelor Theater - Vertiefung Regie - HS 2010', '90807.studierende', 'DDK_FTH_BTH_VRE_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (153, 'CAS Orchesterleitung intermediate HS 2012', '113703.studierende', 'DMU_FMU_CASOCI_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (154, 'Master Music Performance - instrumentale/vokale Performance - Konzert - FS 2013', '120722.studierende', 'DMU_FMU_MPE_VIV_SKT_13F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (155, 'Management_Services (Verwaltungsdirektion)', '14654.', 'Verteilerliste.Management_Services', 'MetaDepartment');
INSERT INTO groups VALUES (156, 'MAS in Type Design and Typography', '83923.studierende', 'DDE_FDE_MASTDT.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (157, 'Bachelor Film HS 2009', '78053.studierende', 'DDK_FFI_BFI_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (158, 'Bachelor Theater - Vertiefung Theaterpädagogik - HS 2010', '90814.studierende', 'DDK_FTH_BTH_VTP_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (159, 'Master Music Performance - instrumentale/vokale Performance - Orchester - FS 2013', '120723.studierende', 'DMU_FMU_MPE_VIV_SOR_13F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (160, 'DKM_Sekretariat', '14652.', 'Verteilerliste.DKM_Sekretariat', 'MetaDepartment');
INSERT INTO groups VALUES (161, 'Vertiefung Cast', '14669.alle', 'DDE_FDE_BDE_VCA.alle', 'MetaDepartment');
INSERT INTO groups VALUES (162, 'Jungstudierende - Kunst- und Sportgymnasium - FS 2011', '96922.studierende', 'DMU_FMU_XJST_VKS_11F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (163, 'Master Specialized Music Performance - Kammermusik - Klavierkammermusik/Lied - FS 2013', '120720.studierende', 'DMU_FMU_MSP_VKAM_SKL_13F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (164, 'Vertiefung Industrial Design', '3037.dozierende', 'DDE_FDE_BDE_VID.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (165, 'MAS in Type Design and Typography', '83923.alle', 'DDE_FDE_MASTDT.alle', 'MetaDepartment');
INSERT INTO groups VALUES (166, 'Bachelor Medien & Kunst - Vertiefung Bildende Kunst - HS 2009', '78180.studierende', 'DKM_FMK_BMK_VBK_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (167, 'Master Music Pedagogy - instrumentale/vokale Musikpädagogik - Jazz - HS 2010', '90271.studierende', 'DMU_FMU_MMP_VIV_SJAZ_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (168, 'Fachrichtung Film', '3033.studierende', 'DDK_FFI.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (169, 'Bühnentanz EFZ HS 2011', '101780.studierende', 'DDK_FTA_XBT_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (170, 'FSP Transdisziplinarität', '107710.mittelbau', 'DKV_FSPTR.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (171, 'Vertiefung Industrial Design', '3037.mittelbau', 'DDE_FDE_BDE_VID.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (172, 'Personen, die Admin-Zugang zu den Z-Modul-Applikationen benötigen.', '75925.', 'Verteilerliste.DKV_Zmodule_Admin', 'MetaDepartment');
INSERT INTO groups VALUES (173, 'Vertiefung Cast / Audiovisuelle Medien', '56662.studierende', 'DDE_FDE_VCA.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (174, 'Vertiefung Theorie - Studien zur Medien-, Kunst- und Designpraxis', '56673.alle', 'DKM_FMK_VTH.alle', 'MetaDepartment');
INSERT INTO groups VALUES (175, 'Master Specialized Music Performance - Kammermusik - Klavierkammermusik/Lied - FS 2012', '108243.studierende', 'DMU_FMU_MSP_VKAM_SKL_12F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (176, 'Bachelor Musik - Instrument/Gesang - Jazz - HS 2012', '114444.studierende', 'DMU_FMU_BMU_VIG_SJAZ_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (177, 'Vertiefung Industrial Design', '3037.personal', 'DDE_FDE_BDE_VID.personal', 'MetaDepartment');
INSERT INTO groups VALUES (178, 'Master Art Education - Vertiefung bilden & vermitteln - HS 2009', '78227.studierende', 'DKV_FAE_MAE_VBV_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (179, 'Qualitätsmanagement', '77386.', 'Verteilerliste.QM', 'MetaDepartment');
INSERT INTO groups VALUES (180, 'Fachrichtung Film', '3033.alle', 'DDK_FFI.alle', 'MetaDepartment');
INSERT INTO groups VALUES (181, 'Master Specialized Music Performance - Solist/in - FS 2012', '108242.studierende', 'DMU_FMU_MSP_VSO_12F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (182, 'Master Design', '74626.personal', 'DDE_FDE_MDE.personal', 'MetaDepartment');
INSERT INTO groups VALUES (183, 'DKV Konferenz', '62003.', 'Verteilerliste.DKVKonferenz', 'MetaDepartment');
INSERT INTO groups VALUES (184, 'MAS Curating', '8406.alle', 'DKV_MASCUR.alle', 'MetaDepartment');
INSERT INTO groups VALUES (185, 'Bachelor Vermittlung von Kunst und Design HS 2008', '66377.studierende', 'DKV_FAE_BAE_08H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (186, 'Master Music Performance - Dirigieren - Orchesterleitung - HS 2010', '90284.studierende', 'DMU_FMU_MPE_VDI_SOL_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (187, 'Vertiefung Cast / Audiovisuelle Medien', '56662.alle', 'DDE_FDE_VCA.alle', 'MetaDepartment');
INSERT INTO groups VALUES (188, 'Profil Theorie', '89976.dozierende', 'DMU_FMU_PTH.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (189, 'Vertiefung Theorie - Studien zur Medien-, Kunst- und Designpraxis', '3036.studierende', 'DKM_FMK_BMK_VTH.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (190, 'Bachelor Musik - Schulmusik - Jazz - HS 2012', '114545.studierende', 'DMU_FMU_BMU_VSMU_SJAZ_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (191, 'Vertiefung Industrial Design', '56663.personal', 'DDE_FDE_VID.personal', 'MetaDepartment');
INSERT INTO groups VALUES (192, 'Vertiefung Theorie - Studien zur Medien-, Kunst- und Designpraxis', '56673.dozierende', 'DKM_FMK_VTH.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (193, 'Bachelor Film', '4397.studierende', 'DDK_FFI_BFI.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (194, 'Bachelor Musik - Schulmusik - Pop - HS 2012', '114449.studierende', 'DMU_FMU_BMU_VSMU_SPOP_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (195, 'Personen, die Stammdaten der elektronischen Einschreibung im Dept. Musik pflegen.', '75921.', 'Verteilerliste.DMU_Einschreibung_Superadmin', 'MetaDepartment');
INSERT INTO groups VALUES (196, 'MAS Curating', '8406.studierende', 'DKV_MASCUR.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (197, 'MAS Musikpraxis', '15350.studierende', 'DMU_MASMPX.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (198, 'Profil Theorie', '89976.alle', 'DMU_FMU_PTH.alle', 'MetaDepartment');
INSERT INTO groups VALUES (199, 'Vertiefung Theorie - Studien zur Medien-, Kunst- und Designpraxis', '3036.alle', 'DKM_FMK_BMK_VTH.alle', 'MetaDepartment');
INSERT INTO groups VALUES (200, 'MAS in klinischer Musiktherapie Upgrade HS 2012', '115391.studierende', 'DMU_FMU_MASMTH_UP_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (201, 'MAS erweiterte Musikpädagogik HS 2012', '119605.studierende', 'DMU_FMU_MASEMP_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (202, 'Senat', '5956.', 'Verteilerliste.Senat', 'MetaDepartment');
INSERT INTO groups VALUES (203, 'Master in Art Education', '68798.mittelbau', 'DKV_FAE_MAE.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (204, 'Departement Kulturanalysen und Vermittlung', '14676.mittelbau', 'DKV.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (205, 'Bachelor Film', '4397.alle', 'DDK_FFI_BFI.alle', 'MetaDepartment');
INSERT INTO groups VALUES (206, 'Personen, die für die Verwaltung der Freundeskreis-.Patenschaften zuständig sind. Auch externe Personen.', '75912.', 'Verteilerliste.DMU_Freundeskreis_Admin', 'MetaDepartment');
INSERT INTO groups VALUES (207, 'MAS Musikpraxis', '15350.alle', 'DMU_MASMPX.alle', 'MetaDepartment');
INSERT INTO groups VALUES (208, 'Bachelor Musik - Komposition und Musiktheorie - Theorie - HS 2010', '90428.studierende', 'DMU_FMU_BMU_VKOT_STH_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (209, 'Vertiefung Theorie - Studien zur Medien-, Kunst- und Designpraxis', '56673.studierende', 'DKM_FMK_VTH.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (210, 'MIZ Archiv', '56709.', 'Verteilerliste.SER_SUP_MIZ_Archiv', 'MetaDepartment');
INSERT INTO groups VALUES (211, 'Institute for Cultural Studies in the Arts', '14675.mittelbau', 'DKV_ICS.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (212, 'Bachelor Theater - Vertiefung Szenografie', '15346.studierende', 'DDK_FTH_BTH_VSZ.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (213, 'Bachelor Medien & Kunst - Vertiefung Theorie - HS 2008', '66367.studierende', 'DKM_FMK_BMK_VTH_08H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (214, 'MIZ Ausleihe', '76817.', 'Verteilerliste.SER_SUP_MIZ_Ausleihe_Ausstellungsstrasse', 'MetaDepartment');
INSERT INTO groups VALUES (215, 'Institute for Cultural Studies in the Arts', '14675.alle', 'DKV_ICS.alle', 'MetaDepartment');
INSERT INTO groups VALUES (216, 'Bachelor Theater - Vertiefung Szenografie', '15346.alle', 'DDK_FTH_BTH_VSZ.alle', 'MetaDepartment');
INSERT INTO groups VALUES (217, 'Master of Arts in Transdisziplinarität HS 2010', '94672.studierende', 'DKV_FTR_MTR_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (218, 'Master Composition and Theory - Komposition - Komposition für Film, Theater und Medien - HS 2010', '90309.studierende', 'DMU_FMU_MKT_VKO_SFTM_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (219, 'Bachelor Musik - Dirigieren - Orchesterleitung - HS 2010', '90335.studierende', 'DMU_FMU_BMU_VDI_SOL_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (220, 'Fachrichtung Transdisziplinarität', '68796.studierende', 'DKV_FTR.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (221, 'Master of Arts in Transdisziplinarität FS 2012', '112040.studierende', 'DKV_FTR_MTR_12F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (222, 'Master Komposition/Theorie', '64309.studierende', 'DMU_FMU_MKT.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (223, 'Teilnehmer des Symposiums Musiktherapie (Weiterbildung)', '100505.', 'Verteilerliste.Teilnehmer_Symposium_Musiktherapie', 'MetaDepartment');
INSERT INTO groups VALUES (224, 'ProfilTheaterpädagogik', '64575.mittelbau', 'DDK_FTH_MTH_VLK_PTP.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (225, 'MIZ Kommission', '58311.', 'Verteilerliste.SER_SUP_MIZ_Kommission', 'MetaDepartment');
INSERT INTO groups VALUES (226, 'Master Fine Arts', '64989.mittelbau', 'DKM_FMK_MAF.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (227, 'Bachelor Musik - Schulmusik - Klassik - HS 2010', '90326.studierende', 'DMU_FMU_BMU_VSMU_SKLA_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (228, 'Departement Kunst und Medien', '5112.mittelbau', 'DKM.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (229, 'Fachrichtung Transdisziplinarität', '68796.alle', 'DKV_FTR.alle', 'MetaDepartment');
INSERT INTO groups VALUES (230, 'Master Music Performance - Dirigieren - Orchesterleitung - HS 2011', '102530.studierende', 'DMU_FMU_MPE_VDI_SOL_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (231, 'Institute for the Performing Arts and Film', '83401.mittelbau', 'DDK_IPF.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (232, 'Master Komposition/Theorie', '64309.alle', 'DMU_FMU_MKT.alle', 'MetaDepartment');
INSERT INTO groups VALUES (233, 'Master Music Performance - instrumentale/vokale Performance - Orchester - FS 2011', '96029.studierende', 'DMU_FMU_MPE_VIV_SOR_11F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (234, 'Master Specialized Music Performance - Dirigieren - Orchesterleitung - HS 2011', '102539.studierende', 'DMU_FMU_MSP_VDI_SOL_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (235, 'Verwaltung Support_Services', '56677.', 'Verteilerliste.Support_Services', 'MetaDepartment');
INSERT INTO groups VALUES (236, 'Fachrichtung Medien & Kunst', '14668.mittelbau', 'DKM_FMK.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (237, 'Master in Transdisziplinarität', '68797.studierende', 'DKV_FTR_MTR.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (238, 'Master Specialized Music Performance - Kammermusik - Klavierkammermusik/Lied - FS 2011', '96031.studierende', 'DMU_FMU_MSP_VKAM_SKL_11F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (239, 'Vertiefung Schauspiel', '64573.dozierende', 'DDK_FTH_MTH_VSC.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (240, 'Master Film HS 2012', '116062.studierende', 'DDK_FFI_MFI_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (241, 'Gäste des DKM (sowohl Externe wie auch ZHdK-Angehörige)', '108324.', 'Verteilerliste.DKM_Gaeste', 'MetaDepartment');
INSERT INTO groups VALUES (242, 'Theater der Künste', '56698.', 'Verteilerliste.TheaterderKuenste', 'MetaDepartment');
INSERT INTO groups VALUES (243, 'Institute for the Performing Arts and Film', '83401.personal', 'DDK_IPF.personal', 'MetaDepartment');
INSERT INTO groups VALUES (244, 'Master Fine Arts', '64989.dozierende', 'DKM_FMK_MAF.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (245, 'Bachelor Musik - Tonmeister - Klassik - HS 2010', '90332.studierende', 'DMU_FMU_BMU_VTO_SKLA_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (246, 'Vertiefung Bildende Kunst', '56670.mittelbau', 'DKM_FMK_VBK.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (247, 'Bachelor Film HS 2010', '90794.studierende', 'DDK_FFI_BFI_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (248, 'Master in Transdisziplinarität', '68797.alle', 'DKV_FTR_MTR.alle', 'MetaDepartment');
INSERT INTO groups VALUES (249, 'Jungstudierende - Klassik - HS 2011', '103125.studierende', 'DMU_FMU_XJST_SKLA_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (250, 'Bachelor Musik und Bewegung HS 2010', '90334.studierende', 'DMU_FMU_BMB_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (251, 'Zugriff auf SAP BW Portal, KST-Auswertung', '103106.', 'Verteilerliste.SAP_BW_Portal_KST', 'MetaDepartment');
INSERT INTO groups VALUES (252, 'Bachelor Theater - Vertiefung Szenografie - HS 2010', '90813.studierende', 'DDK_FTH_BTH_VSZ_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (253, 'Vorlesungsverzeichnis', '100581.', 'Verteilerliste.Vorlesungsverzeichnis', 'MetaDepartment');
INSERT INTO groups VALUES (254, 'Master Specialized Music Performance - Solist/in - FS 2013', '120721.studierende', 'DMU_FMU_MSP_VSO_13F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (255, 'MIZ_Ausstellungsstrasse', '58310.', 'Verteilerliste.SER_SUP_MIZ_Ausstellungsstrasse', 'MetaDepartment');
INSERT INTO groups VALUES (256, 'Master Design', '74626.mittelbau', 'DDE_FDE_MDE.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (257, 'Personal ITZ, Gruppe Planung', '125258.personal', 'SER_SUP_ITZ_Planung.personal', 'MetaDepartment');
INSERT INTO groups VALUES (258, 'Bachelor Musik und Bewegung', '15296.studierende', 'DMU_FMU_BMB.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (259, 'Bachelor Design - Vertiefung Industrial Design - HS 2010', '90733.studierende', 'DDE_FDE_BDE_VID_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (260, 'Personal ITZ, Gruppe Planung', '125258.alle', 'SER_SUP_ITZ_Planung.alle', 'MetaDepartment');
INSERT INTO groups VALUES (261, 'Fachrichtung Tanz', '14665.personal', 'DDK_FTA.personal', 'MetaDepartment');
INSERT INTO groups VALUES (262, 'Bachelor Musik - Komposition und Musiktheorie - Komposition für Film, Theater und Medien - HS 2012', '114454.studierende', 'DMU_FMU_BMU_VKOT_SFTM_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (263, 'CAS Performance Klassik FS 2013', '121182.studierende', 'DMU_FMU_CASKLA_13F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (264, 'Bachelor Musik und Bewegung', '15296.alle', 'DMU_FMU_BMB.alle', 'MetaDepartment');
INSERT INTO groups VALUES (265, 'Bachelor Musik - Tonmeister - Pop - HS 2012', '114453.studierende', 'DMU_FMU_BMU_VTO_SPOP_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (266, 'Master Composition and Theory - Komposition - Komposition - HS 2010', '90307.studierende', 'DMU_FMU_MKT_VKO_SKO4_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (267, 'Master Composition and Theory - Komposition - Elektroakustische Komposition - HS 2012', '114520.studierende', 'DMU_FMU_MKT_VKO_SEAK_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (268, 'Bachelor Theater', '15302.personal', 'DDK_FTH_BTH.personal', 'MetaDepartment');
INSERT INTO groups VALUES (269, 'Vertiefung Game Design', '56666.alle', 'DDE_FDE_VGD.alle', 'MetaDepartment');
INSERT INTO groups VALUES (270, 'Master Composition and Theory - Komposition - Komposition für Film, Theater und Medien - HS 2012', '114521.studierende', 'DMU_FMU_MKT_VKO_SFTM_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (271, 'Bachelor Theater - Vertiefung Dramaturgie - HS 2012', '115170.studierende', 'DDK_FTH_BTH_VDR_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (272, 'MAS Spatial Design HS 2012', '120140.studierende', 'DDE_FDE_MASSD_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (273, 'Services', '14645.personal', 'SER.personal', 'MetaDepartment');
INSERT INTO groups VALUES (274, 'Master Theater - Vertiefung Bühnenbild - HS 2010', '91581.studierende', 'DDK_FTH_MTH_VBN_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (275, 'Master Composition and Theory - Komposition - Komposition - HS 2012', '114791.studierende', 'DMU_FMU_MKT_VKO_SKO4_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (276, 'Bachelor Theater - Vertiefung Regie - HS 2012', '115171.studierende', 'DDK_FTH_BTH_VRE_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (277, 'MAS Curating HS 2012', '120139.studierende', 'DKV_MASCUR_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (278, 'Vertiefung Game Design', '3047.studierende', 'DDE_FDE_BDE_VGD.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (279, 'Bachelor Theater - Vertiefung Theaterpädagogik - HS 2012', '115174.studierende', 'DDK_FTH_BTH_VTP_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (280, 'Master in Transdisziplinarität', '68797.dozierende', 'DKV_FTR_MTR.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (281, 'Profil Musik und Bewegung', '65628.dozierende', 'DMU_FMU_PMB.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (282, 'Services', '14645.alle', 'SER.alle', 'MetaDepartment');
INSERT INTO groups VALUES (283, 'MAS Spatial Design HS 2011', '107550.studierende', 'DDE_FDE_MASSD_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (284, 'MAS in musikalischer Kreation HS 2012', '119607.studierende', 'DMU_FMU_MASMK_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (285, 'Profil Bühnenbild', '64577.studierende', 'DDK_FTH_MTH_VLK_PBN.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (286, 'Vertiefung Game Design', '3047.alle', 'DDE_FDE_BDE_VGD.alle', 'MetaDepartment');
INSERT INTO groups VALUES (287, 'MAS Spatial Design', '107592.studierende', 'DDE_FDE_MASSD.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (288, 'MAS Musikpraxis HS 2012', '119606.studierende', 'DMU_FMU_MASMPX_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (289, 'Profil Musik und Bewegung', '65628.alle', 'DMU_FMU_PMB.alle', 'MetaDepartment');
INSERT INTO groups VALUES (290, 'MAS Design Culture', '4187.alle', 'DDE_FDE_MASDEC.alle', 'MetaDepartment');
INSERT INTO groups VALUES (291, 'Services, Management Services', '75440.personal', 'SER_MAN.personal', 'MetaDepartment');
INSERT INTO groups VALUES (292, 'MAS Spatial Design', '107592.alle', 'DDE_FDE_MASSD.alle', 'MetaDepartment');
INSERT INTO groups VALUES (293, 'MAS in klinischer Musiktherapie HS 2012', '119608.studierende', 'DMU_FMU_MASMTH_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (294, 'Profil Bühnenbild', '64577.alle', 'DDK_FTH_MTH_VLK_PBN.alle', 'MetaDepartment');
INSERT INTO groups VALUES (295, 'Vertiefung Game Design', '56666.studierende', 'DDE_FDE_VGD.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (296, 'Fachrichtung Art Education', '3048.personal', 'DKV_FAE.personal', 'MetaDepartment');
INSERT INTO groups VALUES (297, 'Sammlungen', '15427.personal', 'DKV_Sammlungen.personal', 'MetaDepartment');
INSERT INTO groups VALUES (298, 'MAS Design Culture', '4187.studierende', 'DDE_FDE_MASDEC.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (299, 'Services, Management Services', '75440.alle', 'SER_MAN.alle', 'MetaDepartment');
INSERT INTO groups VALUES (300, 'MAS in Type Design and Typography', '83923.dozierende', 'DDE_FDE_MASTDT.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (301, 'Bachelor Design - Vertiefung Game Design - HS 2008', '66286.studierende', 'DDE_FDE_BDE_VGD_08H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (302, 'Master Music Pedagogy - instrumentale/vokale Musikpädagogik - Klassik - FS 2011', '96027.studierende', 'DMU_FMU_MMP_VIV_SKLA_11F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (303, 'MAS Bilden Künste Gesellschaft HS 2008', '83920.studierende', 'DKV_MASBKG_08H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (304, 'Sammlungen', '15427.alle', 'DKV_Sammlungen.alle', 'MetaDepartment');
INSERT INTO groups VALUES (305, 'Master Composition and Theory - Tonmeister - HS 2010', '90310.studierende', 'DMU_FMU_MKT_VTO_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (306, 'Services, Abteilung Personalabteilung', '14590.personal', 'SER_MAN_PER.personal', 'MetaDepartment');
INSERT INTO groups VALUES (307, 'Master Music Performance - instrumentale/vokale Performance - Konzert - FS 2011', '96028.studierende', 'DMU_FMU_MPE_VIV_SKT_11F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (308, 'Bachelor Theater - Vertiefung Theaterpädagogik', '15345.studierende', 'DDK_FTH_BTH_VTP.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (309, 'Master Specialized Music Performance - Solist/in - FS 2011', '96030.studierende', 'DMU_FMU_MSP_VSO_11F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (310, 'Personal Sammlungen', '64173.personal', 'personal.DKV_Sammlungen_detailliert.personal', 'MetaDepartment');
INSERT INTO groups VALUES (311, 'Services, Abteilung Personalabteilung', '14590.alle', 'SER_MAN_PER.alle', 'MetaDepartment');
INSERT INTO groups VALUES (312, 'Vertiefung Leitende Künstlerin / Leitender Künstler', '121195.dozierende', 'DDK_FTH_MTH_VLK.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (313, 'MAS Bilden Künste Gesellschaft HS 2009', '83918.studierende', 'DKV_MASBKG_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (314, 'Profil Klassik', '65626.dozierende', 'DMU_FMU_PKLA.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (315, 'Bachelor Design - Vertiefung Interaction Design - HS 2010', '90732.studierende', 'DDE_FDE_BDE_VIAD_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (316, 'Bachelor Theater - Vertiefung Theaterpädagogik', '15345.alle', 'DDK_FTH_BTH_VTP.alle', 'MetaDepartment');
INSERT INTO groups VALUES (317, 'Vertiefung Leitende Künstlerin / Leitender Künstler', '121195.alle', 'DDK_FTH_MTH_VLK.alle', 'MetaDepartment');
INSERT INTO groups VALUES (318, 'Leitung und Assistenz für den Bachelor Design', '90037.', 'Verteilerliste.BDE_Leitung', 'MetaDepartment');
INSERT INTO groups VALUES (319, 'Personal Sammlungen', '64173.alle', 'personal.DKV_Sammlungen_detailliert.alle', 'MetaDepartment');
INSERT INTO groups VALUES (320, 'Master Musik Performance', '64307.studierende', 'DMU_FMU_MPE.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (321, 'Bachelor Musik - Kunst- und Sportgymnasium - Klassik - HS 2012', '114447.studierende', 'DMU_FMU_BMU_VKS_SKLA_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (323, 'Vertiefung Leitende Künstlerin / Leitender Künstler', '121195.mittelbau', 'DDK_FTH_MTH_VLK.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (324, 'Profil Klassik', '65626.alle', 'DMU_FMU_PKLA.alle', 'MetaDepartment');
INSERT INTO groups VALUES (325, 'Bachelor Musik - Schulmusik - Klassik - HS 2012', '114448.studierende', 'DMU_FMU_BMU_VSMU_SKLA_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (326, 'Master Music Pedagogy - Analyse und Vermittlung - HS 2012', '114498.studierende', 'DMU_FMU_MMP_VAVE_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (328, 'Vertiefung Leitende Künstlerin / Leitender Künstler', '121195.studierende', 'DDK_FTH_MTH_VLK.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (329, 'Master Fine Arts', '64989.personal', 'DKM_FMK_MAF.personal', 'MetaDepartment');
INSERT INTO groups VALUES (330, 'Departement Musik', '15284.personal', 'DMU.personal', 'MetaDepartment');
INSERT INTO groups VALUES (331, 'Master Musik Performance', '64307.alle', 'DMU_FMU_MPE.alle', 'MetaDepartment');
INSERT INTO groups VALUES (332, 'Jungstudierende - Klassik - HS 2012', '115506.studierende', 'DMU_FMU_XJST_SKLA_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (333, 'Master Composition and Theory - Theorie - HS 2012', '114522.studierende', 'DMU_FMU_MKT_VTH_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (334, 'Profil Dramaturgie', '121194.studierende', 'DDK_FTH_MTH_VLK_PDR.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (335, 'MAS erweiterte Musikpädagogik FS 2013', '125678.studierende', 'DMU_FMU_MASEMP_13F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (336, 'Theaterpädagogik', '64576.studierende', 'DDK_FTH_VTP.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (337, 'Master Music Performance - instrumentale/vokale Performance - Orchester - HS 2010', '90282.studierende', 'DMU_FMU_MPE_VIV_SOR_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (338, 'Profil Dramaturgie', '121194.alle', 'DDK_FTH_MTH_VLK_PDR.alle', 'MetaDepartment');
INSERT INTO groups VALUES (339, 'MAS Musikpraxis FS 2013', '125680.studierende', 'DMU_FMU_MASMPX_13F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (340, 'Fachrichtung Musik', '14664.personal', 'DMU_FMU.personal', 'MetaDepartment');
INSERT INTO groups VALUES (341, 'Dramaturgie', '121196.studierende', 'DDK_FTH_VDR.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (342, 'Theaterpädagogik', '64576.alle', 'DDK_FTH_VTP.alle', 'MetaDepartment');
INSERT INTO groups VALUES (343, 'Bachelor Vermittlung von Kunst und Design -  Ästhetische Bildung und Soziokultur - HS 2012', '115228.studierende', 'DKV_FAE_BAE_VAS_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (344, 'Dramaturgie', '121196.alle', 'DDK_FTH_VDR.alle', 'MetaDepartment');
INSERT INTO groups VALUES (345, 'MAS Szenografie', '3652.dozierende', 'DDE_FDE_MASSZ.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (346, 'Fachrichtung Transdisziplinarität', '68796.dozierende', 'DKV_FTR.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (347, 'Bachelor Musik - Instrument/Gesang - Pop - HS 2012', '114446.studierende', 'DMU_FMU_BMU_VIG_SPOP_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (348, 'Departement Kunst und Medien', '5112.dozierende', 'DKM.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (349, 'Bachelor Design - Vertiefung Visuelle Kommunikation - HS 2010', '90736.studierende', 'DDE_FDE_BDE_VVK_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (350, 'Bachelor Theater - Vertiefung Theaterpädagogik - HS 2009', '83417.studierende', 'DDK_FTH_BTH_VTP_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (351, 'Vertiefung Style&Design', '56675.alle', 'DDE_FDE_VSD.alle', 'MetaDepartment');
INSERT INTO groups VALUES (352, 'Bachelor Theater - Vertiefung Dramaturgie - HS 2011', '102898.studierende', 'DDK_FTH_BTH_VDR_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (353, 'Personal ITZ, Gruppe Betrieb', '125256.personal', 'SER_SUP_ITZ_Betrieb.personal', 'MetaDepartment');
INSERT INTO groups VALUES (354, 'Fachrichtung Film', '3033.dozierende', 'DDK_FFI.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (355, 'Z-Module', '68794.dozierende', 'DKV_FTR_ZMO.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (356, 'Personal ITZ, Gruppe Betrieb', '125256.alle', 'SER_SUP_ITZ_Betrieb.alle', 'MetaDepartment');
INSERT INTO groups VALUES (357, 'Fachrichtung Medien & Kunst', '14668.dozierende', 'DKM_FMK.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (358, 'Vertiefung Style&Design', '3040.studierende', 'DDE_FDE_BDE_VSD.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (359, 'Personal ITZ, Gruppe Entwicklung', '125257.personal', 'SER_SUP_ITZ_Entwicklung.personal', 'MetaDepartment');
INSERT INTO groups VALUES (360, 'Vertiefung Fotografie', '56672.mittelbau', 'DKM_FMK_VFO.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (361, 'Bachelor Film', '4397.dozierende', 'DDK_FFI_BFI.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (362, 'Z-Module', '68794.alle', 'DKV_FTR_ZMO.alle', 'MetaDepartment');
INSERT INTO groups VALUES (363, 'Personal ITZ, Gruppe Entwicklung', '125257.alle', 'SER_SUP_ITZ_Entwicklung.alle', 'MetaDepartment');
INSERT INTO groups VALUES (364, 'Vertiefung Fotografie', '56672.dozierende', 'DKM_FMK_VFO.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (365, 'Vertiefung Style&Design', '3040.alle', 'DDE_FDE_BDE_VSD.alle', 'MetaDepartment');
INSERT INTO groups VALUES (366, 'MIZ Katalogisierung GND_S', '121361.', 'Verteilerliste.SER_SUP_MIZ_Katalogisierung_GND_S', 'MetaDepartment');
INSERT INTO groups VALUES (367, 'Vertiefung Style&Design', '56675.studierende', 'DDE_FDE_VSD.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (368, 'Bachelor Theater - Vertiefung Regie - HS 2011', '102897.studierende', 'DDK_FTH_BTH_VRE_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (369, 'Vertiefung Bildende Kunst', '56670.personal', 'DKM_FMK_VBK.personal', 'MetaDepartment');
INSERT INTO groups VALUES (370, 'Institute for Art Education', '15276.dozierende', 'DKV_IAE.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (371, 'Bachelor Theater - Vertiefung Theaterpädagogik - HS 2011', '102764.studierende', 'DDK_FTH_BTH_VTP_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (372, 'Vertiefung Fotografie', '56672.personal', 'DKM_FMK_VFO.personal', 'MetaDepartment');
INSERT INTO groups VALUES (373, 'Vertiefung Theorie - Studien zur Medien-, Kunst- und Designpraxis', '56673.personal', 'DKM_FMK_VTH.personal', 'MetaDepartment');
INSERT INTO groups VALUES (374, 'Leseberechtige Benutzer Evento', '121201.', 'Verteilerliste.Evento_lesen', 'MetaDepartment');
INSERT INTO groups VALUES (375, 'MAS Bilden Künste Gesellschaft', '83919.studierende', 'DKV_MASBKG.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (733, 'Profil Kirchenmusik', '65627.alle', 'DMU_FMU_PKM.alle', 'MetaDepartment');
INSERT INTO groups VALUES (376, 'Institut für Designforschung', '14674.dozierende', 'DDE_IDE.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (616, 'Departement Design', '14667.alle', 'DDE.alle', 'MetaDepartment');
INSERT INTO groups VALUES (377, 'Vertiefung Visuelle Kommunikation', '56668.mittelbau', 'DDE_FDE_VVK.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (378, 'Bachelor Medien & Kunst', '15291.dozierende', 'DKM_FMK_BMK.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (379, 'MAS musikalische Kreation', '15352.studierende', 'DMU_MASMK.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (380, 'MAS Bilden Künste Gesellschaft', '83919.alle', 'DKV_MASBKG.alle', 'MetaDepartment');
INSERT INTO groups VALUES (381, 'Services, Informations-Technologie-Zentrum', '14647.personal', 'SER_SUP_ITZ.personal', 'MetaDepartment');
INSERT INTO groups VALUES (382, 'Services, Produktionszentrum', '15280.personal', 'SER_SUP_PZ.personal', 'MetaDepartment');
INSERT INTO groups VALUES (383, 'Departement Design', '14667.dozierende', 'DDE.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (384, 'Personen, die Leistungen im Evento erfassen', '100761.', 'Verteilerliste.Leistungserfassung_Evento', 'MetaDepartment');
INSERT INTO groups VALUES (385, 'Master Film HS 2010', '90811.studierende', 'DDK_FFI_MFI_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (386, 'Bachelor Musik - Instrument/Gesang - Pop - HS 2009', '77636.studierende', 'DMU_FMU_BMU_VIG_SPOP_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (387, 'CAS Performance Jazz und Pop FS 2013', '121392.studierende', 'DMU_FMU_CASPJA_13F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (388, 'MAS musikalische Kreation', '15352.alle', 'DMU_MASMK.alle', 'MetaDepartment');
INSERT INTO groups VALUES (389, 'Institut für Gegenwartskunst', '66212.personal', 'DKM_IFCAR.personal', 'MetaDepartment');
INSERT INTO groups VALUES (390, 'Services, Produktionszentrum', '15280.alle', 'SER_SUP_PZ.alle', 'MetaDepartment');
INSERT INTO groups VALUES (391, 'Bachelor Musik - Kunst- und Sportgymnasium - Klassik - HS 2010', '90325.studierende', 'DMU_FMU_BMU_VKS_SKLA_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (392, 'Bachelor Vermittlung von Kunst und Design', '4396.studierende', 'DKV_FAE_BAE.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (393, 'Typo3 - RedaktorInnen', '112148.', 'Verteilerliste.Typo3_Redaktion', 'MetaDepartment');
INSERT INTO groups VALUES (394, 'Bachelor Vermittlung von Kunst und Design', '4396.alle', 'DKV_FAE_BAE.alle', 'MetaDepartment');
INSERT INTO groups VALUES (395, 'Vertiefung Bildende Kunst', '56670.dozierende', 'DKM_FMK_VBK.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (396, 'Bachelor Musik', '15295.studierende', 'DMU_FMU_BMU.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (397, 'MAS Cultural Media Studies', '69154.dozierende', 'DKV_MASCMS.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (398, 'Departement Darstellende Künste und Film', '14677.mittelbau', 'DDK.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (399, 'Master Film', '14663.studierende', 'DDK_FFI_MFI.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (400, 'Bachelor Musik', '15295.alle', 'DMU_FMU_BMU.alle', 'MetaDepartment');
INSERT INTO groups VALUES (401, 'NDK / CAS Komposition für Film, Theater und Medien (FTM)', '76942.studierende', 'DMU_FMU_CASFTM.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (402, 'Bachelor Theater - Vertiefung Schauspiel - HS 2011', '102896.studierende', 'DDK_FTH_BTH_VSC_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (403, 'Institute for Art Education', '15276.mittelbau', 'DKV_IAE.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (404, 'Bachelor Theater - Vertiefung Szenografie - HS 2011', '102765.studierende', 'DDK_FTH_BTH_VSZ_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (405, 'Departement Darstellende Künste und Film', '14677.personal', 'DDK.personal', 'MetaDepartment');
INSERT INTO groups VALUES (406, 'Fachrichtung Tanz', '14665.mittelbau', 'DDK_FTA.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (407, 'Master Film', '14663.alle', 'DDK_FFI_MFI.alle', 'MetaDepartment');
INSERT INTO groups VALUES (408, 'Bachelor Musik - Instrument/Gesang - Klassik - HS 2009', '77302.studierende', 'DMU_FMU_BMU_VIG_SKLA_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (409, 'NDK / CAS Komposition für Film, Theater und Medien (FTM)', '76942.alle', 'DMU_FMU_CASFTM.alle', 'MetaDepartment');
INSERT INTO groups VALUES (410, 'Alle Mitglieder des Studierendenrates SturZ', '109149.', 'Verteilerliste.Studierendenrat', 'MetaDepartment');
INSERT INTO groups VALUES (411, 'Master Theater - Vertiefung Schauspiel - HS 2012', '115979.studierende', 'DDK_FTH_MTH_VSC_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (412, 'ITZ Business Applikationen', '120983.', 'Verteilerliste.ITZ_Business_Applikationen', 'MetaDepartment');
INSERT INTO groups VALUES (413, 'MAS Curating', '8406.dozierende', 'DKV_MASCUR.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (414, 'Institute for Art Education', '15276.alle', 'DKV_IAE.alle', 'MetaDepartment');
INSERT INTO groups VALUES (415, 'Bachelor Design - Vertiefung Game Design - HS 2010', '90731.studierende', 'DDE_FDE_BDE_VGD_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (416, 'Bachelor Vermittlung von Kunst und Design -  Ästhetische Bildung und Soziokultur - HS 2010', '90743.studierende', 'DKV_FAE_BAE_VAS_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (417, 'Master Fine Arts HS 2012', '115967.studierende', 'DKM_FMK_MAF_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (418, 'Personalrat', '56693.', 'Verteilerliste.Personalrat', 'MetaDepartment');
INSERT INTO groups VALUES (419, 'Vertiefung Game Design', '56666.dozierende', 'DDE_FDE_VGD.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (420, 'Fachrichtung Theater', '14666.personal', 'DDK_FTH.personal', 'MetaDepartment');
INSERT INTO groups VALUES (421, 'Film_Evaluation: Zugang zu vertraulichen Evaluationsdaten im Bereich Film', '115063.', 'Verteilerliste.Form_Film_Evaluation', 'MetaDepartment');
INSERT INTO groups VALUES (422, 'Institut für Gegenwartskunst', '66212.dozierende', 'DKM_IFCAR.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (423, 'Master Theater', '64570.personal', 'DDK_FTH_MTH.personal', 'MetaDepartment');
INSERT INTO groups VALUES (424, 'CAS Performance Klassik FS 2012', '108574.studierende', 'DMU_FMU_CASKLA_12F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (425, 'MAS Curating', '8406.mittelbau', 'DKV_MASCUR.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (426, 'Film_Leitung (nur Fachrichtungsleitung)', '70173.', 'Verteilerliste.Film_Leitung', 'MetaDepartment');
INSERT INTO groups VALUES (427, 'Master Theater - Vertiefung Leitende Künstlerin / Leitender Künstler - Profil Dramaturgie - HS 2011', '103896.studierende', 'DDK_FTH_MTH_VLK_PDR_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (428, 'CAS Performance Klassik HS 2012', '113699.studierende', 'DMU_FMU_CASKLA_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (429, 'Institut für Gegenwartskunst', '66212.alle', 'DKM_IFCAR.alle', 'MetaDepartment');
INSERT INTO groups VALUES (430, 'Bachelor Design - Vertiefung Scientific Visualization - HS 2010', '90735.studierende', 'DDE_FDE_BDE_VSV_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (431, 'Bachelor Musik - Komposition und Musiktheorie - Komposition - HS 2010', '103124.studierende', 'DMU_FMU_BMU_VKOT_SKO_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (432, 'Bachelor Medien & Kunst - Vertiefung Fotografie - HS 2010', '90739.studierende', 'DKM_FMK_BMK_VFO_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (433, 'Institute for Computer Music and Sound Technology', '15278.dozierende', 'DMU_ICST.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (434, 'Master Specialized Music Performance - Oper - HS 2011', '102542.studierende', 'DMU_FMU_MSP_VOP_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (435, 'studierende.berechtigung', '12778.studierende', 'studierende.berechtigung.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (436, 'DMU elektronische Einschreibung - Liste der involvierten Mitarbeitenden', '69582.', 'Verteilerliste.DMU_Einschreibungen', 'MetaDepartment');
INSERT INTO groups VALUES (437, 'Vertiefung Industrial Design', '56663.alle', 'DDE_FDE_VID.alle', 'MetaDepartment');
INSERT INTO groups VALUES (438, 'Museum', '14660.mittelbau', 'DKV_Museum.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (439, 'dozierende.berechtigung', '12777.dozierende', 'dozierende.berechtigung.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (440, 'Master Design - Vertiefung Ereignis - FS 2013', '124378.studierende', 'DDE_FDE_MDE_VER_13F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (441, 'MAS erweiterte Musikpraxis', '15351.studierende', 'DMU_MASEMP.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (442, 'Personen, die den Veranstaltungskalender der ZHdK bedienen', '75905.', 'Verteilerliste.Events_Admin', 'MetaDepartment');
INSERT INTO groups VALUES (443, 'Vertiefung Industrial Design', '3037.studierende', 'DDE_FDE_BDE_VID.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (444, 'Personen, die erweiterten Zugang in der Personensuche benötigen ', '102553.', 'Verteilerliste.App_Personensuche_Adressen', 'MetaDepartment');
INSERT INTO groups VALUES (445, 'Bachelor Musik - Kunst- und Sportgymnasium - Jazz - HS 2012', '114543.studierende', 'DMU_FMU_BMU_VKS_SJAZ_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (446, 'Propädeutikum - Gestalterische Orientierungsstufe Vollzeit FS 2013', '120102.studierende', 'DKV_XPP_XGO_V_13F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (447, 'Museum Au60', '64181.mittelbau', 'DKV_Museum_Au60.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (448, 'Master Design - Vertiefung Kommunikation - FS 2013', '124381.studierende', 'DDE_FDE_MDE_VKK_13F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (449, 'MAS erweiterte Musikpraxis', '15351.alle', 'DMU_MASEMP.alle', 'MetaDepartment');
INSERT INTO groups VALUES (450, 'Bachelor Vermittlung von Kunst und Design', '4396.dozierende', 'DKV_FAE_BAE.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (451, 'mittelbau.berechtigung', '12782.mittelbau', 'mittelbau.berechtigung.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (452, 'Vertiefung Industrial Design', '3037.alle', 'DDE_FDE_BDE_VID.alle', 'MetaDepartment');
INSERT INTO groups VALUES (453, 'Master Design - Vertiefung Produkt - FS 2013', '124382.studierende', 'DDE_FDE_MDE_VPR_13F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (454, 'Fachbereich Museum Bellerive', '64179.mittelbau', 'DKV_Museum_Bellerive.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (455, 'Bachelor Design - Vertiefung Style & Design - HS 2009', '78176.studierende', 'DDE_FDE_BDE_VSD_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (456, 'Master Specialized Music Performance - Kammermusik - Klavierkammermusik/Lied - HS 2011', '102541.studierende', 'DMU_FMU_MSP_VKAM_SKL_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (457, 'Master Design - Vertiefung Interaktion - FS 2013', '124380.studierende', 'DDE_FDE_MDE_VIA_13F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (458, 'Personal.berechtigung', '12781.personal', 'Personal.berechtigung.personal', 'MetaDepartment');
INSERT INTO groups VALUES (459, 'Vertiefung Industrial Design', '56663.studierende', 'DDE_FDE_VID.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (460, 'Master Design - Vertiefung Trends - FS 2013', '124383.studierende', 'DDE_FDE_MDE_VTR_13F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (461, 'Sammlungen', '15427.mittelbau', 'DKV_Sammlungen.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (462, 'NDK / CAS Composing-Arranging', '15408.studierende', 'DMU_FMU_CASCA.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (463, 'Bachelor Medien & Kunst - Vertiefung Bildende Kunst - HS 2010', '90738.studierende', 'DKM_FMK_BMK_VBK_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (464, 'Master Music Performance - Kirchenmusik - Chorleitung geistlich - HS 2011', '102536.studierende', 'DMU_FMU_MPE_VKM_SCH_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (465, 'PHD', '115092.studierende', 'DKM_PHD_12F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (466, 'Bachelor Medien & Kunst - Vertiefung Bildende Kunst - HS 2012', '115224.studierende', 'DKM_FMK_BMK_VBK_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (467, 'Bachelor Design - Vertiefung Game Design - HS 2012', '115221.studierende', 'DDE_FDE_BDE_VGD_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (468, 'Master Theater - Vertiefung Leitende Künstlerin / Leitender Künstler - Profil Dramaturgie - HS 2012', '120366.studierende', 'DDK_FTH_MTH_VLK_PDR_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (469, 'Vertiefung Style&Design', '56675.dozierende', 'DDE_FDE_VSD.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (470, 'Fachrichtung Theater', '14666.mittelbau', 'DDK_FTH.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (471, 'Master Music Performance - Kirchenmusik - Orgel - HS 2011', '102537.studierende', 'DMU_FMU_MPE_VKM_SOG_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (472, 'Bachelor Medien & Kunst - Vertiefung Mediale Künste - HS 2012', '115226.studierende', 'DKM_FMK_BMK_VMK_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (473, 'NDK / CAS Composing-Arranging', '15408.alle', 'DMU_FMU_CASCA.alle', 'MetaDepartment');
INSERT INTO groups VALUES (474, 'Fachrichtung Art Education', '3048.alle', 'DKV_FAE.alle', 'MetaDepartment');
INSERT INTO groups VALUES (475, 'Bachelor Medien & Kunst - Vertiefung Theorie - HS 2012', '115227.studierende', 'DKM_FMK_BMK_VTH_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (476, 'Bachelor Theater', '15302.mittelbau', 'DDK_FTH_BTH.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (477, 'Bachelor Vermittlung von Kunst und Design - Bildnerisches Gestalten an Maturitätsschulen - HS 2012', '115229.studierende', 'DKV_FAE_BAE_VBG_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (478, 'Vertiefung Bildende Kunst', '3035.studierende', 'DKM_FMK_BMK_VBK.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (479, 'Fachrichtung Art Education', '3048.studierende', 'DKV_FAE.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (480, 'Bachelor Design - Vertiefung Cast / Audiovisuelle Medien - HS 2011', '102478.studierende', 'DDE_FDE_BDE_VCA_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (481, 'Master Art Education - Vertiefung ausstellen & vermitteln - HS 2012', '115452.studierende', 'DKV_FAE_MAE_VAV_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (482, 'Mitglieder der Z-Modul-Konferenz und Personen, die Zugang zu den Daten der Z-Modul-Anmeldung benötigen.', '75924.', 'Verteilerliste.DKV_Zmodulkonferenz', 'MetaDepartment');
INSERT INTO groups VALUES (483, 'Bachelor Theater - Vertiefung Dramaturgie', '15347.mittelbau', 'DDK_FTH_BTH_VDR.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (484, 'Master Art Education - Vertiefung bilden & vermitteln - HS 2012', '115451.studierende', 'DKV_FAE_MAE_VBV_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (485, 'Vertiefung Bildende Kunst', '3035.alle', 'DKM_FMK_BMK_VBK.alle', 'MetaDepartment');
INSERT INTO groups VALUES (486, 'Master Art Education - Vertiefung ausstellen & vermitteln - HS 2009', '78225.studierende', 'DKV_FAE_MAE_VAV_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (487, 'Master Art Education - Vertiefung publizieren & vermitteln - HS 2012', '115450.studierende', 'DKV_FAE_MAE_VPV_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (488, 'CAS Computermusik HS 2012', '113719.studierende', 'DMU_FMU_CASCOM_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (489, 'Vertiefung Visuelle Kommunikation', '56668.dozierende', 'DDE_FDE_VVK.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (490, 'Master Composition and Theory - Tonmeister - HS 2012', '114525.studierende', 'DMU_FMU_MKT_VTO_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (491, 'CAS Chorleitung HS 2012 ', '113705.studierende', 'DMU_FMU_CASCHL_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (492, 'Vertiefung Bildende Kunst', '56670.studierende', 'DKM_FMK_VBK.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (493, 'Master in Art Education', '68798.studierende', 'DKV_FAE_MAE.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (494, 'CAS Kirchenmusik Jazz und Pop advanced HS 2012', '113710.studierende', 'DMU_FMU_CASKMJ_12h.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (495, 'Bachelor Tanz', '82832.alle', 'DDK_FTA_BTA.alle', 'MetaDepartment');
INSERT INTO groups VALUES (496, 'Vertiefung Fotografie', '56672.alle', 'DKM_FMK_VFO.alle', 'MetaDepartment');
INSERT INTO groups VALUES (497, 'CAS Kirchenmusikalische Praxis HS 2012', '113707.studierende', 'DMU_FMU_CASKMP_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (498, 'Vertiefung Bildende Kunst', '56670.alle', 'DKM_FMK_VBK.alle', 'MetaDepartment');
INSERT INTO groups VALUES (499, 'Master in Art Education', '68798.alle', 'DKV_FAE_MAE.alle', 'MetaDepartment');
INSERT INTO groups VALUES (500, 'Propädeutikum - Gestalterische Orientierungsstufe Teilzeit HS 2011', '101967.studierende', 'DKV_XPP_XGO_T_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (501, 'CAS Komposition/Musiktheorie HS 2012', '113717.studierende', 'DMU_FMU_CASKO_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (502, 'Vertiefung Fotografie', '3032.studierende', 'DKM_FMK_BMK_VFO.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (503, 'CAS Musikphysiologie basic HS 2012', '113723.studierende', 'DMU_FMU_CASMPB_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (504, 'MAS Theaterpädagogik', '15356.studierende', 'DDK_FTH_MASTP.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (505, 'Departement Kulturanalysen und Vermittlung', '14676.dozierende', 'DKV.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (506, 'Bachelor Film HS 2011', '103498.studierende', 'DDK_FFI_BFI_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (507, 'CAS Performance Jazz und Pop FS 2012', '108576.studierende', 'DMU_FMU_CASPJA_12F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (508, 'Fachrichtung Film', '3033.mittelbau', 'DDK_FFI.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (509, 'Vertiefung Fotografie', '3032.alle', 'DKM_FMK_BMK_VFO.alle', 'MetaDepartment');
INSERT INTO groups VALUES (510, 'Bachelor Musik - Komposition und Musiktheorie - Komposition für Film, Theater und Medien - HS 2011', '102569.studierende', 'DMU_FMU_BMU_VKOT_SFTM_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (511, 'CAS Tontechnik HS 2012', '113718.studierende', 'DMU_FMU_CASTON_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (512, 'Film_Profilleitung', '121016.', 'Verteilerliste.Film_Profilleitung', 'MetaDepartment');
INSERT INTO groups VALUES (513, 'MAS Theaterpädagogik', '15356.alle', 'DDK_FTH_MASTP.alle', 'MetaDepartment');
INSERT INTO groups VALUES (514, 'Bachelor Musik - Instrument/Gesang - Klassik - HS 2010', '90313.studierende', 'DMU_FMU_BMU_VIG_SKLA_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (515, 'Fachrichtung Art Education', '3048.dozierende', 'DKV_FAE.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (516, 'DASKirchenmusik Chorleitung HS 2011', '106862.studierende', 'DMU_FMU_DASKMC_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (517, 'Rektorat', '14673.personal', 'REK.personal', 'MetaDepartment');
INSERT INTO groups VALUES (518, 'Vertiefung Fotografie', '56672.studierende', 'DKM_FMK_VFO.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (519, 'Bachelor Musik - Tonmeister - Jazz - HS 2011', '102576.studierende', 'DMU_FMU_BMU_VTO_SJAZ_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (520, 'DAS Kirchenmusik Orgel HS 2011', '106456.studierende', 'DMU_FMU_DASKMO_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (521, 'Master in Art Education', '68798.dozierende', 'DKV_FAE_MAE.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (522, 'Bachelor Musik - Tonmeister - Klassik - HS 2011', '102578.studierende', 'DMU_FMU_BMU_VTO_SKLA_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (523, 'DAS Kirchenmusik Orgel HS 2012', '113716.studierende', 'DMU_FMU_DASKMO_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (524, 'Rektorat', '14673.alle', 'REK.alle', 'MetaDepartment');
INSERT INTO groups VALUES (525, 'Master Composition and Theory - Komposition - Elektroakustische Komposition - HS 2011', '102496.studierende', 'DMU_FMU_MKT_VKO_SEAK_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (526, 'MAS in klinischer Musiktherapie HS 2008', '65235.studierende', 'DMU_FMU_MASMTH_08H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (527, 'Bachelor Musik - Komposition und Musiktheorie - Komposition für Film, Theater und Medien - HS 2010', '90323.studierende', 'DMU_FMU_BMU_VKOT_SFTM_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (528, 'Master Music Performance - instrumentale/vokale Performance - Orchester - HS 2009', '76768.studierende', 'DMU_FMU_MPE_VIV_SOR_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (529, 'Master Composition and Theory - Komposition - Komposition für Film, Theater und Medien - HS 2011', '102500.studierende', 'DMU_FMU_MKT_VKO_SFTM_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (530, 'Propädeutikum - Gestalterische Orientierungsstufe Vollzeit FS 2012', '107587.studierende', 'DKV_XPP_XGO_V_12F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (531, 'Master Composition and Theory - Tonmeister - HS 2011', '102501.studierende', 'DMU_FMU_MKT_VTO_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (532, 'Master Theater - Vertiefung Leitende Künstlerin / Leitender Künstler - Profil Bühnenbild - HS 2011', '102899.studierende', 'DDK_FTH_MTH_VLK_PBN_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (533, 'Master Music Performance - instrumentale/vokale Performance - Konzert - HS 2009', '76767.studierende', 'DMU_FMU_MPE_VIV_SKT_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (534, 'Departement Kulturanalysen und Vermittlung', '14676.studierende', 'DKV.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (535, 'Master Composition and Theory - Komposition - Komposition - HS 2011', '102502.studierende', 'DMU_FMU_MKT_VKO_SKO4_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (536, 'Master Theater - Vertiefung Leitende Künstlerin / Leitender Künstler - Profil Regie - HS 2011', '102901.studierende', 'DDK_FTH_MTH_VLK_PRE_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (537, 'Master Composition and Theory - Theorie - HS 2011', '102505.studierende', 'DMU_FMU_MKT_VTH_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (538, 'Master Theater - Vertiefung Schauspiel - HS 2011', '103792.studierende', 'DDK_FTH_MTH_VSC_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (539, 'Departement Musik', '15284.studierende', 'DMU.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (540, 'Departement Kulturanalysen und Vermittlung', '14676.alle', 'DKV.alle', 'MetaDepartment');
INSERT INTO groups VALUES (541, 'Master Specialized Music Performance - Dirigieren - Orchesterleitung - HS 2010', '90305.studierende', 'DMU_FMU_MSP_VDI_SOL_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (542, 'Master Theater - Vertiefung Leitende Künstlerin / Leitender Künstler - Profil Theaterpädagogik - HS 2011', '103791.studierende', 'DDK_FTH_MTH_VLK_PTP_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (543, 'MAS Bilden Künste Gesellschaft HS 2012', '120267.studierende', 'DKV_MASBKG_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (544, 'Master Musikpädagogik', '64306.studierende', 'DMU_FMU_MMP.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (545, 'MAS Design Culture', '4187.dozierende', 'DDE_FDE_MASDEC.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (546, 'Master Music Pedagogy - Schulmusik - Schulmusik II - HS 2010', '90274.studierende', 'DMU_FMU_MMP_VSMU_SSII_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (547, 'Bachelor Design - Vertiefung Interaction Design - HS 2012', '115220.studierende', 'DDE_FDE_BDE_VIAD_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (548, 'MAS Cultural Media Studies', '69154.studierende', 'DKV_MASCMS.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (549, 'Master Musikpädagogik', '64306.alle', 'DMU_FMU_MMP.alle', 'MetaDepartment');
INSERT INTO groups VALUES (550, 'Propädeutikum - Gestalterische Orientierungsstufe', '3043.studierende', 'DKV_XPP_XGO.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (551, 'Bachelor Design - Vertiefung Visuelle Kommunikation - HS 2012', '115215.studierende', 'DDE_FDE_BDE_VVK_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (552, 'MAS Szenografie', '3652.alle', 'DDE_FDE_MASSZ.alle', 'MetaDepartment');
INSERT INTO groups VALUES (553, 'Fachrichtung Musik', '14664.studierende', 'DMU_FMU.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (554, 'Bachelor Design - Vertiefung Style & Design - HS 2012', '115217.studierende', 'DDE_FDE_BDE_VSD_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (555, 'MAS Cultural Media Studies', '69154.alle', 'DKV_MASCMS.alle', 'MetaDepartment');
INSERT INTO groups VALUES (556, 'Fachrichtung Art Education', '3048.mittelbau', 'DKV_FAE.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (557, 'Propädeutikum - Gestalterische Orientierungsstufe', '3043.alle', 'DKV_XPP_XGO.alle', 'MetaDepartment');
INSERT INTO groups VALUES (558, 'Bachelor Design - Vertiefung Industrial Design - HS 2012', '115219.studierende', 'DDE_FDE_BDE_VID_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (559, 'MAS Design Culture', '4187.mittelbau', 'DDE_FDE_MASDEC.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (560, 'MAS Szenografie', '3652.mittelbau', 'DDE_FDE_MASSZ.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (561, 'Bachelor Medien & Kunst - Vertiefung Mediale Künste - HS 2010', '90740.studierende', 'DKM_FMK_BMK_VMK_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (562, 'Master Specialized Music Performance', '64308.studierende', 'DMU_FMU_MSP.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (563, 'Master Art Education - Vertiefung bilden & vermitteln - HS 2011', '103810.studierende', 'DKV_FAE_MAE_VBV_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (564, 'Bachelor Design - Vertiefung Scientific Visualization - HS 2012', '115216.studierende', 'DDE_FDE_BDE_VSV_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (565, 'Bachelor Vermittlung von Kunst und Design', '4396.mittelbau', 'DKV_FAE_BAE.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (566, 'Personen, die Zugriff auf die Daten der Jahresbericht-Formular im Intranet benötigen', '96630.', 'Verteilerliste.Form_Jahresbericht', 'MetaDepartment');
INSERT INTO groups VALUES (567, 'Master Art Education - Vertiefung publizieren & vermitteln - HS 2011', '103830.studierende', 'DKV_FAE_MAE_VPV_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (568, 'Musik Austausch HS 2012', '114790.studierende', 'DMU_FMU_Austausch_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (569, 'Master of Arts in Transdisziplinarität HS 2012', '119730.studierende', 'DKV_FTR_MTR_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (570, 'Vertiefung Cast / Audiovisuelle Medien', '56662.mittelbau', 'DDE_FDE_VCA.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (571, 'Master Specialized Music Performance', '64308.alle', 'DMU_FMU_MSP.alle', 'MetaDepartment');
INSERT INTO groups VALUES (572, 'Vertiefung Interaction Design', '56664.alle', 'DDE_FDE_VIAD.alle', 'MetaDepartment');
INSERT INTO groups VALUES (573, 'Bachelor Musik - Kirchenmusik - Orgel und Chorleitung geistlich - HS 2010', '115658.studierende', 'DMU_FMU_BMU_VKM_SOCH_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (574, 'Master Specialized Music Performance - Dirigieren - Orchesterleitung - HS 2008', '65295.studierende', 'DMU_FMU_MSP_VDI_SOL_08H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (575, 'Fachrichtung Design', '15281.mittelbau', 'DDE_FDE.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (576, 'Forschung und Entwicklung', '14644.alle', 'F_E.alle', 'MetaDepartment');
INSERT INTO groups VALUES (577, 'Master Music Performance - Dirigieren - Orchesterleitung - HS 2012', '114478.studierende', 'DMU_FMU_MPE_VDI_SOL_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (578, 'Bachelor Theater - Vertiefung Szenografie', '15346.dozierende', 'DDK_FTH_BTH_VSZ.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (579, 'Vertiefung Interaction Design', '56664.studierende', 'DDE_FDE_VIAD.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (580, 'Master Music Performance - Kirchenmusik - Chorleitung geistlich - HS 2012', '114482.studierende', 'DMU_FMU_MPE_VKM_SCH_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (581, 'Vertiefung Scientific Visualization', '56669.mittelbau', 'DDE_FDE_VSV.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (582, 'Forschung und Entwicklung', '14644.mittelbau', 'F_E.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (583, 'Master Music Performance - Kirchenmusik - Orgel - HS 2012', '114486.studierende', 'DMU_FMU_MPE_VKM_SOG_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (584, 'Master Specialized Music Performance - Dirigieren - Chorleitung - HS 2012', '114511.studierende', 'DMU_FMU_MSP_VDI_SCH_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (585, 'Bachelor Theater - Vertiefung Szenografie', '15346.mittelbau', 'DDK_FTH_BTH_VSZ.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (586, 'Mitarbeiter IAE', '71074.', 'Verteilerliste.Mitarbeiter_IAE', 'MetaDepartment');
INSERT INTO groups VALUES (587, 'Vertiefung Mediale Künste', '56671.alle', 'DKM_FMK_VMK.alle', 'MetaDepartment');
INSERT INTO groups VALUES (588, 'Master Specialized Music Performance - Dirigieren - Orchesterleitung - HS 2012', '114513.studierende', 'DMU_FMU_MSP_VDI_SOL_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (589, 'Fachrichtung Design', '15281.dozierende', 'DDE_FDE.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (590, 'Vertiefung Interaction Design', '15304.studierende', 'DDE_FDE_BDE_VIAD.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (591, 'Master Specialized Music Performance - Oper - HS 2012', '114517.studierende', 'DMU_FMU_MSP_VOP_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (592, 'Bachelor Theater - Vertiefung Szenografie', '15346.personal', 'DDK_FTH_BTH_VSZ.personal', 'MetaDepartment');
INSERT INTO groups VALUES (593, 'Master Specialized Music Performance - Kammermusik - Klavierkammermusik/Lied - HS 2009', '76887.studierende', 'DMU_FMU_MSP_VKAM_SKL_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (594, 'Fachrichtung Film', '3033.personal', 'DDK_FFI.personal', 'MetaDepartment');
INSERT INTO groups VALUES (595, 'Vertiefung Interaction Design', '56664.dozierende', 'DDE_FDE_VIAD.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (596, 'Vertiefung Interaction Design', '15304.alle', 'DDE_FDE_BDE_VIAD.alle', 'MetaDepartment');
INSERT INTO groups VALUES (597, 'Profil Jazz und Pop', '65629.dozierende', 'DMU_FMU_PJAPO.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (598, 'Vertiefung Mediale Künste', '3034.studierende', 'DKM_FMK_BMK_VMK.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (599, 'Master Theater - Vertiefung Theaterpädagogik - HS 2010', '91584.studierende', 'DDK_FTH_MTH_VTP_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (600, 'Beirat', '102876.', 'Verteilerliste.Beirat', 'MetaDepartment');
INSERT INTO groups VALUES (601, 'MAS in klinischer Musiktherapie Upgrade A FS 2008', '63237.studierende', 'DMU_FMU_MASMTH_UP_A_08F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (602, 'Bühnentanz EFZ HS 2012', '115982.studierende', 'DDK_FTA_XBT_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (603, 'Profil Jazz und Pop', '65629.alle', 'DMU_FMU_PJAPO.alle', 'MetaDepartment');
INSERT INTO groups VALUES (604, 'Vertiefung Mediale Künste', '3034.alle', 'DKM_FMK_BMK_VMK.alle', 'MetaDepartment');
INSERT INTO groups VALUES (605, 'ProfilTheaterpädagogik', '64575.studierende', 'DDK_FTH_MTH_VLK_PTP.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (606, 'Tanz Hauptstudium', '65485.studierende', 'DDK_FTA_GBT_all.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (607, 'Diplomstudium (DaP) Bühnentanz', '15348.studierende', 'DDK_FTA_GBT.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (608, 'Vertiefung Mediale Künste', '56671.studierende', 'DKM_FMK_VMK.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (609, 'ProfilTheaterpädagogik', '64575.alle', 'DDK_FTH_MTH_VLK_PTP.alle', 'MetaDepartment');
INSERT INTO groups VALUES (610, 'MIZ Teamsitzung', '102587.', 'Verteilerliste.SER_SUP_MIZ_Teamsitzung', 'MetaDepartment');
INSERT INTO groups VALUES (611, 'Departement Design', '14667.mittelbau', 'DDE.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (612, 'Bachelor Medien & Kunst - Vertiefung Fotografie - HS 2009', '78182.studierende', 'DKM_FMK_BMK_VFO_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (613, 'Master Music Performance - instrumentale/vokale Performance - Konzert - FS 2012', '108220.studierende', 'DMU_FMU_MPE_VIV_SKT_12F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (614, 'MIZ Katalogisierung/Reklassifizierung', '121234.', 'Verteilerliste.SER_SUP_MIZ_Katalogisierung_Reklassifizierung', 'MetaDepartment');
INSERT INTO groups VALUES (615, 'Institut für Designforschung', '14674.mittelbau', 'DDE_IDE.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (617, 'Film_Dozierende_festang', '56722.', 'Verteilerliste.Film_Dozierende_festang', 'MetaDepartment');
INSERT INTO groups VALUES (618, 'Personen, die Adm-Zugang zur Applikation Raumbelegungsanzeige haben', '85152.', 'Verteilerliste.App_Raumbelegungsanzeige', 'MetaDepartment');
INSERT INTO groups VALUES (619, 'Institut für Designforschung', '14674.alle', 'DDE_IDE.alle', 'MetaDepartment');
INSERT INTO groups VALUES (620, 'Bachelor Musik - Instrument/Gesang - Jazz - HS 2009', '77472.studierende', 'DMU_FMU_BMU_VIG_SJAZ_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (621, 'Fachrichtung Design', '15281.alle', 'DDE_FDE.alle', 'MetaDepartment');
INSERT INTO groups VALUES (622, 'Vertiefung Industrial Design', '56663.dozierende', 'DDE_FDE_VID.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (623, 'Mittelbaurat', '56694.', 'Verteilerliste.Mittelbaurat', 'MetaDepartment');
INSERT INTO groups VALUES (624, 'MAS Musikvermittlung und Konzertpädagogik', '74923.studierende', 'DMU_MASMV.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (625, 'Master Specialized Music Performance - Solist/in - FS 2010', '84472.studierende', 'DMU_FMU_MSP_VSO_10F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (626, 'Vertiefung Visuelle Kommunikation', '56668.alle', 'DDE_FDE_VVK.alle', 'MetaDepartment');
INSERT INTO groups VALUES (627, 'Vertiefung Industrial Design', '56663.mittelbau', 'DDE_FDE_VID.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (628, 'Services, Abteilung Facility Management', '15425.alle', 'SER_SUP_FM.alle', 'MetaDepartment');
INSERT INTO groups VALUES (629, 'Propädeutikum - Gestalterische Orientierungsstufe', '3043.personal', 'DKV_XPP_XGO.personal', 'MetaDepartment');
INSERT INTO groups VALUES (630, 'Film_Leitung_Personal', '14592.', 'Verteilerliste.Film_Leitung_Personal', 'MetaDepartment');
INSERT INTO groups VALUES (631, 'MAS Musikvermittlung und Konzertpädagogik', '74923.alle', 'DMU_MASMV.alle', 'MetaDepartment');
INSERT INTO groups VALUES (632, 'Master Music Pedagogy - instrumentale/vokale Musikpädagogik - Klassik - HS 2010', '90270.studierende', 'DMU_FMU_MMP_VIV_SKLA_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (633, 'Departement Design', '14667.studierende', 'DDE.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (634, 'Personen, die in die Verwaltung der Studiosessions im Dept. Musik involviert sind.', '75913.', 'Verteilerliste.DMU_Studiosession_Admin', 'MetaDepartment');
INSERT INTO groups VALUES (635, 'Services, Abteilung Facility Management', '15425.personal', 'SER_SUP_FM.personal', 'MetaDepartment');
INSERT INTO groups VALUES (636, 'Vertiefung Style&Design', '56675.mittelbau', 'DDE_FDE_VSD.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (637, 'Fachrichtung Transdisziplinarität', '68796.personal', 'DKV_FTR.personal', 'MetaDepartment');
INSERT INTO groups VALUES (638, 'Fachrichtung Design', '15281.studierende', 'DDE_FDE.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (639, 'MAS Theaterpädagogik HS 2010', '95762.studierende', 'DDK_FTH_MASTP_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (640, 'Master in Transdisziplinarität', '68797.personal', 'DKV_FTR_MTR.personal', 'MetaDepartment');
INSERT INTO groups VALUES (641, 'Master Music Performance - instrumentale/vokale Performance - Konzert - HS 2012', '114479.studierende', 'DMU_FMU_MPE_VIV_SKT_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (642, 'MAS in klinischer Musiktherapie Upgrade B FS 2008', '63239.studierende', 'DMU_FMU_MASMTH_UP_B_08F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (643, 'Z-Module', '68794.personal', 'DKV_FTR_ZMO.personal', 'MetaDepartment');
INSERT INTO groups VALUES (644, 'Bachelor Theater - Vertiefung Schauspiel - HS 2010', '90809.studierende', 'DDK_FTH_BTH_VSC_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (645, 'Master Design', '74626.studierende', 'DDE_FDE_MDE.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (646, 'Bachelor Design', '15289.studierende', 'DDE_FDE_BDE.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (647, 'Master Music Performance - instrumentale/vokale Performance - Oper - HS 2012', '114480.studierende', 'DMU_FMU_MPE_VIV_SOP_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (648, 'Bachelor Musik - Instrument/Gesang - Jazz - HS 2011', '102564.studierende', 'DMU_FMU_BMU_VIG_SJAZ_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (649, 'Master Music Performance - instrumentale/vokale Performance - Orchester - HS 2012', '114481.studierende', 'DMU_FMU_MPE_VIV_SOR_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (650, 'Master Design', '74626.alle', 'DDE_FDE_MDE.alle', 'MetaDepartment');
INSERT INTO groups VALUES (651, 'Bachelor Design', '15289.alle', 'DDE_FDE_BDE.alle', 'MetaDepartment');
INSERT INTO groups VALUES (652, 'Bachelor Musik - Instrument/Gesang - Klassik - HS 2011', '102565.studierende', 'DMU_FMU_BMU_VIG_SKLA_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (653, 'Master Specialized Music Performance - Kammermusik - Klavierkammermusik/Lied - HS 2012', '114516.studierende', 'DMU_FMU_MSP_VKAM_SKL_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (654, 'Bachelor Musik - Instrument/Gesang - Pop - HS 2011', '102566.studierende', 'DMU_FMU_BMU_VIG_SPOP_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (655, 'Master Specialized Music Performance - Solist/in - HS 2012', '114518.studierende', 'DMU_FMU_MSP_VSO_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (656, 'Bachelor Theater - Vertiefung Szenografie - HS 2012', '115173.studierende', 'DDK_FTH_BTH_VSZ_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (657, 'Vertiefung Visuelle Kommunikation', '3041.studierende', 'DDE_FDE_BDE_VVK.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (658, 'Bachelor Musik - Kunst- und Sportgymnasium - Klassik - HS 2011', '102571.studierende', 'DMU_FMU_BMU_VKS_SKLA_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (659, 'MAS Spatial Design', '107592.dozierende', 'DDE_FDE_MASSD.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (660, 'Master Theater - Vertiefung Leitende Künstlerin / Leitender Künstler - Profil Bühnenbild - HS 2012', '116028.studierende', 'DDK_FTH_MTH_VLK_PBN_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (661, 'Bachelor Musik - Schulmusik - Klassik - HS 2011', '102574.studierende', 'DMU_FMU_BMU_VSMU_SKLA_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (662, 'MAS Spatial Design', '107592.mittelbau', 'DDE_FDE_MASSD.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (663, 'Master Theater - Vertiefung Leitende Künstlerin / Leitender Künstler - Profil Regie - HS 2012', '116036.studierende', 'DDK_FTH_MTH_VLK_PRE_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (664, 'Vertiefung Visuelle Kommunikation', '3041.alle', 'DDE_FDE_BDE_VVK.alle', 'MetaDepartment');
INSERT INTO groups VALUES (665, 'Bachelor Musik - Schulmusik - Pop - HS 2011', '102575.studierende', 'DMU_FMU_BMU_VSMU_SPOP_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (666, 'Profil Regie', '64571.dozierende', 'DDK_FTH_MTH_VLK_PRE.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (667, 'Master Theater - Vertiefung Leitende Künstlerin / Leitender Künstler - Profil Theaterpädagogik - HS 2012', '116029.studierende', 'DDK_FTH_MTH_VLK_PTP_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (668, 'Bachelor Musik - Schulmusik - Jazz - HS 2010', '90429.studierende', 'DMU_FMU_BMU_VSMU_SJAZ_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (669, 'Master Music Pedagogy - instrumentale/vokale Musikpädagogik - Jazz - HS 2011', '102508.studierende', 'DMU_FMU_MMP_VIV_SJAZ_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (670, 'Institut für Theorie', '57158.personal', 'DKV_ITH.personal', 'MetaDepartment');
INSERT INTO groups VALUES (671, 'Tanz Vorstufe', '90886.studierende', 'DDK_FTA_XVO_all.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (672, 'Vertiefung Visuelle Kommunikation', '56668.studierende', 'DDE_FDE_VVK.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (673, 'Master Music Pedagogy - instrumentale/vokale Musikpädagogik - Klassik - HS 2011', '102509.studierende', 'DMU_FMU_MMP_VIV_SKLA_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (674, 'CAS Composing-Arranging / Musikproduktion HS 2012', '113720.studierende', 'DMU_FMU_CASCA_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (675, 'Departement Musik', '15284.dozierende', 'DMU.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (676, 'Master Music Pedagogy - instrumentale/vokale Musikpädagogik - Klassik - HS 2011', '102510.studierende', 'DMU_FMU_MMP_VIV_SKLA_O_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (677, 'CAS Komposition für Film, Theater und Medien (FTM) HS 2012', '113721.studierende', 'DMU_FMU_CASFTM_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (678, 'Bühnentanz EFZ HS 2009', '77717.studierende', 'DDK_FTA_XBT_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (679, 'Master Music Pedagogy - Musik und Bewegung - Elementare Musikerziehung - HS 2011', '102512.studierende', 'DMU_FMU_MMP_VMB_SEM_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (680, 'CAS Performance Jazz und Pop HS 2012', '113700.studierende', 'DMU_FMU_CASPJA_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (681, 'Departement Musik', '15284.alle', 'DMU.alle', 'MetaDepartment');
INSERT INTO groups VALUES (682, 'Master Music Pedagogy - Musik und Bewegung - Rhythmik - HS 2011', '102514.studierende', 'DMU_FMU_MMP_VMB_SRH_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (683, 'Bachelor Design - Vertiefung Game Design - HS 2011', '102601.studierende', 'DDE_FDE_BDE_VGD_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (684, 'Bachelor Theater - Vertiefung Schauspiel - HS 2012', '115172.studierende', 'DDK_FTH_BTH_VSC_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (685, 'Master Music Pedagogy - Schulmusik - Schulmusik I - HS 2011', '102517.studierende', 'DMU_FMU_MMP_VSMU_SSI_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (686, 'Bachelor Design - Vertiefung Interaction Design - HS 2011', '102602.studierende', 'DDE_FDE_BDE_VIAD_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (687, 'Vertiefung Scientific Visualization', '56669.dozierende', 'DDE_FDE_VSV.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (688, 'MAS Musikphysiologie', '15353.studierende', 'DMU_MASMPH.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (689, 'Hauptfachdozierende Departement Musik ', '84024.', 'Verteilerliste.DMU_HF_Dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (690, 'Personen, die Zugang zu allen Pensenblättern benötigen.', '75927.', 'Verteilerliste.App_Pensenblatt_Admin', 'MetaDepartment');
INSERT INTO groups VALUES (691, 'Bachelor Musik - Tonmeister - Pop - HS 2010', '90327.studierende', 'DMU_FMU_BMU_VTO_SPOP_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (692, 'Fachrichtung Musik', '14664.dozierende', 'DMU_FMU.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (693, 'Master Music Pedagogy - Schulmusik - Schulmusik II - HS 2011', '102507.studierende', 'DMU_FMU_MMP_VSMU_SSII_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (694, 'Bachelor Design - Vertiefung Industrial Design - HS 2011', '102603.studierende', 'DDE_FDE_BDE_VID_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (695, 'Bachelor Design - Vertiefung Style & Design - HS 2011', '102604.studierende', 'DDE_FDE_BDE_VSD_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (696, 'MAS Theaterpädagogik HS 2012', '120442.studierende', 'DDK_FTH_MASTP_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (697, 'MAS Musikphysiologie', '15353.alle', 'DMU_MASMPH.alle', 'MetaDepartment');
INSERT INTO groups VALUES (698, 'Master Design', '74626.dozierende', 'DDE_FDE_MDE.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (699, 'Vertiefungssekretariate', '62706.', 'Verteilerliste.Vertiefungssekretariate', 'MetaDepartment');
INSERT INTO groups VALUES (700, 'Bachelor Musik - Instrument/Gesang - Pop - HS 2010', '90321.studierende', 'DMU_FMU_BMU_VIG_SPOP_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (701, 'Fachrichtung Musik', '14664.alle', 'DMU_FMU.alle', 'MetaDepartment');
INSERT INTO groups VALUES (702, 'Master Theater - Vertiefung Schauspiel - HS 2010', '91583.studierende', 'DDK_FTH_MTH_VSC_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (703, 'Bachelor Design - Vertiefung Scientific Visualization - HS 2011', '102605.studierende', 'DDE_FDE_BDE_VSV_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (704, 'IT-Pool', '66239.personal', 'SER_ITZ_itpool.personal', 'MetaDepartment');
INSERT INTO groups VALUES (705, 'Personen, die die Konzertvermittlung im Dept. Musik betreiben.', '75923.', 'Verteilerliste.DMU_Konzertvermittlung', 'MetaDepartment');
INSERT INTO groups VALUES (706, 'Bachelor Design - Vertiefung Visuelle Kommunikation - HS 2011', '102606.studierende', 'DDE_FDE_BDE_VVK_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (707, 'MAS Musiktheorie', '15355.studierende', 'DMU_MASMTH.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (708, 'Dozierende am Konservatorium Winterthur', '88540.', 'Verteilerliste.Konsi_Winterthur_Dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (709, 'Vertiefung Cast / Audiovisuelle Medien', '56662.dozierende', 'DDE_FDE_VCA.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (710, 'HSAdmin_SG', '62707.', 'Verteilerliste.HSAdmin_SG', 'MetaDepartment');
INSERT INTO groups VALUES (711, 'Master Theater', '64570.studierende', 'DDK_FTH_MTH.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (712, 'Bachelor Vermittlung von Kunst und Design -  Ästhetische Bildung und Soziokultur - HS 2011', '102661.studierende', 'DKV_FAE_BAE_VAS_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (713, 'Bachelor Vermittlung von Kunst und Design - Bildnerisches Gestalten an Maturitätsschulen - HS 2011', '102660.studierende', 'DKV_FAE_BAE_VBG_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (714, 'MAS Musiktheorie', '15355.alle', 'DMU_MASMTH.alle', 'MetaDepartment');
INSERT INTO groups VALUES (715, 'Alle Leitungspersonen im Dept. Musik', '75915.', 'Verteilerliste.DMU_Leitungen', 'MetaDepartment');
INSERT INTO groups VALUES (716, 'Services, Support Services', '75441.alle', 'SER_SUP.alle', 'MetaDepartment');
INSERT INTO groups VALUES (717, 'Master Theater', '64570.alle', 'DDK_FTH_MTH.alle', 'MetaDepartment');
INSERT INTO groups VALUES (718, 'Master Art Education - Vertiefung ausstellen & vermitteln - HS 2011', '103908.studierende', 'DKV_FAE_MAE_VAV_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (719, 'Tanz Grundstudium', '65450.studierende', 'DDK_FTA_XGR_all.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (720, 'Mittelbau Museum Au60', '64176.mittelbau', 'mittelbau.DKV_Museum_Au60.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (721, 'MIZ_Intern', '58309.', 'Verteilerliste.SER_SUP_MIZ_Intern', 'MetaDepartment');
INSERT INTO groups VALUES (722, 'Master Specialized Music Performance - Solist/in - HS 2010', '90288.studierende', 'DMU_FMU_MSP_VSO_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (723, 'Vertiefung Schauspiel', '64573.studierende', 'DDK_FTH_MTH_VSC.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (724, 'Mentoratspersonen, die Einsicht in sensible Daten erhalten.', '75918.', 'Verteilerliste.DMU_Mentoren', 'MetaDepartment');
INSERT INTO groups VALUES (725, 'Profil Kirchenmusik', '65627.dozierende', 'DMU_FMU_PKM.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (726, 'Bachelor Musik und Bewegung HS 2012', '115218.studierende', 'DMU_FMU_BMB_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (727, 'Mittelbau Museum Au60', '64176.alle', 'mittelbau.DKV_Museum_Au60.alle', 'MetaDepartment');
INSERT INTO groups VALUES (728, 'Services, Support Services', '75441.personal', 'SER_SUP.personal', 'MetaDepartment');
INSERT INTO groups VALUES (729, 'Tanz - Grundstufe (12-15 Jahre)', '15419.studierende', 'DDK_FTA_XGR.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (730, 'Vertiefung Schauspiel', '64573.alle', 'DDK_FTH_MTH_VSC.alle', 'MetaDepartment');
INSERT INTO groups VALUES (731, 'Master Music Pedagogy - Musik und Bewegung - Elementare Musikerziehung - HS 2012', '114495.studierende', 'DMU_FMU_MMP_VMB_SEM_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (732, 'Personen, die bei Erfassung von Beurteilungen involviert sind. Diese Personen erhalten ausserdem Einsicht in Beurteilungen (Sensible Daten!)', '75919.', 'Verteilerliste.DMU_Mentoren_Admin', 'MetaDepartment');
INSERT INTO groups VALUES (734, 'Master Art Education - Vertiefung ausstellen & vermitteln - HS 2008', '66499.studierende', 'DKV_FAE_MAE_VAV_08H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (735, 'Master Composition and Theory - Theorie - HS 2010', '90308.studierende', 'DMU_FMU_MKT_VTH_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (736, 'Zeiterfassung', '100920.', 'Verteilerliste.Zeiterfassung', 'MetaDepartment');
INSERT INTO groups VALUES (737, 'Master Music Pedagogy - Musik und Bewegung - Rhythmik - HS 2012', '114496.studierende', 'DMU_FMU_MMP_VMB_SRH_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (738, 'Mittelbau Museum Bellerive', '64177.mittelbau', 'mittelbau.DKV_Museum_Bellerive.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (739, 'Services, Medien- und Informationszentrum', '15279.personal', 'SER_SUP_MIZ.personal', 'MetaDepartment');
INSERT INTO groups VALUES (740, 'Tanz - Grundstufe (12-15 Jahre)', '15419.alle', 'DDK_FTA_XGR.alle', 'MetaDepartment');
INSERT INTO groups VALUES (741, 'Master Music Performance - instrumentale/vokale Performance - Orchester - FS 2012', '108236.studierende', 'DMU_FMU_MPE_VIV_SOR_12F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (742, 'Administrative Modulverantwortliche Evento', '108894.', 'Verteilerliste.Admin_Modulverantwortliche_Evento', 'MetaDepartment');
INSERT INTO groups VALUES (743, 'Master Music Pedagogy - Schulmusik - Schulmusik I - HS 2012', '114497.studierende', 'DMU_FMU_MMP_VSMU_SSI_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (744, 'Involvierte Personen der Orchesteradministration', '75901.', 'Verteilerliste.DMU_Orchesteradministration', 'MetaDepartment');
INSERT INTO groups VALUES (745, 'Master Music Pedagogy - Schulmusik - Schulmusik II - HS 2012', '114490.studierende', 'DMU_FMU_MMP_VSMU_SSII_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (746, 'Mittelbau Museum Bellerive', '64177.alle', 'mittelbau.DKV_Museum_Bellerive.alle', 'MetaDepartment');
INSERT INTO groups VALUES (747, 'Services, Medien- und Informationszentrum', '15279.alle', 'SER_SUP_MIZ.alle', 'MetaDepartment');
INSERT INTO groups VALUES (748, 'Vertiefung Scientific Visualization', '56669.alle', 'DDE_FDE_VSV.alle', 'MetaDepartment');
INSERT INTO groups VALUES (749, 'Bachelor Theater - Vertiefung Schauspiel', '56657.personal', 'DDK_FTH_BTH_VSC.personal', 'MetaDepartment');
INSERT INTO groups VALUES (751, 'Personen, die Stammdaten des Veranstaltungskalenders bearbeiten und Event-Teaser auf die Startseite setzen können.', '75911.', 'Verteilerliste.Events_Superadmin', 'MetaDepartment');
INSERT INTO groups VALUES (752, 'Personen, die die Tonträger-Datenbank des MIZ pflegen', '75931.', 'Verteilerliste.App_Tontraeger_Admin', 'MetaDepartment');
INSERT INTO groups VALUES (753, 'Vertiefung Schauspiel', '64573.personal', 'DDK_FTH_MTH_VSC.personal', 'MetaDepartment');
INSERT INTO groups VALUES (754, 'DMU Mitarbeitende', '64298.', 'Verteilerliste.DMU_Mitarbeitende', 'MetaDepartment');
INSERT INTO groups VALUES (755, 'Departement Kunst und Medien', '5112.alle', 'DKM.alle', 'MetaDepartment');
INSERT INTO groups VALUES (756, 'Bachelor Medien & Kunst - Vertiefung Mediale Künste - HS 2009', '78188.studierende', 'DKM_FMK_BMK_VMK_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (758, 'Services, Informations-Technologie-Zentrum', '14647.alle', 'SER_SUP_ITZ.alle', 'MetaDepartment');
INSERT INTO groups VALUES (759, 'Vertiefung Scientific Visualization / Wissenschaftliche Illustration', '3042.studierende', 'DDE_FDE_BDE_VSV.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (760, 'Bachelor Design - Vertiefung Style & Design - HS 2010', '90734.studierende', 'DDE_FDE_BDE_VSD_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (761, 'MAS in klinischer Musiktherapie Upgrade C FS 2008', '63244.studierende', 'DMU_FMU_MASMTH_UP_C_08F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (762, 'Personen in allen Sekretariaten des Dept. Musik', '75914.', 'Verteilerliste.DMU_Sekretariate', 'MetaDepartment');
INSERT INTO groups VALUES (763, 'Fachrichtung Medien & Kunst', '14668.alle', 'DKM_FMK.alle', 'MetaDepartment');
INSERT INTO groups VALUES (764, 'Vertiefung Scientific Visualization / Wissenschaftliche Illustration', '3042.alle', 'DDE_FDE_BDE_VSV.alle', 'MetaDepartment');
INSERT INTO groups VALUES (765, 'MAS Theaterpädagogik HS 2011', '108010.studierende', 'DDK_FTH_MASTP_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (766, 'Blitzkurse', '120209.dozierende', 'SER_ITZ_Blitzkurse.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (767, 'Blitzkurse', '120209.alle', 'SER_ITZ_Blitzkurse.alle', 'MetaDepartment');
INSERT INTO groups VALUES (768, 'Departement Kunst und Medien', '5112.personal', 'DKM.personal', 'MetaDepartment');
INSERT INTO groups VALUES (769, 'Vertiefung Scientific Visualization', '56669.studierende', 'DDE_FDE_VSV.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (770, 'Departement Kunst und Medien', '5112.studierende', 'DKM.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (771, 'Blitzkurse', '120209.personal', 'SER_ITZ_Blitzkurse.personal', 'MetaDepartment');
INSERT INTO groups VALUES (772, 'Certificate of Advanced Studies, Zertifikatslehrgänge', '3651.dozierende', 'CAS.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (773, 'Master Composition and Theory - Komposition - Elektroakustische Komposition - HS 2009', '76894.studierende', 'DMU_FMU_MKT_VKO_SEAK_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (774, 'F_und_E Projektleiter (Aracely Uzeda)', '14643.', 'Verteilerliste.F_E_Projektleiter', 'MetaDepartment');
INSERT INTO groups VALUES (775, 'Master Art Education - Vertiefung publizieren & vermitteln - HS 2009', '78229.studierende', 'DKV_FAE_MAE_VPV_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (776, 'Fachbereich Museum Bellerive', '64179.personal', 'DKV_Museum_Bellerive.personal', 'MetaDepartment');
INSERT INTO groups VALUES (777, 'Institut für Designforschung', '14674.personal', 'DDE_IDE.personal', 'MetaDepartment');
INSERT INTO groups VALUES (778, 'Bachelor Medien & Kunst HS 2012', '115223.studierende', 'DKM_FMK_BMK_Austausch_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (779, 'Fachrichtung Medien & Kunst', '14668.personal', 'DKM_FMK.personal', 'MetaDepartment');
INSERT INTO groups VALUES (780, 'Bachelor Vermittlung von Kunst und Design - Bildnerisches Gestalten an Maturitätsschulen - HS 2010', '90744.studierende', 'DKV_FAE_BAE_VBG_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (781, 'Fachrichtung Medien & Kunst', '14668.studierende', 'DKM_FMK.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (782, 'SAP Superuser', '102618.', 'Verteilerliste.SAP_Superuser', 'MetaDepartment');
INSERT INTO groups VALUES (783, 'Master Music Performance - instrumentale/vokale Performance - Konzert - HS 2011', '102533.studierende', 'DMU_FMU_MPE_VIV_SKT_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (784, 'Rektorat', '14673.dozierende', 'REK.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (785, 'Zugang zu den Formulardaten "Wettbewerbs-Anmeldungen"', '76407.', 'Verteilerliste.Form_DMU_Wettbewerbe', 'MetaDepartment');
INSERT INTO groups VALUES (786, 'Fachbereich Museum Bellerive', '64179.alle', 'DKV_Museum_Bellerive.alle', 'MetaDepartment');
INSERT INTO groups VALUES (787, 'Fachrichtung Tanz', '14665.dozierende', 'DDK_FTA.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (788, 'Master Theater - Vertiefung Regie - HS 2010', '91582.studierende', 'DDK_FTH_MTH_VRE_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (789, 'Bachelor Medien & Kunst', '15291.studierende', 'DKM_FMK_BMK.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (790, 'Master Music Performance - instrumentale/vokale Performance - Orchester - HS 2011', '102535.studierende', 'DMU_FMU_MPE_VIV_SOR_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (791, 'Certificate of Advanced Studies, Zertifikatslehrgänge', '3651.alle', 'CAS.alle', 'MetaDepartment');
INSERT INTO groups VALUES (792, 'Services', '14645.dozierende', 'SER.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (793, 'Zugang zu den sensiblen Formulardaten "Feedback Personalrat"', '75930.', 'Verteilerliste.Form_Personalrat_Feedback', 'MetaDepartment');
INSERT INTO groups VALUES (794, 'Personal Museum Bellerive', '64178.personal', 'personal.DKV_Museum_Bellerive.personal', 'MetaDepartment');
INSERT INTO groups VALUES (795, 'Vertiefung Interaction Design', '56664.mittelbau', 'DDE_FDE_VIAD.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (796, 'Departement Design', '14667.personal', 'DDE.personal', 'MetaDepartment');
INSERT INTO groups VALUES (797, 'Master Specialized Music Performance - Solist/in - HS 2011', '102543.studierende', 'DMU_FMU_MSP_VSO_11H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (798, 'Profil Regie', '64571.studierende', 'DDK_FTH_MTH_VLK_PRE.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (799, 'Bachelor Medien & Kunst', '15291.alle', 'DKM_FMK_BMK.alle', 'MetaDepartment');
INSERT INTO groups VALUES (800, 'Certificate of Advanced Studies, Zertifikatslehrgänge', '3651.mittelbau', 'CAS.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (801, 'Personal Museum Bellerive', '64178.alle', 'personal.DKV_Museum_Bellerive.alle', 'MetaDepartment');
INSERT INTO groups VALUES (802, 'Fachrichtung Design', '15281.personal', 'DDE_FDE.personal', 'MetaDepartment');
INSERT INTO groups VALUES (803, 'Institut für Theorie', '57158.dozierende', 'DKV_ITH.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (804, 'Profil Regie', '64571.alle', 'DDK_FTH_MTH_VLK_PRE.alle', 'MetaDepartment');
INSERT INTO groups VALUES (805, 'Bachelor Design', '15289.mittelbau', 'DDE_FDE_BDE.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (806, 'Superuser der Webapplikation Raumverwaltung', '75916.', 'Verteilerliste.App_Raumverwaltung_Superuser', 'MetaDepartment');
INSERT INTO groups VALUES (807, 'Bachelor Theater - Vertiefung Schauspiel - HS 2009', '78238.studierende', 'DDK_FTH_BTH_VSC_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (808, 'Master Design - Vertiefung Ereignis - FS 2012', '121248.studierende', 'DDE_FDE_MDE_VER_12F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (809, 'IT-Pool', '66239.dozierende', 'SER_ITZ_itpool.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (810, 'Profil Theorie', '89976.mittelbau', 'DMU_FMU_PTH.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (811, 'Master Music Pedagogy - Musik und Bewegung - Rhythmik - HS 2010', '90275.studierende', 'DMU_FMU_MMP_VMB_SRH_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (812, 'Master Design - Vertiefung Interaktion - FS 2012', '121247.studierende', 'DDE_FDE_MDE_VIA_12F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (813, 'Institute for Computer Music and Sound Technology', '15278.mittelbau', 'DMU_ICST.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (814, 'Bachelor Theater - Vertiefung Schauspiel', '56657.studierende', 'DDK_FTH_BTH_VSC.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (815, 'Master Design - Vertiefung Kommunikation - FS 2012', '121245.studierende', 'DDE_FDE_MDE_VKK_12F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (816, 'Master Design - Vertiefung Produkt - FS 2012', '121246.studierende', 'DDE_FDE_MDE_VPR_12F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (817, 'Institute for Computer Music and Sound Technology', '15278.alle', 'DMU_ICST.alle', 'MetaDepartment');
INSERT INTO groups VALUES (818, 'Bachelor Theater - Vertiefung Schauspiel', '56657.alle', 'DDK_FTH_BTH_VSC.alle', 'MetaDepartment');
INSERT INTO groups VALUES (819, 'Master Design - Vertiefung Trends - FS 2012', '121249.studierende', 'DDE_FDE_MDE_VTR_12F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (820, 'Fachdozierende FTM > Komposition für Film, Theater und Medien', '65230.', 'Verteilerliste.FTM_Fachdozierende', 'MetaDepartment');
INSERT INTO groups VALUES (821, 'Personen, die die Applikation Weiterbildung-News pflegen.', '121244.', 'Verteilerliste.App_Weiterbildungsnews_Admin', 'MetaDepartment');
INSERT INTO groups VALUES (822, 'IT-Pool', '66239.alle', 'SER_ITZ_itpool.alle', 'MetaDepartment');
INSERT INTO groups VALUES (823, 'Departement Darstellende Künste und Film', '14677.dozierende', 'DDK.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (824, 'Bachelor Design - Vertiefung Cast / Audiovisuelle Medien - HS 2012', '115222.studierende', 'DDE_FDE_BDE_VCA_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (825, 'Kernfachdozierende FTM > Komposition für Film, Theater und Medien', '65229.', 'Verteilerliste.FTM_Kernfachdozierende', 'MetaDepartment');
INSERT INTO groups VALUES (826, 'Master Music Pedagogy - Schulmusik - Schulmusik I - HS 2010', '90273.studierende', 'DMU_FMU_MMP_VSMU_SSI_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (827, 'Schauspiel', '64574.studierende', 'DDK_FTH_VSC.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (828, 'Bachelor Medien & Kunst - Vertiefung Fotografie - HS 2012', '115225.studierende', 'DKM_FMK_BMK_VFO_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (829, 'Bachelor Film HS 2008', '66372.studierende', 'DDK_FFI_BFI_08H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (830, 'Services, Abteilung Business Applications', '15426.personal', 'SER_MAN_BAP.personal', 'MetaDepartment');
INSERT INTO groups VALUES (831, 'Institute for the Performing Arts and Film', '83401.dozierende', 'DDK_IPF.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (832, 'Bachelor Musik - Instrument/Gesang - Klassik - HS 2012', '114445.studierende', 'DMU_FMU_BMU_VIG_SKLA_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (833, 'Master Theater', '64570.dozierende', 'DDK_FTH_MTH.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (834, 'Schauspiel', '64574.alle', 'DDK_FTH_VSC.alle', 'MetaDepartment');
INSERT INTO groups VALUES (835, 'MAS Szenografie HS 2010', '95095.studierende', 'DDE_FDE_MASSZ_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (836, 'Services, Abteilung Business Applications', '15426.alle', 'SER_MAN_BAP.alle', 'MetaDepartment');
INSERT INTO groups VALUES (837, 'Diplomstudium (DaP) Studiengang V', '15301.studierende', 'DMU_FMU_GKT.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (838, 'Institute for the Performing Arts and Film', '83401.alle', 'DDK_IPF.alle', 'MetaDepartment');
INSERT INTO groups VALUES (839, 'Personalabteilung: Linienvorgesetzte', '95140.', 'Verteilerliste.SER_PER_Vorgesetzte', 'MetaDepartment');
INSERT INTO groups VALUES (840, 'Vertiefung Mediale Künste', '56671.dozierende', 'DKM_FMK_VMK.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (841, 'Services, Abteilung Finanzen', '12544.personal', 'SER_MAN_FIN.personal', 'MetaDepartment');
INSERT INTO groups VALUES (842, 'Diplomstudium (DaP) Studiengang V', '15301.alle', 'DMU_FMU_GKT.alle', 'MetaDepartment');
INSERT INTO groups VALUES (843, 'Bachelor Vermittlung von Kunst und Design -  Ästhetische Bildung und Soziokultur - HS 2009', '78191.studierende', 'DKV_FAE_BAE_VAS_09H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (844, 'Vertiefung Mediale Künste', '56671.personal', 'DKM_FMK_VMK.personal', 'MetaDepartment');
INSERT INTO groups VALUES (845, 'Master Music Pedagogy - instrumentale/vokale Musikpädagogik - Klassik - FS 2012', '108218.studierende', 'DMU_FMU_MMP_VIV_SKLA_12F.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (846, 'Services, Abteilung Finanzen', '12544.alle', 'SER_MAN_FIN.alle', 'MetaDepartment');
INSERT INTO groups VALUES (847, 'Propädeutikum - Gestalterische Orientierungsstufe', '3043.dozierende', 'DKV_XPP_XGO.dozierende', 'MetaDepartment');
INSERT INTO groups VALUES (848, 'Master Music Pedagogy - instrumentale/vokale Musikpädagogik - Klassik - HS 2012', '114492.studierende', 'DMU_FMU_MMP_VIV_SKLA_12H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (849, 'Departement Musik', '15284.mittelbau', 'DMU.mittelbau', 'MetaDepartment');
INSERT INTO groups VALUES (850, 'Bühnentanz EFZ HS 2010', '89313.studierende', 'DDK_FTA_XBT_10H.studierende', 'MetaDepartment');
INSERT INTO groups VALUES (851, 'Services, Abteilung Hochschuladministration', '15424.personal', 'SER_MAN_HAD.personal', 'MetaDepartment');


--
-- Data for Name: groups_users; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO groups_users VALUES (2, 1);
INSERT INTO groups_users VALUES (3, 2);
INSERT INTO groups_users VALUES (4, 2);
INSERT INTO groups_users VALUES (3, 3);
INSERT INTO groups_users VALUES (5, 4);
INSERT INTO groups_users VALUES (3, 5);
INSERT INTO groups_users VALUES (3, 6);
INSERT INTO groups_users VALUES (8, 7);


--
-- Data for Name: keywords; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO keywords VALUES (57, 533, 6, 61, '2012-08-31 12:01:47');
INSERT INTO keywords VALUES (59, 535, 6, 61, '2012-08-31 12:01:47');
INSERT INTO keywords VALUES (61, 513, 6, 61, '2012-08-31 12:01:47');
INSERT INTO keywords VALUES (63, 515, 6, 61, '2012-08-31 12:01:47');
INSERT INTO keywords VALUES (65, 537, 6, 61, '2012-08-31 12:01:47');
INSERT INTO keywords VALUES (67, 539, 6, 61, '2012-08-31 12:01:47');
INSERT INTO keywords VALUES (69, 541, 6, 61, '2012-08-31 12:01:47');
INSERT INTO keywords VALUES (71, 527, 6, 61, '2012-08-31 12:01:47');
INSERT INTO keywords VALUES (72, 655, 7, 103, '2012-10-16 13:46:53.402927');
INSERT INTO keywords VALUES (73, 35, 7, 103, '2012-10-16 13:46:53.466088');
INSERT INTO keywords VALUES (74, 76, 7, 103, '2012-10-16 13:46:53.469592');
INSERT INTO keywords VALUES (75, 405, 7, 103, '2012-10-16 13:46:53.472586');
INSERT INTO keywords VALUES (76, 2411, 7, 103, '2012-10-16 13:46:53.475594');
INSERT INTO keywords VALUES (77, 4598, 7, 103, '2012-10-16 13:46:53.478633');
INSERT INTO keywords VALUES (78, 4599, 7, 103, '2012-10-16 13:46:53.481598');
INSERT INTO keywords VALUES (79, 4600, 7, 103, '2012-10-16 13:46:53.484593');
INSERT INTO keywords VALUES (80, 4601, 7, 103, '2012-10-16 13:46:53.487575');
INSERT INTO keywords VALUES (81, 4602, 7, 103, '2012-10-16 13:46:53.490591');
INSERT INTO keywords VALUES (82, 4603, 7, 103, '2012-10-16 13:46:53.493533');
INSERT INTO keywords VALUES (83, 655, 7, 124, '2012-10-16 13:47:05.939634');
INSERT INTO keywords VALUES (84, 35, 7, 124, '2012-10-16 13:47:05.943294');
INSERT INTO keywords VALUES (85, 76, 7, 124, '2012-10-16 13:47:05.946459');
INSERT INTO keywords VALUES (86, 405, 7, 124, '2012-10-16 13:47:05.949566');
INSERT INTO keywords VALUES (87, 2411, 7, 124, '2012-10-16 13:47:05.952677');
INSERT INTO keywords VALUES (88, 4598, 7, 124, '2012-10-16 13:47:05.955557');
INSERT INTO keywords VALUES (89, 4599, 7, 124, '2012-10-16 13:47:05.958427');
INSERT INTO keywords VALUES (90, 4600, 7, 124, '2012-10-16 13:47:05.961279');
INSERT INTO keywords VALUES (91, 4601, 7, 124, '2012-10-16 13:47:05.964162');
INSERT INTO keywords VALUES (92, 4602, 7, 124, '2012-10-16 13:47:05.96703');
INSERT INTO keywords VALUES (93, 4603, 7, 124, '2012-10-16 13:47:05.970018');
INSERT INTO keywords VALUES (94, 1475, 7, 142, '2012-10-16 13:47:08.912842');
INSERT INTO keywords VALUES (95, 1477, 7, 142, '2012-10-16 13:47:08.915979');
INSERT INTO keywords VALUES (96, 2665, 7, 170, '2012-10-16 13:47:11.398805');
INSERT INTO keywords VALUES (97, 447, 7, 170, '2012-10-16 13:47:11.401972');
INSERT INTO keywords VALUES (98, 1353, 7, 170, '2012-10-16 13:47:11.40491');
INSERT INTO keywords VALUES (99, 76, 7, 170, '2012-10-16 13:47:11.407949');
INSERT INTO keywords VALUES (100, 405, 7, 170, '2012-10-16 13:47:11.41091');
INSERT INTO keywords VALUES (101, 4604, 7, 170, '2012-10-16 13:47:11.413904');
INSERT INTO keywords VALUES (102, 4605, 7, 170, '2012-10-16 13:47:11.41684');
INSERT INTO keywords VALUES (103, 4606, 7, 170, '2012-10-16 13:47:11.419767');
INSERT INTO keywords VALUES (104, 4607, 7, 170, '2012-10-16 13:47:11.42273');
INSERT INTO keywords VALUES (105, 4608, 7, 170, '2012-10-16 13:47:11.425661');
INSERT INTO keywords VALUES (106, 1475, 7, 188, '2012-10-16 13:47:16.425599');
INSERT INTO keywords VALUES (107, 1477, 7, 188, '2012-10-16 13:47:16.428621');
INSERT INTO keywords VALUES (108, 2665, 7, 230, '2012-10-16 13:47:28.292791');
INSERT INTO keywords VALUES (109, 447, 7, 230, '2012-10-16 13:47:28.296251');
INSERT INTO keywords VALUES (110, 1353, 7, 230, '2012-10-16 13:47:28.299448');
INSERT INTO keywords VALUES (111, 76, 7, 230, '2012-10-16 13:47:28.302477');
INSERT INTO keywords VALUES (112, 405, 7, 230, '2012-10-16 13:47:28.30557');
INSERT INTO keywords VALUES (113, 4604, 7, 230, '2012-10-16 13:47:28.308642');
INSERT INTO keywords VALUES (114, 4605, 7, 230, '2012-10-16 13:47:28.311768');
INSERT INTO keywords VALUES (115, 4606, 7, 230, '2012-10-16 13:47:28.314874');
INSERT INTO keywords VALUES (116, 4607, 7, 230, '2012-10-16 13:47:28.317879');
INSERT INTO keywords VALUES (117, 4608, 7, 230, '2012-10-16 13:47:28.320918');
INSERT INTO keywords VALUES (118, 1475, 7, 264, '2012-10-16 13:47:35.352424');
INSERT INTO keywords VALUES (119, 1477, 7, 264, '2012-10-16 13:47:35.35562');
INSERT INTO keywords VALUES (120, 2665, 7, 303, '2012-10-16 13:47:40.04498');
INSERT INTO keywords VALUES (121, 447, 7, 303, '2012-10-16 13:47:40.048108');
INSERT INTO keywords VALUES (122, 1353, 7, 303, '2012-10-16 13:47:40.051024');
INSERT INTO keywords VALUES (123, 76, 7, 303, '2012-10-16 13:47:40.054034');
INSERT INTO keywords VALUES (124, 405, 7, 303, '2012-10-16 13:47:40.057235');
INSERT INTO keywords VALUES (125, 4604, 7, 303, '2012-10-16 13:47:40.060119');
INSERT INTO keywords VALUES (126, 4605, 7, 303, '2012-10-16 13:47:40.06299');
INSERT INTO keywords VALUES (127, 4606, 7, 303, '2012-10-16 13:47:40.065908');
INSERT INTO keywords VALUES (128, 4607, 7, 303, '2012-10-16 13:47:40.068773');
INSERT INTO keywords VALUES (129, 4608, 7, 303, '2012-10-16 13:47:40.071667');
INSERT INTO keywords VALUES (130, 4610, 7, 330, '2012-10-16 13:47:44.825353');
INSERT INTO keywords VALUES (131, 1281, 7, 330, '2012-10-16 13:47:44.828856');
INSERT INTO keywords VALUES (132, 4611, 7, 330, '2012-10-16 13:47:44.832263');
INSERT INTO keywords VALUES (133, 2337, 7, 330, '2012-10-16 13:47:44.835739');
INSERT INTO keywords VALUES (134, 2665, 7, 349, '2012-10-16 13:47:49.063318');
INSERT INTO keywords VALUES (135, 447, 7, 349, '2012-10-16 13:47:49.066478');
INSERT INTO keywords VALUES (136, 1353, 7, 349, '2012-10-16 13:47:49.069455');
INSERT INTO keywords VALUES (137, 76, 7, 349, '2012-10-16 13:47:49.072354');
INSERT INTO keywords VALUES (138, 405, 7, 349, '2012-10-16 13:47:49.075285');
INSERT INTO keywords VALUES (139, 4604, 7, 349, '2012-10-16 13:47:49.078229');
INSERT INTO keywords VALUES (140, 4605, 7, 349, '2012-10-16 13:47:49.081196');
INSERT INTO keywords VALUES (141, 4606, 7, 349, '2012-10-16 13:47:49.084184');
INSERT INTO keywords VALUES (142, 4607, 7, 349, '2012-10-16 13:47:49.087131');
INSERT INTO keywords VALUES (143, 4608, 7, 349, '2012-10-16 13:47:49.090064');
INSERT INTO keywords VALUES (144, 2485, 7, 375, '2012-10-16 13:47:53.883257');
INSERT INTO keywords VALUES (145, 2665, 7, 393, '2012-10-16 13:47:58.458323');
INSERT INTO keywords VALUES (146, 447, 7, 393, '2012-10-16 13:47:58.461558');
INSERT INTO keywords VALUES (147, 1353, 7, 393, '2012-10-16 13:47:58.464463');
INSERT INTO keywords VALUES (148, 76, 7, 393, '2012-10-16 13:47:58.467371');
INSERT INTO keywords VALUES (149, 405, 7, 393, '2012-10-16 13:47:58.470293');
INSERT INTO keywords VALUES (150, 4604, 7, 393, '2012-10-16 13:47:58.473202');
INSERT INTO keywords VALUES (151, 4605, 7, 393, '2012-10-16 13:47:58.476122');
INSERT INTO keywords VALUES (152, 4606, 7, 393, '2012-10-16 13:47:58.479064');
INSERT INTO keywords VALUES (153, 4607, 7, 393, '2012-10-16 13:47:58.48203');
INSERT INTO keywords VALUES (154, 4608, 7, 393, '2012-10-16 13:47:58.48494');
INSERT INTO keywords VALUES (155, 899, 7, 408, '2012-10-16 13:48:01.151546');
INSERT INTO keywords VALUES (156, 4612, 7, 419, '2012-10-16 13:48:03.940478');
INSERT INTO keywords VALUES (157, 1353, 7, 419, '2012-10-16 13:48:03.94367');
INSERT INTO keywords VALUES (158, 1483, 7, 419, '2012-10-16 13:48:03.946725');
INSERT INTO keywords VALUES (159, 431, 7, 419, '2012-10-16 13:48:03.949879');
INSERT INTO keywords VALUES (160, 4613, 7, 419, '2012-10-16 13:48:03.952828');
INSERT INTO keywords VALUES (161, 655, 7, 436, '2012-10-16 13:48:07.196379');
INSERT INTO keywords VALUES (162, 35, 7, 436, '2012-10-16 13:48:07.199406');
INSERT INTO keywords VALUES (163, 76, 7, 436, '2012-10-16 13:48:07.202473');
INSERT INTO keywords VALUES (164, 405, 7, 436, '2012-10-16 13:48:07.205426');
INSERT INTO keywords VALUES (165, 2411, 7, 436, '2012-10-16 13:48:07.208378');
INSERT INTO keywords VALUES (166, 4598, 7, 436, '2012-10-16 13:48:07.211319');
INSERT INTO keywords VALUES (167, 4599, 7, 436, '2012-10-16 13:48:07.214244');
INSERT INTO keywords VALUES (168, 4600, 7, 436, '2012-10-16 13:48:07.217142');
INSERT INTO keywords VALUES (169, 4601, 7, 436, '2012-10-16 13:48:07.220069');
INSERT INTO keywords VALUES (170, 4602, 7, 436, '2012-10-16 13:48:07.223002');
INSERT INTO keywords VALUES (171, 4603, 7, 436, '2012-10-16 13:48:07.225971');
INSERT INTO keywords VALUES (172, 2665, 7, 457, '2012-10-16 13:48:09.748956');
INSERT INTO keywords VALUES (173, 447, 7, 457, '2012-10-16 13:48:09.752062');
INSERT INTO keywords VALUES (174, 1353, 7, 457, '2012-10-16 13:48:09.754965');
INSERT INTO keywords VALUES (175, 76, 7, 457, '2012-10-16 13:48:09.757858');
INSERT INTO keywords VALUES (176, 405, 7, 457, '2012-10-16 13:48:09.760733');
INSERT INTO keywords VALUES (177, 4604, 7, 457, '2012-10-16 13:48:09.763612');
INSERT INTO keywords VALUES (178, 4605, 7, 457, '2012-10-16 13:48:09.766439');
INSERT INTO keywords VALUES (179, 4606, 7, 457, '2012-10-16 13:48:09.769345');
INSERT INTO keywords VALUES (180, 4607, 7, 457, '2012-10-16 13:48:09.77223');
INSERT INTO keywords VALUES (181, 4608, 7, 457, '2012-10-16 13:48:09.775147');
INSERT INTO keywords VALUES (182, 76, 7, 492, '2012-10-16 13:56:37.740241');
INSERT INTO keywords VALUES (183, 655, 7, 511, '2012-10-16 13:56:44.480583');
INSERT INTO keywords VALUES (184, 35, 7, 511, '2012-10-16 13:56:44.48366');
INSERT INTO keywords VALUES (185, 76, 7, 511, '2012-10-16 13:56:44.486554');
INSERT INTO keywords VALUES (186, 405, 7, 511, '2012-10-16 13:56:44.489446');
INSERT INTO keywords VALUES (187, 2411, 7, 511, '2012-10-16 13:56:44.492362');
INSERT INTO keywords VALUES (188, 4598, 7, 511, '2012-10-16 13:56:44.495288');
INSERT INTO keywords VALUES (189, 4599, 7, 511, '2012-10-16 13:56:44.498219');
INSERT INTO keywords VALUES (190, 4600, 7, 511, '2012-10-16 13:56:44.501135');
INSERT INTO keywords VALUES (191, 4601, 7, 511, '2012-10-16 13:56:44.504011');
INSERT INTO keywords VALUES (192, 4602, 7, 511, '2012-10-16 13:56:44.506911');
INSERT INTO keywords VALUES (193, 4603, 7, 511, '2012-10-16 13:56:44.509804');
INSERT INTO keywords VALUES (194, 76, 7, 534, '2012-10-16 13:56:50.289151');
INSERT INTO keywords VALUES (195, 655, 7, 555, '2012-10-16 13:56:55.650183');
INSERT INTO keywords VALUES (196, 35, 7, 555, '2012-10-16 13:56:55.653201');
INSERT INTO keywords VALUES (197, 76, 7, 555, '2012-10-16 13:56:55.656038');
INSERT INTO keywords VALUES (198, 405, 7, 555, '2012-10-16 13:56:55.658899');
INSERT INTO keywords VALUES (199, 2411, 7, 555, '2012-10-16 13:56:55.661749');
INSERT INTO keywords VALUES (200, 4598, 7, 555, '2012-10-16 13:56:55.664615');
INSERT INTO keywords VALUES (201, 4599, 7, 555, '2012-10-16 13:56:55.66746');
INSERT INTO keywords VALUES (202, 4600, 7, 555, '2012-10-16 13:56:55.670303');
INSERT INTO keywords VALUES (203, 4601, 7, 555, '2012-10-16 13:56:55.67313');
INSERT INTO keywords VALUES (204, 4602, 7, 555, '2012-10-16 13:56:55.675966');
INSERT INTO keywords VALUES (205, 4603, 7, 555, '2012-10-16 13:56:55.678815');
INSERT INTO keywords VALUES (206, 1475, 7, 573, '2012-10-16 13:56:59.146098');
INSERT INTO keywords VALUES (207, 1477, 7, 573, '2012-10-16 13:56:59.149701');
INSERT INTO keywords VALUES (208, 2665, 7, 601, '2012-10-16 13:57:02.043526');
INSERT INTO keywords VALUES (209, 447, 7, 601, '2012-10-16 13:57:02.046646');
INSERT INTO keywords VALUES (210, 1353, 7, 601, '2012-10-16 13:57:02.049555');
INSERT INTO keywords VALUES (211, 76, 7, 601, '2012-10-16 13:57:02.052468');
INSERT INTO keywords VALUES (212, 405, 7, 601, '2012-10-16 13:57:02.055357');
INSERT INTO keywords VALUES (213, 4604, 7, 601, '2012-10-16 13:57:02.05826');
INSERT INTO keywords VALUES (214, 4605, 7, 601, '2012-10-16 13:57:02.061168');
INSERT INTO keywords VALUES (215, 4606, 7, 601, '2012-10-16 13:57:02.064049');
INSERT INTO keywords VALUES (216, 4607, 7, 601, '2012-10-16 13:57:02.066952');
INSERT INTO keywords VALUES (217, 4608, 7, 601, '2012-10-16 13:57:02.069852');
INSERT INTO keywords VALUES (218, 1475, 7, 619, '2012-10-16 13:57:06.062174');
INSERT INTO keywords VALUES (219, 1477, 7, 619, '2012-10-16 13:57:06.065244');
INSERT INTO keywords VALUES (220, 2665, 7, 649, '2012-10-16 13:57:23.997701');
INSERT INTO keywords VALUES (221, 447, 7, 649, '2012-10-16 13:57:24.000641');
INSERT INTO keywords VALUES (222, 1353, 7, 649, '2012-10-16 13:57:24.015042');
INSERT INTO keywords VALUES (223, 76, 7, 649, '2012-10-16 13:57:24.019173');
INSERT INTO keywords VALUES (224, 405, 7, 649, '2012-10-16 13:57:24.023226');
INSERT INTO keywords VALUES (225, 4604, 7, 649, '2012-10-16 13:57:24.026908');
INSERT INTO keywords VALUES (226, 4605, 7, 649, '2012-10-16 13:57:24.030516');
INSERT INTO keywords VALUES (227, 4606, 7, 649, '2012-10-16 13:57:24.034173');
INSERT INTO keywords VALUES (228, 4607, 7, 649, '2012-10-16 13:57:24.038076');
INSERT INTO keywords VALUES (229, 4608, 7, 649, '2012-10-16 13:57:24.041651');
INSERT INTO keywords VALUES (230, 1475, 7, 667, '2012-10-16 13:57:30.37396');
INSERT INTO keywords VALUES (231, 1477, 7, 667, '2012-10-16 13:57:30.377108');
INSERT INTO keywords VALUES (232, 2665, 7, 706, '2012-10-16 13:57:36.488959');
INSERT INTO keywords VALUES (233, 447, 7, 706, '2012-10-16 13:57:36.492702');
INSERT INTO keywords VALUES (234, 1353, 7, 706, '2012-10-16 13:57:36.496284');
INSERT INTO keywords VALUES (235, 76, 7, 706, '2012-10-16 13:57:36.499698');
INSERT INTO keywords VALUES (236, 405, 7, 706, '2012-10-16 13:57:36.502866');
INSERT INTO keywords VALUES (237, 4604, 7, 706, '2012-10-16 13:57:36.505776');
INSERT INTO keywords VALUES (238, 4605, 7, 706, '2012-10-16 13:57:36.508661');
INSERT INTO keywords VALUES (239, 4606, 7, 706, '2012-10-16 13:57:36.51157');
INSERT INTO keywords VALUES (240, 4607, 7, 706, '2012-10-16 13:57:36.514578');
INSERT INTO keywords VALUES (241, 4608, 7, 706, '2012-10-16 13:57:36.518228');
INSERT INTO keywords VALUES (242, 2665, 7, 732, '2012-10-16 13:57:45.188947');
INSERT INTO keywords VALUES (243, 447, 7, 732, '2012-10-16 13:57:45.191961');
INSERT INTO keywords VALUES (244, 1353, 7, 732, '2012-10-16 13:57:45.195246');
INSERT INTO keywords VALUES (245, 76, 7, 732, '2012-10-16 13:57:45.19858');
INSERT INTO keywords VALUES (246, 405, 7, 732, '2012-10-16 13:57:45.201631');
INSERT INTO keywords VALUES (247, 4604, 7, 732, '2012-10-16 13:57:45.204576');
INSERT INTO keywords VALUES (248, 4605, 7, 732, '2012-10-16 13:57:45.207489');
INSERT INTO keywords VALUES (249, 4606, 7, 732, '2012-10-16 13:57:45.210432');
INSERT INTO keywords VALUES (250, 4607, 7, 732, '2012-10-16 13:57:45.213372');
INSERT INTO keywords VALUES (251, 4608, 7, 732, '2012-10-16 13:57:45.216286');
INSERT INTO keywords VALUES (252, 2665, 7, 762, '2012-10-16 13:57:54.706925');
INSERT INTO keywords VALUES (253, 447, 7, 762, '2012-10-16 13:57:54.711081');
INSERT INTO keywords VALUES (254, 1353, 7, 762, '2012-10-16 13:57:54.714583');
INSERT INTO keywords VALUES (255, 76, 7, 762, '2012-10-16 13:57:54.718092');
INSERT INTO keywords VALUES (256, 405, 7, 762, '2012-10-16 13:57:54.721376');
INSERT INTO keywords VALUES (257, 4604, 7, 762, '2012-10-16 13:57:54.724244');
INSERT INTO keywords VALUES (258, 4605, 7, 762, '2012-10-16 13:57:54.727519');
INSERT INTO keywords VALUES (259, 4606, 7, 762, '2012-10-16 13:57:54.73108');
INSERT INTO keywords VALUES (260, 4607, 7, 762, '2012-10-16 13:57:54.73461');
INSERT INTO keywords VALUES (261, 4608, 7, 762, '2012-10-16 13:57:54.738129');
INSERT INTO keywords VALUES (262, 4612, 7, 796, '2012-10-16 13:58:03.781869');
INSERT INTO keywords VALUES (263, 1353, 7, 796, '2012-10-16 13:58:03.785097');
INSERT INTO keywords VALUES (264, 1483, 7, 796, '2012-10-16 13:58:03.78825');
INSERT INTO keywords VALUES (265, 431, 7, 796, '2012-10-16 13:58:03.791257');
INSERT INTO keywords VALUES (266, 4613, 7, 796, '2012-10-16 13:58:03.794201');
INSERT INTO keywords VALUES (267, 4610, 7, 814, '2012-10-16 13:58:09.219684');
INSERT INTO keywords VALUES (268, 1281, 7, 814, '2012-10-16 13:58:09.22279');
INSERT INTO keywords VALUES (269, 4611, 7, 814, '2012-10-16 13:58:09.225834');
INSERT INTO keywords VALUES (270, 2337, 7, 814, '2012-10-16 13:58:09.228876');
INSERT INTO keywords VALUES (271, 2485, 7, 829, '2012-10-16 13:58:15.122624');
INSERT INTO keywords VALUES (272, 899, 7, 848, '2012-10-16 13:58:21.61493');
INSERT INTO keywords VALUES (273, 655, 7, 867, '2012-10-16 13:58:24.909406');
INSERT INTO keywords VALUES (274, 35, 7, 867, '2012-10-16 13:58:24.913514');
INSERT INTO keywords VALUES (275, 76, 7, 867, '2012-10-16 13:58:24.917131');
INSERT INTO keywords VALUES (276, 405, 7, 867, '2012-10-16 13:58:24.920754');
INSERT INTO keywords VALUES (277, 2411, 7, 867, '2012-10-16 13:58:24.924419');
INSERT INTO keywords VALUES (278, 4598, 7, 867, '2012-10-16 13:58:24.928061');
INSERT INTO keywords VALUES (279, 4599, 7, 867, '2012-10-16 13:58:24.931744');
INSERT INTO keywords VALUES (280, 4600, 7, 867, '2012-10-16 13:58:24.935381');
INSERT INTO keywords VALUES (281, 4601, 7, 867, '2012-10-16 13:58:24.938993');
INSERT INTO keywords VALUES (282, 4602, 7, 867, '2012-10-16 13:58:24.942618');
INSERT INTO keywords VALUES (283, 4603, 7, 867, '2012-10-16 13:58:24.946236');
INSERT INTO keywords VALUES (284, 2665, 7, 888, '2012-10-16 13:58:27.95146');
INSERT INTO keywords VALUES (285, 447, 7, 888, '2012-10-16 13:58:27.95523');
INSERT INTO keywords VALUES (286, 1353, 7, 888, '2012-10-16 13:58:27.958805');
INSERT INTO keywords VALUES (287, 76, 7, 888, '2012-10-16 13:58:27.962418');
INSERT INTO keywords VALUES (288, 405, 7, 888, '2012-10-16 13:58:27.966');
INSERT INTO keywords VALUES (289, 4604, 7, 888, '2012-10-16 13:58:27.969588');
INSERT INTO keywords VALUES (290, 4605, 7, 888, '2012-10-16 13:58:27.973174');
INSERT INTO keywords VALUES (291, 4606, 7, 888, '2012-10-16 13:58:27.97679');
INSERT INTO keywords VALUES (292, 4607, 7, 888, '2012-10-16 13:58:27.980007');
INSERT INTO keywords VALUES (293, 4608, 7, 888, '2012-10-16 13:58:27.983029');
INSERT INTO keywords VALUES (294, 899, 2, 926, '2012-10-16 14:10:18.585763');
INSERT INTO keywords VALUES (302, 75, 6, 1055, '2013-03-07 08:43:22.605544');
INSERT INTO keywords VALUES (303, 4614, 6, 1055, '2013-03-07 08:43:22.612476');
INSERT INTO keywords VALUES (304, 435, 6, 1055, '2013-03-07 08:43:22.619374');
INSERT INTO keywords VALUES (305, 4611, 6, 1090, '2013-03-07 08:49:31.390876');
INSERT INTO keywords VALUES (306, 2337, 6, 1090, '2013-03-07 08:49:31.40385');
INSERT INTO keywords VALUES (307, 4616, 1, 1097, '2013-03-07 09:03:35.18922');


--
-- Data for Name: media_files; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO media_files VALUES (52, 668, 141537, 1024, 'image/tiff', 'Import_Export_MG_3919.tif', '2df542bd70b946d8aa6dc20e30a9d36f', '5c843047-3e8b-4618-8286-91a1e660c2d1', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 668
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x668
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:47:58.695185', '2012-10-16 13:47:58.867796', 'tif', 'image');
INSERT INTO media_files VALUES (54, 670, 132165, 1024, 'image/tiff', '01142-01-038-006.tif', '70776c6bf8084592b0c464ca1082e385', 'c3ec5d7f-5745-4bbc-ae0e-a5128bae77fd', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 670
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x670
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:48:04.112931', '2012-10-16 13:48:04.267618', 'tif', 'image');
INSERT INTO media_files VALUES (51, 669, 151805, 1024, 'image/tiff', '01142-01-041-015.tif', '0d5e46f7705e47b4abe2df24e08007d2', '9422cc30-7446-49ff-8622-7a5d5f58bb90', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 669
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x669
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:47:56.292633', '2012-10-16 13:47:56.477765', 'tif', 'image');
INSERT INTO media_files VALUES (53, 768, 218484, 1024, 'image/jpeg', 'seerose_4.jpg', '37be15bc92cd45b79107f0a1fe932f89', '3ef25269-4dd6-416e-9cbf-524fcbd42a72', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 768
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:2 (2 1)
Composite:ImageSize: 1024x768
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: appl
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: appl
ICC-header:ProfileClass: Input Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: appl
ICC-header:ProfileDateTime: 2003:07:01 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.2.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.15662 0.08336 0.71953
ICC_Profile:ChromaticAdaptation: 1.04788 0.02292 -0.0502 0.02957 0.99049 -0.01706 -0.00923 0.01508 0.75165
ICC_Profile:GreenMatrixColumn: 0.35332 0.67441 0.09042
ICC_Profile:MediaWhitePoint: 0.95047 1 1.0891
ICC_Profile:ProfileDescription: Camera RGB Profile
ICC_Profile:ProfileDescriptionML: Camera RGB Profile
ICC_Profile:ProfileDescriptionML-da-DK: RGB-beskrivelse til Kamera
ICC_Profile:ProfileDescriptionML-de-DE: "RGB-Profil f\xC3\xBCr Kameras"
ICC_Profile:ProfileDescriptionML-es-ES: "Perfil RGB para C\xC3\xA1mara"
ICC_Profile:ProfileDescriptionML-fi-FI: Kameran RGB-profiili
ICC_Profile:ProfileDescriptionML-fr-FU: "Profil RVB de l\xE2\x80\x99appareil-photo"
ICC_Profile:ProfileDescriptionML-it-IT: Profilo RGB Fotocamera
ICC_Profile:ProfileDescriptionML-ja-JP: "\xE3\x82\xAB\xE3\x83\xA1\xE3\x83\xA9 RGB \xE3\x83\x97\xE3\x83\xAD\xE3\x83\x95\xE3\x82\xA1\xE3\x82\xA4\xE3\x83\xAB"
ICC_Profile:ProfileDescriptionML-ko-KR: "\xEC\xB9\xB4\xEB\xA9\x94\xEB\x9D\xBC RGB \xED\x94\x84\xEB\xA1\x9C\xED\x8C\x8C\xEC\x9D\xBC"
ICC_Profile:ProfileDescriptionML-nl-NL: RGB-profiel Camera
ICC_Profile:ProfileDescriptionML-no-NO: RGB-kameraprofil
ICC_Profile:ProfileDescriptionML-pt-BR: "Perfil RGB de C\xC3\xA2mera"
ICC_Profile:ProfileDescriptionML-sv-SE: "RGB-profil f\xC3\xB6r Kamera"
ICC_Profile:ProfileDescriptionML-zh-CN: "\xE7\x9B\xB8\xE6\x9C\xBA RGB \xE6\x8F\x8F\xE8\xBF\xB0\xE6\x96\x87\xE4\xBB\xB6"
ICC_Profile:ProfileDescriptionML-zh-TW: "\xE6\x95\xB8\xE4\xBD\x8D\xE7\x9B\xB8\xE6\xA9\x9F RGB \xE8\x89\xB2\xE5\xBD\xA9\xE6\x8F\x8F\xE8\xBF\xB0"
ICC_Profile:RedMatrixColumn: 0.45427 0.24263 0.01482
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:48:01.426794', '2012-10-16 13:48:01.715082', 'jpg', 'image');
INSERT INTO media_files VALUES (55, 672, 153910, 1024, 'image/tiff', '01142-01-041-013.tif', '2b68888c0bf14c96a77153feb312e07d', '83878cab-cf3c-4067-85cf-efb70469e21a', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 672
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x672
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:48:07.495769', '2012-10-16 13:48:07.647506', 'tif', 'image');
INSERT INTO media_files VALUES (56, 683, 431844, 1024, 'image/jpeg', 'glowing_oilsurface.jpg', '11df5179c244420daa7d2b3bbad7be71', '52a7dbd1-d7d2-464b-8d93-1bc5e0c9b346', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 683
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 1024x683
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:48:10.086895', '2012-10-16 13:48:10.280383', 'jpg', 'image');
INSERT INTO media_files VALUES (57, 683, 293742, 1024, 'image/tiff', 'Vernissage_MG_3657.tif', '29ede99b7a9d48e588daac4ae519dae8', '439c59b2-0c3f-49d7-b8cf-c40d5aa7505c', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 683
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x683
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:48:12.557282', '2012-10-16 13:48:12.705976', 'tif', 'image');
INSERT INTO media_files VALUES (1, 429, 96330, 640, 'image/jpeg', 'berlin_wall_01.jpg', '83d62ab97f1946e6ae2797af0576e0ce', '9f652d08-f3c6-4c67-aa46-eb40ca5b19ec', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 429
File:ImageWidth: 640
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 640x429
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 72
JFIF:YResolution: 72
', '2012-04-20 12:04:17', '2012-10-16 13:33:29.842653', 'jpg', 'image');
INSERT INTO media_files VALUES (2, 429, 96330, 640, 'image/jpeg', 'berlin_wall_01.jpg', '3682e9a5212b49a7927a5e197c7bb4a9', 'e0ba8d3e-ea81-4595-a167-3f83207bc7ed', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 429
File:ImageWidth: 640
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 640x429
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 72
JFIF:YResolution: 72
', '2012-04-20 12:04:18', '2012-10-16 13:33:29.848786', 'jpg', 'image');
INSERT INTO media_files VALUES (93, 668, 141537, 1024, 'image/tiff', 'Import_Export_MG_3919.tif', '2415e323a0634f3692cbdc42865f002d', '0b601ca1-835b-4cdf-b595-980479d19510', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 668
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x668
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:58:18.738647', '2012-10-16 13:58:18.979566', 'tif', 'image');
INSERT INTO media_files VALUES (59, 670, 165600, 1024, 'image/tiff', '01142-02-010-011.tif', '0a4db977dd6a40449518eb21fadf0faa', '6a1ed3a5-7155-494d-b7c6-8fa2f6a2488c', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 670
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x670
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:56:35.014567', '2012-10-16 13:56:35.225485', 'tif', 'image');
INSERT INTO media_files VALUES (3, 429, 96330, 640, 'image/jpeg', 'berlin_wall_01.jpg', '27462e6b17274d20b46b6652c6178d18', 'f285c39f-abad-405f-9c9d-b3ecbf1322f0', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 429
File:ImageWidth: 640
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 640x429
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 72
JFIF:YResolution: 72
', '2012-04-20 12:04:18', '2012-10-16 13:33:29.849734', 'jpg', 'image');
INSERT INTO media_files VALUES (4, 429, 96330, 640, 'image/jpeg', 'berlin_wall_01.jpg', '93df27ec55ae4c5aa394fe0d8161a35a', '51607bd7-5595-465e-ae44-f7900ac12f47', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 429
File:ImageWidth: 640
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 640x429
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 72
JFIF:YResolution: 72
', '2012-04-20 12:04:19', '2012-10-16 13:33:29.850554', 'jpg', 'image');
INSERT INTO media_files VALUES (5, 429, 96330, 640, 'image/jpeg', 'berlin_wall_01.jpg', 'de929612d8f9403d97e4f88c30087dca', '2df736d8-ba07-4c4f-b4a4-a51b9d8b3ebe', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 429
File:ImageWidth: 640
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 640x429
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 72
JFIF:YResolution: 72
', '2012-04-20 12:04:19', '2012-10-16 13:33:29.85134', 'jpg', 'image');
INSERT INTO media_files VALUES (6, 429, 96330, 640, 'image/jpeg', 'berlin_wall_01.jpg', '797417767e0744cb86cd32ffe5f06dda', 'b3657715-db00-4ec1-ba80-66891ab35b1d', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 429
File:ImageWidth: 640
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 640x429
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 72
JFIF:YResolution: 72
', '2012-04-20 12:04:20', '2012-10-16 13:33:29.852105', 'jpg', 'image');
INSERT INTO media_files VALUES (16, 375, 80603, 500, 'image/jpeg', 'gg_gps.jpg', 'd023b834979043b68400f2ce9f9529c0', 'c7132511-745e-44c3-9b4e-5e91987e629d', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:ExifByteOrder: Little-endian (Intel, II)
File:FileType: JPEG
File:ImageHeight: 375
File:ImageWidth: 500
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:Aperture: 4.5
Composite:CircleOfConfusion: 0.020 mm
Composite:FOV: 54.4 deg
Composite:FocalLength35efl: "23.3 mm (35 mm equivalent: 35.0 mm)"
Composite:GPSDateTime: 2003:11:23 18:07:37Z
Composite:GPSLatitude: 39.915556 N
Composite:GPSLongitude: 116.390833 E
Composite:GPSPosition: 39.915556 N, 116.390833 E
Composite:HyperfocalDistance: 6.04 m
Composite:ImageSize: 500x375
Composite:ScaleFactor35efl: 1.5
Composite:ShutterSpeed: 1/125
Composite:SubSecCreateDate: 2003:11:23 18:07:37.63
Composite:SubSecDateTimeOriginal: 2003:11:23 18:07:37.63
Composite:SubSecModifyDate: 2005:07:02 10:38:28.63
Composite:ThumbnailImage: (Binary data 4034 bytes)
ExifIFD:CFAPattern: "[Green,Blue][Red,Green]"
ExifIFD:ColorSpace: Uncalibrated
ExifIFD:CompressedBitsPerPixel: 4
ExifIFD:Contrast: Low
ExifIFD:CreateDate: 2003:11:23 18:07:37
ExifIFD:CustomRendered: Normal
ExifIFD:DateTimeOriginal: 2003:11:23 18:07:37
ExifIFD:DigitalZoomRatio: 1
ExifIFD:ExifImageHeight: 375
ExifIFD:ExifImageWidth: 500
ExifIFD:ExifVersion: "0220"
ExifIFD:ExposureCompensation: 0
ExifIFD:ExposureMode: Auto
ExifIFD:ExposureProgram: Aperture-priority AE
ExifIFD:ExposureTime: 1/125
ExifIFD:FNumber: 4.5
ExifIFD:FileSource: Digital Camera
ExifIFD:Flash: No Flash
ExifIFD:FlashpixVersion: "0100"
ExifIFD:FocalLength: 23.3 mm
ExifIFD:FocalLengthIn35mmFormat: 35 mm
ExifIFD:GainControl: Low gain up
ExifIFD:LightSource: Unknown
ExifIFD:MaxApertureValue: 2.8
ExifIFD:MeteringMode: Spot
ExifIFD:RelatedSoundFile: "            "
ExifIFD:Saturation: Normal
ExifIFD:SceneCaptureType: Standard
ExifIFD:SceneType: Directly photographed
ExifIFD:SensingMethod: One-chip color area
ExifIFD:Sharpness: Normal
ExifIFD:SubSecTime: 63
ExifIFD:SubSecTimeDigitized: 63
ExifIFD:SubSecTimeOriginal: 63
ExifIFD:SubjectDistanceRange: Unknown
ExifIFD:WhiteBalance: Auto
IFD0:Make: NIKON CORPORATION
IFD0:Model: NIKON D2H
IFD0:ModifyDate: 2005:07:02 10:38:28
IFD0:Orientation: Horizontal (normal)
IFD0:ResolutionUnit: inches
IFD0:Software: Opanda PowerExif
IFD0:XResolution: 256
IFD0:YResolution: 256
IFD1:Compression: JPEG (old-style)
IFD1:ResolutionUnit: inches
IFD1:ThumbnailLength: 4034
IFD1:ThumbnailOffset: 1118
IFD1:XResolution: 72
IFD1:YResolution: 72
XMP-xmpMM:DocumentID: adobe:docid:photoshop:48361733-eaa2-11d9-a6e9-a8189497d9c2
Photoshop:CopyrightFlag: false
Photoshop:DisplayedUnitsX: inches
Photoshop:DisplayedUnitsY: inches
Photoshop:GlobalAltitude: 30
Photoshop:GlobalAngle: 30
Photoshop:GridGuidesInfo: !binary |
  AAAAAQAAAkAAAAJAAAAAAA==

Photoshop:ICC_Untagged: !binary |
  AQ==

Photoshop:IDsBaseValue: !binary |
  AAAAAQ==

Photoshop:IPTCDigest: "00000000000000000000000000000000"
Photoshop:PhotoshopFormat: Standard
Photoshop:PhotoshopQuality: 8
Photoshop:PhotoshopThumbnail: (Binary data 4782 bytes)
Photoshop:PrintFlags: !binary |
  AAAAAAAAAAAB

Photoshop:PrintFlagsInfo: !binary |
  AAEAAAAAAAAAAg==

Photoshop:ProgressiveScans: 3 Scans
Photoshop:URL_List: !binary |
  AAAAAA==

Photoshop:VersionInfo: !binary |
  AAAAAQEAAAAPAEEAZABvAGIAZQAgAFAAaABvAHQAbwBzAGgAbwBwAAAAEwBB
  AGQAbwBiAGUAIABQAGgAbwB0AG8AcwBoAG8AcAAgADcALgAwAAAAAQ==

Photoshop:XResolution: 256
Photoshop:YResolution: 256
JFIF:JFIFVersion: 1.02
JFIF:ResolutionUnit: inches
JFIF:XResolution: 256
JFIF:YResolution: 256
GPS:GPSDateStamp: "2003:11:23"
GPS:GPSLatitude: 39.915556
GPS:GPSLatitudeRef: North
GPS:GPSLongitude: 116.390833
GPS:GPSLongitudeRef: East
GPS:GPSTimeStamp: "18:07:37"
GPS:GPSVersionID: 2.2.0.0
', '2012-04-20 12:04:24', '2012-10-16 13:33:29.858354', 'jpg', 'image');
INSERT INTO media_files VALUES (61, 675, 188738, 1024, 'image/tiff', '01142-01-038-016.tif', 'b5c3c220239f4c6380ecac0e184563ed', 'b9113fdb-fae8-4171-83bd-6ba96773c9c0', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 675
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x675
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:56:41.675179', '2012-10-16 13:56:41.874385', 'tif', 'image');
INSERT INTO media_files VALUES (62, 768, 93203, 545, 'image/jpeg', '03_Magie_der_Dinge.jpg', 'd5208d0eb97a48ebb8c43bac5924cf11', '14b4a387-cce8-4beb-a573-f93fcf291015', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 768
File:ImageWidth: 545
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 545x768
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: "IEC "
ICC-header:DeviceModel: sRGB
ICC-header:PrimaryPlatform: Microsoft Corporation
ICC-header:ProfileCMMType: Lino
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: "HP  "
ICC-header:ProfileDateTime: 1998:02:09 06:49:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Media-Relative Colorimetric
ICC-meas:MeasurementBacking: 0 0 0
ICC-meas:MeasurementFlare: 0.999%
ICC-meas:MeasurementGeometry: Unknown (0)
ICC-meas:MeasurementIlluminant: D65
ICC-meas:MeasurementObserver: CIE 1931
ICC-view:ViewingCondIlluminant: 19.6445 20.3718 16.8089
ICC-view:ViewingCondIlluminantType: D50
ICC-view:ViewingCondSurround: 3.92889 4.07439 3.36179
ICC_Profile:BlueMatrixColumn: 0.14307 0.06061 0.7141
ICC_Profile:DeviceMfgDesc: IEC http://www.iec.ch
ICC_Profile:DeviceModelDesc: IEC 61966-2.1 Default RGB colour space - sRGB
ICC_Profile:GreenMatrixColumn: 0.38515 0.71687 0.09708
ICC_Profile:Luminance: 76.03647 80 87.12462
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: sRGB IEC61966-2.1
ICC_Profile:RedMatrixColumn: 0.43607 0.22249 0.01392
ICC_Profile:Technology: Cathode Ray Tube Display
ICC_Profile:ViewingCondDesc: Reference Viewing Condition in IEC61966-2.1
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:56:44.668863', '2012-10-16 13:56:44.904303', 'jpg', 'image');
INSERT INTO media_files VALUES (7, 429, 96330, 640, 'image/jpeg', 'berlin_wall_01.jpg', 'd7eedd16bbcb4bccb38fec9d94a5edb3', 'ed220124-8e75-448a-aec0-9b4ed1200fe9', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 429
File:ImageWidth: 640
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 640x429
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 72
JFIF:YResolution: 72
', '2012-04-20 12:04:20', '2012-10-16 13:33:29.852905', 'jpg', 'image');
INSERT INTO media_files VALUES (8, 429, 96330, 640, 'image/jpeg', 'berlin_wall_01.jpg', '91129f3af6ef4431bfa3691ae440ac56', 'c17de0aa-2db7-4880-9a59-eb23765610c3', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 429
File:ImageWidth: 640
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 640x429
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 72
JFIF:YResolution: 72
', '2012-04-20 12:04:21', '2012-10-16 13:33:29.853994', 'jpg', 'image');
INSERT INTO media_files VALUES (9, 429, 96330, 640, 'image/jpeg', 'berlin_wall_01.jpg', 'efa28250a9234a6e9a6c98215497212e', '75bf464a-86b1-43d3-b50b-46a5f9994630', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 429
File:ImageWidth: 640
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 640x429
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 72
JFIF:YResolution: 72
', '2012-04-20 12:04:21', '2012-10-16 13:33:29.854817', 'jpg', 'image');
INSERT INTO media_files VALUES (11, 429, 96330, 640, 'image/jpeg', 'berlin_wall_01.jpg', '00e09e95462e45ecb8f18b8f8b6af9c8', '5e3589b1-a465-437b-9595-2fa2c7b57631', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 429
File:ImageWidth: 640
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 640x429
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 72
JFIF:YResolution: 72
', '2012-04-20 12:04:22', '2012-10-16 13:33:29.856392', 'jpg', 'image');
INSERT INTO media_files VALUES (13, 429, 96330, 640, 'image/jpeg', 'berlin_wall_01.jpg', '541786d3aee34e9c886c0d89468e15a3', '599ab05a-fb38-40c2-a4f4-eb1b7dd37fcc', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 429
File:ImageWidth: 640
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 640x429
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 72
JFIF:YResolution: 72
', '2012-04-20 12:04:23', '2012-10-16 13:33:29.859144', 'jpg', 'image');
INSERT INTO media_files VALUES (14, 429, 96330, 640, 'image/jpeg', 'berlin_wall_01.jpg', 'c34ef180441d486397779528617c4d86', '7f087415-a888-4674-a127-23644f475d32', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 429
File:ImageWidth: 640
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 640x429
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 72
JFIF:YResolution: 72
', '2012-04-20 12:04:23', '2012-10-16 13:33:29.859927', 'jpg', 'image');
INSERT INTO media_files VALUES (15, 429, 96330, 640, 'image/jpeg', 'berlin_wall_01.jpg', '7006f71d28934c83b16192787d6066a7', '24933ff8-aa5f-4f63-b826-256c667db252', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 429
File:ImageWidth: 640
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 640x429
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 72
JFIF:YResolution: 72
', '2012-04-20 12:04:24', '2012-10-16 13:33:29.860719', 'jpg', 'image');
INSERT INTO media_files VALUES (19, 500, 379540, 531, 'image/jpeg', 'Deutzer+Hafen.jpg', '03c6836c3a5f4bada4bbcb9ea6a49ba0', 'fac9bde1-dd39-4951-b5a9-1fe68334bbaf', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 500
File:ImageWidth: 531
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 531x500
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 240
JFIF:YResolution: 240
', '2012-08-31 09:18:00', '2012-10-16 13:33:29.861555', 'jpg', 'image');
INSERT INTO media_files VALUES (21, 500, 254954, 401, 'image/jpeg', 'virginandchild.jpg', '04a2654076114099af6c372e80983612', '64bb62d2-07de-415b-8bf3-3c20075fa7a4', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 500
File:ImageWidth: 401
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 401x500
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 72
JFIF:YResolution: 72
', '2012-08-31 12:00:05', '2012-10-16 13:33:29.862356', 'jpg', 'image');
INSERT INTO media_files VALUES (23, 768, 439215, 1024, 'image/jpeg', 'Bild1col.JPG', '9d26effa26e4406c8613f0093085d175', 'c5c0fd5c-52b4-4702-af5b-02001a22ccfd', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 768
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:2 (2 1)
Composite:ImageSize: 1024x768
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: appl
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: appl
ICC-header:ProfileClass: Input Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: appl
ICC-header:ProfileDateTime: 2003:07:01 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.2.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.15662 0.08336 0.71953
ICC_Profile:ChromaticAdaptation: 1.04788 0.02292 -0.0502 0.02957 0.99049 -0.01706 -0.00923 0.01508 0.75165
ICC_Profile:GreenMatrixColumn: 0.35332 0.67441 0.09042
ICC_Profile:MediaWhitePoint: 0.95047 1 1.0891
ICC_Profile:ProfileDescription: Camera RGB Profile
ICC_Profile:ProfileDescriptionML: Camera RGB Profile
ICC_Profile:ProfileDescriptionML-da-DK: RGB-beskrivelse til Kamera
ICC_Profile:ProfileDescriptionML-de-DE: "RGB-Profil f\xC3\xBCr Kameras"
ICC_Profile:ProfileDescriptionML-es-ES: "Perfil RGB para C\xC3\xA1mara"
ICC_Profile:ProfileDescriptionML-fi-FI: Kameran RGB-profiili
ICC_Profile:ProfileDescriptionML-fr-FU: "Profil RVB de l\xE2\x80\x99appareil-photo"
ICC_Profile:ProfileDescriptionML-it-IT: Profilo RGB Fotocamera
ICC_Profile:ProfileDescriptionML-ja-JP: "\xE3\x82\xAB\xE3\x83\xA1\xE3\x83\xA9 RGB \xE3\x83\x97\xE3\x83\xAD\xE3\x83\x95\xE3\x82\xA1\xE3\x82\xA4\xE3\x83\xAB"
ICC_Profile:ProfileDescriptionML-ko-KR: "\xEC\xB9\xB4\xEB\xA9\x94\xEB\x9D\xBC RGB \xED\x94\x84\xEB\xA1\x9C\xED\x8C\x8C\xEC\x9D\xBC"
ICC_Profile:ProfileDescriptionML-nl-NL: RGB-profiel Camera
ICC_Profile:ProfileDescriptionML-no-NO: RGB-kameraprofil
ICC_Profile:ProfileDescriptionML-pt-BR: "Perfil RGB de C\xC3\xA2mera"
ICC_Profile:ProfileDescriptionML-sv-SE: "RGB-profil f\xC3\xB6r Kamera"
ICC_Profile:ProfileDescriptionML-zh-CN: "\xE7\x9B\xB8\xE6\x9C\xBA RGB \xE6\x8F\x8F\xE8\xBF\xB0\xE6\x96\x87\xE4\xBB\xB6"
ICC_Profile:ProfileDescriptionML-zh-TW: "\xE6\x95\xB8\xE4\xBD\x8D\xE7\x9B\xB8\xE6\xA9\x9F RGB \xE8\x89\xB2\xE5\xBD\xA9\xE6\x8F\x8F\xE8\xBF\xB0"
ICC_Profile:RedMatrixColumn: 0.45427 0.24263 0.01482
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 180
JFIF:YResolution: 180
', '2012-10-16 13:28:23.695668', '2012-10-16 13:33:29.863164', 'jpg', 'image');
INSERT INTO media_files VALUES (22, 768, 336099, 1024, 'image/jpeg', 'IMG_0143.JPG', '0e7735f32d6e4c1a898287d211f3a846', 'cfb7f656-1f53-45db-8f06-24bd6b38507b', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 768
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:2 (2 1)
Composite:ImageSize: 1024x768
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: appl
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: appl
ICC-header:ProfileClass: Input Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: appl
ICC-header:ProfileDateTime: 2003:07:01 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.2.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.15662 0.08336 0.71953
ICC_Profile:ChromaticAdaptation: 1.04788 0.02292 -0.0502 0.02957 0.99049 -0.01706 -0.00923 0.01508 0.75165
ICC_Profile:GreenMatrixColumn: 0.35332 0.67441 0.09042
ICC_Profile:MediaWhitePoint: 0.95047 1 1.0891
ICC_Profile:ProfileDescription: Camera RGB Profile
ICC_Profile:ProfileDescriptionML: Camera RGB Profile
ICC_Profile:ProfileDescriptionML-da-DK: RGB-beskrivelse til Kamera
ICC_Profile:ProfileDescriptionML-de-DE: "RGB-Profil f\xC3\xBCr Kameras"
ICC_Profile:ProfileDescriptionML-es-ES: "Perfil RGB para C\xC3\xA1mara"
ICC_Profile:ProfileDescriptionML-fi-FI: Kameran RGB-profiili
ICC_Profile:ProfileDescriptionML-fr-FU: "Profil RVB de l\xE2\x80\x99appareil-photo"
ICC_Profile:ProfileDescriptionML-it-IT: Profilo RGB Fotocamera
ICC_Profile:ProfileDescriptionML-ja-JP: "\xE3\x82\xAB\xE3\x83\xA1\xE3\x83\xA9 RGB \xE3\x83\x97\xE3\x83\xAD\xE3\x83\x95\xE3\x82\xA1\xE3\x82\xA4\xE3\x83\xAB"
ICC_Profile:ProfileDescriptionML-ko-KR: "\xEC\xB9\xB4\xEB\xA9\x94\xEB\x9D\xBC RGB \xED\x94\x84\xEB\xA1\x9C\xED\x8C\x8C\xEC\x9D\xBC"
ICC_Profile:ProfileDescriptionML-nl-NL: RGB-profiel Camera
ICC_Profile:ProfileDescriptionML-no-NO: RGB-kameraprofil
ICC_Profile:ProfileDescriptionML-pt-BR: "Perfil RGB de C\xC3\xA2mera"
ICC_Profile:ProfileDescriptionML-sv-SE: "RGB-profil f\xC3\xB6r Kamera"
ICC_Profile:ProfileDescriptionML-zh-CN: "\xE7\x9B\xB8\xE6\x9C\xBA RGB \xE6\x8F\x8F\xE8\xBF\xB0\xE6\x96\x87\xE4\xBB\xB6"
ICC_Profile:ProfileDescriptionML-zh-TW: "\xE6\x95\xB8\xE4\xBD\x8D\xE7\x9B\xB8\xE6\xA9\x9F RGB \xE8\x89\xB2\xE5\xBD\xA9\xE6\x8F\x8F\xE8\xBF\xB0"
ICC_Profile:RedMatrixColumn: 0.45427 0.24263 0.01482
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 180
JFIF:YResolution: 180
', '2012-10-16 13:28:21.025527', '2012-10-16 13:33:29.863989', 'jpg', 'image');
INSERT INTO media_files VALUES (107, NULL, 3775767, NULL, 'application/octet-stream', 'Arabic+Calligraphy+Relif+Golden', '21187505bf984b6b9a4203f539700dd1', 'b5262c58-5c16-4cc2-a1b4-373624c737a2', '--- {}

', '2012-11-07 16:38:47.057092', '2012-11-07 16:38:47.057092', '', 'document');
INSERT INTO media_files VALUES (24, 675, 188738, 1024, 'image/tiff', '01142-01-038-016.tif', 'e9e1671708bf436e840d7845c7aebc54', '04b312f9-56ad-4aef-9fc3-1d7cc237541a', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 675
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x675
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:46:50.812354', '2012-10-16 13:46:50.995331', 'tif', 'image');
INSERT INTO media_files VALUES (63, 768, 64941, 502, 'image/tiff', '01142-02-013-006.tif', '804b755ab83647dfa07908970ac6cdf2', 'a6a7696c-bc40-4058-8305-406d40ac6ac6', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 768
File:ImageWidth: 502
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 502x768
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:56:47.404583', '2012-10-16 13:56:47.627079', 'tif', 'image');
INSERT INTO media_files VALUES (41, 717, 787985, 1024, 'image/jpeg', 'OIL_PIPELINE_EXPLOSION_2005%281%29.jpg', 'c3093da902a94905a55c94bc3c921285', '3cb646ca-66dc-464e-beb4-b343e86351ab', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 717
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 1024x717
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:47:33.241289', '2012-10-16 13:47:33.403678', 'jpg', 'image');
INSERT INTO media_files VALUES (31, 768, 168733, 621, 'image/tiff', '01142-01-041-005.tif', '9234595eca5646a695afa32e91049490', '80960c45-ecba-4ff6-9453-41d1df4a6bbc', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 768
File:ImageWidth: 621
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 621x768
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:47:09.172062', '2012-10-16 13:47:09.421481', 'tif', 'image');
INSERT INTO media_files VALUES (29, 675, 188362, 1024, 'image/tiff', '01142-01-038-012.tif', 'b46f64181b4a418c9ed2a8101dda2efa', '9c6f2540-7511-4d20-8b3e-f83be0e427a5', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 675
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x675
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:47:03.627652', '2012-10-16 13:47:03.785005', 'tif', 'image');
INSERT INTO media_files VALUES (30, 683, 683051, 1024, 'image/jpeg', 'militant_group.jpg', '1408c123b58f4d4cb6476218ec885a16', 'd63ab7fe-3299-4c8c-8c45-40e73657f4d7', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 683
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 1024x683
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 350
JFIF:YResolution: 350
', '2012-10-16 13:47:06.420811', '2012-10-16 13:47:06.67042', 'jpg', 'image');
INSERT INTO media_files VALUES (64, NULL, 169045, NULL, 'application/pdf', 'PORT-AP-KO-E02-03-SAB-N.13-b.pdf', '2a586fcf60e74affa2770f9200722d5a', '8dd8542d-71c6-4737-a115-1bc733996079', '--- {}

', '2012-10-16 13:56:50.453122', '2012-10-16 13:56:50.453122', 'pdf', 'document');
INSERT INTO media_files VALUES (33, 717, 787985, 1024, 'image/jpeg', 'OIL_PIPELINE_EXPLOSION_2005.jpg', '9f4813805e5d44c987f3a730b959d3ea', 'ce9e4265-7436-470b-9f30-da2e94195c53', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 717
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 1024x717
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:47:14.180187', '2012-10-16 13:47:14.42371', 'jpg', 'image');
INSERT INTO media_files VALUES (65, 675, 188362, 1024, 'image/tiff', '01142-01-038-012.tif', '9d52c9a6ff5b4eada7c489b3e2a6111b', '9c2839ce-d5ab-4f10-9097-d91fb0fa023d', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 675
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x675
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:56:52.892865', '2012-10-16 13:56:53.120323', 'tif', 'image');
INSERT INTO media_files VALUES (66, 683, 683051, 1024, 'image/jpeg', 'militant_group.jpg', '9312b221582c4c67b86745e3769bbc0b', 'c09278ac-4349-4349-bc78-d6d75d0f7da2', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 683
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 1024x683
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 350
JFIF:YResolution: 350
', '2012-10-16 13:56:55.921711', '2012-10-16 13:56:56.114971', 'jpg', 'image');
INSERT INTO media_files VALUES (36, 768, 439215, 1024, 'image/jpeg', 'Bild1col.JPG', '90a43903d1704d21a54f6002815401b3', '85b77af5-c7f1-4b62-9169-62609e06884f', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 768
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:2 (2 1)
Composite:ImageSize: 1024x768
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: appl
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: appl
ICC-header:ProfileClass: Input Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: appl
ICC-header:ProfileDateTime: 2003:07:01 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.2.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.15662 0.08336 0.71953
ICC_Profile:ChromaticAdaptation: 1.04788 0.02292 -0.0502 0.02957 0.99049 -0.01706 -0.00923 0.01508 0.75165
ICC_Profile:GreenMatrixColumn: 0.35332 0.67441 0.09042
ICC_Profile:MediaWhitePoint: 0.95047 1 1.0891
ICC_Profile:ProfileDescription: Camera RGB Profile
ICC_Profile:ProfileDescriptionML: Camera RGB Profile
ICC_Profile:ProfileDescriptionML-da-DK: RGB-beskrivelse til Kamera
ICC_Profile:ProfileDescriptionML-de-DE: "RGB-Profil f\xC3\xBCr Kameras"
ICC_Profile:ProfileDescriptionML-es-ES: "Perfil RGB para C\xC3\xA1mara"
ICC_Profile:ProfileDescriptionML-fi-FI: Kameran RGB-profiili
ICC_Profile:ProfileDescriptionML-fr-FU: "Profil RVB de l\xE2\x80\x99appareil-photo"
ICC_Profile:ProfileDescriptionML-it-IT: Profilo RGB Fotocamera
ICC_Profile:ProfileDescriptionML-ja-JP: "\xE3\x82\xAB\xE3\x83\xA1\xE3\x83\xA9 RGB \xE3\x83\x97\xE3\x83\xAD\xE3\x83\x95\xE3\x82\xA1\xE3\x82\xA4\xE3\x83\xAB"
ICC_Profile:ProfileDescriptionML-ko-KR: "\xEC\xB9\xB4\xEB\xA9\x94\xEB\x9D\xBC RGB \xED\x94\x84\xEB\xA1\x9C\xED\x8C\x8C\xEC\x9D\xBC"
ICC_Profile:ProfileDescriptionML-nl-NL: RGB-profiel Camera
ICC_Profile:ProfileDescriptionML-no-NO: RGB-kameraprofil
ICC_Profile:ProfileDescriptionML-pt-BR: "Perfil RGB de C\xC3\xA2mera"
ICC_Profile:ProfileDescriptionML-sv-SE: "RGB-profil f\xC3\xB6r Kamera"
ICC_Profile:ProfileDescriptionML-zh-CN: "\xE7\x9B\xB8\xE6\x9C\xBA RGB \xE6\x8F\x8F\xE8\xBF\xB0\xE6\x96\x87\xE4\xBB\xB6"
ICC_Profile:ProfileDescriptionML-zh-TW: "\xE6\x95\xB8\xE4\xBD\x8D\xE7\x9B\xB8\xE6\xA9\x9F RGB \xE8\x89\xB2\xE5\xBD\xA9\xE6\x8F\x8F\xE8\xBF\xB0"
ICC_Profile:RedMatrixColumn: 0.45427 0.24263 0.01482
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 180
JFIF:YResolution: 180
', '2012-10-16 13:47:21.021806', '2012-10-16 13:47:21.255192', 'jpg', 'image');
INSERT INTO media_files VALUES (67, 768, 168733, 621, 'image/tiff', '01142-01-041-005.tif', '90b268ef4efd40d4b2679019985ef1f2', '3060972c-88b0-409a-b243-0756c732c6d6', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 768
File:ImageWidth: 621
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 621x768
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:56:59.364199', '2012-10-16 13:56:59.586092', 'tif', 'image');
INSERT INTO media_files VALUES (37, 768, 336099, 1024, 'image/jpeg', 'IMG_0143.JPG', '33d7abf0674e44e385b1274fa584a661', '39b171e0-a03a-41d1-8153-1fb18e4c9683', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 768
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:2 (2 1)
Composite:ImageSize: 1024x768
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: appl
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: appl
ICC-header:ProfileClass: Input Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: appl
ICC-header:ProfileDateTime: 2003:07:01 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.2.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.15662 0.08336 0.71953
ICC_Profile:ChromaticAdaptation: 1.04788 0.02292 -0.0502 0.02957 0.99049 -0.01706 -0.00923 0.01508 0.75165
ICC_Profile:GreenMatrixColumn: 0.35332 0.67441 0.09042
ICC_Profile:MediaWhitePoint: 0.95047 1 1.0891
ICC_Profile:ProfileDescription: Camera RGB Profile
ICC_Profile:ProfileDescriptionML: Camera RGB Profile
ICC_Profile:ProfileDescriptionML-da-DK: RGB-beskrivelse til Kamera
ICC_Profile:ProfileDescriptionML-de-DE: "RGB-Profil f\xC3\xBCr Kameras"
ICC_Profile:ProfileDescriptionML-es-ES: "Perfil RGB para C\xC3\xA1mara"
ICC_Profile:ProfileDescriptionML-fi-FI: Kameran RGB-profiili
ICC_Profile:ProfileDescriptionML-fr-FU: "Profil RVB de l\xE2\x80\x99appareil-photo"
ICC_Profile:ProfileDescriptionML-it-IT: Profilo RGB Fotocamera
ICC_Profile:ProfileDescriptionML-ja-JP: "\xE3\x82\xAB\xE3\x83\xA1\xE3\x83\xA9 RGB \xE3\x83\x97\xE3\x83\xAD\xE3\x83\x95\xE3\x82\xA1\xE3\x82\xA4\xE3\x83\xAB"
ICC_Profile:ProfileDescriptionML-ko-KR: "\xEC\xB9\xB4\xEB\xA9\x94\xEB\x9D\xBC RGB \xED\x94\x84\xEB\xA1\x9C\xED\x8C\x8C\xEC\x9D\xBC"
ICC_Profile:ProfileDescriptionML-nl-NL: RGB-profiel Camera
ICC_Profile:ProfileDescriptionML-no-NO: RGB-kameraprofil
ICC_Profile:ProfileDescriptionML-pt-BR: "Perfil RGB de C\xC3\xA2mera"
ICC_Profile:ProfileDescriptionML-sv-SE: "RGB-profil f\xC3\xB6r Kamera"
ICC_Profile:ProfileDescriptionML-zh-CN: "\xE7\x9B\xB8\xE6\x9C\xBA RGB \xE6\x8F\x8F\xE8\xBF\xB0\xE6\x96\x87\xE4\xBB\xB6"
ICC_Profile:ProfileDescriptionML-zh-TW: "\xE6\x95\xB8\xE4\xBD\x8D\xE7\x9B\xB8\xE6\xA9\x9F RGB \xE8\x89\xB2\xE5\xBD\xA9\xE6\x8F\x8F\xE8\xBF\xB0"
ICC_Profile:RedMatrixColumn: 0.45427 0.24263 0.01482
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 180
JFIF:YResolution: 180
', '2012-10-16 13:47:23.650486', '2012-10-16 13:47:23.908245', 'jpg', 'image');
INSERT INTO media_files VALUES (68, 717, 787985, 1024, 'image/jpeg', 'OIL_PIPELINE_EXPLOSION_2005.jpg', '507e5b3acf4341858fc3ac116f1f9691', 'cd523a8a-84db-43f5-980a-d4ade6ccf2cf', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 717
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 1024x717
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:57:02.484402', '2012-10-16 13:57:02.691531', 'jpg', 'image');
INSERT INTO media_files VALUES (38, 768, 288846, 952, 'image/tiff', '01142-01-041-004.tif', 'c96fde7621df4cf6a46f788ce654bc10', '249f565d-72f2-4f7d-85bf-d9cb3854b990', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 768
File:ImageWidth: 952
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 952x768
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:47:26.363871', '2012-10-16 13:47:26.525151', 'tif', 'image');
INSERT INTO media_files VALUES (40, 683, 186954, 1024, 'image/tiff', 'Leo_MG_3686.tif', 'd7477bb1ec664c4eb6109f9b430856ec', '1c58d72b-9cff-4093-8861-8d4b6138710c', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 683
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x683
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:47:31.008677', '2012-10-16 13:47:31.177373', 'tif', 'image');
INSERT INTO media_files VALUES (42, 682, 565382, 1024, 'image/jpeg', '_DSC4500.jpg', 'c2d513ef39564e7f91a3be00fe862660', 'b12789fc-874d-4c03-b174-f8f256476790', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 682
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 1024x682
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:47:35.708353', '2012-10-16 13:47:35.885835', 'jpg', 'image');
INSERT INTO media_files VALUES (43, 768, 246211, 961, 'image/tiff', '01142-01-041-002.tif', '0e0cd049407e4491b75a0afd5bc7b9d9', '811fb60c-0d07-4ad0-baa1-64c56a882c34', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 768
File:ImageWidth: 961
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 961x768
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:47:37.855512', '2012-10-16 13:47:38.032508', 'tif', 'image');
INSERT INTO media_files VALUES (44, 768, 192911, 1024, 'image/jpeg', 'Krohn_2.jpg', '72d5719b1c1c4264932519dec70e7113', 'bbfd4e2a-796a-4c7f-af0b-7c2a907e09f0', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 768
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:2 (2 1)
Composite:ImageSize: 1024x768
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 180
JFIF:YResolution: 180
', '2012-10-16 13:47:40.373892', '2012-10-16 13:47:40.552394', 'jpg', 'image');
INSERT INTO media_files VALUES (45, 706, 192506, 1024, 'image/tiff', 'Treier_MG_3882.tif', 'df2d6c7e54654961bea8b45f286eb2dd', '3ac40f29-22ca-4f19-a210-dd9d903ba56d', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 706
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x706
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:47:42.696905', '2012-10-16 13:47:42.876962', 'tif', 'image');
INSERT INTO media_files VALUES (74, 768, 288846, 952, 'image/tiff', '01142-01-041-004.tif', 'fc57d96b85ca4b9ebf96d460efcc9dba', '45cbb64c-1dcf-464d-adf4-8e95bbf2b865', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 768
File:ImageWidth: 952
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 952x768
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:57:21.178654', '2012-10-16 13:57:21.379125', 'tif', 'image');
INSERT INTO media_files VALUES (47, 668, 180824, 1024, 'image/tiff', '01142-01-041-014.tif', '212c4cf6bcdf47a9a5a80cfde870b2de', '5ef35be7-c6bb-4a9b-944c-0ef383fcfc3d', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 668
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x668
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:47:47.233289', '2012-10-16 13:47:47.393381', 'tif', 'image');
INSERT INTO media_files VALUES (77, 682, 565382, 1024, 'image/jpeg', '_DSC4500.jpg', 'a04e6ca0c0824050abd7c52990d4ecec', '9b645af9-f051-4460-ba2b-72e3e7040514', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 682
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 1024x682
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:57:30.634941', '2012-10-16 13:57:30.843695', 'jpg', 'image');
INSERT INTO media_files VALUES (48, 617, 665837, 1024, 'image/jpeg', 'Kennel.jpg', 'a4b49df933564b3c93f34c186be5909e', '6d463b54-f777-4d75-bd8a-4bbab7a2a68c', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 617
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 1024x617
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: "IEC "
ICC-header:DeviceModel: sRGB
ICC-header:PrimaryPlatform: Microsoft Corporation
ICC-header:ProfileCMMType: Lino
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: "HP  "
ICC-header:ProfileDateTime: 1998:02:09 06:49:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC-meas:MeasurementBacking: 0 0 0
ICC-meas:MeasurementFlare: 0.999%
ICC-meas:MeasurementGeometry: Unknown (0)
ICC-meas:MeasurementIlluminant: D65
ICC-meas:MeasurementObserver: CIE 1931
ICC-view:ViewingCondIlluminant: 19.6445 20.3718 16.8089
ICC-view:ViewingCondIlluminantType: D50
ICC-view:ViewingCondSurround: 3.92889 4.07439 3.36179
ICC_Profile:BlueMatrixColumn: 0.14307 0.06061 0.7141
ICC_Profile:DeviceMfgDesc: IEC http://www.iec.ch
ICC_Profile:DeviceModelDesc: IEC 61966-2.1 Default RGB colour space - sRGB
ICC_Profile:GreenMatrixColumn: 0.38515 0.71687 0.09708
ICC_Profile:Luminance: 76.03647 80 87.12462
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: sRGB IEC61966-2.1
ICC_Profile:RedMatrixColumn: 0.43607 0.22249 0.01392
ICC_Profile:Technology: Cathode Ray Tube Display
ICC_Profile:ViewingCondDesc: Reference Viewing Condition in IEC61966-2.1
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:47:49.388095', '2012-10-16 13:47:49.543088', 'jpg', 'image');
INSERT INTO media_files VALUES (49, 699, 160352, 1024, 'image/tiff', 'Kistler_MG_3861.tif', '909b5d475a714bbbbbdd575cda814c28', 'edfe519f-a1ef-43c9-bb6e-ec45f846a2dc', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 699
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x699
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:47:51.842942', '2012-10-16 13:47:52.026191', 'tif', 'image');
INSERT INTO media_files VALUES (76, 717, 787985, 1024, 'image/jpeg', 'OIL_PIPELINE_EXPLOSION_2005%281%29.jpg', '1c367cc8e2f849158cdd940017d14943', 'd1ccf4a9-7ae3-40d9-90b7-98962e443596', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 717
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 1024x717
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:57:27.500235', '2012-10-16 13:57:27.662096', 'jpg', 'image');
INSERT INTO media_files VALUES (78, 768, 246211, 961, 'image/tiff', '01142-01-041-002.tif', 'ad42a43b63574c48bfe9977a2fa54c41', '6daa80cc-d5fa-4f89-8f57-6fd50b922ccf', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 768
File:ImageWidth: 961
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 961x768
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:57:33.702735', '2012-10-16 13:57:33.903912', 'tif', 'image');
INSERT INTO media_files VALUES (81, 668, 180824, 1024, 'image/tiff', '01142-01-041-014.tif', '8170d52fb27745b299da78b6298ff144', '375af22f-9248-4b78-8ed1-1726c8f84257', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 668
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x668
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:57:42.487302', '2012-10-16 13:57:42.664842', 'tif', 'image');
INSERT INTO media_files VALUES (79, 768, 192911, 1024, 'image/jpeg', 'Krohn_2.jpg', '42b8ac3bd7b646d182017670dba9fad0', 'ff33b7b3-cb10-4472-94b5-d1450bee331e', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 768
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:2 (2 1)
Composite:ImageSize: 1024x768
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 180
JFIF:YResolution: 180
', '2012-10-16 13:57:36.780418', '2012-10-16 13:57:36.927717', 'jpg', 'image');
INSERT INTO media_files VALUES (82, 617, 665837, 1024, 'image/jpeg', 'Kennel.jpg', 'cefa87582fd04711b6b79443663df3be', 'f09ee7a4-3011-45cf-8e13-da5f2fa41f70', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 617
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 1024x617
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: "IEC "
ICC-header:DeviceModel: sRGB
ICC-header:PrimaryPlatform: Microsoft Corporation
ICC-header:ProfileCMMType: Lino
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: "HP  "
ICC-header:ProfileDateTime: 1998:02:09 06:49:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC-meas:MeasurementBacking: 0 0 0
ICC-meas:MeasurementFlare: 0.999%
ICC-meas:MeasurementGeometry: Unknown (0)
ICC-meas:MeasurementIlluminant: D65
ICC-meas:MeasurementObserver: CIE 1931
ICC-view:ViewingCondIlluminant: 19.6445 20.3718 16.8089
ICC-view:ViewingCondIlluminantType: D50
ICC-view:ViewingCondSurround: 3.92889 4.07439 3.36179
ICC_Profile:BlueMatrixColumn: 0.14307 0.06061 0.7141
ICC_Profile:DeviceMfgDesc: IEC http://www.iec.ch
ICC_Profile:DeviceModelDesc: IEC 61966-2.1 Default RGB colour space - sRGB
ICC_Profile:GreenMatrixColumn: 0.38515 0.71687 0.09708
ICC_Profile:Luminance: 76.03647 80 87.12462
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: sRGB IEC61966-2.1
ICC_Profile:RedMatrixColumn: 0.43607 0.22249 0.01392
ICC_Profile:Technology: Cathode Ray Tube Display
ICC_Profile:ViewingCondDesc: Reference Viewing Condition in IEC61966-2.1
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:57:45.449375', '2012-10-16 13:57:45.655549', 'jpg', 'image');
INSERT INTO media_files VALUES (86, 683, 186954, 1024, 'image/tiff', 'Leo_MG_3686.tif', '70def7abbb32428489befa4578205984', '84f0fdcc-8628-44eb-bf3c-237ff316fa42', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 683
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x683
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:57:57.882157', '2012-10-16 13:57:58.179882', 'tif', 'image');
INSERT INTO media_files VALUES (84, 669, 151805, 1024, 'image/tiff', '01142-01-041-015.tif', 'dbfb300edaa04bcd960cebeec0c46bc3', '62ba5c76-ffe0-455e-9548-7f1cf1e08a1f', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 669
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x669
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:57:51.614252', '2012-10-16 13:57:51.827944', 'tif', 'image');
INSERT INTO media_files VALUES (85, 768, 336099, 1024, 'image/jpeg', 'IMG_0143.JPG', '7d9de7c4b3a542b7985add2ad385d1f6', 'ce5dfdae-90ed-4012-b952-c6bfef6d13a6', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 768
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:2 (2 1)
Composite:ImageSize: 1024x768
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: appl
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: appl
ICC-header:ProfileClass: Input Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: appl
ICC-header:ProfileDateTime: 2003:07:01 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.2.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.15662 0.08336 0.71953
ICC_Profile:ChromaticAdaptation: 1.04788 0.02292 -0.0502 0.02957 0.99049 -0.01706 -0.00923 0.01508 0.75165
ICC_Profile:GreenMatrixColumn: 0.35332 0.67441 0.09042
ICC_Profile:MediaWhitePoint: 0.95047 1 1.0891
ICC_Profile:ProfileDescription: Camera RGB Profile
ICC_Profile:ProfileDescriptionML: Camera RGB Profile
ICC_Profile:ProfileDescriptionML-da-DK: RGB-beskrivelse til Kamera
ICC_Profile:ProfileDescriptionML-de-DE: "RGB-Profil f\xC3\xBCr Kameras"
ICC_Profile:ProfileDescriptionML-es-ES: "Perfil RGB para C\xC3\xA1mara"
ICC_Profile:ProfileDescriptionML-fi-FI: Kameran RGB-profiili
ICC_Profile:ProfileDescriptionML-fr-FU: "Profil RVB de l\xE2\x80\x99appareil-photo"
ICC_Profile:ProfileDescriptionML-it-IT: Profilo RGB Fotocamera
ICC_Profile:ProfileDescriptionML-ja-JP: "\xE3\x82\xAB\xE3\x83\xA1\xE3\x83\xA9 RGB \xE3\x83\x97\xE3\x83\xAD\xE3\x83\x95\xE3\x82\xA1\xE3\x82\xA4\xE3\x83\xAB"
ICC_Profile:ProfileDescriptionML-ko-KR: "\xEC\xB9\xB4\xEB\xA9\x94\xEB\x9D\xBC RGB \xED\x94\x84\xEB\xA1\x9C\xED\x8C\x8C\xEC\x9D\xBC"
ICC_Profile:ProfileDescriptionML-nl-NL: RGB-profiel Camera
ICC_Profile:ProfileDescriptionML-no-NO: RGB-kameraprofil
ICC_Profile:ProfileDescriptionML-pt-BR: "Perfil RGB de C\xC3\xA2mera"
ICC_Profile:ProfileDescriptionML-sv-SE: "RGB-profil f\xC3\xB6r Kamera"
ICC_Profile:ProfileDescriptionML-zh-CN: "\xE7\x9B\xB8\xE6\x9C\xBA RGB \xE6\x8F\x8F\xE8\xBF\xB0\xE6\x96\x87\xE4\xBB\xB6"
ICC_Profile:ProfileDescriptionML-zh-TW: "\xE6\x95\xB8\xE4\xBD\x8D\xE7\x9B\xB8\xE6\xA9\x9F RGB \xE8\x89\xB2\xE5\xBD\xA9\xE6\x8F\x8F\xE8\xBF\xB0"
ICC_Profile:RedMatrixColumn: 0.45427 0.24263 0.01482
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 180
JFIF:YResolution: 180
', '2012-10-16 13:57:54.933299', '2012-10-16 13:57:55.152688', 'jpg', 'image');
INSERT INTO media_files VALUES (87, 768, 218484, 1024, 'image/jpeg', 'seerose_4.jpg', '113b53d839df47638c60286d6ce746f7', 'ffe86695-8384-4ed1-a884-7e6e2d6fa2e1', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 768
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:2 (2 1)
Composite:ImageSize: 1024x768
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: appl
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: appl
ICC-header:ProfileClass: Input Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: appl
ICC-header:ProfileDateTime: 2003:07:01 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.2.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.15662 0.08336 0.71953
ICC_Profile:ChromaticAdaptation: 1.04788 0.02292 -0.0502 0.02957 0.99049 -0.01706 -0.00923 0.01508 0.75165
ICC_Profile:GreenMatrixColumn: 0.35332 0.67441 0.09042
ICC_Profile:MediaWhitePoint: 0.95047 1 1.0891
ICC_Profile:ProfileDescription: Camera RGB Profile
ICC_Profile:ProfileDescriptionML: Camera RGB Profile
ICC_Profile:ProfileDescriptionML-da-DK: RGB-beskrivelse til Kamera
ICC_Profile:ProfileDescriptionML-de-DE: "RGB-Profil f\xC3\xBCr Kameras"
ICC_Profile:ProfileDescriptionML-es-ES: "Perfil RGB para C\xC3\xA1mara"
ICC_Profile:ProfileDescriptionML-fi-FI: Kameran RGB-profiili
ICC_Profile:ProfileDescriptionML-fr-FU: "Profil RVB de l\xE2\x80\x99appareil-photo"
ICC_Profile:ProfileDescriptionML-it-IT: Profilo RGB Fotocamera
ICC_Profile:ProfileDescriptionML-ja-JP: "\xE3\x82\xAB\xE3\x83\xA1\xE3\x83\xA9 RGB \xE3\x83\x97\xE3\x83\xAD\xE3\x83\x95\xE3\x82\xA1\xE3\x82\xA4\xE3\x83\xAB"
ICC_Profile:ProfileDescriptionML-ko-KR: "\xEC\xB9\xB4\xEB\xA9\x94\xEB\x9D\xBC RGB \xED\x94\x84\xEB\xA1\x9C\xED\x8C\x8C\xEC\x9D\xBC"
ICC_Profile:ProfileDescriptionML-nl-NL: RGB-profiel Camera
ICC_Profile:ProfileDescriptionML-no-NO: RGB-kameraprofil
ICC_Profile:ProfileDescriptionML-pt-BR: "Perfil RGB de C\xC3\xA2mera"
ICC_Profile:ProfileDescriptionML-sv-SE: "RGB-profil f\xC3\xB6r Kamera"
ICC_Profile:ProfileDescriptionML-zh-CN: "\xE7\x9B\xB8\xE6\x9C\xBA RGB \xE6\x8F\x8F\xE8\xBF\xB0\xE6\x96\x87\xE4\xBB\xB6"
ICC_Profile:ProfileDescriptionML-zh-TW: "\xE6\x95\xB8\xE4\xBD\x8D\xE7\x9B\xB8\xE6\xA9\x9F RGB \xE8\x89\xB2\xE5\xBD\xA9\xE6\x8F\x8F\xE8\xBF\xB0"
ICC_Profile:RedMatrixColumn: 0.45427 0.24263 0.01482
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:58:00.84975', '2012-10-16 13:58:01.19871', 'jpg', 'image');
INSERT INTO media_files VALUES (91, 699, 160352, 1024, 'image/tiff', 'Kistler_MG_3861.tif', '0f1e2ef7be614044af088b5bb92c581c', 'cb254e6e-2b96-4e2a-8b5d-20f07d3f933e', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 699
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x699
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:58:12.367573', '2012-10-16 13:58:12.568337', 'tif', 'image');
INSERT INTO media_files VALUES (89, 706, 192506, 1024, 'image/tiff', 'Treier_MG_3882.tif', 'a96ccdf503334117b44bb6eef9d67001', '4ad4a6ee-6318-4651-be8b-7292bb1d7b20', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 706
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x706
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:58:06.810562', '2012-10-16 13:58:07.018961', 'tif', 'image');
INSERT INTO media_files VALUES (92, 768, 439215, 1024, 'image/jpeg', 'Bild1col.JPG', '1959e8c1ac2c4ec9ade2fa2086ff74c2', '078845df-da98-48b6-aaab-4dc7a4421e47', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 768
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:2 (2 1)
Composite:ImageSize: 1024x768
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: appl
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: appl
ICC-header:ProfileClass: Input Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: appl
ICC-header:ProfileDateTime: 2003:07:01 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.2.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.15662 0.08336 0.71953
ICC_Profile:ChromaticAdaptation: 1.04788 0.02292 -0.0502 0.02957 0.99049 -0.01706 -0.00923 0.01508 0.75165
ICC_Profile:GreenMatrixColumn: 0.35332 0.67441 0.09042
ICC_Profile:MediaWhitePoint: 0.95047 1 1.0891
ICC_Profile:ProfileDescription: Camera RGB Profile
ICC_Profile:ProfileDescriptionML: Camera RGB Profile
ICC_Profile:ProfileDescriptionML-da-DK: RGB-beskrivelse til Kamera
ICC_Profile:ProfileDescriptionML-de-DE: "RGB-Profil f\xC3\xBCr Kameras"
ICC_Profile:ProfileDescriptionML-es-ES: "Perfil RGB para C\xC3\xA1mara"
ICC_Profile:ProfileDescriptionML-fi-FI: Kameran RGB-profiili
ICC_Profile:ProfileDescriptionML-fr-FU: "Profil RVB de l\xE2\x80\x99appareil-photo"
ICC_Profile:ProfileDescriptionML-it-IT: Profilo RGB Fotocamera
ICC_Profile:ProfileDescriptionML-ja-JP: "\xE3\x82\xAB\xE3\x83\xA1\xE3\x83\xA9 RGB \xE3\x83\x97\xE3\x83\xAD\xE3\x83\x95\xE3\x82\xA1\xE3\x82\xA4\xE3\x83\xAB"
ICC_Profile:ProfileDescriptionML-ko-KR: "\xEC\xB9\xB4\xEB\xA9\x94\xEB\x9D\xBC RGB \xED\x94\x84\xEB\xA1\x9C\xED\x8C\x8C\xEC\x9D\xBC"
ICC_Profile:ProfileDescriptionML-nl-NL: RGB-profiel Camera
ICC_Profile:ProfileDescriptionML-no-NO: RGB-kameraprofil
ICC_Profile:ProfileDescriptionML-pt-BR: "Perfil RGB de C\xC3\xA2mera"
ICC_Profile:ProfileDescriptionML-sv-SE: "RGB-profil f\xC3\xB6r Kamera"
ICC_Profile:ProfileDescriptionML-zh-CN: "\xE7\x9B\xB8\xE6\x9C\xBA RGB \xE6\x8F\x8F\xE8\xBF\xB0\xE6\x96\x87\xE4\xBB\xB6"
ICC_Profile:ProfileDescriptionML-zh-TW: "\xE6\x95\xB8\xE4\xBD\x8D\xE7\x9B\xB8\xE6\xA9\x9F RGB \xE8\x89\xB2\xE5\xBD\xA9\xE6\x8F\x8F\xE8\xBF\xB0"
ICC_Profile:RedMatrixColumn: 0.45427 0.24263 0.01482
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 180
JFIF:YResolution: 180
', '2012-10-16 13:58:15.460874', '2012-10-16 13:58:15.755016', 'jpg', 'image');
INSERT INTO media_files VALUES (94, 670, 132165, 1024, 'image/tiff', '01142-01-038-006.tif', '892b9d59952047649b4ba55776062c6e', 'cc5fa918-320d-4a8c-99ad-604dbcd4b58d', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 670
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x670
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:58:21.960948', '2012-10-16 13:58:22.180649', 'tif', 'image');
INSERT INTO media_files VALUES (95, 672, 153910, 1024, 'image/tiff', '01142-01-041-013.tif', '82aac15d6f8f40c09341ac67900a6912', 'ff059d77-6aa2-4479-b145-234aa5cefd2e', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 672
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x672
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:58:25.290166', '2012-10-16 13:58:25.470333', 'tif', 'image');
INSERT INTO media_files VALUES (96, 683, 431844, 1024, 'image/jpeg', 'glowing_oilsurface.jpg', 'f97864380d3243f4bd608b32a540eaf9', 'efeb3a46-a486-405b-912e-03743d88ea08', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 683
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 1024x683
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:58:28.285269', '2012-10-16 13:58:28.425823', 'jpg', 'image');
INSERT INTO media_files VALUES (97, 683, 293742, 1024, 'image/tiff', 'Vernissage_MG_3657.tif', 'cc529d4936ec47fca6d4957000c24a32', '50542185-17a1-4020-a347-e580a0b4e959', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 683
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x683
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 13:58:31.125062', '2012-10-16 13:58:31.31082', 'tif', 'image');
INSERT INTO media_files VALUES (103, 668, 141537, 1024, 'image/tiff', 'Import_Export_MG_3919.tif', 'fec452eb8d194593b176aa36fd3eca7c', 'a9f827d4-5446-4323-94da-df9dc14cadd2', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 668
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x668
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 14:10:16.197977', '2012-10-16 14:10:16.417712', 'tif', 'image');
INSERT INTO media_files VALUES (105, 683, 285967, 1024, 'image/tiff', 'Vernissage_MG_3658.tif', '619fe0823d304f97ac2c6ecace872d48', '4582ffd1-a41a-40db-bfef-d1dee98bc21a', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 683
File:ImageWidth: 1024
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:ImageSize: 1024x683
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: none
ICC-header:DeviceModel: ""
ICC-header:PrimaryPlatform: Apple Computer Inc.
ICC-header:ProfileCMMType: ADBE
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: ADBE
ICC-header:ProfileDateTime: 1999:06:03 00:00:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Perceptual
ICC_Profile:BlueMatrixColumn: 0.14919 0.06322 0.74457
ICC_Profile:GreenMatrixColumn: 0.20528 0.62567 0.06087
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: Adobe RGB (1998)
ICC_Profile:RedMatrixColumn: 0.60974 0.31111 0.01947
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 300
JFIF:YResolution: 300
', '2012-10-16 14:10:22.054184', '2012-10-16 14:10:22.232135', 'tif', 'image');
INSERT INTO media_files VALUES (109, 720, 922620, 1280, 'video/quicktime', 'zencoder_test.mov', 'd17762a96c634555bbc5fe3610eff673', '44d30f33-70a4-4aa1-adea-5af1f62910d8', '--- 
File:FileType: MP4
File:MIMEType: video/mp4
Composite:AvgBitrate: 1.45 Mbps
Composite:ImageSize: 1280x720
Composite:Rotation: 0
QuickTime:CompatibleBrands: 
- isom
- avc1
QuickTime:CreateDate: 2012:04:02 10:02:06
QuickTime:CurrentTime: 0 s
QuickTime:Duration: 5.07 s
QuickTime:MajorBrand: MP4  Base Media v1 [IS0 14496-12:2003]
QuickTime:MatrixStructure: 1 0 0 0 1 0 0 0 1
QuickTime:MinorVersion: 0.0.1
QuickTime:ModifyDate: 2012:04:02 10:02:06
QuickTime:MovieDataSize: 920203
QuickTime:MovieHeaderVersion: 0
QuickTime:NextTrackID: 3
QuickTime:PosterTime: 0 s
QuickTime:PreferredRate: 1
QuickTime:PreferredVolume: 100.00%
QuickTime:PreviewDuration: 0 s
QuickTime:PreviewTime: 0 s
QuickTime:SelectionDuration: 0 s
QuickTime:SelectionTime: 0 s
QuickTime:TimeScale: 600
', '2013-03-07 08:42:20.907132', '2013-03-07 08:42:21.313648', 'mov', 'video');
INSERT INTO media_files VALUES (110, NULL, 2793600, NULL, 'audio/mpeg', 'shit_in_my_head.mp3', 'f0636d00b2a443409cb992dde7ea0a40', '79aea089-81e3-4408-ba0b-42955a6190f9', '--- {}

', '2013-03-07 08:45:44.721587', '2013-03-07 08:45:44.721587', 'mp3', 'audio');
INSERT INTO media_files VALUES (111, 768, 77999, 510, 'image/jpeg', 'Favorite.jpg', '5e172a4a8405457abac60aee80f33948', 'd9e31635-830d-47bb-b99b-22e60c97a963', '--- 
File:BitsPerSample: 8
File:ColorComponents: 3
File:EncodingProcess: Baseline DCT, Huffman coding
File:FileType: JPEG
File:ImageHeight: 768
File:ImageWidth: 510
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:4:4 (1 1)
Composite:ImageSize: 510x768
ICC-header:CMMFlags: Not Embedded, Independent
ICC-header:ColorSpaceData: "RGB "
ICC-header:ConnectionSpaceIlluminant: 0.9642 1 0.82491
ICC-header:DeviceAttributes: Reflective, Glossy, Positive, Color
ICC-header:DeviceManufacturer: "IEC "
ICC-header:DeviceModel: sRGB
ICC-header:PrimaryPlatform: Microsoft Corporation
ICC-header:ProfileCMMType: Lino
ICC-header:ProfileClass: Display Device Profile
ICC-header:ProfileConnectionSpace: "XYZ "
ICC-header:ProfileCreator: "HP  "
ICC-header:ProfileDateTime: 1998:02:09 06:49:00
ICC-header:ProfileFileSignature: acsp
ICC-header:ProfileID: 0
ICC-header:ProfileVersion: 2.1.0
ICC-header:RenderingIntent: Media-Relative Colorimetric
ICC-meas:MeasurementBacking: 0 0 0
ICC-meas:MeasurementFlare: 0.999%
ICC-meas:MeasurementGeometry: Unknown (0)
ICC-meas:MeasurementIlluminant: D65
ICC-meas:MeasurementObserver: CIE 1931
ICC-view:ViewingCondIlluminant: 19.6445 20.3718 16.8089
ICC-view:ViewingCondIlluminantType: D50
ICC-view:ViewingCondSurround: 3.92889 4.07439 3.36179
ICC_Profile:BlueMatrixColumn: 0.14307 0.06061 0.7141
ICC_Profile:DeviceMfgDesc: IEC http://www.iec.ch
ICC_Profile:DeviceModelDesc: IEC 61966-2.1 Default RGB colour space - sRGB
ICC_Profile:GreenMatrixColumn: 0.38515 0.71687 0.09708
ICC_Profile:Luminance: 76.03647 80 87.12462
ICC_Profile:MediaBlackPoint: 0 0 0
ICC_Profile:MediaWhitePoint: 0.95045 1 1.08905
ICC_Profile:ProfileDescription: sRGB IEC61966-2.1
ICC_Profile:RedMatrixColumn: 0.43607 0.22249 0.01392
ICC_Profile:Technology: Cathode Ray Tube Display
ICC_Profile:ViewingCondDesc: Reference Viewing Condition in IEC61966-2.1
JFIF:JFIFVersion: 1.01
JFIF:ResolutionUnit: inches
JFIF:XResolution: 240
JFIF:YResolution: 240
', '2013-03-12 10:32:12.192981', '2013-03-12 10:32:12.564842', 'jpg', 'image');
INSERT INTO media_files VALUES (112, 720, 922621, 1280, 'video/quicktime', 'zencoder_test.mov', '66b1ef50186645438c047179f54ec6e6', '4eb0ffec-58a1-4e9b-9056-b4f6fd4729ae', '---
File:FileType: MP4
File:MIMEType: video/mp4
Composite:AvgBitrate: 1.45 Mbps
Composite:ImageSize: 1280x720
Composite:Rotation: 0
QuickTime:CompatibleBrands:
- isom
- avc1
QuickTime:CreateDate: 2012:04:02 10:02:06
QuickTime:CurrentTime: 0 s
QuickTime:Duration: 5.07 s
QuickTime:MajorBrand: MP4  Base Media v1 [IS0 14496-12:2003]
QuickTime:MatrixStructure: 1 0 0 0 1 0 0 0 1
QuickTime:MinorVersion: 0.0.1
QuickTime:ModifyDate: 2012:04:02 10:02:06
QuickTime:MovieDataSize: 920203
QuickTime:MovieHeaderVersion: 0
QuickTime:NextTrackID: 3
QuickTime:PosterTime: 0 s
QuickTime:PreferredRate: 1
QuickTime:PreferredVolume: 100.00%
QuickTime:PreviewDuration: 0 s
QuickTime:PreviewTime: 0 s
QuickTime:SelectionDuration: 0 s
QuickTime:SelectionTime: 0 s
QuickTime:TimeScale: 600
', '2013-05-21 06:54:11.211627', '2013-05-21 06:54:11.446769', 'mov', 'video');
INSERT INTO media_files VALUES (113, NULL, 3047144, NULL, 'application/pdf', 'map.geo.admin.ch (1).pdf', '6985741d84e04b71b5345b2f6a077372', 'c1fb5b24-c098-43e8-8d90-2167d69ae6d6', '--- {}
', '2013-07-08 08:26:54.604936', '2013-07-08 08:26:54.604936', 'pdf', 'document');
INSERT INTO media_files VALUES (114, 600, 45845, 800, 'image/jpeg', 'blah_blah_blah.jpg', '2a0cba39a2c242c189ced07dcea19dc6', '9eceda10-0c8c-4e1a-ba48-4be5666a89ac', '---
File:BitsPerSample: 8
File:ColorComponents: 3
File:Comment: ACD Systems Digital Imaging
File:EncodingProcess: Baseline DCT, Huffman coding
File:ExifByteOrder: Little-endian (Intel, II)
File:FileType: JPEG
File:ImageHeight: 600
File:ImageWidth: 800
File:MIMEType: image/jpeg
File:YCbCrSubSampling: YCbCr4:2:0 (2 2)
Composite:Aperture: 2.0
Composite:FocalLength35efl: 7.1 mm
Composite:ImageSize: 800x600
Composite:ShutterSpeed: 1/60
ExifIFD:ColorSpace: sRGB
ExifIFD:ComponentsConfiguration: Y, Cb, Cr, -
ExifIFD:CompressedBitsPerPixel: 4.012406463
ExifIFD:CreateDate: 2005:06:02 18:05:09
ExifIFD:DateTimeOriginal: 2005:06:02 18:05:09
ExifIFD:ExifImageHeight: 1680
ExifIFD:ExifImageWidth: 2240
ExifIFD:ExifVersion: ''0210''
ExifIFD:ExposureCompensation: 0
ExifIFD:ExposureProgram: Program AE
ExifIFD:ExposureTime: 1/60
ExifIFD:FNumber: 2.0
ExifIFD:FileSource: Digital Camera
ExifIFD:Flash: Fired
ExifIFD:FlashpixVersion: ''0100''
ExifIFD:FocalLength: 7.1 mm
ExifIFD:MaxApertureValue: 2.0
ExifIFD:MeteringMode: Multi-segment
IFD0:Make: CASIO
IFD0:Model: QV-4000
IFD0:ModifyDate: 2005:06:02 18:05:09
IFD0:Orientation: Horizontal (normal)
IFD0:ResolutionUnit: inches
IFD0:Software: Ver1.01
IFD0:XResolution: 72
IFD0:YCbCrPositioning: Centered
IFD0:YResolution: 72
JFIF:JFIFVersion: 1.02
JFIF:ResolutionUnit: cm
JFIF:XResolution: 0
JFIF:YResolution: 0
', '2013-07-08 08:41:52.685269', '2013-07-08 08:41:52.901876', 'jpg', 'image');


--
-- Data for Name: media_resource_arcs; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO media_resource_arcs VALUES (1, 1, 3, false, NULL);
INSERT INTO media_resource_arcs VALUES (2, 2, 3, false, NULL);
INSERT INTO media_resource_arcs VALUES (3, 15, 17, false, NULL);
INSERT INTO media_resource_arcs VALUES (4, 13, 17, false, NULL);
INSERT INTO media_resource_arcs VALUES (5, 12, 17, false, NULL);
INSERT INTO media_resource_arcs VALUES (6, 14, 17, false, NULL);
INSERT INTO media_resource_arcs VALUES (7, 17, 22, false, NULL);
INSERT INTO media_resource_arcs VALUES (8, 17, 23, false, NULL);
INSERT INTO media_resource_arcs VALUES (9, 17, 25, false, NULL);
INSERT INTO media_resource_arcs VALUES (10, 15, 26, false, NULL);
INSERT INTO media_resource_arcs VALUES (11, 1, 29, false, true);
INSERT INTO media_resource_arcs VALUES (13, 1, 30, false, NULL);
INSERT INTO media_resource_arcs VALUES (15, 2, 30, false, true);
INSERT INTO media_resource_arcs VALUES (17, 4, 7, false, true);
INSERT INTO media_resource_arcs VALUES (19, 4, 8, false, NULL);
INSERT INTO media_resource_arcs VALUES (21, 5, 6, false, true);
INSERT INTO media_resource_arcs VALUES (23, 9, 10, false, true);
INSERT INTO media_resource_arcs VALUES (25, 9, 11, false, NULL);
INSERT INTO media_resource_arcs VALUES (27, 15, 16, false, true);
INSERT INTO media_resource_arcs VALUES (29, 17, 18, false, true);
INSERT INTO media_resource_arcs VALUES (31, 17, 19, false, NULL);
INSERT INTO media_resource_arcs VALUES (33, 17, 20, false, NULL);
INSERT INTO media_resource_arcs VALUES (37, 17, 24, false, NULL);
INSERT INTO media_resource_arcs VALUES (42, 32, 16, false, true);
INSERT INTO media_resource_arcs VALUES (44, 32, 6, false, NULL);
INSERT INTO media_resource_arcs VALUES (45, 37, 33, false, true);
INSERT INTO media_resource_arcs VALUES (47, 37, 35, false, true);
INSERT INTO media_resource_arcs VALUES (48, 38, 6, false, true);
INSERT INTO media_resource_arcs VALUES (49, 1, 33, false, NULL);
INSERT INTO media_resource_arcs VALUES (50, 39, 40, false, true);
INSERT INTO media_resource_arcs VALUES (51, 39, 99, false, NULL);
INSERT INTO media_resource_arcs VALUES (52, 102, 47, false, true);
INSERT INTO media_resource_arcs VALUES (53, 102, 46, false, true);
INSERT INTO media_resource_arcs VALUES (54, 103, 80, false, true);
INSERT INTO media_resource_arcs VALUES (55, 103, 81, false, true);
INSERT INTO media_resource_arcs VALUES (56, 101, 103, false, true);
INSERT INTO media_resource_arcs VALUES (57, 101, 102, false, true);
INSERT INTO media_resource_arcs VALUES (58, 101, 99, false, NULL);
INSERT INTO media_resource_arcs VALUES (59, 107, 105, false, true);
INSERT INTO media_resource_arcs VALUES (60, 107, 106, false, NULL);
INSERT INTO media_resource_arcs VALUES (41, 26, 28, false, true);


--
-- Data for Name: media_resources; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO media_resources VALUES (1, false, false, false, true, NULL, NULL, 1, '--- {}

', 'MediaSet', '2012-04-20 12:04:17', '2012-04-20 12:04:17');
INSERT INTO media_resources VALUES (2, false, false, false, false, NULL, NULL, 1, '--- {}

', 'MediaSet', '2012-04-20 12:04:17', '2012-04-20 12:04:17');
INSERT INTO media_resources VALUES (3, false, false, false, false, NULL, NULL, 1, '--- {}

', 'MediaSet', '2012-04-20 12:04:17', '2012-04-20 12:04:17');
INSERT INTO media_resources VALUES (4, false, false, false, false, NULL, NULL, 2, '--- {}

', 'MediaSet', '2012-04-20 12:04:17', '2012-04-20 12:04:17');
INSERT INTO media_resources VALUES (5, false, false, false, false, NULL, NULL, 3, '--- {}

', 'MediaSet', '2012-04-20 12:04:17', '2012-04-20 12:04:17');
INSERT INTO media_resources VALUES (7, false, false, false, false, NULL, 2, 2, NULL, 'MediaEntry', '2012-04-20 12:04:18', '2012-04-20 12:04:18');
INSERT INTO media_resources VALUES (8, false, false, false, false, NULL, 3, 2, NULL, 'MediaEntry', '2012-04-20 12:04:19', '2012-04-20 12:04:19');
INSERT INTO media_resources VALUES (9, false, false, false, true, NULL, NULL, 2, '--- {}

', 'MediaSet', '2012-04-20 12:04:19', '2012-04-20 12:04:19');
INSERT INTO media_resources VALUES (109, false, false, false, false, NULL, NULL, 2, '--- 
:filter: 
  :meta_data: 
    :style: 
      :ids: 
      - any
  :search: ""
', 'FilterSet', '2013-03-15 09:32:48.591698', '2013-03-15 09:32:48.905461');
INSERT INTO media_resources VALUES (11, false, false, false, false, NULL, 5, 2, NULL, 'MediaEntry', '2012-04-20 12:04:20', '2012-04-20 12:04:20');
INSERT INTO media_resources VALUES (12, false, false, false, false, NULL, NULL, 2, '--- {}

', 'MediaSet', '2012-04-20 12:04:20', '2012-04-20 12:04:20');
INSERT INTO media_resources VALUES (13, false, false, false, false, NULL, NULL, 2, '--- {}

', 'MediaSet', '2012-04-20 12:04:20', '2012-04-20 12:04:20');
INSERT INTO media_resources VALUES (14, false, false, false, false, NULL, NULL, 2, '--- {}

', 'MediaSet', '2012-04-20 12:04:20', '2012-04-20 12:04:20');
INSERT INTO media_resources VALUES (15, false, false, false, false, NULL, NULL, 2, '--- {}

', 'MediaSet', '2012-04-20 12:04:20', '2012-04-20 12:04:20');
INSERT INTO media_resources VALUES (16, false, false, false, true, NULL, 6, 2, NULL, 'MediaEntry', '2012-04-20 12:04:20', '2012-04-20 12:04:20');
INSERT INTO media_resources VALUES (17, false, false, false, false, NULL, NULL, 2, '--- {}

', 'MediaSet', '2012-04-20 12:04:20', '2012-04-20 12:04:20');
INSERT INTO media_resources VALUES (111, false, false, false, false, NULL, NULL, 2, '---
:filter:
  :permissions:
    :scope:
      :ids:
      - public
  :search: ''''
', 'FilterSet', '2013-05-17 12:58:25.286747', '2013-05-17 12:58:25.581905');
INSERT INTO media_resources VALUES (22, false, false, false, false, NULL, NULL, 2, '--- {}

', 'MediaSet', '2012-04-20 12:04:22', '2012-04-20 12:04:22');
INSERT INTO media_resources VALUES (23, false, false, false, false, NULL, NULL, 2, '--- {}

', 'MediaSet', '2012-04-20 12:04:22', '2012-04-20 12:04:22');
INSERT INTO media_resources VALUES (24, false, false, false, false, NULL, 11, 2, NULL, 'MediaEntry', '2012-04-20 12:04:22', '2012-04-20 12:04:22');
INSERT INTO media_resources VALUES (25, false, false, false, false, NULL, NULL, 2, '--- {}

', 'MediaSet', '2012-04-20 12:04:22', '2012-04-20 12:04:22');
INSERT INTO media_resources VALUES (26, false, false, false, false, NULL, NULL, 2, '--- {}

', 'MediaSet', '2012-04-20 12:04:22', '2012-04-20 12:04:22');
INSERT INTO media_resources VALUES (28, false, false, false, false, NULL, 13, 2, NULL, 'MediaEntry', '2012-04-20 12:04:23', '2012-04-20 12:04:23');
INSERT INTO media_resources VALUES (29, false, false, false, false, NULL, 14, 6, NULL, 'MediaEntry', '2012-04-20 12:04:24', '2012-04-20 12:04:24');
INSERT INTO media_resources VALUES (30, false, false, false, false, NULL, 15, 6, NULL, 'MediaEntry', '2012-04-20 12:04:24', '2012-04-20 12:04:24');
INSERT INTO media_resources VALUES (31, false, false, false, false, NULL, 16, 6, NULL, 'MediaEntry', '2012-04-20 12:04:25', '2012-04-20 12:04:25');
INSERT INTO media_resources VALUES (32, false, false, false, true, NULL, NULL, 1, '--- {}

', 'MediaSet', '2012-06-21 10:59:57', '2012-06-21 11:00:16');
INSERT INTO media_resources VALUES (35, false, false, false, true, NULL, 21, 6, NULL, 'MediaEntry', '2012-08-31 12:00:08', '2012-08-31 12:01:59');
INSERT INTO media_resources VALUES (100, false, false, false, true, NULL, 107, 7, NULL, 'MediaEntry', '2012-11-07 16:38:47.710881', '2012-11-08 07:30:13.401085');
INSERT INTO media_resources VALUES (38, false, false, false, false, NULL, NULL, 1, '--- {}

', 'MediaSet', '2012-10-12 11:54:22.051365', '2012-10-12 11:55:03.039456');
INSERT INTO media_resources VALUES (33, false, false, false, true, NULL, 19, 6, NULL, 'MediaEntry', '2012-08-31 09:18:03', '2012-10-12 11:56:30.201361');
INSERT INTO media_resources VALUES (6, false, false, false, true, NULL, 1, 3, NULL, 'MediaEntry', '2012-04-20 12:04:18', '2012-10-12 11:57:52.22069');
INSERT INTO media_resources VALUES (102, false, false, false, true, NULL, NULL, 1, '--- {}

', 'MediaSet', '2012-12-11 12:36:41.599777', '2012-12-11 12:37:52.323267');
INSERT INTO media_resources VALUES (101, false, false, false, true, NULL, NULL, 1, '--- {}

', 'MediaSet', '2012-12-11 12:35:19.364402', '2012-12-11 12:41:13.211');
INSERT INTO media_resources VALUES (39, false, false, false, true, NULL, NULL, 1, '--- {}

', 'MediaSet', '2012-10-16 11:51:40.519619', '2012-10-16 13:13:01.642662');
INSERT INTO media_resources VALUES (10, true, false, false, true, NULL, 4, 2, NULL, 'MediaEntry', '2012-04-20 12:04:19', '2013-03-04 13:50:02.608077');
INSERT INTO media_resources VALUES (40, false, false, false, true, NULL, NULL, 1, '--- 
:filter: 
  :meta_data: 
    :keywords: 
      :ids: 
      - any
', 'FilterSet', '2012-10-16 11:54:12.653711', '2012-10-16 13:15:11.864125');
INSERT INTO media_resources VALUES (18, true, false, false, true, NULL, 7, 2, NULL, 'MediaEntry', '2012-04-20 12:04:21', '2013-03-04 13:50:02.957321');
INSERT INTO media_resources VALUES (19, true, false, false, true, NULL, 8, 2, NULL, 'MediaEntry', '2012-04-20 12:04:21', '2013-03-04 13:50:02.97647');
INSERT INTO media_resources VALUES (20, true, false, false, true, NULL, 9, 2, NULL, 'MediaEntry', '2012-04-20 12:04:21', '2013-03-04 13:50:02.995063');
INSERT INTO media_resources VALUES (41, false, false, false, true, NULL, 22, 7, NULL, 'MediaEntry', '2012-10-16 13:28:23.45422', '2012-10-16 13:29:21.229226');
INSERT INTO media_resources VALUES (42, false, false, false, true, NULL, 23, 7, NULL, 'MediaEntry', '2012-10-16 13:28:26.41117', '2012-10-16 13:29:21.403063');
INSERT INTO media_resources VALUES (37, false, false, false, true, NULL, NULL, 6, '--- {}

', 'MediaSet', '2012-08-31 14:36:24', '2012-10-24 08:14:30.206886');
INSERT INTO media_resources VALUES (105, true, false, false, true, NULL, 109, 6, NULL, 'MediaEntry', '2013-03-07 08:42:22.285271', '2013-03-07 08:47:27.018023');
INSERT INTO media_resources VALUES (107, true, false, false, true, NULL, NULL, 1, '--- {}

', 'MediaSet', '2013-03-07 09:02:45.743746', '2013-03-07 09:06:31.412765');
INSERT INTO media_resources VALUES (108, false, false, false, false, NULL, 111, 3, NULL, 'MediaEntry', '2013-03-12 10:32:15.442076', '2013-03-12 10:32:15.442076');
INSERT INTO media_resources VALUES (43, false, false, false, true, NULL, 24, 7, NULL, 'MediaEntry', '2012-10-16 13:46:53.335845', '2012-10-16 13:48:32.885296');
INSERT INTO media_resources VALUES (44, false, false, false, true, NULL, 29, 7, NULL, 'MediaEntry', '2012-10-16 13:47:05.895751', '2012-10-16 13:48:32.932654');
INSERT INTO media_resources VALUES (45, false, false, false, true, NULL, 30, 7, NULL, 'MediaEntry', '2012-10-16 13:47:08.882605', '2012-10-16 13:48:32.976137');
INSERT INTO media_resources VALUES (46, false, false, false, true, NULL, 31, 7, NULL, 'MediaEntry', '2012-10-16 13:47:11.348191', '2012-10-16 13:48:33.079839');
INSERT INTO media_resources VALUES (47, false, false, false, true, NULL, 33, 7, NULL, 'MediaEntry', '2012-10-16 13:47:16.394432', '2012-10-16 13:48:33.215856');
INSERT INTO media_resources VALUES (48, false, false, false, true, NULL, 36, 7, NULL, 'MediaEntry', '2012-10-16 13:47:23.484679', '2012-10-16 13:48:33.264353');
INSERT INTO media_resources VALUES (49, false, false, false, true, NULL, 37, 7, NULL, 'MediaEntry', '2012-10-16 13:47:26.158636', '2012-10-16 13:48:33.28843');
INSERT INTO media_resources VALUES (50, false, false, false, true, NULL, 38, 7, NULL, 'MediaEntry', '2012-10-16 13:47:28.245899', '2012-10-16 13:48:33.312581');
INSERT INTO media_resources VALUES (51, false, false, false, true, NULL, 40, 7, NULL, 'MediaEntry', '2012-10-16 13:47:32.888265', '2012-10-16 13:48:33.355385');
INSERT INTO media_resources VALUES (52, false, false, false, true, NULL, 41, 7, NULL, 'MediaEntry', '2012-10-16 13:47:35.32106', '2012-10-16 13:48:33.389865');
INSERT INTO media_resources VALUES (53, false, false, false, true, NULL, 42, 7, NULL, 'MediaEntry', '2012-10-16 13:47:37.717683', '2012-10-16 13:48:33.437077');
INSERT INTO media_resources VALUES (54, false, false, false, true, NULL, 43, 7, NULL, 'MediaEntry', '2012-10-16 13:47:39.994105', '2012-10-16 13:48:33.463658');
INSERT INTO media_resources VALUES (55, false, false, false, true, NULL, 44, 7, NULL, 'MediaEntry', '2012-10-16 13:47:42.588159', '2012-10-16 13:48:33.506457');
INSERT INTO media_resources VALUES (56, false, false, false, true, NULL, 45, 7, NULL, 'MediaEntry', '2012-10-16 13:47:44.773613', '2012-10-16 13:48:33.5881');
INSERT INTO media_resources VALUES (57, false, false, false, true, NULL, 47, 7, NULL, 'MediaEntry', '2012-10-16 13:47:49.014411', '2012-10-16 13:48:33.634105');
INSERT INTO media_resources VALUES (58, false, false, false, true, NULL, 48, 7, NULL, 'MediaEntry', '2012-10-16 13:47:51.715653', '2012-10-16 13:48:33.681447');
INSERT INTO media_resources VALUES (59, false, false, false, true, NULL, 49, 7, NULL, 'MediaEntry', '2012-10-16 13:47:53.85754', '2012-10-16 13:48:33.711926');
INSERT INTO media_resources VALUES (60, false, false, false, true, NULL, 51, 7, NULL, 'MediaEntry', '2012-10-16 13:47:58.413496', '2012-10-16 13:48:33.747217');
INSERT INTO media_resources VALUES (61, false, false, false, true, NULL, 52, 7, NULL, 'MediaEntry', '2012-10-16 13:48:01.113773', '2012-10-16 13:48:33.795129');
INSERT INTO media_resources VALUES (62, false, false, false, true, NULL, 53, 7, NULL, 'MediaEntry', '2012-10-16 13:48:03.92891', '2012-10-16 13:48:33.831205');
INSERT INTO media_resources VALUES (63, false, false, false, true, NULL, 54, 7, NULL, 'MediaEntry', '2012-10-16 13:48:07.143979', '2012-10-16 13:48:33.948574');
INSERT INTO media_resources VALUES (64, false, false, false, true, NULL, 55, 7, NULL, 'MediaEntry', '2012-10-16 13:48:09.707432', '2012-10-16 13:48:33.993103');
INSERT INTO media_resources VALUES (66, false, false, false, true, NULL, 57, 7, NULL, 'MediaEntry', '2012-10-16 13:48:14.833367', '2012-10-16 13:48:34.051194');
INSERT INTO media_resources VALUES (65, false, false, false, true, NULL, 56, 7, NULL, 'MediaEntry', '2012-10-16 13:48:12.436357', '2012-10-16 13:49:02.346313');
INSERT INTO media_resources VALUES (92, false, false, false, true, NULL, 95, 7, NULL, 'MediaEntry', '2012-10-16 13:58:27.896877', '2012-11-09 14:10:36.969229');
INSERT INTO media_resources VALUES (103, false, false, false, true, NULL, NULL, 1, '--- {}

', 'MediaSet', '2012-12-11 12:37:11.448242', '2012-12-11 12:37:52.341934');
INSERT INTO media_resources VALUES (99, false, false, false, true, NULL, NULL, 1, '--- 
:filter: 
  :meta_data: 
    :type: 
      :ids: 
      - any
', 'FilterSet', '2012-10-25 13:14:18.493795', '2012-12-11 12:38:23.41564');
INSERT INTO media_resources VALUES (106, true, false, false, true, NULL, 110, 6, NULL, 'MediaEntry', '2013-03-07 08:45:45.502891', '2013-03-07 08:51:40.793639');
INSERT INTO media_resources VALUES (67, false, false, false, true, NULL, 59, 7, NULL, 'MediaEntry', '2012-10-16 13:56:37.697963', '2012-10-16 13:59:06.918763');
INSERT INTO media_resources VALUES (68, false, false, false, true, NULL, 61, 7, NULL, 'MediaEntry', '2012-10-16 13:56:44.435054', '2012-10-16 13:59:06.982204');
INSERT INTO media_resources VALUES (69, false, false, false, true, NULL, 62, 7, NULL, 'MediaEntry', '2012-10-16 13:56:47.174357', '2012-10-16 13:59:07.049423');
INSERT INTO media_resources VALUES (70, false, false, false, true, NULL, 63, 7, NULL, 'MediaEntry', '2012-10-16 13:56:50.270281', '2012-10-16 13:59:07.080647');
INSERT INTO media_resources VALUES (72, false, false, false, true, NULL, 65, 7, NULL, 'MediaEntry', '2012-10-16 13:56:55.609485', '2012-10-16 13:59:07.132886');
INSERT INTO media_resources VALUES (73, false, false, false, true, NULL, 66, 7, NULL, 'MediaEntry', '2012-10-16 13:56:59.11323', '2012-10-16 13:59:07.184268');
INSERT INTO media_resources VALUES (74, false, false, false, true, NULL, 67, 7, NULL, 'MediaEntry', '2012-10-16 13:57:01.905561', '2012-10-16 13:59:07.247534');
INSERT INTO media_resources VALUES (75, false, false, false, true, NULL, 68, 7, NULL, 'MediaEntry', '2012-10-16 13:57:06.029913', '2012-10-16 13:59:07.305897');
INSERT INTO media_resources VALUES (76, false, false, false, true, NULL, 74, 7, NULL, 'MediaEntry', '2012-10-16 13:57:23.955811', '2012-10-16 13:59:07.417688');
INSERT INTO media_resources VALUES (77, false, false, false, true, NULL, 76, 7, NULL, 'MediaEntry', '2012-10-16 13:57:30.343497', '2012-10-16 13:59:07.465745');
INSERT INTO media_resources VALUES (78, false, false, false, true, NULL, 77, 7, NULL, 'MediaEntry', '2012-10-16 13:57:33.45007', '2012-10-16 13:59:07.520409');
INSERT INTO media_resources VALUES (79, false, false, false, true, NULL, 78, 7, NULL, 'MediaEntry', '2012-10-16 13:57:36.439471', '2012-10-16 13:59:07.549584');
INSERT INTO media_resources VALUES (80, false, false, false, true, NULL, 79, 7, NULL, 'MediaEntry', '2012-10-16 13:57:39.618974', '2012-10-16 13:59:07.600067');
INSERT INTO media_resources VALUES (81, false, false, false, true, NULL, 81, 7, NULL, 'MediaEntry', '2012-10-16 13:57:45.146224', '2012-10-16 13:59:07.625654');
INSERT INTO media_resources VALUES (82, false, false, false, true, NULL, 82, 7, NULL, 'MediaEntry', '2012-10-16 13:57:48.422262', '2012-10-16 13:59:07.673591');
INSERT INTO media_resources VALUES (83, false, false, false, true, NULL, 84, 7, NULL, 'MediaEntry', '2012-10-16 13:57:54.651547', '2012-10-16 13:59:07.766193');
INSERT INTO media_resources VALUES (84, false, false, false, true, NULL, 85, 7, NULL, 'MediaEntry', '2012-10-16 13:57:57.747579', '2012-10-16 13:59:07.815767');
INSERT INTO media_resources VALUES (85, false, false, false, true, NULL, 86, 7, NULL, 'MediaEntry', '2012-10-16 13:58:00.691021', '2012-10-16 13:59:07.844638');
INSERT INTO media_resources VALUES (86, false, false, false, true, NULL, 87, 7, NULL, 'MediaEntry', '2012-10-16 13:58:03.769424', '2012-10-16 13:59:07.888655');
INSERT INTO media_resources VALUES (87, false, false, false, true, NULL, 89, 7, NULL, 'MediaEntry', '2012-10-16 13:58:09.175315', '2012-10-16 13:59:07.926373');
INSERT INTO media_resources VALUES (88, false, false, false, true, NULL, 91, 7, NULL, 'MediaEntry', '2012-10-16 13:58:15.099627', '2012-10-16 13:59:07.977819');
INSERT INTO media_resources VALUES (89, false, false, false, true, NULL, 92, 7, NULL, 'MediaEntry', '2012-10-16 13:58:18.601592', '2012-10-16 13:59:08.018218');
INSERT INTO media_resources VALUES (90, false, false, false, true, NULL, 93, 7, NULL, 'MediaEntry', '2012-10-16 13:58:21.57789', '2012-10-16 13:59:08.047681');
INSERT INTO media_resources VALUES (91, false, false, false, true, NULL, 94, 7, NULL, 'MediaEntry', '2012-10-16 13:58:24.861346', '2012-10-16 13:59:08.084644');
INSERT INTO media_resources VALUES (94, false, false, false, true, NULL, 97, 7, NULL, 'MediaEntry', '2012-10-16 13:58:33.793825', '2012-10-16 13:59:08.247959');
INSERT INTO media_resources VALUES (93, false, false, false, true, NULL, 96, 7, NULL, 'MediaEntry', '2012-10-16 13:58:30.995018', '2012-10-16 13:59:33.811575');
INSERT INTO media_resources VALUES (71, false, false, false, true, NULL, 64, 7, NULL, 'MediaEntry', '2012-10-16 13:56:52.773475', '2012-10-16 13:59:41.274674');
INSERT INTO media_resources VALUES (97, false, false, false, false, NULL, 105, 2, NULL, 'MediaEntry', '2012-10-16 14:10:24.575813', '2012-10-16 14:10:24.575813');
INSERT INTO media_resources VALUES (113, true, false, false, true, NULL, 112, 2, NULL, 'MediaEntry', '2013-05-21 06:54:12.16464', '2013-05-21 06:55:06.217403');
INSERT INTO media_resources VALUES (114, false, false, false, false, NULL, 113, 1, NULL, 'MediaEntry', '2013-07-08 08:26:58.837965', '2013-07-08 08:27:25.249773');
INSERT INTO media_resources VALUES (115, false, false, false, false, NULL, 114, 1, NULL, 'MediaEntry', '2013-07-08 08:41:53.512733', '2013-07-08 08:42:03.938963');
INSERT INTO media_resources VALUES (95, false, false, false, false, NULL, 103, 1, NULL, 'MediaEntry', '2012-10-16 14:10:18.53238', '2013-07-09 08:41:59.977788');


--
-- Data for Name: media_sets_meta_contexts; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO media_sets_meta_contexts VALUES (1, 'Landschaftsvisualisierung');
INSERT INTO media_sets_meta_contexts VALUES (38, 'VFO');
INSERT INTO media_sets_meta_contexts VALUES (2, 'Zett');
INSERT INTO media_sets_meta_contexts VALUES (3, 'Games');


--
-- Data for Name: meta_context_groups; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO meta_context_groups VALUES (1, 'Metadaten', 0);
INSERT INTO meta_context_groups VALUES (3, 'Kontexte', 0);


--
-- Data for Name: meta_contexts; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO meta_contexts VALUES (284, NULL, NULL, true, NULL, 'core');
INSERT INTO meta_contexts VALUES (292, NULL, NULL, false, NULL, 'tms');
INSERT INTO meta_contexts VALUES (286, NULL, NULL, false, NULL, 'io_interface');
INSERT INTO meta_contexts VALUES (293, NULL, 1, true, 1, 'media_content');
INSERT INTO meta_contexts VALUES (294, NULL, 1, true, 2, 'media_object');
INSERT INTO meta_contexts VALUES (299, NULL, NULL, true, NULL, 'media_set');
INSERT INTO meta_contexts VALUES (298, NULL, 1, true, 3, 'copyright');
INSERT INTO meta_contexts VALUES (290, NULL, NULL, true, NULL, 'upload');
INSERT INTO meta_contexts VALUES (297, NULL, 1, true, 4, 'zhdk_bereich');
INSERT INTO meta_contexts VALUES (919, NULL, NULL, true, NULL, 'Projekte ZHdK');
INSERT INTO meta_contexts VALUES (977, 2263, 3, true, 1, 'Landschaftsvisualisierung');
INSERT INTO meta_contexts VALUES (1471, 1473, 3, true, 2, 'SupplyLines');
INSERT INTO meta_contexts VALUES (1491, NULL, 3, true, 3, 'Columns');
INSERT INTO meta_contexts VALUES (1631, NULL, 3, true, 4, 'archhist');
INSERT INTO meta_contexts VALUES (1809, NULL, 3, true, 5, 'VFO');
INSERT INTO meta_contexts VALUES (2025, NULL, 3, true, 6, 'Zett');
INSERT INTO meta_contexts VALUES (2233, NULL, 3, true, 7, 'Toni');
INSERT INTO meta_contexts VALUES (3371, NULL, 3, true, 8, 'Forschung ZHdK');
INSERT INTO meta_contexts VALUES (3837, NULL, 3, true, 9, 'Performance-Artefakte');
INSERT INTO meta_contexts VALUES (4558, NULL, NULL, true, NULL, 'Games');
INSERT INTO meta_contexts VALUES (4559, NULL, NULL, true, NULL, 'Nutzung');
INSERT INTO meta_contexts VALUES (4567, NULL, NULL, true, NULL, 'Institution');
INSERT INTO meta_contexts VALUES (4615, NULL, 3, false, NULL, 'sq6');


--
-- Data for Name: meta_data; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO meta_data VALUES (1112, NULL, 111, 'MetaDatumString', 'FilterSet including all public accessible resources', 'title');
INSERT INTO meta_data VALUES (1064, NULL, 106, 'MetaDatumString', '17.5 kHz', 'lame low pass filter');
INSERT INTO meta_data VALUES (1065, NULL, 106, 'MetaDatumString', 'CBR', 'lame method');
INSERT INTO meta_data VALUES (1066, NULL, 106, 'MetaDatumString', '3', 'lame quality');
INSERT INTO meta_data VALUES (1067, NULL, 106, 'MetaDatumString', 'Joint Stereo', 'lame stereo mode');
INSERT INTO meta_data VALUES (1068, NULL, 106, 'MetaDatumString', '4', 'lame vbr quality');
INSERT INTO meta_data VALUES (1069, NULL, 106, 'MetaDatumString', '1', 'mpeg audio version');
INSERT INTO meta_data VALUES (1070, NULL, 106, 'MetaDatumString', 'On', 'ms stereo');
INSERT INTO meta_data VALUES (1071, NULL, 106, 'MetaDatumString', 't', 'original media');
INSERT INTO meta_data VALUES (1072, NULL, 106, 'MetaDatumString', '44100', 'sample rate');
INSERT INTO meta_data VALUES (1073, NULL, 106, 'MetaDatumString', '2052', 'id3 size');
INSERT INTO meta_data VALUES (1074, NULL, 106, 'MetaDatumString', 'Shit in my Head', 'album');
INSERT INTO meta_data VALUES (1075, NULL, 106, 'MetaDatumString', 'Bit-Tuner and Kurt Kuene', 'artist');
INSERT INTO meta_data VALUES (1076, NULL, 106, 'MetaDatumString', '//wipking.krungkuene.org and', 'comment');
INSERT INTO meta_data VALUES (1077, NULL, 106, 'MetaDatumMetaTerms', NULL, 'genre');
INSERT INTO meta_data VALUES (1078, NULL, 106, 'MetaDatumString', 'Shit in my Head', 'title');
INSERT INTO meta_data VALUES (1079, NULL, 106, 'MetaDatumString', '1', 'track');
INSERT INTO meta_data VALUES (1080, NULL, 106, 'MetaDatumString', '2007', 'year');
INSERT INTO meta_data VALUES (1081, NULL, 106, 'MetaDatumString', '2007', 'date time original');
INSERT INTO meta_data VALUES (1082, NULL, 106, 'MetaDatumString', '0:02:54 (approx)', 'duration');
INSERT INTO meta_data VALUES (1083, 3, 106, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (1084, NULL, 106, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (1, NULL, 1, 'MetaDatumString', 'Landschaften', 'title');
INSERT INTO meta_data VALUES (2, NULL, 2, 'MetaDatumString', 'Zett', 'title');
INSERT INTO meta_data VALUES (3, NULL, 3, 'MetaDatumString', 'Zett über Landschaften', 'title');
INSERT INTO meta_data VALUES (4, NULL, 4, 'MetaDatumString', 'Abgabe zum Kurs Product Design', 'title');
INSERT INTO meta_data VALUES (5, NULL, 5, 'MetaDatumString', 'Mein Test Set', 'title');
INSERT INTO meta_data VALUES (6, NULL, 6, 'MetaDatumString', 'Mein Erstes Photo (mit der neuen Nikon)', 'title');
INSERT INTO meta_data VALUES (7, NULL, 7, 'MetaDatumString', 'Abgabe', 'title');
INSERT INTO meta_data VALUES (8, NULL, 8, 'MetaDatumString', 'Konzepte', 'title');
INSERT INTO meta_data VALUES (9, NULL, 9, 'MetaDatumString', 'Fotografie Kurs HS 2010', 'title');
INSERT INTO meta_data VALUES (10, NULL, 10, 'MetaDatumString', 'Portrait', 'title');
INSERT INTO meta_data VALUES (11, NULL, 11, 'MetaDatumString', 'Stilleben', 'title');
INSERT INTO meta_data VALUES (12, NULL, 12, 'MetaDatumString', 'Meine Ausstellungen', 'title');
INSERT INTO meta_data VALUES (13, NULL, 13, 'MetaDatumString', 'Meine Highlights 2012', 'title');
INSERT INTO meta_data VALUES (14, NULL, 14, 'MetaDatumString', 'Dropbox', 'title');
INSERT INTO meta_data VALUES (15, NULL, 15, 'MetaDatumString', 'Diplomarbeit 2012', 'title');
INSERT INTO meta_data VALUES (16, NULL, 16, 'MetaDatumString', 'Präsentation', 'title');
INSERT INTO meta_data VALUES (17, NULL, 17, 'MetaDatumString', 'Ausstellungen', 'title');
INSERT INTO meta_data VALUES (18, NULL, 18, 'MetaDatumString', 'Ausstellung Photo 1', 'title');
INSERT INTO meta_data VALUES (19, NULL, 19, 'MetaDatumString', 'Ausstellung Photo 2', 'title');
INSERT INTO meta_data VALUES (20, NULL, 20, 'MetaDatumString', 'Ausstellung Photo 3', 'title');
INSERT INTO meta_data VALUES (22, NULL, 22, 'MetaDatumString', 'Ausstellung ZHdK', 'title');
INSERT INTO meta_data VALUES (23, NULL, 23, 'MetaDatumString', 'Ausstellung Museum Zürich', 'title');
INSERT INTO meta_data VALUES (24, NULL, 24, 'MetaDatumString', 'Ausstellung Photo 5', 'title');
INSERT INTO meta_data VALUES (25, NULL, 25, 'MetaDatumString', 'Ausstellung Gallerie Limatquai', 'title');
INSERT INTO meta_data VALUES (26, NULL, 26, 'MetaDatumString', 'Konzepte', 'title');
INSERT INTO meta_data VALUES (28, NULL, 28, 'MetaDatumString', 'Zweiter Entwurf', 'title');
INSERT INTO meta_data VALUES (29, NULL, 29, 'MetaDatumString', 'Schweizer Panorama', 'title');
INSERT INTO meta_data VALUES (30, NULL, 30, 'MetaDatumString', 'Deutsches Panorama', 'title');
INSERT INTO meta_data VALUES (31, NULL, 31, 'MetaDatumString', 'Chinese Temple', 'title');
INSERT INTO meta_data VALUES (32, NULL, 32, 'MetaDatumString', 'Splashscreen', 'title');
INSERT INTO meta_data VALUES (33, 3, 33, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (35, NULL, 33, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (37, NULL, 33, 'MetaDatumString', 'Deutzer Hafen in Köln', 'title');
INSERT INTO meta_data VALUES (39, NULL, 33, 'MetaDatumDate', '2002', 'portrayed object dates');
INSERT INTO meta_data VALUES (41, NULL, 33, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (43, NULL, 33, 'MetaDatumString', 'Wilhlem Schulte', 'copyright notice');
INSERT INTO meta_data VALUES (45, NULL, 33, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (47, NULL, 33, 'MetaDatumMetaTerms', NULL, 'portrayed object materials');
INSERT INTO meta_data VALUES (49, NULL, 33, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (51, 3, 35, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (53, NULL, 35, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (55, NULL, 35, 'MetaDatumString', 'Virgin and Child with Saints Catherine and Barbara', 'title');
INSERT INTO meta_data VALUES (57, NULL, 35, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (59, NULL, 35, 'MetaDatumDate', '1470/1500', 'portrayed object dates');
INSERT INTO meta_data VALUES (61, NULL, 35, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (63, NULL, 35, 'MetaDatumString', 'unbekannt', 'copyright notice');
INSERT INTO meta_data VALUES (65, NULL, 37, 'MetaDatumString', 'Abgaben', 'title');
INSERT INTO meta_data VALUES (74, NULL, 38, 'MetaDatumString', 'Fotografie', 'title');
INSERT INTO meta_data VALUES (75, NULL, 33, 'MetaDatumMetaTerms', NULL, 'style');
INSERT INTO meta_data VALUES (76, NULL, 6, 'MetaDatumMetaTerms', NULL, 'style');
INSERT INTO meta_data VALUES (77, NULL, 39, 'MetaDatumString', 'Katalog', 'title');
INSERT INTO meta_data VALUES (78, NULL, 40, 'MetaDatumString', 'Schlagworte', 'title');
INSERT INTO meta_data VALUES (79, NULL, 39, 'MetaDatumString', 'Der Katalog bietet Ihnen die Möglichkeit das Medienarchiv der Künste nach Überraschendem zu erkunden.', 'description');
INSERT INTO meta_data VALUES (80, NULL, 40, 'MetaDatumString', 'Erkunden Sie Medieneinträge mit unterschiedlichsten Schlagworten.', 'description');
INSERT INTO meta_data VALUES (81, NULL, 41, 'MetaDatumString', 'Flurina Gradin', 'copyright notice');
INSERT INTO meta_data VALUES (82, NULL, 41, 'MetaDatumString', 'landjäger1_zett 11_3', 'title');
INSERT INTO meta_data VALUES (83, 13, 41, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (84, NULL, 41, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (85, NULL, 41, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (86, NULL, 41, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (87, NULL, 42, 'MetaDatumString', 'Flurina Gradin', 'copyright notice');
INSERT INTO meta_data VALUES (88, NULL, 42, 'MetaDatumString', 'landjäger2_zett 11_3', 'title');
INSERT INTO meta_data VALUES (89, 13, 42, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (177, NULL, 46, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (1086, NULL, 105, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (90, NULL, 42, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (91, NULL, 42, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (92, NULL, 42, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (93, NULL, 43, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (94, NULL, 43, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (95, NULL, 43, 'MetaDatumDate', '1998', 'date created');
INSERT INTO meta_data VALUES (96, NULL, 43, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (97, NULL, 43, 'MetaDatumDate', '1998', 'portrayed object dates');
INSERT INTO meta_data VALUES (98, NULL, 43, 'MetaDatumMetaTerms', NULL, 'portrayed object materials');
INSERT INTO meta_data VALUES (99, NULL, 43, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (100, NULL, 43, 'MetaDatumString', 'es erscheint die Publikation:
Peter Tillessen - Gold, [Text: Ulf Erdmann Ziegler] Baden, Lars Müller, 2000 ', 'remark');
INSERT INTO meta_data VALUES (101, NULL, 43, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (102, NULL, 43, 'MetaDatumString', 'Zürcher Hochschule der Künste ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (103, NULL, 43, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (104, NULL, 43, 'MetaDatumString', 'Spaziergang', 'title');
INSERT INTO meta_data VALUES (105, NULL, 43, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (106, NULL, 43, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (107, NULL, 43, 'MetaDatumString', 'Zürcher Hochschule der Künste Vertiefung Fotografie', 'provider');
INSERT INTO meta_data VALUES (108, NULL, 43, 'MetaDatumString', 'Diplomarbeit', 'subtitle');
INSERT INTO meta_data VALUES (109, 13, 43, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (110, NULL, 43, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (111, NULL, 43, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (112, NULL, 43, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (113, NULL, 43, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (114, NULL, 44, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (115, NULL, 44, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (116, NULL, 44, 'MetaDatumDate', '1998', 'date created');
INSERT INTO meta_data VALUES (117, NULL, 44, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (118, NULL, 44, 'MetaDatumDate', '1998', 'portrayed object dates');
INSERT INTO meta_data VALUES (119, NULL, 44, 'MetaDatumMetaTerms', NULL, 'portrayed object materials');
INSERT INTO meta_data VALUES (120, NULL, 44, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (121, NULL, 44, 'MetaDatumString', 'es erscheint die Publikation:
Peter Tillessen - Gold, [Text: Ulf Erdmann Ziegler] Baden, Lars Müller, 2000 ', 'remark');
INSERT INTO meta_data VALUES (122, NULL, 44, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (123, NULL, 44, 'MetaDatumString', 'Zürcher Hochschule der Künste ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (124, NULL, 44, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (125, NULL, 44, 'MetaDatumString', 'Spaziergang', 'title');
INSERT INTO meta_data VALUES (126, NULL, 44, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (127, NULL, 44, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (128, NULL, 44, 'MetaDatumString', 'Zürcher Hochschule der Künste Vertiefung Fotografie', 'provider');
INSERT INTO meta_data VALUES (129, NULL, 44, 'MetaDatumString', 'Diplomarbeit', 'subtitle');
INSERT INTO meta_data VALUES (130, 13, 44, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (131, NULL, 44, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (132, NULL, 44, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (133, NULL, 44, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (134, NULL, 44, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (135, NULL, 45, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (136, NULL, 45, 'MetaDatumDate', '10.07.2007', 'date created');
INSERT INTO meta_data VALUES (137, NULL, 45, 'MetaDatumString', 'image/jpeg', 'format');
INSERT INTO meta_data VALUES (138, NULL, 45, 'MetaDatumString', 'http://www.georgeosodi.co.uk/portfolio/permalink/75935/16dfab77b9dcf9', 'hyperlinks');
INSERT INTO meta_data VALUES (139, NULL, 45, 'MetaDatumDate', '10.07.2007', 'portrayed object dates');
INSERT INTO meta_data VALUES (140, NULL, 45, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (141, NULL, 45, 'MetaDatumString', 'Osodi, George', 'copyright notice');
INSERT INTO meta_data VALUES (142, NULL, 45, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (143, NULL, 45, 'MetaDatumString', 'Oil Rich Niger Delta', 'title');
INSERT INTO meta_data VALUES (144, NULL, 45, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (145, NULL, 45, 'MetaDatumString', 'Photographer', 'creator position');
INSERT INTO meta_data VALUES (146, NULL, 45, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (147, NULL, 45, 'MetaDatumString', 'RGB', 'color mode');
INSERT INTO meta_data VALUES (148, NULL, 45, 'MetaDatumString', 'Nigeria', 'portrayed object country');
INSERT INTO meta_data VALUES (149, NULL, 45, 'MetaDatumString', 'Forschungsprojekt "Supply Lines"', 'provider');
INSERT INTO meta_data VALUES (150, NULL, 45, 'MetaDatumString', 'Niger Delta', 'subtitle');
INSERT INTO meta_data VALUES (151, NULL, 45, 'MetaDatumString', 'Nigerdelta', 'portrayed object state');
INSERT INTO meta_data VALUES (152, NULL, 45, 'MetaDatumCountry', 'NG', 'portrayed object country code');
INSERT INTO meta_data VALUES (153, NULL, 45, 'MetaDatumString', 'Nigeria / GB', 'creator country');
INSERT INTO meta_data VALUES (154, NULL, 45, 'MetaDatumString', 'www.georgeosodi.co.uk', 'creator work url');
INSERT INTO meta_data VALUES (155, 13, 45, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (156, NULL, 45, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (157, NULL, 45, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (158, NULL, 45, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (159, NULL, 45, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (160, NULL, 46, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (161, NULL, 46, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (162, NULL, 46, 'MetaDatumDate', '1999', 'date created');
INSERT INTO meta_data VALUES (163, NULL, 46, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (164, NULL, 46, 'MetaDatumDate', '1999', 'portrayed object dates');
INSERT INTO meta_data VALUES (165, NULL, 46, 'MetaDatumMetaTerms', NULL, 'portrayed object materials');
INSERT INTO meta_data VALUES (166, NULL, 46, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (167, NULL, 46, 'MetaDatumString', 'Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.', 'remark');
INSERT INTO meta_data VALUES (168, NULL, 46, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (169, NULL, 46, 'MetaDatumString', 'Zürcher Hochschule der Künste ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (170, NULL, 46, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (171, NULL, 46, 'MetaDatumString', 'Diplom', 'title');
INSERT INTO meta_data VALUES (172, NULL, 46, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (173, NULL, 46, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (174, NULL, 46, 'MetaDatumString', 'Zürcher Hochschule der Künste Vertiefung Fotografie', 'provider');
INSERT INTO meta_data VALUES (175, 13, 46, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (176, NULL, 46, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (178, NULL, 46, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (179, NULL, 46, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (180, NULL, 47, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (181, NULL, 47, 'MetaDatumDate', '22.12.2005', 'date created');
INSERT INTO meta_data VALUES (182, NULL, 47, 'MetaDatumString', 'http://www.georgeosodi.co.uk/portfolio/permalink/75935/16dfab77b9dcf9', 'hyperlinks');
INSERT INTO meta_data VALUES (183, NULL, 47, 'MetaDatumDate', '22.12.2005', 'portrayed object dates');
INSERT INTO meta_data VALUES (184, NULL, 47, 'MetaDatumString', 'XGO105', 'transmission reference');
INSERT INTO meta_data VALUES (185, NULL, 47, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (270, NULL, 52, 'MetaDatumString', 'ASAGBA OKWAN', 'portrayed object city');
INSERT INTO meta_data VALUES (271, NULL, 52, 'MetaDatumString', 'Nigeria', 'portrayed object country');
INSERT INTO meta_data VALUES (272, NULL, 52, 'MetaDatumString', 'Forschungsprojekt "Supply Lines"', 'provider');
INSERT INTO meta_data VALUES (186, NULL, 47, 'MetaDatumString', 'villagers who are evaquating drive pass smoke and flames from a burning oil pipeline belonging to Shell Petroleum Development Company across the Opobo Channel in Asagba Okwan Asarama about 50km south-west of Port Harcourt, Nigeria, Thursday, Dec. 22 2005.( Photo/George Osodi)', 'description');
INSERT INTO meta_data VALUES (187, NULL, 47, 'MetaDatumString', 'Osodi, George', 'copyright notice');
INSERT INTO meta_data VALUES (188, NULL, 47, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (189, NULL, 47, 'MetaDatumString', 'Oil Rich Niger Delta', 'title');
INSERT INTO meta_data VALUES (190, NULL, 47, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (191, NULL, 47, 'MetaDatumString', 'Photographer', 'creator position');
INSERT INTO meta_data VALUES (192, NULL, 47, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (193, NULL, 47, 'MetaDatumString', 'I', 'category');
INSERT INTO meta_data VALUES (194, NULL, 47, 'MetaDatumString', 'ASAGBA OKWAN', 'portrayed object city');
INSERT INTO meta_data VALUES (195, NULL, 47, 'MetaDatumString', 'Nigeria', 'portrayed object country');
INSERT INTO meta_data VALUES (196, NULL, 47, 'MetaDatumString', 'Forschungsprojekt "Supply Lines"', 'provider');
INSERT INTO meta_data VALUES (197, NULL, 47, 'MetaDatumString', 'Niger Delta', 'subtitle');
INSERT INTO meta_data VALUES (198, NULL, 47, 'MetaDatumString', 'AP', 'source');
INSERT INTO meta_data VALUES (199, NULL, 47, 'MetaDatumString', 'Nigerdelta', 'portrayed object state');
INSERT INTO meta_data VALUES (200, NULL, 47, 'MetaDatumCountry', 'NG', 'portrayed object country code');
INSERT INTO meta_data VALUES (201, NULL, 47, 'MetaDatumString', 'Nigeria / GB', 'creator country');
INSERT INTO meta_data VALUES (202, NULL, 47, 'MetaDatumString', 'www.georgeosodi.co.uk', 'creator work url');
INSERT INTO meta_data VALUES (203, 13, 47, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (204, NULL, 47, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (205, NULL, 47, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (206, NULL, 47, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (207, NULL, 47, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (208, NULL, 48, 'MetaDatumString', 'Flurina Gradin', 'copyright notice');
INSERT INTO meta_data VALUES (209, NULL, 48, 'MetaDatumString', 'landjäger2_zett 11_3', 'title');
INSERT INTO meta_data VALUES (210, 13, 48, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (211, NULL, 48, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (212, NULL, 48, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (213, NULL, 48, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (214, NULL, 49, 'MetaDatumString', 'Flurina Gradin', 'copyright notice');
INSERT INTO meta_data VALUES (215, NULL, 49, 'MetaDatumString', 'landjäger1_zett 11_3', 'title');
INSERT INTO meta_data VALUES (216, 13, 49, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (217, NULL, 49, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (218, NULL, 49, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (219, NULL, 49, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (220, NULL, 50, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (221, NULL, 50, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (222, NULL, 50, 'MetaDatumDate', '1999', 'date created');
INSERT INTO meta_data VALUES (223, NULL, 50, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (224, NULL, 50, 'MetaDatumDate', '1999', 'portrayed object dates');
INSERT INTO meta_data VALUES (225, NULL, 50, 'MetaDatumMetaTerms', NULL, 'portrayed object materials');
INSERT INTO meta_data VALUES (226, NULL, 50, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (327, NULL, 56, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (328, NULL, 56, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (329, NULL, 56, 'MetaDatumString', 'ZHdK DKM VMK', 'copyright notice');
INSERT INTO meta_data VALUES (330, NULL, 56, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (227, NULL, 50, 'MetaDatumString', 'Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.', 'remark');
INSERT INTO meta_data VALUES (228, NULL, 50, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (229, NULL, 50, 'MetaDatumString', 'Zürcher Hochschule der Künste ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (230, NULL, 50, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (231, NULL, 50, 'MetaDatumString', 'Diplom', 'title');
INSERT INTO meta_data VALUES (232, NULL, 50, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (233, NULL, 50, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (234, NULL, 50, 'MetaDatumString', 'Zürcher Hochschule der Künste Vertiefung Fotografie', 'provider');
INSERT INTO meta_data VALUES (235, 13, 50, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (236, NULL, 50, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (237, NULL, 50, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (238, NULL, 50, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (239, NULL, 50, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (240, NULL, 51, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (241, NULL, 51, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (242, NULL, 51, 'MetaDatumDate', '2012', 'date created');
INSERT INTO meta_data VALUES (243, NULL, 51, 'MetaDatumString', 'image/tiff', 'format');
INSERT INTO meta_data VALUES (244, NULL, 51, 'MetaDatumDate', '2012', 'portrayed object dates');
INSERT INTO meta_data VALUES (245, NULL, 51, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (246, NULL, 51, 'MetaDatumString', 'ZHdK DKM VMK', 'copyright notice');
INSERT INTO meta_data VALUES (247, NULL, 51, 'MetaDatumString', 'suche_system[xx,y]', 'title');
INSERT INTO meta_data VALUES (248, NULL, 51, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (249, NULL, 51, 'MetaDatumString', 'RGB', 'color mode');
INSERT INTO meta_data VALUES (250, NULL, 51, 'MetaDatumString', 'Eine kollektive Suchbewegung.', 'subtitle');
INSERT INTO meta_data VALUES (251, NULL, 51, 'MetaDatumString', 'Vertiefung Mediale Künste, Sihlquai 131, 8005 Zürich', 'portrayed object location');
INSERT INTO meta_data VALUES (252, 13, 51, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (253, NULL, 51, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (254, NULL, 51, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (255, NULL, 51, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (256, NULL, 52, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (257, NULL, 52, 'MetaDatumDate', '22.12.2005', 'date created');
INSERT INTO meta_data VALUES (258, NULL, 52, 'MetaDatumString', 'http://www.georgeosodi.co.uk/portfolio/permalink/75935/16dfab77b9dcf9', 'hyperlinks');
INSERT INTO meta_data VALUES (259, NULL, 52, 'MetaDatumDate', '22.12.2005', 'portrayed object dates');
INSERT INTO meta_data VALUES (260, NULL, 52, 'MetaDatumString', 'XGO105', 'transmission reference');
INSERT INTO meta_data VALUES (261, NULL, 52, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (262, NULL, 52, 'MetaDatumString', 'villagers who are evaquating drive pass smoke and flames from a burning oil pipeline belonging to Shell Petroleum Development Company across the Opobo Channel in Asagba Okwan Asarama about 50km south-west of Port Harcourt, Nigeria, Thursday, Dec. 22 2005.( Photo/George Osodi)', 'description');
INSERT INTO meta_data VALUES (263, NULL, 52, 'MetaDatumString', 'Osodi, George', 'copyright notice');
INSERT INTO meta_data VALUES (264, NULL, 52, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (265, NULL, 52, 'MetaDatumString', 'Oil Rich Niger Delta', 'title');
INSERT INTO meta_data VALUES (266, NULL, 52, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (267, NULL, 52, 'MetaDatumString', 'Photographer', 'creator position');
INSERT INTO meta_data VALUES (268, NULL, 52, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (269, NULL, 52, 'MetaDatumString', 'I', 'category');
INSERT INTO meta_data VALUES (457, NULL, 64, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (273, NULL, 52, 'MetaDatumString', 'Niger Delta', 'subtitle');
INSERT INTO meta_data VALUES (274, NULL, 52, 'MetaDatumString', 'AP', 'source');
INSERT INTO meta_data VALUES (275, NULL, 52, 'MetaDatumString', 'Nigerdelta', 'portrayed object state');
INSERT INTO meta_data VALUES (276, NULL, 52, 'MetaDatumCountry', 'NG', 'portrayed object country code');
INSERT INTO meta_data VALUES (277, NULL, 52, 'MetaDatumString', 'Nigeria / GB', 'creator country');
INSERT INTO meta_data VALUES (278, NULL, 52, 'MetaDatumString', 'www.georgeosodi.co.uk', 'creator work url');
INSERT INTO meta_data VALUES (279, 13, 52, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (280, NULL, 52, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (281, NULL, 52, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (282, NULL, 52, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (283, NULL, 52, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (284, NULL, 53, 'MetaDatumDate', '2012:09:26 11:49:27.032', 'date created');
INSERT INTO meta_data VALUES (285, NULL, 53, 'MetaDatumString', 'image/jpeg', 'format');
INSERT INTO meta_data VALUES (286, NULL, 53, 'MetaDatumString', 'ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (287, NULL, 53, 'MetaDatumString', 'Z+', 'title');
INSERT INTO meta_data VALUES (288, NULL, 53, 'MetaDatumString', 'RGB', 'color mode');
INSERT INTO meta_data VALUES (289, 13, 53, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (290, NULL, 53, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (291, NULL, 53, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (292, NULL, 53, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (293, NULL, 54, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (294, NULL, 54, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (295, NULL, 54, 'MetaDatumDate', '1999', 'date created');
INSERT INTO meta_data VALUES (296, NULL, 54, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (297, NULL, 54, 'MetaDatumDate', '1999', 'portrayed object dates');
INSERT INTO meta_data VALUES (298, NULL, 54, 'MetaDatumMetaTerms', NULL, 'portrayed object materials');
INSERT INTO meta_data VALUES (299, NULL, 54, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (300, NULL, 54, 'MetaDatumString', 'Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.', 'remark');
INSERT INTO meta_data VALUES (301, NULL, 54, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (302, NULL, 54, 'MetaDatumString', 'Zürcher Hochschule der Künste ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (303, NULL, 54, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (304, NULL, 54, 'MetaDatumString', 'Diplom', 'title');
INSERT INTO meta_data VALUES (305, NULL, 54, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (306, NULL, 54, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (307, NULL, 54, 'MetaDatumString', 'Zürcher Hochschule der Künste Vertiefung Fotografie', 'provider');
INSERT INTO meta_data VALUES (308, 13, 54, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (309, NULL, 54, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (310, NULL, 54, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (311, NULL, 54, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (312, NULL, 54, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (313, NULL, 55, 'MetaDatumString', 'ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (314, NULL, 55, 'MetaDatumString', 'Design Artikel, Michael Krohn', 'title');
INSERT INTO meta_data VALUES (315, 13, 55, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (316, NULL, 55, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (317, NULL, 55, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (318, NULL, 55, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (319, NULL, 56, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (320, NULL, 56, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (321, NULL, 56, 'MetaDatumDate', '2012', 'date created');
INSERT INTO meta_data VALUES (322, NULL, 56, 'MetaDatumString', 'image/tiff', 'format');
INSERT INTO meta_data VALUES (323, NULL, 56, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (324, NULL, 56, 'MetaDatumDate', '2012', 'portrayed object dates');
INSERT INTO meta_data VALUES (325, NULL, 56, 'MetaDatumString', '5 Min., Loop', 'portrayed object dimensions');
INSERT INTO meta_data VALUES (326, NULL, 56, 'MetaDatumMetaTerms', NULL, 'portrayed object materials');
INSERT INTO meta_data VALUES (331, NULL, 56, 'MetaDatumString', 'stimme-sprach-raum-teil3', 'title');
INSERT INTO meta_data VALUES (332, NULL, 56, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (333, NULL, 56, 'MetaDatumString', 'RGB', 'color mode');
INSERT INTO meta_data VALUES (334, NULL, 56, 'MetaDatumString', 'Vertiefung Mediale Künste, Sihlquai 131, 8005 Zürich', 'portrayed object location');
INSERT INTO meta_data VALUES (335, 13, 56, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (336, NULL, 56, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (337, NULL, 56, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (338, NULL, 56, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (339, NULL, 57, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (340, NULL, 57, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (341, NULL, 57, 'MetaDatumDate', '1999', 'date created');
INSERT INTO meta_data VALUES (342, NULL, 57, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (343, NULL, 57, 'MetaDatumDate', '1999', 'portrayed object dates');
INSERT INTO meta_data VALUES (344, NULL, 57, 'MetaDatumMetaTerms', NULL, 'portrayed object materials');
INSERT INTO meta_data VALUES (345, NULL, 57, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (346, NULL, 57, 'MetaDatumString', 'Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.', 'remark');
INSERT INTO meta_data VALUES (347, NULL, 57, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (611, NULL, 75, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (348, NULL, 57, 'MetaDatumString', 'Zürcher Hochschule der Künste ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (349, NULL, 57, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (350, NULL, 57, 'MetaDatumString', 'Diplom', 'title');
INSERT INTO meta_data VALUES (351, NULL, 57, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (352, NULL, 57, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (353, NULL, 57, 'MetaDatumString', 'Zürcher Hochschule der Künste Vertiefung Fotografie', 'provider');
INSERT INTO meta_data VALUES (354, 13, 57, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (355, NULL, 57, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (356, NULL, 57, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (357, NULL, 57, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (358, NULL, 57, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (359, NULL, 58, 'MetaDatumDate', '2012:05:30 23:57:41.005', 'date created');
INSERT INTO meta_data VALUES (360, NULL, 58, 'MetaDatumString', 'image/jpeg', 'format');
INSERT INTO meta_data VALUES (361, NULL, 58, 'MetaDatumString', 'Die Gartenküche canorta erlaubt spontane Öffentlichkeit.', 'public caption');
INSERT INTO meta_data VALUES (362, NULL, 58, 'MetaDatumString', 'Reto Togni und Dominique Schmutz ', 'copyright notice');
INSERT INTO meta_data VALUES (363, NULL, 58, 'MetaDatumString', 'Canorta', 'title');
INSERT INTO meta_data VALUES (364, NULL, 58, 'MetaDatumString', 'RGB', 'color mode');
INSERT INTO meta_data VALUES (365, 13, 58, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (458, NULL, 64, 'MetaDatumString', 'Diplom', 'title');
INSERT INTO meta_data VALUES (459, NULL, 64, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (366, NULL, 58, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (367, NULL, 58, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (368, NULL, 58, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (369, NULL, 59, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (370, NULL, 59, 'MetaDatumDate', '2012:06:06 11:41:53.059', 'date created');
INSERT INTO meta_data VALUES (371, NULL, 59, 'MetaDatumString', 'image/tiff', 'format');
INSERT INTO meta_data VALUES (372, NULL, 59, 'MetaDatumDate', '2012', 'portrayed object dates');
INSERT INTO meta_data VALUES (373, NULL, 59, 'MetaDatumString', '18:13 Min.', 'portrayed object dimensions');
INSERT INTO meta_data VALUES (374, NULL, 59, 'MetaDatumString', 'ZHdK DKM VMK', 'copyright notice');
INSERT INTO meta_data VALUES (375, NULL, 59, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (376, NULL, 59, 'MetaDatumString', 'stribog_13_meets_electra', 'title');
INSERT INTO meta_data VALUES (377, NULL, 59, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (378, NULL, 59, 'MetaDatumString', 'RGB', 'color mode');
INSERT INTO meta_data VALUES (379, 13, 59, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (380, NULL, 59, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (381, NULL, 59, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (382, NULL, 59, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (383, NULL, 60, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (384, NULL, 60, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (385, NULL, 60, 'MetaDatumDate', '1999', 'date created');
INSERT INTO meta_data VALUES (386, NULL, 60, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (387, NULL, 60, 'MetaDatumDate', '1999', 'portrayed object dates');
INSERT INTO meta_data VALUES (388, NULL, 60, 'MetaDatumMetaTerms', NULL, 'portrayed object materials');
INSERT INTO meta_data VALUES (389, NULL, 60, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (390, NULL, 60, 'MetaDatumString', 'Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.', 'remark');
INSERT INTO meta_data VALUES (391, NULL, 60, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (392, NULL, 60, 'MetaDatumString', 'Zürcher Hochschule der Künste ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (393, NULL, 60, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (394, NULL, 60, 'MetaDatumString', 'Diplom', 'title');
INSERT INTO meta_data VALUES (395, NULL, 60, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (396, NULL, 60, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (397, NULL, 60, 'MetaDatumString', 'Zürcher Hochschule der Künste Vertiefung Fotografie', 'provider');
INSERT INTO meta_data VALUES (398, 13, 60, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (399, NULL, 60, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (400, NULL, 60, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (401, NULL, 60, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (402, NULL, 60, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (403, NULL, 61, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (404, NULL, 61, 'MetaDatumDate', '2012', 'date created');
INSERT INTO meta_data VALUES (405, NULL, 61, 'MetaDatumString', 'image/tiff', 'format');
INSERT INTO meta_data VALUES (406, NULL, 61, 'MetaDatumDate', '2012', 'portrayed object dates');
INSERT INTO meta_data VALUES (407, NULL, 61, 'MetaDatumString', 'ZHdK DKM VMK', 'copyright notice');
INSERT INTO meta_data VALUES (408, NULL, 61, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (409, NULL, 61, 'MetaDatumString', 'Arbeitsraum mit unbestimmten Ausgängen', 'title');
INSERT INTO meta_data VALUES (410, NULL, 61, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (411, NULL, 61, 'MetaDatumString', 'RGB', 'color mode');
INSERT INTO meta_data VALUES (412, NULL, 61, 'MetaDatumString', 'Vertiefung Mediale Künste, Sihlquai 131, 8005 Zürich', 'portrayed object location');
INSERT INTO meta_data VALUES (413, 13, 61, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (414, NULL, 61, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (415, NULL, 61, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (416, NULL, 61, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (417, NULL, 62, 'MetaDatumDate', '2011', 'portrayed object dates');
INSERT INTO meta_data VALUES (418, NULL, 62, 'MetaDatumString', 'Scheiber Dahou, Judith', 'copyright notice');
INSERT INTO meta_data VALUES (419, NULL, 62, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (420, NULL, 62, 'MetaDatumString', 'Seerosen', 'title');
INSERT INTO meta_data VALUES (421, NULL, 62, 'MetaDatumString', 'Der schwimmende Garten', 'subtitle');
INSERT INTO meta_data VALUES (422, 13, 62, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (423, NULL, 62, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (424, NULL, 62, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (425, NULL, 62, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (426, NULL, 63, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (427, NULL, 63, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (428, NULL, 63, 'MetaDatumDate', '1998', 'date created');
INSERT INTO meta_data VALUES (429, NULL, 63, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (430, NULL, 63, 'MetaDatumDate', '1998', 'portrayed object dates');
INSERT INTO meta_data VALUES (431, NULL, 63, 'MetaDatumMetaTerms', NULL, 'portrayed object materials');
INSERT INTO meta_data VALUES (432, NULL, 63, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (639, NULL, 76, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (433, NULL, 63, 'MetaDatumString', 'es erscheint die Publikation:
Peter Tillessen - Gold, [Text: Ulf Erdmann Ziegler] Baden, Lars Müller, 2000 ', 'remark');
INSERT INTO meta_data VALUES (434, NULL, 63, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (435, NULL, 63, 'MetaDatumString', 'Zürcher Hochschule der Künste ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (436, NULL, 63, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (437, NULL, 63, 'MetaDatumString', 'Spaziergang', 'title');
INSERT INTO meta_data VALUES (438, NULL, 63, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (439, NULL, 63, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (440, NULL, 63, 'MetaDatumString', 'Zürcher Hochschule der Künste Vertiefung Fotografie', 'provider');
INSERT INTO meta_data VALUES (441, NULL, 63, 'MetaDatumString', 'Diplomarbeit', 'subtitle');
INSERT INTO meta_data VALUES (442, 13, 63, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (443, NULL, 63, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (444, NULL, 63, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (445, NULL, 63, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (446, NULL, 63, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (447, NULL, 64, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (448, NULL, 64, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (449, NULL, 64, 'MetaDatumDate', '1999', 'date created');
INSERT INTO meta_data VALUES (450, NULL, 64, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (451, NULL, 64, 'MetaDatumDate', '1999', 'portrayed object dates');
INSERT INTO meta_data VALUES (452, NULL, 64, 'MetaDatumMetaTerms', NULL, 'portrayed object materials');
INSERT INTO meta_data VALUES (453, NULL, 64, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (454, NULL, 64, 'MetaDatumString', 'Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.', 'remark');
INSERT INTO meta_data VALUES (455, NULL, 64, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (456, NULL, 64, 'MetaDatumString', 'Zürcher Hochschule der Künste ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (460, NULL, 64, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (461, NULL, 64, 'MetaDatumString', 'Zürcher Hochschule der Künste Vertiefung Fotografie', 'provider');
INSERT INTO meta_data VALUES (462, 13, 64, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (463, NULL, 64, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (464, NULL, 64, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (465, NULL, 64, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (466, NULL, 64, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (467, 3, 65, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (468, NULL, 65, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (469, NULL, 66, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (470, NULL, 66, 'MetaDatumDate', '2012', 'date created');
INSERT INTO meta_data VALUES (471, NULL, 66, 'MetaDatumString', 'image/tiff', 'format');
INSERT INTO meta_data VALUES (472, NULL, 66, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (473, NULL, 66, 'MetaDatumDate', '2012', 'portrayed object dates');
INSERT INTO meta_data VALUES (474, NULL, 66, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (475, NULL, 66, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (476, NULL, 66, 'MetaDatumString', 'ZHdK DKM VMK', 'copyright notice');
INSERT INTO meta_data VALUES (477, NULL, 66, 'MetaDatumString', 'Leerschlag [ ]', 'title');
INSERT INTO meta_data VALUES (478, NULL, 66, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (479, NULL, 66, 'MetaDatumString', 'RGB', 'color mode');
INSERT INTO meta_data VALUES (480, NULL, 66, 'MetaDatumString', 'Vernissage', 'subtitle');
INSERT INTO meta_data VALUES (481, NULL, 66, 'MetaDatumString', 'Vertiefung Mediale Künste, Sihlquai 131, 8005 Zürich', 'portrayed object location');
INSERT INTO meta_data VALUES (482, 13, 66, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (483, NULL, 66, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (484, NULL, 66, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (485, NULL, 66, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (486, NULL, 65, 'MetaDatumString', 'Water Oil', 'title');
INSERT INTO meta_data VALUES (487, NULL, 65, 'MetaDatumString', 'unbekannt', 'copyright notice');
INSERT INTO meta_data VALUES (488, NULL, 67, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (489, NULL, 67, 'MetaDatumDate', '1995', 'portrayed object dates');
INSERT INTO meta_data VALUES (490, NULL, 67, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (491, NULL, 67, 'MetaDatumString', 'Zürcher Hochschule der Künste ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (492, NULL, 67, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (493, NULL, 67, 'MetaDatumString', 'Letten it be', 'title');
INSERT INTO meta_data VALUES (494, NULL, 67, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (495, NULL, 67, 'MetaDatumString', 'Zürcher Hochschule der Künste Vertiefung Fotografie', 'provider');
INSERT INTO meta_data VALUES (496, 13, 67, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (497, NULL, 67, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (498, NULL, 67, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (499, NULL, 67, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (500, NULL, 67, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (501, NULL, 68, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (502, NULL, 68, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (503, NULL, 68, 'MetaDatumDate', '1998', 'date created');
INSERT INTO meta_data VALUES (504, NULL, 68, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (505, NULL, 68, 'MetaDatumDate', '1998', 'portrayed object dates');
INSERT INTO meta_data VALUES (506, NULL, 68, 'MetaDatumMetaTerms', NULL, 'portrayed object materials');
INSERT INTO meta_data VALUES (507, NULL, 68, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (508, NULL, 68, 'MetaDatumString', 'es erscheint die Publikation:
Peter Tillessen - Gold, [Text: Ulf Erdmann Ziegler] Baden, Lars Müller, 2000 ', 'remark');
INSERT INTO meta_data VALUES (509, NULL, 68, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (510, NULL, 68, 'MetaDatumString', 'Zürcher Hochschule der Künste ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (511, NULL, 68, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (512, NULL, 68, 'MetaDatumString', 'Spaziergang', 'title');
INSERT INTO meta_data VALUES (513, NULL, 68, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (514, NULL, 68, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (515, NULL, 68, 'MetaDatumString', 'Zürcher Hochschule der Künste Vertiefung Fotografie', 'provider');
INSERT INTO meta_data VALUES (516, NULL, 68, 'MetaDatumString', 'Diplomarbeit', 'subtitle');
INSERT INTO meta_data VALUES (517, 13, 68, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (518, NULL, 68, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (519, NULL, 68, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (520, NULL, 68, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (521, NULL, 68, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (522, NULL, 69, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (523, NULL, 69, 'MetaDatumString', 'image/jpeg', 'format');
INSERT INTO meta_data VALUES (524, NULL, 69, 'MetaDatumDate', '1934', 'portrayed object dates');
INSERT INTO meta_data VALUES (525, NULL, 69, 'MetaDatumString', 'Zürcher Hochschule der Künste, ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (526, NULL, 69, 'MetaDatumString', 'PKZ', 'title');
INSERT INTO meta_data VALUES (527, 13, 69, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (528, NULL, 69, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (529, NULL, 69, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (530, NULL, 69, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (531, NULL, 70, 'MetaDatumDate', '1995', 'portrayed object dates');
INSERT INTO meta_data VALUES (532, NULL, 70, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (533, NULL, 70, 'MetaDatumString', 'Zürcher Hochschule der Künste ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (534, NULL, 70, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (535, NULL, 70, 'MetaDatumString', 'Inkognito', 'title');
INSERT INTO meta_data VALUES (536, NULL, 70, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (640, NULL, 76, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (537, NULL, 70, 'MetaDatumString', 'Zürcher Hochschule der Künste Vertiefung Fotografie', 'provider');
INSERT INTO meta_data VALUES (538, 13, 70, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (539, NULL, 70, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (540, NULL, 70, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (541, NULL, 70, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (542, NULL, 70, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (543, 3, 71, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (544, NULL, 71, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (545, NULL, 72, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (546, NULL, 72, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (547, NULL, 72, 'MetaDatumDate', '1998', 'date created');
INSERT INTO meta_data VALUES (548, NULL, 72, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (549, NULL, 72, 'MetaDatumDate', '1998', 'portrayed object dates');
INSERT INTO meta_data VALUES (550, NULL, 72, 'MetaDatumMetaTerms', NULL, 'portrayed object materials');
INSERT INTO meta_data VALUES (551, NULL, 72, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (552, NULL, 72, 'MetaDatumString', 'es erscheint die Publikation:
Peter Tillessen - Gold, [Text: Ulf Erdmann Ziegler] Baden, Lars Müller, 2000 ', 'remark');
INSERT INTO meta_data VALUES (553, NULL, 72, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (732, NULL, 81, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (554, NULL, 72, 'MetaDatumString', 'Zürcher Hochschule der Künste ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (555, NULL, 72, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (556, NULL, 72, 'MetaDatumString', 'Spaziergang', 'title');
INSERT INTO meta_data VALUES (557, NULL, 72, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (558, NULL, 72, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (559, NULL, 72, 'MetaDatumString', 'Zürcher Hochschule der Künste Vertiefung Fotografie', 'provider');
INSERT INTO meta_data VALUES (560, NULL, 72, 'MetaDatumString', 'Diplomarbeit', 'subtitle');
INSERT INTO meta_data VALUES (561, 13, 72, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (562, NULL, 72, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (563, NULL, 72, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (564, NULL, 72, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (565, NULL, 72, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (566, NULL, 73, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (567, NULL, 73, 'MetaDatumDate', '10.07.2007', 'date created');
INSERT INTO meta_data VALUES (568, NULL, 73, 'MetaDatumString', 'image/jpeg', 'format');
INSERT INTO meta_data VALUES (569, NULL, 73, 'MetaDatumString', 'http://www.georgeosodi.co.uk/portfolio/permalink/75935/16dfab77b9dcf9', 'hyperlinks');
INSERT INTO meta_data VALUES (570, NULL, 73, 'MetaDatumDate', '10.07.2007', 'portrayed object dates');
INSERT INTO meta_data VALUES (571, NULL, 73, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (572, NULL, 73, 'MetaDatumString', 'Osodi, George', 'copyright notice');
INSERT INTO meta_data VALUES (573, NULL, 73, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (574, NULL, 73, 'MetaDatumString', 'Oil Rich Niger Delta', 'title');
INSERT INTO meta_data VALUES (575, NULL, 73, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (576, NULL, 73, 'MetaDatumString', 'Photographer', 'creator position');
INSERT INTO meta_data VALUES (577, NULL, 73, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (578, NULL, 73, 'MetaDatumString', 'RGB', 'color mode');
INSERT INTO meta_data VALUES (579, NULL, 73, 'MetaDatumString', 'Nigeria', 'portrayed object country');
INSERT INTO meta_data VALUES (580, NULL, 73, 'MetaDatumString', 'Forschungsprojekt "Supply Lines"', 'provider');
INSERT INTO meta_data VALUES (581, NULL, 73, 'MetaDatumString', 'Niger Delta', 'subtitle');
INSERT INTO meta_data VALUES (582, NULL, 73, 'MetaDatumString', 'Nigerdelta', 'portrayed object state');
INSERT INTO meta_data VALUES (583, NULL, 73, 'MetaDatumCountry', 'NG', 'portrayed object country code');
INSERT INTO meta_data VALUES (584, NULL, 73, 'MetaDatumString', 'Nigeria / GB', 'creator country');
INSERT INTO meta_data VALUES (585, NULL, 73, 'MetaDatumString', 'www.georgeosodi.co.uk', 'creator work url');
INSERT INTO meta_data VALUES (586, 13, 73, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (587, NULL, 73, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (588, NULL, 73, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (589, NULL, 73, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (590, NULL, 73, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (591, NULL, 74, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (592, NULL, 74, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (593, NULL, 74, 'MetaDatumDate', '1999', 'date created');
INSERT INTO meta_data VALUES (594, NULL, 74, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (595, NULL, 74, 'MetaDatumDate', '1999', 'portrayed object dates');
INSERT INTO meta_data VALUES (596, NULL, 74, 'MetaDatumMetaTerms', NULL, 'portrayed object materials');
INSERT INTO meta_data VALUES (597, NULL, 74, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (598, NULL, 74, 'MetaDatumString', 'Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.', 'remark');
INSERT INTO meta_data VALUES (599, NULL, 74, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (600, NULL, 74, 'MetaDatumString', 'Zürcher Hochschule der Künste ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (601, NULL, 74, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (602, NULL, 74, 'MetaDatumString', 'Diplom', 'title');
INSERT INTO meta_data VALUES (603, NULL, 74, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (604, NULL, 74, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (605, NULL, 74, 'MetaDatumString', 'Zürcher Hochschule der Künste Vertiefung Fotografie', 'provider');
INSERT INTO meta_data VALUES (606, 13, 74, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (607, NULL, 74, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (608, NULL, 74, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (609, NULL, 74, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (610, NULL, 74, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (612, NULL, 75, 'MetaDatumDate', '22.12.2005', 'date created');
INSERT INTO meta_data VALUES (613, NULL, 75, 'MetaDatumString', 'http://www.georgeosodi.co.uk/portfolio/permalink/75935/16dfab77b9dcf9', 'hyperlinks');
INSERT INTO meta_data VALUES (614, NULL, 75, 'MetaDatumDate', '22.12.2005', 'portrayed object dates');
INSERT INTO meta_data VALUES (615, NULL, 75, 'MetaDatumString', 'XGO105', 'transmission reference');
INSERT INTO meta_data VALUES (616, NULL, 75, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (617, NULL, 75, 'MetaDatumString', 'villagers who are evaquating drive pass smoke and flames from a burning oil pipeline belonging to Shell Petroleum Development Company across the Opobo Channel in Asagba Okwan Asarama about 50km south-west of Port Harcourt, Nigeria, Thursday, Dec. 22 2005.( Photo/George Osodi)', 'description');
INSERT INTO meta_data VALUES (618, NULL, 75, 'MetaDatumString', 'Osodi, George', 'copyright notice');
INSERT INTO meta_data VALUES (619, NULL, 75, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (620, NULL, 75, 'MetaDatumString', 'Oil Rich Niger Delta', 'title');
INSERT INTO meta_data VALUES (621, NULL, 75, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (622, NULL, 75, 'MetaDatumString', 'Photographer', 'creator position');
INSERT INTO meta_data VALUES (623, NULL, 75, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (624, NULL, 75, 'MetaDatumString', 'I', 'category');
INSERT INTO meta_data VALUES (625, NULL, 75, 'MetaDatumString', 'ASAGBA OKWAN', 'portrayed object city');
INSERT INTO meta_data VALUES (626, NULL, 75, 'MetaDatumString', 'Nigeria', 'portrayed object country');
INSERT INTO meta_data VALUES (627, NULL, 75, 'MetaDatumString', 'Forschungsprojekt "Supply Lines"', 'provider');
INSERT INTO meta_data VALUES (628, NULL, 75, 'MetaDatumString', 'Niger Delta', 'subtitle');
INSERT INTO meta_data VALUES (629, NULL, 75, 'MetaDatumString', 'AP', 'source');
INSERT INTO meta_data VALUES (630, NULL, 75, 'MetaDatumString', 'Nigerdelta', 'portrayed object state');
INSERT INTO meta_data VALUES (631, NULL, 75, 'MetaDatumCountry', 'NG', 'portrayed object country code');
INSERT INTO meta_data VALUES (632, NULL, 75, 'MetaDatumString', 'Nigeria / GB', 'creator country');
INSERT INTO meta_data VALUES (633, NULL, 75, 'MetaDatumString', 'www.georgeosodi.co.uk', 'creator work url');
INSERT INTO meta_data VALUES (634, 13, 75, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (635, NULL, 75, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (636, NULL, 75, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (637, NULL, 75, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (638, NULL, 75, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (641, NULL, 76, 'MetaDatumDate', '1999', 'date created');
INSERT INTO meta_data VALUES (642, NULL, 76, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (643, NULL, 76, 'MetaDatumDate', '1999', 'portrayed object dates');
INSERT INTO meta_data VALUES (644, NULL, 76, 'MetaDatumMetaTerms', NULL, 'portrayed object materials');
INSERT INTO meta_data VALUES (645, NULL, 76, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (733, NULL, 81, 'MetaDatumString', 'Diplom', 'title');
INSERT INTO meta_data VALUES (734, NULL, 81, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (646, NULL, 76, 'MetaDatumString', 'Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.', 'remark');
INSERT INTO meta_data VALUES (647, NULL, 76, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (648, NULL, 76, 'MetaDatumString', 'Zürcher Hochschule der Künste ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (649, NULL, 76, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (650, NULL, 76, 'MetaDatumString', 'Diplom', 'title');
INSERT INTO meta_data VALUES (651, NULL, 76, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (652, NULL, 76, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (653, NULL, 76, 'MetaDatumString', 'Zürcher Hochschule der Künste Vertiefung Fotografie', 'provider');
INSERT INTO meta_data VALUES (654, 13, 76, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (655, NULL, 76, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (656, NULL, 76, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (657, NULL, 76, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (658, NULL, 76, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (659, NULL, 77, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (660, NULL, 77, 'MetaDatumDate', '22.12.2005', 'date created');
INSERT INTO meta_data VALUES (661, NULL, 77, 'MetaDatumString', 'http://www.georgeosodi.co.uk/portfolio/permalink/75935/16dfab77b9dcf9', 'hyperlinks');
INSERT INTO meta_data VALUES (662, NULL, 77, 'MetaDatumDate', '22.12.2005', 'portrayed object dates');
INSERT INTO meta_data VALUES (663, NULL, 77, 'MetaDatumString', 'XGO105', 'transmission reference');
INSERT INTO meta_data VALUES (664, NULL, 77, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (665, NULL, 77, 'MetaDatumString', 'villagers who are evaquating drive pass smoke and flames from a burning oil pipeline belonging to Shell Petroleum Development Company across the Opobo Channel in Asagba Okwan Asarama about 50km south-west of Port Harcourt, Nigeria, Thursday, Dec. 22 2005.( Photo/George Osodi)', 'description');
INSERT INTO meta_data VALUES (666, NULL, 77, 'MetaDatumString', 'Osodi, George', 'copyright notice');
INSERT INTO meta_data VALUES (667, NULL, 77, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (668, NULL, 77, 'MetaDatumString', 'Oil Rich Niger Delta', 'title');
INSERT INTO meta_data VALUES (669, NULL, 77, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (670, NULL, 77, 'MetaDatumString', 'Photographer', 'creator position');
INSERT INTO meta_data VALUES (671, NULL, 77, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (672, NULL, 77, 'MetaDatumString', 'I', 'category');
INSERT INTO meta_data VALUES (673, NULL, 77, 'MetaDatumString', 'ASAGBA OKWAN', 'portrayed object city');
INSERT INTO meta_data VALUES (674, NULL, 77, 'MetaDatumString', 'Nigeria', 'portrayed object country');
INSERT INTO meta_data VALUES (675, NULL, 77, 'MetaDatumString', 'Forschungsprojekt "Supply Lines"', 'provider');
INSERT INTO meta_data VALUES (676, NULL, 77, 'MetaDatumString', 'Niger Delta', 'subtitle');
INSERT INTO meta_data VALUES (677, NULL, 77, 'MetaDatumString', 'AP', 'source');
INSERT INTO meta_data VALUES (678, NULL, 77, 'MetaDatumString', 'Nigerdelta', 'portrayed object state');
INSERT INTO meta_data VALUES (679, NULL, 77, 'MetaDatumCountry', 'NG', 'portrayed object country code');
INSERT INTO meta_data VALUES (680, NULL, 77, 'MetaDatumString', 'Nigeria / GB', 'creator country');
INSERT INTO meta_data VALUES (681, NULL, 77, 'MetaDatumString', 'www.georgeosodi.co.uk', 'creator work url');
INSERT INTO meta_data VALUES (682, 13, 77, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (683, NULL, 77, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (684, NULL, 77, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (685, NULL, 77, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (686, NULL, 77, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (687, NULL, 78, 'MetaDatumDate', '2012:09:26 11:49:27.032', 'date created');
INSERT INTO meta_data VALUES (688, NULL, 78, 'MetaDatumString', 'image/jpeg', 'format');
INSERT INTO meta_data VALUES (689, NULL, 78, 'MetaDatumString', 'ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (690, NULL, 78, 'MetaDatumString', 'Z+', 'title');
INSERT INTO meta_data VALUES (691, NULL, 78, 'MetaDatumString', 'RGB', 'color mode');
INSERT INTO meta_data VALUES (692, 13, 78, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (693, NULL, 78, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (694, NULL, 78, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (695, NULL, 78, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (696, NULL, 79, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (697, NULL, 79, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (698, NULL, 79, 'MetaDatumDate', '1999', 'date created');
INSERT INTO meta_data VALUES (699, NULL, 79, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (700, NULL, 79, 'MetaDatumDate', '1999', 'portrayed object dates');
INSERT INTO meta_data VALUES (701, NULL, 79, 'MetaDatumMetaTerms', NULL, 'portrayed object materials');
INSERT INTO meta_data VALUES (702, NULL, 79, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (703, NULL, 79, 'MetaDatumString', 'Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.', 'remark');
INSERT INTO meta_data VALUES (704, NULL, 79, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (705, NULL, 79, 'MetaDatumString', 'Zürcher Hochschule der Künste ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (706, NULL, 79, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (707, NULL, 79, 'MetaDatumString', 'Diplom', 'title');
INSERT INTO meta_data VALUES (708, NULL, 79, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (709, NULL, 79, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (710, NULL, 79, 'MetaDatumString', 'Zürcher Hochschule der Künste Vertiefung Fotografie', 'provider');
INSERT INTO meta_data VALUES (711, 13, 79, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (712, NULL, 79, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (713, NULL, 79, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (714, NULL, 79, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (715, NULL, 79, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (716, NULL, 80, 'MetaDatumString', 'ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (717, NULL, 80, 'MetaDatumString', 'Design Artikel, Michael Krohn', 'title');
INSERT INTO meta_data VALUES (718, 13, 80, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (719, NULL, 80, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (720, NULL, 80, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (721, NULL, 80, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (722, NULL, 81, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (723, NULL, 81, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (724, NULL, 81, 'MetaDatumDate', '1999', 'date created');
INSERT INTO meta_data VALUES (725, NULL, 81, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (726, NULL, 81, 'MetaDatumDate', '1999', 'portrayed object dates');
INSERT INTO meta_data VALUES (727, NULL, 81, 'MetaDatumMetaTerms', NULL, 'portrayed object materials');
INSERT INTO meta_data VALUES (728, NULL, 81, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (729, NULL, 81, 'MetaDatumString', 'Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.', 'remark');
INSERT INTO meta_data VALUES (730, NULL, 81, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (731, NULL, 81, 'MetaDatumString', 'Zürcher Hochschule der Künste ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (735, NULL, 81, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (736, NULL, 81, 'MetaDatumString', 'Zürcher Hochschule der Künste Vertiefung Fotografie', 'provider');
INSERT INTO meta_data VALUES (737, 13, 81, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (841, NULL, 89, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (738, NULL, 81, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (739, NULL, 81, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (740, NULL, 81, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (741, NULL, 81, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (742, NULL, 82, 'MetaDatumDate', '2012:05:30 23:57:41.005', 'date created');
INSERT INTO meta_data VALUES (743, NULL, 82, 'MetaDatumString', 'image/jpeg', 'format');
INSERT INTO meta_data VALUES (744, NULL, 82, 'MetaDatumString', 'Die Gartenküche canorta erlaubt spontane Öffentlichkeit.', 'public caption');
INSERT INTO meta_data VALUES (745, NULL, 82, 'MetaDatumString', 'Reto Togni und Dominique Schmutz ', 'copyright notice');
INSERT INTO meta_data VALUES (746, NULL, 82, 'MetaDatumString', 'Canorta', 'title');
INSERT INTO meta_data VALUES (747, NULL, 82, 'MetaDatumString', 'RGB', 'color mode');
INSERT INTO meta_data VALUES (748, 13, 82, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (749, NULL, 82, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (750, NULL, 82, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (751, NULL, 82, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (752, NULL, 83, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (753, NULL, 83, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (754, NULL, 83, 'MetaDatumDate', '1999', 'date created');
INSERT INTO meta_data VALUES (755, NULL, 83, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (756, NULL, 83, 'MetaDatumDate', '1999', 'portrayed object dates');
INSERT INTO meta_data VALUES (757, NULL, 83, 'MetaDatumMetaTerms', NULL, 'portrayed object materials');
INSERT INTO meta_data VALUES (758, NULL, 83, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (759, NULL, 83, 'MetaDatumString', 'Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.', 'remark');
INSERT INTO meta_data VALUES (760, NULL, 83, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (761, NULL, 83, 'MetaDatumString', 'Zürcher Hochschule der Künste ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (762, NULL, 83, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (763, NULL, 83, 'MetaDatumString', 'Diplom', 'title');
INSERT INTO meta_data VALUES (764, NULL, 83, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (765, NULL, 83, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (766, NULL, 83, 'MetaDatumString', 'Zürcher Hochschule der Künste Vertiefung Fotografie', 'provider');
INSERT INTO meta_data VALUES (767, 13, 83, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (768, NULL, 83, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (769, NULL, 83, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (770, NULL, 83, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (771, NULL, 83, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (772, NULL, 84, 'MetaDatumString', 'Flurina Gradin', 'copyright notice');
INSERT INTO meta_data VALUES (773, NULL, 84, 'MetaDatumString', 'landjäger1_zett 11_3', 'title');
INSERT INTO meta_data VALUES (774, 13, 84, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (775, NULL, 84, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (776, NULL, 84, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (777, NULL, 84, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (778, NULL, 85, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (779, NULL, 85, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (780, NULL, 85, 'MetaDatumDate', '2012', 'date created');
INSERT INTO meta_data VALUES (781, NULL, 85, 'MetaDatumString', 'image/tiff', 'format');
INSERT INTO meta_data VALUES (782, NULL, 85, 'MetaDatumDate', '2012', 'portrayed object dates');
INSERT INTO meta_data VALUES (783, NULL, 85, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (784, NULL, 85, 'MetaDatumString', 'ZHdK DKM VMK', 'copyright notice');
INSERT INTO meta_data VALUES (785, NULL, 85, 'MetaDatumString', 'suche_system[xx,y]', 'title');
INSERT INTO meta_data VALUES (786, NULL, 85, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (787, NULL, 85, 'MetaDatumString', 'RGB', 'color mode');
INSERT INTO meta_data VALUES (788, NULL, 85, 'MetaDatumString', 'Eine kollektive Suchbewegung.', 'subtitle');
INSERT INTO meta_data VALUES (789, NULL, 85, 'MetaDatumString', 'Vertiefung Mediale Künste, Sihlquai 131, 8005 Zürich', 'portrayed object location');
INSERT INTO meta_data VALUES (790, 13, 85, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (791, NULL, 85, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (792, NULL, 85, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (793, NULL, 85, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (794, NULL, 86, 'MetaDatumDate', '2011', 'portrayed object dates');
INSERT INTO meta_data VALUES (795, NULL, 86, 'MetaDatumString', 'Scheiber Dahou, Judith', 'copyright notice');
INSERT INTO meta_data VALUES (796, NULL, 86, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (797, NULL, 86, 'MetaDatumString', 'Seerosen', 'title');
INSERT INTO meta_data VALUES (798, NULL, 86, 'MetaDatumString', 'Der schwimmende Garten', 'subtitle');
INSERT INTO meta_data VALUES (799, 13, 86, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (800, NULL, 86, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (801, NULL, 86, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (802, NULL, 86, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (803, NULL, 87, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (804, NULL, 87, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (805, NULL, 87, 'MetaDatumDate', '2012', 'date created');
INSERT INTO meta_data VALUES (806, NULL, 87, 'MetaDatumString', 'image/tiff', 'format');
INSERT INTO meta_data VALUES (807, NULL, 87, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (808, NULL, 87, 'MetaDatumDate', '2012', 'portrayed object dates');
INSERT INTO meta_data VALUES (809, NULL, 87, 'MetaDatumString', '5 Min., Loop', 'portrayed object dimensions');
INSERT INTO meta_data VALUES (810, NULL, 87, 'MetaDatumMetaTerms', NULL, 'portrayed object materials');
INSERT INTO meta_data VALUES (811, NULL, 87, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (812, NULL, 87, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (813, NULL, 87, 'MetaDatumString', 'ZHdK DKM VMK', 'copyright notice');
INSERT INTO meta_data VALUES (814, NULL, 87, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (815, NULL, 87, 'MetaDatumString', 'stimme-sprach-raum-teil3', 'title');
INSERT INTO meta_data VALUES (816, NULL, 87, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (817, NULL, 87, 'MetaDatumString', 'RGB', 'color mode');
INSERT INTO meta_data VALUES (818, NULL, 87, 'MetaDatumString', 'Vertiefung Mediale Künste, Sihlquai 131, 8005 Zürich', 'portrayed object location');
INSERT INTO meta_data VALUES (819, 13, 87, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (820, NULL, 87, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (821, NULL, 87, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (822, NULL, 87, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (823, NULL, 88, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (824, NULL, 88, 'MetaDatumDate', '2012:06:06 11:41:53.059', 'date created');
INSERT INTO meta_data VALUES (825, NULL, 88, 'MetaDatumString', 'image/tiff', 'format');
INSERT INTO meta_data VALUES (826, NULL, 88, 'MetaDatumDate', '2012', 'portrayed object dates');
INSERT INTO meta_data VALUES (827, NULL, 88, 'MetaDatumString', '18:13 Min.', 'portrayed object dimensions');
INSERT INTO meta_data VALUES (828, NULL, 88, 'MetaDatumString', 'ZHdK DKM VMK', 'copyright notice');
INSERT INTO meta_data VALUES (829, NULL, 88, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (830, NULL, 88, 'MetaDatumString', 'stribog_13_meets_electra', 'title');
INSERT INTO meta_data VALUES (831, NULL, 88, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (832, NULL, 88, 'MetaDatumString', 'RGB', 'color mode');
INSERT INTO meta_data VALUES (833, 13, 88, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (834, NULL, 88, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (835, NULL, 88, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (836, NULL, 88, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (837, NULL, 89, 'MetaDatumString', 'Flurina Gradin', 'copyright notice');
INSERT INTO meta_data VALUES (838, NULL, 89, 'MetaDatumString', 'landjäger2_zett 11_3', 'title');
INSERT INTO meta_data VALUES (839, 13, 89, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (840, NULL, 89, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (842, NULL, 89, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (843, NULL, 90, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (844, NULL, 90, 'MetaDatumDate', '2012', 'date created');
INSERT INTO meta_data VALUES (845, NULL, 90, 'MetaDatumString', 'image/tiff', 'format');
INSERT INTO meta_data VALUES (846, NULL, 90, 'MetaDatumDate', '2012', 'portrayed object dates');
INSERT INTO meta_data VALUES (847, NULL, 90, 'MetaDatumString', 'ZHdK DKM VMK', 'copyright notice');
INSERT INTO meta_data VALUES (848, NULL, 90, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (849, NULL, 90, 'MetaDatumString', 'Arbeitsraum mit unbestimmten Ausgängen', 'title');
INSERT INTO meta_data VALUES (850, NULL, 90, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (851, NULL, 90, 'MetaDatumString', 'RGB', 'color mode');
INSERT INTO meta_data VALUES (852, NULL, 90, 'MetaDatumString', 'Vertiefung Mediale Künste, Sihlquai 131, 8005 Zürich', 'portrayed object location');
INSERT INTO meta_data VALUES (853, 13, 90, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (854, NULL, 90, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (855, NULL, 90, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (856, NULL, 90, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (857, NULL, 91, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (858, NULL, 91, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (859, NULL, 91, 'MetaDatumDate', '1998', 'date created');
INSERT INTO meta_data VALUES (860, NULL, 91, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (861, NULL, 91, 'MetaDatumDate', '1998', 'portrayed object dates');
INSERT INTO meta_data VALUES (862, NULL, 91, 'MetaDatumMetaTerms', NULL, 'portrayed object materials');
INSERT INTO meta_data VALUES (863, NULL, 91, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (864, NULL, 91, 'MetaDatumString', 'es erscheint die Publikation:
Peter Tillessen - Gold, [Text: Ulf Erdmann Ziegler] Baden, Lars Müller, 2000 ', 'remark');
INSERT INTO meta_data VALUES (865, NULL, 91, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (866, NULL, 91, 'MetaDatumString', 'Zürcher Hochschule der Künste ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (867, NULL, 91, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (868, NULL, 91, 'MetaDatumString', 'Spaziergang', 'title');
INSERT INTO meta_data VALUES (869, NULL, 91, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (870, NULL, 91, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (871, NULL, 91, 'MetaDatumString', 'Zürcher Hochschule der Künste Vertiefung Fotografie', 'provider');
INSERT INTO meta_data VALUES (872, NULL, 91, 'MetaDatumString', 'Diplomarbeit', 'subtitle');
INSERT INTO meta_data VALUES (873, 13, 91, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (874, NULL, 91, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (875, NULL, 91, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (876, NULL, 91, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (877, NULL, 91, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (878, NULL, 92, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (879, NULL, 92, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (880, NULL, 92, 'MetaDatumDate', '1999', 'date created');
INSERT INTO meta_data VALUES (881, NULL, 92, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (882, NULL, 92, 'MetaDatumDate', '1999', 'portrayed object dates');
INSERT INTO meta_data VALUES (883, NULL, 92, 'MetaDatumMetaTerms', NULL, 'portrayed object materials');
INSERT INTO meta_data VALUES (884, NULL, 92, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (885, NULL, 92, 'MetaDatumString', 'Die Künstlerin hat ihren Namen gewechselt. Zur Zeit ihres Studiums hiess sie Andrea Bangerter, heute nennt sie sich Andrea Thal. Da sie unter dem letzten Namen als Künstlerin bekannt ist, werden hier beide Namen aufgeführt.', 'remark');
INSERT INTO meta_data VALUES (886, NULL, 92, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (887, NULL, 92, 'MetaDatumString', 'Zürcher Hochschule der Künste ZHdK', 'copyright notice');
INSERT INTO meta_data VALUES (888, NULL, 92, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (889, NULL, 92, 'MetaDatumString', 'Diplom', 'title');
INSERT INTO meta_data VALUES (890, NULL, 92, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (891, NULL, 92, 'MetaDatumPeople', NULL, 'description author');
INSERT INTO meta_data VALUES (892, NULL, 92, 'MetaDatumString', 'Zürcher Hochschule der Künste Vertiefung Fotografie', 'provider');
INSERT INTO meta_data VALUES (893, 13, 92, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (894, NULL, 92, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (895, NULL, 92, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (896, NULL, 92, 'MetaDatumPeople', NULL, 'description author before import');
INSERT INTO meta_data VALUES (897, NULL, 92, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (898, 3, 93, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (899, NULL, 93, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (900, NULL, 94, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (901, NULL, 94, 'MetaDatumDate', '2012', 'date created');
INSERT INTO meta_data VALUES (902, NULL, 94, 'MetaDatumString', 'image/tiff', 'format');
INSERT INTO meta_data VALUES (903, NULL, 94, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (904, NULL, 94, 'MetaDatumDate', '2012', 'portrayed object dates');
INSERT INTO meta_data VALUES (905, NULL, 94, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (906, NULL, 94, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (907, NULL, 94, 'MetaDatumString', 'ZHdK DKM VMK', 'copyright notice');
INSERT INTO meta_data VALUES (908, NULL, 94, 'MetaDatumString', 'Leerschlag [ ]', 'title');
INSERT INTO meta_data VALUES (909, NULL, 94, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (910, NULL, 94, 'MetaDatumString', 'RGB', 'color mode');
INSERT INTO meta_data VALUES (911, NULL, 94, 'MetaDatumString', 'Vernissage', 'subtitle');
INSERT INTO meta_data VALUES (912, NULL, 94, 'MetaDatumString', 'Vertiefung Mediale Künste, Sihlquai 131, 8005 Zürich', 'portrayed object location');
INSERT INTO meta_data VALUES (913, 13, 94, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (914, NULL, 94, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (915, NULL, 94, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (916, NULL, 94, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (917, NULL, 93, 'MetaDatumString', 'Water with oil', 'title');
INSERT INTO meta_data VALUES (918, NULL, 93, 'MetaDatumString', 'unbekannt', 'copyright notice');
INSERT INTO meta_data VALUES (919, NULL, 71, 'MetaDatumString', 'Plan', 'title');
INSERT INTO meta_data VALUES (920, NULL, 71, 'MetaDatumString', 'unbekannt', 'copyright notice');
INSERT INTO meta_data VALUES (921, NULL, 95, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (922, NULL, 95, 'MetaDatumDate', '2012', 'date created');
INSERT INTO meta_data VALUES (923, NULL, 95, 'MetaDatumString', 'image/tiff', 'format');
INSERT INTO meta_data VALUES (924, NULL, 95, 'MetaDatumDate', '2012', 'portrayed object dates');
INSERT INTO meta_data VALUES (925, NULL, 95, 'MetaDatumString', 'ZHdK DKM VMK', 'copyright notice');
INSERT INTO meta_data VALUES (926, NULL, 95, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (927, NULL, 95, 'MetaDatumString', 'Arbeitsraum mit unbestimmten Ausgängen', 'title');
INSERT INTO meta_data VALUES (928, NULL, 95, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (929, NULL, 95, 'MetaDatumString', 'RGB', 'color mode');
INSERT INTO meta_data VALUES (930, NULL, 95, 'MetaDatumString', 'Vertiefung Mediale Künste, Sihlquai 131, 8005 Zürich', 'portrayed object location');
INSERT INTO meta_data VALUES (931, 13, 95, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (932, NULL, 95, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (933, NULL, 95, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (934, NULL, 95, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (960, NULL, 97, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (961, NULL, 97, 'MetaDatumDate', '2012', 'date created');
INSERT INTO meta_data VALUES (962, NULL, 97, 'MetaDatumString', 'image/tiff', 'format');
INSERT INTO meta_data VALUES (963, NULL, 97, 'MetaDatumDepartments', NULL, 'institutional affiliation');
INSERT INTO meta_data VALUES (964, NULL, 97, 'MetaDatumDate', '2012', 'portrayed object dates');
INSERT INTO meta_data VALUES (965, NULL, 97, 'MetaDatumMetaTerms', NULL, 'project type');
INSERT INTO meta_data VALUES (966, NULL, 97, 'MetaDatumPeople', NULL, 'creator');
INSERT INTO meta_data VALUES (967, NULL, 97, 'MetaDatumString', 'ZHdK DKM VMK', 'copyright notice');
INSERT INTO meta_data VALUES (968, NULL, 97, 'MetaDatumString', 'Leerschlag [ ]', 'title');
INSERT INTO meta_data VALUES (969, NULL, 97, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (970, NULL, 97, 'MetaDatumString', 'RGB', 'color mode');
INSERT INTO meta_data VALUES (971, NULL, 97, 'MetaDatumString', 'Vernissage', 'subtitle');
INSERT INTO meta_data VALUES (972, NULL, 97, 'MetaDatumString', 'Vertiefung Mediale Künste, Sihlquai 131, 8005 Zürich', 'portrayed object location');
INSERT INTO meta_data VALUES (973, 13, 97, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (974, NULL, 97, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (975, NULL, 97, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (976, NULL, 97, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (987, NULL, 99, 'MetaDatumString', 'Gattung', 'title');
INSERT INTO meta_data VALUES (988, NULL, 99, 'MetaDatumString', 'Erkunden Sie Medieneinträge mit unterschiedlichen Gattungen.', 'description');
INSERT INTO meta_data VALUES (989, 3, 100, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (990, NULL, 100, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (991, NULL, 100, 'MetaDatumString', 'Arabic', 'title');
INSERT INTO meta_data VALUES (992, NULL, 100, 'MetaDatumString', 'Unbekannt', 'copyright notice');
INSERT INTO meta_data VALUES (993, NULL, 101, 'MetaDatumString', 'Beispielhafte-Sets', 'title');
INSERT INTO meta_data VALUES (994, NULL, 102, 'MetaDatumString', 'Beispiele1', 'title');
INSERT INTO meta_data VALUES (995, NULL, 103, 'MetaDatumString', 'Diplomarbeiten', 'title');
INSERT INTO meta_data VALUES (998, NULL, 105, 'MetaDatumString', '--- 
- isom
- avc1
', 'compatible brands');
INSERT INTO meta_data VALUES (999, NULL, 105, 'MetaDatumString', '2012:04:02 10:02:06', 'create date');
INSERT INTO meta_data VALUES (1000, NULL, 105, 'MetaDatumString', '0 s', 'current time');
INSERT INTO meta_data VALUES (1001, NULL, 105, 'MetaDatumString', '5.07 s', 'duration');
INSERT INTO meta_data VALUES (1002, NULL, 105, 'MetaDatumString', 'MP4  Base Media v1 [IS0 14496-12:2003]', 'major brand');
INSERT INTO meta_data VALUES (1003, NULL, 105, 'MetaDatumString', '1 0 0 0 1 0 0 0 1', 'matrix structure');
INSERT INTO meta_data VALUES (1004, NULL, 105, 'MetaDatumString', '0.0.1', 'minor version');
INSERT INTO meta_data VALUES (1005, NULL, 105, 'MetaDatumString', '2012:04:02 10:02:06', 'modify date');
INSERT INTO meta_data VALUES (1006, NULL, 105, 'MetaDatumString', '920203', 'movie data size');
INSERT INTO meta_data VALUES (1007, NULL, 105, 'MetaDatumString', '0', 'movie header version');
INSERT INTO meta_data VALUES (1008, NULL, 105, 'MetaDatumString', '3', 'next track id');
INSERT INTO meta_data VALUES (1009, NULL, 105, 'MetaDatumString', '0 s', 'poster time');
INSERT INTO meta_data VALUES (1010, NULL, 105, 'MetaDatumString', '1', 'preferred rate');
INSERT INTO meta_data VALUES (1011, NULL, 105, 'MetaDatumString', '100.00%', 'preferred volume');
INSERT INTO meta_data VALUES (1012, NULL, 105, 'MetaDatumString', '0 s', 'preview duration');
INSERT INTO meta_data VALUES (1013, NULL, 105, 'MetaDatumString', '0 s', 'preview time');
INSERT INTO meta_data VALUES (1014, NULL, 105, 'MetaDatumString', '0 s', 'selection duration');
INSERT INTO meta_data VALUES (1015, NULL, 105, 'MetaDatumString', '0 s', 'selection time');
INSERT INTO meta_data VALUES (1016, NULL, 105, 'MetaDatumString', '600', 'time scale');
INSERT INTO meta_data VALUES (1017, NULL, 105, 'MetaDatumString', '24', 'bit depth');
INSERT INTO meta_data VALUES (1018, NULL, 105, 'MetaDatumString', 'avc1', 'compressor id');
INSERT INTO meta_data VALUES (1019, NULL, 105, 'MetaDatumString', 'srcCopy', 'graphics mode');
INSERT INTO meta_data VALUES (1020, NULL, 105, 'MetaDatumString', 'GPAC ISO Video Handler', 'handler description');
INSERT INTO meta_data VALUES (1021, NULL, 105, 'MetaDatumString', 'Video Track', 'handler type');
INSERT INTO meta_data VALUES (1022, NULL, 105, 'MetaDatumString', '720', 'image height');
INSERT INTO meta_data VALUES (1023, NULL, 105, 'MetaDatumString', '1280', 'image width');
INSERT INTO meta_data VALUES (1024, NULL, 105, 'MetaDatumString', '2012:04:02 10:02:00', 'media create date');
INSERT INTO meta_data VALUES (1025, NULL, 105, 'MetaDatumString', '5.07 s', 'media duration');
INSERT INTO meta_data VALUES (1026, NULL, 105, 'MetaDatumString', '0', 'media header version');
INSERT INTO meta_data VALUES (1027, NULL, 105, 'MetaDatumString', 'und', 'media language code');
INSERT INTO meta_data VALUES (1028, NULL, 105, 'MetaDatumString', '2012:04:02 10:02:06', 'media modify date');
INSERT INTO meta_data VALUES (1029, NULL, 105, 'MetaDatumString', '30', 'media time scale');
INSERT INTO meta_data VALUES (1030, NULL, 105, 'MetaDatumString', '0 0 0', 'op color');
INSERT INTO meta_data VALUES (1031, NULL, 105, 'MetaDatumString', '720', 'source image height');
INSERT INTO meta_data VALUES (1032, NULL, 105, 'MetaDatumString', '1280', 'source image width');
INSERT INTO meta_data VALUES (1033, NULL, 105, 'MetaDatumString', '2012:04:02 10:02:00', 'track create date');
INSERT INTO meta_data VALUES (1034, NULL, 105, 'MetaDatumString', '5.07 s', 'track duration');
INSERT INTO meta_data VALUES (1035, NULL, 105, 'MetaDatumString', '0', 'track header version');
INSERT INTO meta_data VALUES (1036, NULL, 105, 'MetaDatumString', '1', 'track id');
INSERT INTO meta_data VALUES (1037, NULL, 105, 'MetaDatumString', '0', 'track layer');
INSERT INTO meta_data VALUES (1038, NULL, 105, 'MetaDatumString', '2012:04:02 10:02:06', 'track modify date');
INSERT INTO meta_data VALUES (1039, NULL, 105, 'MetaDatumString', '0.00%', 'track volume');
INSERT INTO meta_data VALUES (1040, NULL, 105, 'MetaDatumString', '30', 'video frame rate');
INSERT INTO meta_data VALUES (1041, NULL, 105, 'MetaDatumString', '72', 'x resolution');
INSERT INTO meta_data VALUES (1042, NULL, 105, 'MetaDatumString', '72', 'y resolution');
INSERT INTO meta_data VALUES (1043, NULL, 105, 'MetaDatumString', '16', 'audio bits per sample');
INSERT INTO meta_data VALUES (1044, NULL, 105, 'MetaDatumString', '2', 'audio channels');
INSERT INTO meta_data VALUES (1045, NULL, 105, 'MetaDatumString', 'mp4a', 'audio format');
INSERT INTO meta_data VALUES (1046, NULL, 105, 'MetaDatumString', '22050', 'audio sample rate');
INSERT INTO meta_data VALUES (1047, NULL, 105, 'MetaDatumString', '0', 'balance');
INSERT INTO meta_data VALUES (1048, NULL, 105, 'MetaDatumString', '1.45 Mbps', 'avg bitrate');
INSERT INTO meta_data VALUES (1049, NULL, 105, 'MetaDatumString', '1280x720', 'image size');
INSERT INTO meta_data VALUES (1050, NULL, 105, 'MetaDatumString', '0', 'rotation');
INSERT INTO meta_data VALUES (1051, 3, 105, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (1052, NULL, 105, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (1053, NULL, 105, 'MetaDatumString', 'Zencoder Test Movie', 'title');
INSERT INTO meta_data VALUES (1054, NULL, 105, 'MetaDatumDate', '2010', 'portrayed object dates');
INSERT INTO meta_data VALUES (1055, NULL, 105, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (1056, NULL, 105, 'MetaDatumString', '???', 'copyright notice');
INSERT INTO meta_data VALUES (1057, NULL, 106, 'MetaDatumString', '128 kbps', 'audio bitrate');
INSERT INTO meta_data VALUES (1058, NULL, 106, 'MetaDatumString', '3', 'audio layer');
INSERT INTO meta_data VALUES (1059, NULL, 106, 'MetaDatumString', 'Joint Stereo', 'channel mode');
INSERT INTO meta_data VALUES (1060, NULL, 106, 'MetaDatumString', 'None', 'emphasis');
INSERT INTO meta_data VALUES (1061, NULL, 106, 'MetaDatumString', 'LAME3.96r', 'encoder');
INSERT INTO meta_data VALUES (1062, NULL, 106, 'MetaDatumString', 'Off', 'intensity stereo');
INSERT INTO meta_data VALUES (1063, NULL, 106, 'MetaDatumString', '128 kbps', 'lame bitrate');
INSERT INTO meta_data VALUES (1085, NULL, 106, 'MetaDatumString', '???', 'copyright notice');
INSERT INTO meta_data VALUES (1087, NULL, 105, 'MetaDatumString', 'Himmel', 'portrayed object location');
INSERT INTO meta_data VALUES (1088, NULL, 105, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (1089, NULL, 105, 'MetaDatumString', 'http://www.copyright.ch', 'copyright url');
INSERT INTO meta_data VALUES (1090, NULL, 106, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (1091, NULL, 106, 'MetaDatumMetaTerms', NULL, 'type');
INSERT INTO meta_data VALUES (1092, NULL, 106, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (1093, NULL, 106, 'MetaDatumString', 'http://www.copyright.ch', 'copyright url');
INSERT INTO meta_data VALUES (1094, NULL, 106, 'MetaDatumMetaTerms', NULL, 'academic year');
INSERT INTO meta_data VALUES (1095, NULL, 107, 'MetaDatumString', 'Set in SQ6 Context', 'title');
INSERT INTO meta_data VALUES (1096, NULL, 107, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (1097, NULL, 107, 'MetaDatumKeywords', NULL, 'keywords');
INSERT INTO meta_data VALUES (1098, NULL, 107, 'MetaDatumString', 'Set im Kontext SQ6 ', 'description');
INSERT INTO meta_data VALUES (1099, NULL, 108, 'MetaDatumPeople', NULL, 'author');
INSERT INTO meta_data VALUES (1100, NULL, 108, 'MetaDatumDate', '2011:03:15 15:02:22+01:00', 'date created');
INSERT INTO meta_data VALUES (1101, NULL, 108, 'MetaDatumString', 'image/jpeg', 'format');
INSERT INTO meta_data VALUES (1102, NULL, 108, 'MetaDatumString', 'Sebastian Pape', 'copyright notice');
INSERT INTO meta_data VALUES (1103, NULL, 108, 'MetaDatumString', 'Flakon Variante 1', 'title');
INSERT INTO meta_data VALUES (1104, NULL, 108, 'MetaDatumString', 'RGB', 'color mode');
INSERT INTO meta_data VALUES (1105, NULL, 108, 'MetaDatumCountry', 'CH', 'portrayed object country code');
INSERT INTO meta_data VALUES (1106, 13, 108, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (1107, NULL, 108, 'MetaDatumString', 'Das Werk darf nur mit Einwilligung des Autors/Rechteinhabers weiter verwendet werden.', 'copyright usage');
INSERT INTO meta_data VALUES (1108, NULL, 108, 'MetaDatumString', 'http://www.ige.ch', 'copyright url');
INSERT INTO meta_data VALUES (1109, NULL, 108, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (1110, NULL, 109, 'MetaDatumString', 'Stil- und Kunstrichtung', 'title');
INSERT INTO meta_data VALUES (1114, NULL, 113, 'MetaDatumString', '---
- isom
- avc1
', 'compatible brands');
INSERT INTO meta_data VALUES (1115, NULL, 113, 'MetaDatumString', '2012:04:02 10:02:06', 'create date');
INSERT INTO meta_data VALUES (1116, NULL, 113, 'MetaDatumString', '0 s', 'current time');
INSERT INTO meta_data VALUES (1117, NULL, 113, 'MetaDatumString', '5.07 s', 'duration');
INSERT INTO meta_data VALUES (1118, NULL, 113, 'MetaDatumString', 'MP4  Base Media v1 [IS0 14496-12:2003]', 'major brand');
INSERT INTO meta_data VALUES (1119, NULL, 113, 'MetaDatumString', '1 0 0 0 1 0 0 0 1', 'matrix structure');
INSERT INTO meta_data VALUES (1120, NULL, 113, 'MetaDatumString', '0.0.1', 'minor version');
INSERT INTO meta_data VALUES (1121, NULL, 113, 'MetaDatumString', '2012:04:02 10:02:06', 'modify date');
INSERT INTO meta_data VALUES (1122, NULL, 113, 'MetaDatumString', '920203', 'movie data size');
INSERT INTO meta_data VALUES (1123, NULL, 113, 'MetaDatumString', '0', 'movie header version');
INSERT INTO meta_data VALUES (1124, NULL, 113, 'MetaDatumString', '3', 'next track id');
INSERT INTO meta_data VALUES (1125, NULL, 113, 'MetaDatumString', '0 s', 'poster time');
INSERT INTO meta_data VALUES (1126, NULL, 113, 'MetaDatumString', '1', 'preferred rate');
INSERT INTO meta_data VALUES (1127, NULL, 113, 'MetaDatumString', '100.00%', 'preferred volume');
INSERT INTO meta_data VALUES (1128, NULL, 113, 'MetaDatumString', '0 s', 'preview duration');
INSERT INTO meta_data VALUES (1129, NULL, 113, 'MetaDatumString', '0 s', 'preview time');
INSERT INTO meta_data VALUES (1130, NULL, 113, 'MetaDatumString', '0 s', 'selection duration');
INSERT INTO meta_data VALUES (1131, NULL, 113, 'MetaDatumString', '0 s', 'selection time');
INSERT INTO meta_data VALUES (1132, NULL, 113, 'MetaDatumString', '600', 'time scale');
INSERT INTO meta_data VALUES (1133, NULL, 113, 'MetaDatumString', '24', 'bit depth');
INSERT INTO meta_data VALUES (1134, NULL, 113, 'MetaDatumString', 'avc1', 'compressor id');
INSERT INTO meta_data VALUES (1135, NULL, 113, 'MetaDatumString', 'srcCopy', 'graphics mode');
INSERT INTO meta_data VALUES (1136, NULL, 113, 'MetaDatumString', 'GPAC ISO Video Handler', 'handler description');
INSERT INTO meta_data VALUES (1137, NULL, 113, 'MetaDatumString', 'Video Track', 'handler type');
INSERT INTO meta_data VALUES (1138, NULL, 113, 'MetaDatumString', '720', 'image height');
INSERT INTO meta_data VALUES (1139, NULL, 113, 'MetaDatumString', '1280', 'image width');
INSERT INTO meta_data VALUES (1140, NULL, 113, 'MetaDatumString', '2012:04:02 10:02:00', 'media create date');
INSERT INTO meta_data VALUES (1141, NULL, 113, 'MetaDatumString', '5.07 s', 'media duration');
INSERT INTO meta_data VALUES (1142, NULL, 113, 'MetaDatumString', '0', 'media header version');
INSERT INTO meta_data VALUES (1143, NULL, 113, 'MetaDatumString', 'und', 'media language code');
INSERT INTO meta_data VALUES (1144, NULL, 113, 'MetaDatumString', '2012:04:02 10:02:06', 'media modify date');
INSERT INTO meta_data VALUES (1145, NULL, 113, 'MetaDatumString', '30', 'media time scale');
INSERT INTO meta_data VALUES (1146, NULL, 113, 'MetaDatumString', '0 0 0', 'op color');
INSERT INTO meta_data VALUES (1147, NULL, 113, 'MetaDatumString', '720', 'source image height');
INSERT INTO meta_data VALUES (1148, NULL, 113, 'MetaDatumString', '1280', 'source image width');
INSERT INTO meta_data VALUES (1149, NULL, 113, 'MetaDatumString', '2012:04:02 10:02:00', 'track create date');
INSERT INTO meta_data VALUES (1150, NULL, 113, 'MetaDatumString', '5.07 s', 'track duration');
INSERT INTO meta_data VALUES (1151, NULL, 113, 'MetaDatumString', '0', 'track header version');
INSERT INTO meta_data VALUES (1152, NULL, 113, 'MetaDatumString', '1', 'track id');
INSERT INTO meta_data VALUES (1153, NULL, 113, 'MetaDatumString', '0', 'track layer');
INSERT INTO meta_data VALUES (1154, NULL, 113, 'MetaDatumString', '2012:04:02 10:02:06', 'track modify date');
INSERT INTO meta_data VALUES (1155, NULL, 113, 'MetaDatumString', '0.00%', 'track volume');
INSERT INTO meta_data VALUES (1156, NULL, 113, 'MetaDatumString', '30', 'video frame rate');
INSERT INTO meta_data VALUES (1157, NULL, 113, 'MetaDatumString', '72', 'x resolution');
INSERT INTO meta_data VALUES (1158, NULL, 113, 'MetaDatumString', '72', 'y resolution');
INSERT INTO meta_data VALUES (1159, NULL, 113, 'MetaDatumString', '16', 'audio bits per sample');
INSERT INTO meta_data VALUES (1160, NULL, 113, 'MetaDatumString', '2', 'audio channels');
INSERT INTO meta_data VALUES (1161, NULL, 113, 'MetaDatumString', 'mp4a', 'audio format');
INSERT INTO meta_data VALUES (1162, NULL, 113, 'MetaDatumString', '22050', 'audio sample rate');
INSERT INTO meta_data VALUES (1163, NULL, 113, 'MetaDatumString', '0', 'balance');
INSERT INTO meta_data VALUES (1164, NULL, 113, 'MetaDatumString', '1.45 Mbps', 'avg bitrate');
INSERT INTO meta_data VALUES (1165, NULL, 113, 'MetaDatumString', '1280x720', 'image size');
INSERT INTO meta_data VALUES (1166, NULL, 113, 'MetaDatumString', '0', 'rotation');
INSERT INTO meta_data VALUES (1167, 3, 113, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (1168, NULL, 113, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (1169, NULL, 113, 'MetaDatumString', 'A public movie to test public viewing', 'title');
INSERT INTO meta_data VALUES (1170, NULL, 113, 'MetaDatumString', 'Who knows?', 'copyright notice');
INSERT INTO meta_data VALUES (1171, 3, 114, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (1172, NULL, 114, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (1173, NULL, 114, 'MetaDatumString', 'some pdf', 'title');
INSERT INTO meta_data VALUES (1174, NULL, 114, 'MetaDatumString', 'asdfasdf', 'copyright notice');
INSERT INTO meta_data VALUES (1175, 3, 115, 'MetaDatumCopyright', NULL, 'copyright status');
INSERT INTO meta_data VALUES (1176, NULL, 115, 'MetaDatumUsers', NULL, 'uploaded by');
INSERT INTO meta_data VALUES (1177, NULL, 115, 'MetaDatumString', 'blah', 'title');
INSERT INTO meta_data VALUES (1178, NULL, 115, 'MetaDatumString', 'asdfa', 'copyright notice');


--
-- Data for Name: meta_data_meta_departments; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: meta_data_meta_terms; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO meta_data_meta_terms VALUES (49, 88);
INSERT INTO meta_data_meta_terms VALUES (49, 89);
INSERT INTO meta_data_meta_terms VALUES (49, 91);
INSERT INTO meta_data_meta_terms VALUES (47, 2169);
INSERT INTO meta_data_meta_terms VALUES (45, 73);
INSERT INTO meta_data_meta_terms VALUES (75, 1833);
INSERT INTO meta_data_meta_terms VALUES (75, 655);
INSERT INTO meta_data_meta_terms VALUES (76, 655);
INSERT INTO meta_data_meta_terms VALUES (93, 341);
INSERT INTO meta_data_meta_terms VALUES (98, 2197);
INSERT INTO meta_data_meta_terms VALUES (99, 85);
INSERT INTO meta_data_meta_terms VALUES (105, 76);
INSERT INTO meta_data_meta_terms VALUES (114, 341);
INSERT INTO meta_data_meta_terms VALUES (119, 2197);
INSERT INTO meta_data_meta_terms VALUES (120, 85);
INSERT INTO meta_data_meta_terms VALUES (126, 76);
INSERT INTO meta_data_meta_terms VALUES (144, 76);
INSERT INTO meta_data_meta_terms VALUES (160, 341);
INSERT INTO meta_data_meta_terms VALUES (165, 2197);
INSERT INTO meta_data_meta_terms VALUES (166, 85);
INSERT INTO meta_data_meta_terms VALUES (172, 76);
INSERT INTO meta_data_meta_terms VALUES (190, 76);
INSERT INTO meta_data_meta_terms VALUES (220, 341);
INSERT INTO meta_data_meta_terms VALUES (225, 2197);
INSERT INTO meta_data_meta_terms VALUES (226, 85);
INSERT INTO meta_data_meta_terms VALUES (232, 76);
INSERT INTO meta_data_meta_terms VALUES (240, 2131);
INSERT INTO meta_data_meta_terms VALUES (245, 86);
INSERT INTO meta_data_meta_terms VALUES (248, 79);
INSERT INTO meta_data_meta_terms VALUES (266, 76);
INSERT INTO meta_data_meta_terms VALUES (293, 341);
INSERT INTO meta_data_meta_terms VALUES (298, 2197);
INSERT INTO meta_data_meta_terms VALUES (299, 85);
INSERT INTO meta_data_meta_terms VALUES (305, 76);
INSERT INTO meta_data_meta_terms VALUES (319, 2131);
INSERT INTO meta_data_meta_terms VALUES (326, 4609);
INSERT INTO meta_data_meta_terms VALUES (327, 86);
INSERT INTO meta_data_meta_terms VALUES (332, 79);
INSERT INTO meta_data_meta_terms VALUES (339, 341);
INSERT INTO meta_data_meta_terms VALUES (344, 2197);
INSERT INTO meta_data_meta_terms VALUES (345, 85);
INSERT INTO meta_data_meta_terms VALUES (351, 76);
INSERT INTO meta_data_meta_terms VALUES (377, 79);
INSERT INTO meta_data_meta_terms VALUES (383, 341);
INSERT INTO meta_data_meta_terms VALUES (388, 2197);
INSERT INTO meta_data_meta_terms VALUES (389, 85);
INSERT INTO meta_data_meta_terms VALUES (395, 76);
INSERT INTO meta_data_meta_terms VALUES (410, 79);
INSERT INTO meta_data_meta_terms VALUES (426, 341);
INSERT INTO meta_data_meta_terms VALUES (431, 2197);
INSERT INTO meta_data_meta_terms VALUES (432, 85);
INSERT INTO meta_data_meta_terms VALUES (438, 76);
INSERT INTO meta_data_meta_terms VALUES (447, 341);
INSERT INTO meta_data_meta_terms VALUES (452, 2197);
INSERT INTO meta_data_meta_terms VALUES (453, 85);
INSERT INTO meta_data_meta_terms VALUES (459, 76);
INSERT INTO meta_data_meta_terms VALUES (469, 2131);
INSERT INTO meta_data_meta_terms VALUES (474, 86);
INSERT INTO meta_data_meta_terms VALUES (478, 79);
INSERT INTO meta_data_meta_terms VALUES (501, 341);
INSERT INTO meta_data_meta_terms VALUES (506, 2197);
INSERT INTO meta_data_meta_terms VALUES (507, 85);
INSERT INTO meta_data_meta_terms VALUES (513, 76);
INSERT INTO meta_data_meta_terms VALUES (545, 341);
INSERT INTO meta_data_meta_terms VALUES (550, 2197);
INSERT INTO meta_data_meta_terms VALUES (551, 85);
INSERT INTO meta_data_meta_terms VALUES (557, 76);
INSERT INTO meta_data_meta_terms VALUES (575, 76);
INSERT INTO meta_data_meta_terms VALUES (591, 341);
INSERT INTO meta_data_meta_terms VALUES (596, 2197);
INSERT INTO meta_data_meta_terms VALUES (597, 85);
INSERT INTO meta_data_meta_terms VALUES (603, 76);
INSERT INTO meta_data_meta_terms VALUES (621, 76);
INSERT INTO meta_data_meta_terms VALUES (639, 341);
INSERT INTO meta_data_meta_terms VALUES (644, 2197);
INSERT INTO meta_data_meta_terms VALUES (645, 85);
INSERT INTO meta_data_meta_terms VALUES (651, 76);
INSERT INTO meta_data_meta_terms VALUES (669, 76);
INSERT INTO meta_data_meta_terms VALUES (696, 341);
INSERT INTO meta_data_meta_terms VALUES (701, 2197);
INSERT INTO meta_data_meta_terms VALUES (702, 85);
INSERT INTO meta_data_meta_terms VALUES (708, 76);
INSERT INTO meta_data_meta_terms VALUES (722, 341);
INSERT INTO meta_data_meta_terms VALUES (727, 2197);
INSERT INTO meta_data_meta_terms VALUES (728, 85);
INSERT INTO meta_data_meta_terms VALUES (734, 76);
INSERT INTO meta_data_meta_terms VALUES (752, 341);
INSERT INTO meta_data_meta_terms VALUES (757, 2197);
INSERT INTO meta_data_meta_terms VALUES (758, 85);
INSERT INTO meta_data_meta_terms VALUES (764, 76);
INSERT INTO meta_data_meta_terms VALUES (778, 2131);
INSERT INTO meta_data_meta_terms VALUES (783, 86);
INSERT INTO meta_data_meta_terms VALUES (786, 79);
INSERT INTO meta_data_meta_terms VALUES (803, 2131);
INSERT INTO meta_data_meta_terms VALUES (810, 4609);
INSERT INTO meta_data_meta_terms VALUES (811, 86);
INSERT INTO meta_data_meta_terms VALUES (816, 79);
INSERT INTO meta_data_meta_terms VALUES (831, 79);
INSERT INTO meta_data_meta_terms VALUES (850, 79);
INSERT INTO meta_data_meta_terms VALUES (857, 341);
INSERT INTO meta_data_meta_terms VALUES (862, 2197);
INSERT INTO meta_data_meta_terms VALUES (863, 85);
INSERT INTO meta_data_meta_terms VALUES (869, 76);
INSERT INTO meta_data_meta_terms VALUES (878, 341);
INSERT INTO meta_data_meta_terms VALUES (883, 2197);
INSERT INTO meta_data_meta_terms VALUES (884, 85);
INSERT INTO meta_data_meta_terms VALUES (900, 2131);
INSERT INTO meta_data_meta_terms VALUES (905, 86);
INSERT INTO meta_data_meta_terms VALUES (909, 79);
INSERT INTO meta_data_meta_terms VALUES (928, 79);
INSERT INTO meta_data_meta_terms VALUES (960, 2131);
INSERT INTO meta_data_meta_terms VALUES (965, 86);
INSERT INTO meta_data_meta_terms VALUES (969, 79);
INSERT INTO meta_data_meta_terms VALUES (890, 79);
INSERT INTO meta_data_meta_terms VALUES (1077, 2225);
INSERT INTO meta_data_meta_terms VALUES (1086, 75);
INSERT INTO meta_data_meta_terms VALUES (1091, 83);
INSERT INTO meta_data_meta_terms VALUES (1094, 2666);


--
-- Data for Name: meta_data_people; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO meta_data_people VALUES (57, 9);
INSERT INTO meta_data_people VALUES (41, 7);
INSERT INTO meta_data_people VALUES (94, 11);
INSERT INTO meta_data_people VALUES (101, 12);
INSERT INTO meta_data_people VALUES (106, 13);
INSERT INTO meta_data_people VALUES (112, 13);
INSERT INTO meta_data_people VALUES (115, 11);
INSERT INTO meta_data_people VALUES (122, 11);
INSERT INTO meta_data_people VALUES (127, 13);
INSERT INTO meta_data_people VALUES (133, 13);
INSERT INTO meta_data_people VALUES (135, 14);
INSERT INTO meta_data_people VALUES (140, 15);
INSERT INTO meta_data_people VALUES (146, 16);
INSERT INTO meta_data_people VALUES (158, 16);
INSERT INTO meta_data_people VALUES (161, 17);
INSERT INTO meta_data_people VALUES (161, 18);
INSERT INTO meta_data_people VALUES (168, 19);
INSERT INTO meta_data_people VALUES (173, 13);
INSERT INTO meta_data_people VALUES (178, 13);
INSERT INTO meta_data_people VALUES (180, 14);
INSERT INTO meta_data_people VALUES (185, 14);
INSERT INTO meta_data_people VALUES (192, 16);
INSERT INTO meta_data_people VALUES (206, 16);
INSERT INTO meta_data_people VALUES (221, 17);
INSERT INTO meta_data_people VALUES (221, 18);
INSERT INTO meta_data_people VALUES (228, 17);
INSERT INTO meta_data_people VALUES (233, 13);
INSERT INTO meta_data_people VALUES (238, 13);
INSERT INTO meta_data_people VALUES (241, 20);
INSERT INTO meta_data_people VALUES (256, 14);
INSERT INTO meta_data_people VALUES (261, 14);
INSERT INTO meta_data_people VALUES (268, 16);
INSERT INTO meta_data_people VALUES (282, 16);
INSERT INTO meta_data_people VALUES (294, 17);
INSERT INTO meta_data_people VALUES (294, 18);
INSERT INTO meta_data_people VALUES (301, 17);
INSERT INTO meta_data_people VALUES (306, 13);
INSERT INTO meta_data_people VALUES (311, 13);
INSERT INTO meta_data_people VALUES (320, 21);
INSERT INTO meta_data_people VALUES (328, 22);
INSERT INTO meta_data_people VALUES (340, 17);
INSERT INTO meta_data_people VALUES (340, 18);
INSERT INTO meta_data_people VALUES (347, 17);
INSERT INTO meta_data_people VALUES (352, 13);
INSERT INTO meta_data_people VALUES (357, 13);
INSERT INTO meta_data_people VALUES (369, 23);
INSERT INTO meta_data_people VALUES (384, 17);
INSERT INTO meta_data_people VALUES (384, 18);
INSERT INTO meta_data_people VALUES (391, 17);
INSERT INTO meta_data_people VALUES (396, 13);
INSERT INTO meta_data_people VALUES (401, 13);
INSERT INTO meta_data_people VALUES (403, 24);
INSERT INTO meta_data_people VALUES (403, 25);
INSERT INTO meta_data_people VALUES (403, 26);
INSERT INTO meta_data_people VALUES (403, 27);
INSERT INTO meta_data_people VALUES (403, 28);
INSERT INTO meta_data_people VALUES (403, 29);
INSERT INTO meta_data_people VALUES (427, 11);
INSERT INTO meta_data_people VALUES (434, 11);
INSERT INTO meta_data_people VALUES (439, 13);
INSERT INTO meta_data_people VALUES (445, 13);
INSERT INTO meta_data_people VALUES (448, 17);
INSERT INTO meta_data_people VALUES (448, 18);
INSERT INTO meta_data_people VALUES (455, 17);
INSERT INTO meta_data_people VALUES (460, 13);
INSERT INTO meta_data_people VALUES (465, 13);
INSERT INTO meta_data_people VALUES (475, 22);
INSERT INTO meta_data_people VALUES (488, 30);
INSERT INTO meta_data_people VALUES (490, 31);
INSERT INTO meta_data_people VALUES (494, 13);
INSERT INTO meta_data_people VALUES (499, 13);
INSERT INTO meta_data_people VALUES (502, 11);
INSERT INTO meta_data_people VALUES (509, 11);
INSERT INTO meta_data_people VALUES (514, 13);
INSERT INTO meta_data_people VALUES (520, 13);
INSERT INTO meta_data_people VALUES (522, 32);
INSERT INTO meta_data_people VALUES (532, 33);
INSERT INTO meta_data_people VALUES (536, 13);
INSERT INTO meta_data_people VALUES (541, 13);
INSERT INTO meta_data_people VALUES (546, 11);
INSERT INTO meta_data_people VALUES (553, 11);
INSERT INTO meta_data_people VALUES (558, 13);
INSERT INTO meta_data_people VALUES (564, 13);
INSERT INTO meta_data_people VALUES (566, 14);
INSERT INTO meta_data_people VALUES (571, 14);
INSERT INTO meta_data_people VALUES (577, 16);
INSERT INTO meta_data_people VALUES (589, 16);
INSERT INTO meta_data_people VALUES (592, 17);
INSERT INTO meta_data_people VALUES (592, 18);
INSERT INTO meta_data_people VALUES (599, 17);
INSERT INTO meta_data_people VALUES (604, 13);
INSERT INTO meta_data_people VALUES (609, 13);
INSERT INTO meta_data_people VALUES (611, 14);
INSERT INTO meta_data_people VALUES (616, 14);
INSERT INTO meta_data_people VALUES (623, 16);
INSERT INTO meta_data_people VALUES (637, 16);
INSERT INTO meta_data_people VALUES (640, 17);
INSERT INTO meta_data_people VALUES (640, 18);
INSERT INTO meta_data_people VALUES (647, 17);
INSERT INTO meta_data_people VALUES (652, 13);
INSERT INTO meta_data_people VALUES (657, 13);
INSERT INTO meta_data_people VALUES (659, 14);
INSERT INTO meta_data_people VALUES (664, 14);
INSERT INTO meta_data_people VALUES (671, 16);
INSERT INTO meta_data_people VALUES (685, 16);
INSERT INTO meta_data_people VALUES (697, 17);
INSERT INTO meta_data_people VALUES (697, 18);
INSERT INTO meta_data_people VALUES (704, 17);
INSERT INTO meta_data_people VALUES (709, 13);
INSERT INTO meta_data_people VALUES (714, 13);
INSERT INTO meta_data_people VALUES (723, 17);
INSERT INTO meta_data_people VALUES (723, 18);
INSERT INTO meta_data_people VALUES (730, 17);
INSERT INTO meta_data_people VALUES (735, 13);
INSERT INTO meta_data_people VALUES (740, 13);
INSERT INTO meta_data_people VALUES (753, 17);
INSERT INTO meta_data_people VALUES (753, 18);
INSERT INTO meta_data_people VALUES (760, 17);
INSERT INTO meta_data_people VALUES (765, 13);
INSERT INTO meta_data_people VALUES (770, 13);
INSERT INTO meta_data_people VALUES (779, 20);
INSERT INTO meta_data_people VALUES (804, 21);
INSERT INTO meta_data_people VALUES (812, 22);
INSERT INTO meta_data_people VALUES (823, 23);
INSERT INTO meta_data_people VALUES (843, 24);
INSERT INTO meta_data_people VALUES (843, 25);
INSERT INTO meta_data_people VALUES (843, 26);
INSERT INTO meta_data_people VALUES (843, 27);
INSERT INTO meta_data_people VALUES (843, 28);
INSERT INTO meta_data_people VALUES (843, 29);
INSERT INTO meta_data_people VALUES (858, 11);
INSERT INTO meta_data_people VALUES (865, 11);
INSERT INTO meta_data_people VALUES (870, 13);
INSERT INTO meta_data_people VALUES (876, 13);
INSERT INTO meta_data_people VALUES (886, 17);
INSERT INTO meta_data_people VALUES (891, 13);
INSERT INTO meta_data_people VALUES (896, 13);
INSERT INTO meta_data_people VALUES (906, 22);
INSERT INTO meta_data_people VALUES (921, 24);
INSERT INTO meta_data_people VALUES (921, 25);
INSERT INTO meta_data_people VALUES (921, 26);
INSERT INTO meta_data_people VALUES (921, 27);
INSERT INTO meta_data_people VALUES (921, 28);
INSERT INTO meta_data_people VALUES (921, 29);
INSERT INTO meta_data_people VALUES (966, 22);
INSERT INTO meta_data_people VALUES (879, 17);
INSERT INTO meta_data_people VALUES (879, 18);
INSERT INTO meta_data_people VALUES (1096, 1);
INSERT INTO meta_data_people VALUES (1099, 34);


--
-- Data for Name: meta_data_users; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO meta_data_users VALUES (35, 6);
INSERT INTO meta_data_users VALUES (53, 6);
INSERT INTO meta_data_users VALUES (86, 7);
INSERT INTO meta_data_users VALUES (92, 7);
INSERT INTO meta_data_users VALUES (113, 7);
INSERT INTO meta_data_users VALUES (134, 7);
INSERT INTO meta_data_users VALUES (159, 7);
INSERT INTO meta_data_users VALUES (179, 7);
INSERT INTO meta_data_users VALUES (207, 7);
INSERT INTO meta_data_users VALUES (213, 7);
INSERT INTO meta_data_users VALUES (219, 7);
INSERT INTO meta_data_users VALUES (239, 7);
INSERT INTO meta_data_users VALUES (255, 7);
INSERT INTO meta_data_users VALUES (283, 7);
INSERT INTO meta_data_users VALUES (292, 7);
INSERT INTO meta_data_users VALUES (312, 7);
INSERT INTO meta_data_users VALUES (318, 7);
INSERT INTO meta_data_users VALUES (338, 7);
INSERT INTO meta_data_users VALUES (358, 7);
INSERT INTO meta_data_users VALUES (368, 7);
INSERT INTO meta_data_users VALUES (382, 7);
INSERT INTO meta_data_users VALUES (402, 7);
INSERT INTO meta_data_users VALUES (416, 7);
INSERT INTO meta_data_users VALUES (425, 7);
INSERT INTO meta_data_users VALUES (446, 7);
INSERT INTO meta_data_users VALUES (466, 7);
INSERT INTO meta_data_users VALUES (468, 7);
INSERT INTO meta_data_users VALUES (485, 7);
INSERT INTO meta_data_users VALUES (500, 7);
INSERT INTO meta_data_users VALUES (521, 7);
INSERT INTO meta_data_users VALUES (530, 7);
INSERT INTO meta_data_users VALUES (542, 7);
INSERT INTO meta_data_users VALUES (544, 7);
INSERT INTO meta_data_users VALUES (565, 7);
INSERT INTO meta_data_users VALUES (590, 7);
INSERT INTO meta_data_users VALUES (610, 7);
INSERT INTO meta_data_users VALUES (638, 7);
INSERT INTO meta_data_users VALUES (658, 7);
INSERT INTO meta_data_users VALUES (686, 7);
INSERT INTO meta_data_users VALUES (695, 7);
INSERT INTO meta_data_users VALUES (715, 7);
INSERT INTO meta_data_users VALUES (721, 7);
INSERT INTO meta_data_users VALUES (741, 7);
INSERT INTO meta_data_users VALUES (751, 7);
INSERT INTO meta_data_users VALUES (771, 7);
INSERT INTO meta_data_users VALUES (777, 7);
INSERT INTO meta_data_users VALUES (793, 7);
INSERT INTO meta_data_users VALUES (802, 7);
INSERT INTO meta_data_users VALUES (822, 7);
INSERT INTO meta_data_users VALUES (836, 7);
INSERT INTO meta_data_users VALUES (842, 7);
INSERT INTO meta_data_users VALUES (856, 7);
INSERT INTO meta_data_users VALUES (877, 7);
INSERT INTO meta_data_users VALUES (897, 7);
INSERT INTO meta_data_users VALUES (899, 7);
INSERT INTO meta_data_users VALUES (916, 7);
INSERT INTO meta_data_users VALUES (934, 2);
INSERT INTO meta_data_users VALUES (976, 2);
INSERT INTO meta_data_users VALUES (990, 7);
INSERT INTO meta_data_users VALUES (1052, 6);
INSERT INTO meta_data_users VALUES (1084, 6);
INSERT INTO meta_data_users VALUES (1109, 3);
INSERT INTO meta_data_users VALUES (1168, 2);
INSERT INTO meta_data_users VALUES (1172, 1);
INSERT INTO meta_data_users VALUES (1176, 1);


--
-- Data for Name: meta_key_definitions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO meta_key_definitions VALUES (136, 121, NULL, 116, false, NULL, NULL, 6, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'copyright status', 'upload');
INSERT INTO meta_key_definitions VALUES (1, 276, NULL, 1, false, NULL, NULL, 1, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'title', 'core');
INSERT INTO meta_key_definitions VALUES (4, 278, NULL, 7, false, NULL, NULL, 4, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'keywords', 'core');
INSERT INTO meta_key_definitions VALUES (86, 917, 139, 3, false, NULL, NULL, 3, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'author', 'media_content');
INSERT INTO meta_key_definitions VALUES (89, 935, NULL, 254, false, 255, NULL, 4, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object dates', 'media_content');
INSERT INTO meta_key_definitions VALUES (90, 256, NULL, 255, false, NULL, NULL, 11, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object location', 'media_content');
INSERT INTO meta_key_definitions VALUES (3, 275, NULL, 274, false, 255, NULL, 3, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object dates', 'core');
INSERT INTO meta_key_definitions VALUES (5, 279, NULL, 1431, false, NULL, NULL, 5, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'copyright notice', 'core');
INSERT INTO meta_key_definitions VALUES (8, NULL, 13, 304, false, NULL, NULL, 32, 'objects.objectnumber', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'objectnumber', 'tms');
INSERT INTO meta_key_definitions VALUES (9, NULL, 14, 304, false, NULL, NULL, 33, 'objects.objectname', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'objectname', 'tms');
INSERT INTO meta_key_definitions VALUES (10, NULL, 1, 1, false, NULL, NULL, 1, 'objtitles.title titletypID=1', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'title', 'tms');
INSERT INTO meta_key_definitions VALUES (11, NULL, 196, 16, false, NULL, NULL, 2, 'objtitles.title titletypID=6', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'subtitle', 'tms');
INSERT INTO meta_key_definitions VALUES (12, NULL, 2645, 18, false, NULL, NULL, 8, 'objects.chat', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'description', 'tms');
INSERT INTO meta_key_definitions VALUES (14, NULL, 212, 21, false, NULL, NULL, 9, 'objects.notes', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'remark', 'tms');
INSERT INTO meta_key_definitions VALUES (15, NULL, 311, 254, false, 255, NULL, 5, 'objects.dated', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object dates', 'tms');
INSERT INTO meta_key_definitions VALUES (17, NULL, 2653, 25, false, NULL, NULL, 25, 'objects.copyright typ=creditlinerepro', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'copyright notice', 'tms');
INSERT INTO meta_key_definitions VALUES (18, NULL, 244, 108, false, NULL, NULL, 30, 'objects.dimensions', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object dimensions', 'tms');
INSERT INTO meta_key_definitions VALUES (19, NULL, 333, 332, false, NULL, NULL, 31, 'objects.medium', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object materials', 'tms');
INSERT INTO meta_key_definitions VALUES (20, NULL, NULL, NULL, true, NULL, NULL, 1, 'XMP-madek:Author', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'author', 'io_interface');
INSERT INTO meta_key_definitions VALUES (21, NULL, NULL, NULL, false, NULL, NULL, 2, 'XMP-madek:AdditionalAuthors', 'Array', '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'additional authors', 'io_interface');
INSERT INTO meta_key_definitions VALUES (22, NULL, NULL, NULL, true, NULL, NULL, 3, 'XMP-dc:Rights', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'copyright notice', 'io_interface');
INSERT INTO meta_key_definitions VALUES (23, NULL, NULL, NULL, false, NULL, NULL, 4, 'XMP-xmpRights:Marked', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'copyright status', 'io_interface');
INSERT INTO meta_key_definitions VALUES (24, NULL, NULL, NULL, false, NULL, NULL, 5, 'XMP-xmpRights:UsageTerms', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'copyright usage', 'io_interface');
INSERT INTO meta_key_definitions VALUES (25, NULL, NULL, NULL, false, NULL, NULL, 6, 'XMP-xmpRights:WebStatement', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'copyright url', 'io_interface');
INSERT INTO meta_key_definitions VALUES (26, NULL, NULL, NULL, true, NULL, NULL, 7, 'XMP-photoshop:CaptionWriter', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'description author', 'io_interface');
INSERT INTO meta_key_definitions VALUES (27, NULL, NULL, NULL, true, 255, 2, 8, 'XMP-madek:Coverage', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'coverage', 'io_interface');
INSERT INTO meta_key_definitions VALUES (28, NULL, NULL, NULL, true, NULL, NULL, 9, 'XMP-dc:Creator', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'creator', 'io_interface');
INSERT INTO meta_key_definitions VALUES (29, NULL, NULL, NULL, true, NULL, NULL, 10, 'XMP-photoshop:AuthorsPosition', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'creator position', 'io_interface');
INSERT INTO meta_key_definitions VALUES (30, NULL, NULL, NULL, true, 32, 1, 11, 'XMP-iptcCore:CreatorAddress', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'creator address', 'io_interface');
INSERT INTO meta_key_definitions VALUES (31, NULL, NULL, NULL, true, 32, 1, 12, 'XMP-iptcCore:CreatorCity', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'creator city', 'io_interface');
INSERT INTO meta_key_definitions VALUES (32, NULL, NULL, NULL, true, 32, 1, 13, 'XMP-iptcCore:CreatorRegion', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'creator state', 'io_interface');
INSERT INTO meta_key_definitions VALUES (33, NULL, NULL, NULL, true, 32, 1, 14, 'XMP-iptcCore:CreatorCountry', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'creator country', 'io_interface');
INSERT INTO meta_key_definitions VALUES (34, NULL, NULL, NULL, true, 32, 1, 15, 'XMP-iptcCore:CreatorPostalCode', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'creator postal code', 'io_interface');
INSERT INTO meta_key_definitions VALUES (35, NULL, NULL, NULL, true, 32, 1, 16, 'XMP-iptcCore:CreatorWorkTelephone', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'creator work telephone', 'io_interface');
INSERT INTO meta_key_definitions VALUES (36, NULL, NULL, NULL, true, 32, 1, 17, 'XMP-iptcCore:CreatorWorkEmail', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'creator work email', 'io_interface');
INSERT INTO meta_key_definitions VALUES (37, NULL, NULL, NULL, true, 32, 1, 18, 'XMP-iptcCore:CreatorWorkURL', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'creator work url', 'io_interface');
INSERT INTO meta_key_definitions VALUES (38, NULL, NULL, NULL, true, 4096, 1, 19, 'XMP-dc:Description', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'description', 'io_interface');
INSERT INTO meta_key_definitions VALUES (39, NULL, NULL, NULL, true, NULL, NULL, 20, 'XMP-madek:Format', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'format', 'io_interface');
INSERT INTO meta_key_definitions VALUES (40, NULL, NULL, NULL, false, NULL, NULL, 21, 'XMP-madek:Hyperlinks', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'hyperlinks', 'io_interface');
INSERT INTO meta_key_definitions VALUES (41, NULL, NULL, NULL, false, NULL, NULL, 22, 'XMP-madek:InstitutionalAffiliation', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'institutional affiliation', 'io_interface');
INSERT INTO meta_key_definitions VALUES (42, NULL, NULL, NULL, true, 255, 1, 23, 'XMP-dc:Identifier', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'identifier', 'io_interface');
INSERT INTO meta_key_definitions VALUES (43, NULL, NULL, NULL, true, NULL, NULL, 24, 'XMP-dc:Subject', 'Array', '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'keywords', 'io_interface');
INSERT INTO meta_key_definitions VALUES (44, NULL, NULL, NULL, true, NULL, NULL, 25, 'XMP-madek:Language', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'language', 'io_interface');
INSERT INTO meta_key_definitions VALUES (45, NULL, NULL, NULL, false, 255, 1, 26, 'XMP-madek:OtherCreativeParticipants', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'other creative participants', 'io_interface');
INSERT INTO meta_key_definitions VALUES (47, NULL, NULL, NULL, false, NULL, NULL, 28, 'XMP-madek:patron', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'patron', 'io_interface');
INSERT INTO meta_key_definitions VALUES (48, NULL, NULL, NULL, false, NULL, NULL, 29, 'XMP-madek:PortrayedPerson', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed person', 'io_interface');
INSERT INTO meta_key_definitions VALUES (49, NULL, NULL, NULL, false, NULL, NULL, 30, 'XMP-madek:PortrayedInstitution', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed institution', 'io_interface');
INSERT INTO meta_key_definitions VALUES (50, NULL, NULL, NULL, false, NULL, NULL, 31, 'XMP-madek:ProjectLeader', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'project leader', 'io_interface');
INSERT INTO meta_key_definitions VALUES (51, NULL, NULL, NULL, false, NULL, NULL, 32, 'XMP-madek:PublicCaption', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'public caption', 'io_interface');
INSERT INTO meta_key_definitions VALUES (52, NULL, NULL, NULL, false, NULL, NULL, 33, 'XMP-madek:PortrayedObjectDimensions', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object dimensions', 'io_interface');
INSERT INTO meta_key_definitions VALUES (53, NULL, NULL, NULL, false, NULL, NULL, 34, 'XMP-madek:PortrayedObjectMaterials', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object materials', 'io_interface');
INSERT INTO meta_key_definitions VALUES (54, NULL, NULL, NULL, true, 255, NULL, 35, 'XMP-madek:PortrayedObjectDates', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object dates', 'io_interface');
INSERT INTO meta_key_definitions VALUES (55, NULL, NULL, NULL, true, 32, 1, 36, 'XMP-iptcCore:CountryCode', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object country code', 'io_interface');
INSERT INTO meta_key_definitions VALUES (56, NULL, NULL, NULL, true, 32, 1, 37, 'XMP-iptcCore:Location', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object location', 'io_interface');
INSERT INTO meta_key_definitions VALUES (57, NULL, NULL, NULL, true, 32, 1, 38, 'XMP-photoshop:City', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object city', 'io_interface');
INSERT INTO meta_key_definitions VALUES (58, NULL, NULL, NULL, true, 32, 1, 39, 'XMP-photoshop:State', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object state', 'io_interface');
INSERT INTO meta_key_definitions VALUES (59, NULL, NULL, NULL, true, 32, 1, 40, 'XMP-photoshop:Country', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object country', 'io_interface');
INSERT INTO meta_key_definitions VALUES (60, NULL, NULL, NULL, true, NULL, NULL, 41, 'XMP-photoshop:Credit', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'provider', 'io_interface');
INSERT INTO meta_key_definitions VALUES (61, NULL, NULL, NULL, true, NULL, NULL, 42, 'XMP-xmp:Rating', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'rating', 'io_interface');
INSERT INTO meta_key_definitions VALUES (62, NULL, NULL, NULL, true, NULL, NULL, 43, 'XMP-madek:Relation', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'relation', 'io_interface');
INSERT INTO meta_key_definitions VALUES (63, NULL, NULL, NULL, false, NULL, NULL, 44, 'XMP-madek:Remark', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'remark', 'io_interface');
INSERT INTO meta_key_definitions VALUES (64, NULL, NULL, NULL, true, NULL, NULL, 45, 'XMP-photoshop:Source', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'source', 'io_interface');
INSERT INTO meta_key_definitions VALUES (65, NULL, NULL, NULL, false, NULL, NULL, 46, 'XMP-madek:SourceImage', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'source image', 'io_interface');
INSERT INTO meta_key_definitions VALUES (66, NULL, NULL, NULL, false, NULL, NULL, 47, 'XMP-madek:SourcePlate', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'source plate', 'io_interface');
INSERT INTO meta_key_definitions VALUES (67, NULL, NULL, NULL, false, NULL, NULL, 48, 'XMP-madek:SourceSide', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'source side', 'io_interface');
INSERT INTO meta_key_definitions VALUES (68, NULL, NULL, NULL, false, NULL, NULL, 49, 'XMP-madek:SourceIsbn', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'source isbn', 'io_interface');
INSERT INTO meta_key_definitions VALUES (69, NULL, NULL, NULL, true, 32, 1, 50, 'XMP-iptcCore:Scene', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'scene', 'io_interface');
INSERT INTO meta_key_definitions VALUES (70, NULL, NULL, NULL, true, 32, 1, 51, 'XMP-iptcCore:SubjectCode', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'subject code', 'io_interface');
INSERT INTO meta_key_definitions VALUES (71, NULL, NULL, NULL, false, NULL, NULL, 52, 'XMP-madek:ShortDescription', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'short description', 'io_interface');
INSERT INTO meta_key_definitions VALUES (72, NULL, NULL, NULL, false, NULL, NULL, 53, 'XMP-photoshop:Headline', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'subtitle', 'io_interface');
INSERT INTO meta_key_definitions VALUES (73, NULL, NULL, NULL, true, 4096, 1, 54, 'XMP-dc:Title', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'title', 'io_interface');
INSERT INTO meta_key_definitions VALUES (74, NULL, NULL, NULL, true, NULL, NULL, 55, 'XMP-dc:Type', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'type', 'io_interface');
INSERT INTO meta_key_definitions VALUES (75, NULL, NULL, NULL, true, NULL, NULL, 56, 'XMP-madek:ProjectType', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'project type', 'io_interface');
INSERT INTO meta_key_definitions VALUES (76, NULL, NULL, NULL, false, NULL, NULL, 57, 'XMP-madek:AcademicYear', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'academic year', 'io_interface');
INSERT INTO meta_key_definitions VALUES (77, NULL, NULL, NULL, false, NULL, NULL, 58, 'XMP-madek:ParticipatingInstitution', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'participating institution', 'io_interface');
INSERT INTO meta_key_definitions VALUES (78, NULL, NULL, NULL, false, NULL, NULL, 59, 'XMP-madek:Publisher', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'publisher', 'io_interface');
INSERT INTO meta_key_definitions VALUES (79, NULL, NULL, NULL, false, NULL, NULL, 60, 'XMP-madek:TransmissionReference', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'transmission reference', 'io_interface');
INSERT INTO meta_key_definitions VALUES (80, NULL, NULL, NULL, false, NULL, NULL, 61, 'XMP-madek:Urn', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'urn', 'io_interface');
INSERT INTO meta_key_definitions VALUES (81, NULL, NULL, NULL, false, NULL, NULL, 62, 'XMP-madek:Tags', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'tags', 'io_interface');
INSERT INTO meta_key_definitions VALUES (82, NULL, NULL, NULL, false, NULL, NULL, 63, 'XMP-madek:DateCreated, XMP-photoshop:DateCreated', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'date created', 'io_interface');
INSERT INTO meta_key_definitions VALUES (83, 276, 1915, 1919, false, NULL, NULL, 1, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'title', 'media_content');
INSERT INTO meta_key_definitions VALUES (84, 1917, NULL, 16, false, NULL, NULL, 2, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'subtitle', 'media_content');
INSERT INTO meta_key_definitions VALUES (85, 248, 138, 7, false, NULL, NULL, 5, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'keywords', 'media_content');
INSERT INTO meta_key_definitions VALUES (91, 161, NULL, 35, false, NULL, NULL, 12, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object city', 'media_content');
INSERT INTO meta_key_definitions VALUES (92, 162, NULL, 37, false, NULL, NULL, 13, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object state', 'media_content');
INSERT INTO meta_key_definitions VALUES (93, 163, NULL, 39, false, NULL, NULL, 14, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object country', 'media_content');
INSERT INTO meta_key_definitions VALUES (94, 164, NULL, 41, false, NULL, NULL, 15, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object country code', 'media_content');
INSERT INTO meta_key_definitions VALUES (95, 133, NULL, 43, false, NULL, NULL, 17, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed person', 'media_content');
INSERT INTO meta_key_definitions VALUES (97, 168, 167, 46, false, NULL, NULL, 16, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'other creative participants', 'media_content');
INSERT INTO meta_key_definitions VALUES (98, 142, NULL, 48, false, NULL, NULL, 19, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'participating institution', 'media_content');
INSERT INTO meta_key_definitions VALUES (99, 141, NULL, 49, false, NULL, NULL, 20, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'patron', 'media_content');
INSERT INTO meta_key_definitions VALUES (102, 271, NULL, 66, false, NULL, NULL, 7, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'public caption', 'media_content');
INSERT INTO meta_key_definitions VALUES (103, 272, 158, 18, false, NULL, NULL, 8, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'description', 'media_content');
INSERT INTO meta_key_definitions VALUES (104, 273, NULL, 21, false, NULL, NULL, 9, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'remark', 'media_content');
INSERT INTO meta_key_definitions VALUES (105, 360, 359, 70, false, NULL, NULL, 10, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'hyperlinks', 'media_content');
INSERT INTO meta_key_definitions VALUES (106, 270, 149, 71, false, NULL, NULL, 6, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'type', 'media_content');
INSERT INTO meta_key_definitions VALUES (108, 260, 139, 184, false, NULL, NULL, 1, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'creator', 'media_object');
INSERT INTO meta_key_definitions VALUES (109, NULL, NULL, 94, true, 32, 1, 2, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'creator address', 'media_object');
INSERT INTO meta_key_definitions VALUES (110, NULL, NULL, 35, true, 32, 1, 3, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'creator city', 'media_object');
INSERT INTO meta_key_definitions VALUES (111, NULL, NULL, 37, true, 32, 1, 4, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'creator state', 'media_object');
INSERT INTO meta_key_definitions VALUES (112, NULL, NULL, 95, true, 32, 1, 5, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'creator postal code', 'media_object');
INSERT INTO meta_key_definitions VALUES (113, NULL, NULL, 39, true, 32, 1, 6, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'creator country', 'media_object');
INSERT INTO meta_key_definitions VALUES (114, NULL, NULL, 96, true, 32, 1, 7, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'creator work telephone', 'media_object');
INSERT INTO meta_key_definitions VALUES (115, NULL, NULL, 97, true, 32, 1, 8, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'creator work email', 'media_object');
INSERT INTO meta_key_definitions VALUES (116, NULL, NULL, 98, true, 32, 1, 9, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'creator work url', 'media_object');
INSERT INTO meta_key_definitions VALUES (117, NULL, NULL, 99, false, 32, 1, 10, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'creator position', 'media_object');
INSERT INTO meta_key_definitions VALUES (119, 267, 937, 102, false, NULL, NULL, 12, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'date created', 'media_object');
INSERT INTO meta_key_definitions VALUES (122, 175, 185, 108, false, NULL, NULL, 15, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object dimensions', 'media_object');
INSERT INTO meta_key_definitions VALUES (123, 363, 362, 266, false, NULL, NULL, 16, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object materials', 'media_object');
INSERT INTO meta_key_definitions VALUES (124, 395, NULL, 1, true, 255, NULL, 1, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'title', 'media_set');
INSERT INTO meta_key_definitions VALUES (127, 361, 364, 1431, false, NULL, NULL, 1, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'copyright notice', 'copyright');
INSERT INTO meta_key_definitions VALUES (128, 117, NULL, 116, false, NULL, NULL, 2, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'copyright status', 'copyright');
INSERT INTO meta_key_definitions VALUES (129, 365, NULL, 118, false, NULL, NULL, 3, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'copyright usage', 'copyright');
INSERT INTO meta_key_definitions VALUES (130, 367, 359, 119, false, NULL, NULL, 4, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'copyright url', 'copyright');
INSERT INTO meta_key_definitions VALUES (131, 153, NULL, 1, true, 255, 1, 1, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'title', 'upload');
INSERT INTO meta_key_definitions VALUES (132, 909, 139, 3, false, NULL, NULL, 2, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'author', 'upload');
INSERT INTO meta_key_definitions VALUES (133, 935, NULL, 274, false, 255, NULL, 3, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object dates', 'upload');
INSERT INTO meta_key_definitions VALUES (134, 248, 138, 7, false, NULL, NULL, 4, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'keywords', 'upload');
INSERT INTO meta_key_definitions VALUES (135, 361, 364, 1431, true, 255, 1, 5, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'copyright notice', 'upload');
INSERT INTO meta_key_definitions VALUES (137, 365, NULL, 118, false, NULL, NULL, 7, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'copyright usage', 'upload');
INSERT INTO meta_key_definitions VALUES (138, 367, 359, 119, false, NULL, NULL, 8, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'copyright url', 'upload');
INSERT INTO meta_key_definitions VALUES (140, NULL, NULL, NULL, false, NULL, NULL, 64, 'XMP-photoshop:ColorMode', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'color mode', 'io_interface');
INSERT INTO meta_key_definitions VALUES (141, NULL, NULL, NULL, false, NULL, NULL, 65, 'XMP-photoshop:History', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'history', 'io_interface');
INSERT INTO meta_key_definitions VALUES (142, NULL, NULL, NULL, false, NULL, NULL, 66, 'XMP-iptcCore:IntellectualGenre', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'intellectual genre', 'io_interface');
INSERT INTO meta_key_definitions VALUES (145, NULL, NULL, NULL, false, NULL, NULL, 67, 'XMP-iptcCore:CreatorContactInfo', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'creator contact info', 'io_interface');
INSERT INTO meta_key_definitions VALUES (146, 188, 1507, 30, false, NULL, NULL, 1, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'institutional affiliation', 'zhdk_bereich');
INSERT INTO meta_key_definitions VALUES (147, 358, 149, 189, false, NULL, NULL, 2, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'project type', 'zhdk_bereich');
INSERT INTO meta_key_definitions VALUES (148, 2013, 149, 2011, false, NULL, NULL, 3, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'academic year', 'zhdk_bereich');
INSERT INTO meta_key_definitions VALUES (149, 146, NULL, 65, false, NULL, NULL, 5, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'project leader', 'zhdk_bereich');
INSERT INTO meta_key_definitions VALUES (150, 262, 192, 104, false, NULL, NULL, 5, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'source', 'copyright');
INSERT INTO meta_key_definitions VALUES (152, 193, 366, 106, false, NULL, NULL, 6, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'provider', 'copyright');
INSERT INTO meta_key_definitions VALUES (180, 301, NULL, 300, false, NULL, NULL, 4, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'project title', 'zhdk_bereich');
INSERT INTO meta_key_definitions VALUES (181, 400, 138, 302, false, NULL, NULL, 3, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'keywords', 'media_set');
INSERT INTO meta_key_definitions VALUES (182, 399, 158, 208, false, NULL, NULL, 4, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'description', 'media_set');
INSERT INTO meta_key_definitions VALUES (185, NULL, NULL, 3, false, NULL, NULL, 2, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'author', 'core');
INSERT INTO meta_key_definitions VALUES (186, 4357, 139, 3, false, NULL, NULL, 2, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'author', 'media_set');
INSERT INTO meta_key_definitions VALUES (187, NULL, 305, 305, false, NULL, NULL, 3, 'objtitles.title titletypID=99||sites.sitename', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'project title', 'tms');
INSERT INTO meta_key_definitions VALUES (188, NULL, 307, 198, false, NULL, NULL, 4, 'person RoleTypeID=1 RoleID=150', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'author', 'tms');
INSERT INTO meta_key_definitions VALUES (189, NULL, 2657, 308, false, NULL, NULL, 29, 'objects.publicaccess', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'public access', 'tms');
INSERT INTO meta_key_definitions VALUES (190, NULL, 2651, 200, false, NULL, NULL, 23, 'person RoleTypeID=1 RoleID=251', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'institutional affiliation', 'tms');
INSERT INTO meta_key_definitions VALUES (191, NULL, 204, 302, false, NULL, NULL, 6, 'textentries textart=Stichworte', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'keywords', 'tms');
INSERT INTO meta_key_definitions VALUES (192, NULL, 206, 317, false, NULL, NULL, 7, 'textentries textart=Gattung', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'type', 'tms');
INSERT INTO meta_key_definitions VALUES (194, NULL, 214, 214, false, NULL, NULL, 10, 'textentries textart="Web-Link"', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'hyperlinks', 'tms');
INSERT INTO meta_key_definitions VALUES (195, NULL, 2649, 216, false, NULL, NULL, 19, 'person RoleTypeID=1 RoleID=155', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed person', 'tms');
INSERT INTO meta_key_definitions VALUES (196, NULL, 218, 218, false, NULL, NULL, 20, 'person RoleTypeID=1 RoleID=156', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed institution', 'tms');
INSERT INTO meta_key_definitions VALUES (197, NULL, 321, 220, false, NULL, NULL, 16, 'person RoleTypeID=1 RoleID=86', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'other creative participants', 'tms');
INSERT INTO meta_key_definitions VALUES (503, NULL, NULL, 1993, false, NULL, NULL, 12, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'style', 'Landschaftsvisualisierung');
INSERT INTO meta_key_definitions VALUES (198, NULL, 2647, 222, false, NULL, NULL, 17, 'person RoleTypeID=1 RoleID=87', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'participating institution', 'tms');
INSERT INTO meta_key_definitions VALUES (199, NULL, 224, 224, false, NULL, NULL, 18, 'person RoleTypeID=1 RoleID=22', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'patron', 'tms');
INSERT INTO meta_key_definitions VALUES (201, NULL, 229, 229, false, NULL, NULL, 24, 'person RoleTypeID=1 RoleID=61', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'project leader', 'tms');
INSERT INTO meta_key_definitions VALUES (202, NULL, 325, 231, false, NULL, NULL, 21, 'person RoleTypeID=1 RoleID=21', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'creator', 'tms');
INSERT INTO meta_key_definitions VALUES (205, NULL, 239, 239, false, NULL, NULL, 27, 'objects.copyright typ=restrictions', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'copyright usage', 'tms');
INSERT INTO meta_key_definitions VALUES (206, NULL, 329, 241, false, NULL, NULL, 28, 'objects.copyright typ=restrictions', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'copyright url', 'tms');
INSERT INTO meta_key_definitions VALUES (208, NULL, 334, 334, false, NULL, NULL, 11, 'textentries textart=Geografie typ="Standort/Aufführungsort"', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object location', 'tms');
INSERT INTO meta_key_definitions VALUES (209, NULL, 335, 336, false, NULL, NULL, 12, 'textentries textart=Geografie typ=Stadt', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object city', 'tms');
INSERT INTO meta_key_definitions VALUES (210, NULL, 335, 337, false, NULL, NULL, 13, 'textentries textart=Geografie typ="Kanton/Bundesland"', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object state', 'tms');
INSERT INTO meta_key_definitions VALUES (211, NULL, 335, 338, false, NULL, NULL, 14, 'textentries textart=Geografie typ=Land', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object country', 'tms');
INSERT INTO meta_key_definitions VALUES (212, NULL, 335, 339, false, NULL, NULL, 15, 'textentries textart=Geografie typ="ISO-Ländercode"', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'portrayed object country code', 'tms');
INSERT INTO meta_key_definitions VALUES (217, 368, 139, 348, false, NULL, NULL, 7, NULL, NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'description author', 'copyright');
INSERT INTO meta_key_definitions VALUES (218, 371, 349, 349, false, NULL, NULL, 35, 'textentries textart="Erfasser/in"', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'description author', 'tms');
INSERT INTO meta_key_definitions VALUES (219, 369, 355, 355, false, NULL, NULL, 36, 'textentries textart="Erfasser/in vor dem Hochladen ins Medienarchiv"', NULL, '2012-04-20 12:01:52', '2012-04-20 12:01:52', 'description author before import', 'tms');
INSERT INTO meta_key_definitions VALUES (221, 369, 139, 355, false, NULL, NULL, 8, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'description author before import', 'copyright');
INSERT INTO meta_key_definitions VALUES (224, NULL, NULL, 394, false, NULL, NULL, 7, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'uploaded at', 'media_set');
INSERT INTO meta_key_definitions VALUES (225, NULL, NULL, NULL, false, NULL, NULL, 68, 'XMP-photoshop:SidecarForExtension', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'sidecar for extension', 'io_interface');
INSERT INTO meta_key_definitions VALUES (227, NULL, 981, 979, false, NULL, NULL, 1, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'LV_Landschaftstyp', 'Landschaftsvisualisierung');
INSERT INTO meta_key_definitions VALUES (229, NULL, 981, 983, false, NULL, NULL, 2, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'LV_Verwendungszweck', 'Landschaftsvisualisierung');
INSERT INTO meta_key_definitions VALUES (231, 1415, 987, 985, false, NULL, NULL, 10, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'LV_Bildwirkung', 'Landschaftsvisualisierung');
INSERT INTO meta_key_definitions VALUES (233, 993, NULL, 991, false, NULL, NULL, 3, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'LV_Bildzeit', 'Landschaftsvisualisierung');
INSERT INTO meta_key_definitions VALUES (235, 1015, 987, 995, false, NULL, NULL, 5, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'LV_Farbe', 'Landschaftsvisualisierung');
INSERT INTO meta_key_definitions VALUES (237, 1001, 987, 999, false, NULL, NULL, 9, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'LV_Landschaftselemente', 'Landschaftsvisualisierung');
INSERT INTO meta_key_definitions VALUES (239, NULL, 981, 1003, false, NULL, NULL, 4, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'LV_Wetter/Klima', 'Landschaftsvisualisierung');
INSERT INTO meta_key_definitions VALUES (241, 1007, NULL, 1005, false, 1, NULL, 6, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'LV_Horizontlinie', 'Landschaftsvisualisierung');
INSERT INTO meta_key_definitions VALUES (243, NULL, 149, 1009, false, NULL, NULL, 7, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'LV_Ra?umliche Wahrnehmung', 'Landschaftsvisualisierung');
INSERT INTO meta_key_definitions VALUES (245, 1013, NULL, 1011, false, 1, NULL, 8, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'LV_Abstraktionsgrad', 'Landschaftsvisualisierung');
INSERT INTO meta_key_definitions VALUES (247, 208, 1189, 1187, false, NULL, NULL, 0, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'LV_Ra?umliche Wahrnehmung', 'Projekte ZHdK');
INSERT INTO meta_key_definitions VALUES (249, NULL, NULL, NULL, false, NULL, NULL, 69, 'XMP-photoshop:Category', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'category', 'io_interface');
INSERT INTO meta_key_definitions VALUES (251, NULL, NULL, 1489, false, NULL, NULL, 0, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'SL_Resourcen', 'SupplyLines');
INSERT INTO meta_key_definitions VALUES (253, NULL, NULL, 1503, false, NULL, NULL, 1, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'SO_Ordnungen', 'Columns');
INSERT INTO meta_key_definitions VALUES (255, 3537, NULL, 1633, false, NULL, NULL, 8, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'CA_Konzept', 'archhist');
INSERT INTO meta_key_definitions VALUES (257, 3529, NULL, 3432, false, NULL, NULL, 5, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'CA_Informationstechnologie', 'archhist');
INSERT INTO meta_key_definitions VALUES (259, 3523, NULL, 3521, false, NULL, NULL, 2, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'CA_Zweck', 'archhist');
INSERT INTO meta_key_definitions VALUES (261, 3527, NULL, 1637, false, NULL, NULL, 4, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'CA_Ausgangsmaterial', 'archhist');
INSERT INTO meta_key_definitions VALUES (263, 3531, NULL, 1639, false, NULL, NULL, 6, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'CA_Daten', 'archhist');
INSERT INTO meta_key_definitions VALUES (265, 3525, NULL, 1641, false, NULL, NULL, 3, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'CA_Kontext', 'archhist');
INSERT INTO meta_key_definitions VALUES (267, 3533, NULL, 1803, false, NULL, NULL, 7, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'CA_Sinnstiftung', 'archhist');
INSERT INTO meta_key_definitions VALUES (269, 3519, NULL, 1645, false, NULL, NULL, 1, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'CA_Thema', 'archhist');
INSERT INTO meta_key_definitions VALUES (271, NULL, NULL, 1981, false, NULL, NULL, 7, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'epoch', 'Columns');
INSERT INTO meta_key_definitions VALUES (273, NULL, NULL, 1667, false, NULL, NULL, 2, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'SO_Elemente', 'Columns');
INSERT INTO meta_key_definitions VALUES (275, NULL, NULL, 1641, false, NULL, NULL, 3, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'SO_Kontext', 'Columns');
INSERT INTO meta_key_definitions VALUES (277, NULL, NULL, 1669, false, NULL, NULL, 4, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'SO_Medium', 'Columns');
INSERT INTO meta_key_definitions VALUES (281, NULL, NULL, 1813, false, NULL, NULL, 1, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'VFO_Ansätze', 'VFO');
INSERT INTO meta_key_definitions VALUES (287, NULL, NULL, 1819, false, NULL, NULL, 2, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'VFO_Ausstellungen', 'VFO');
INSERT INTO meta_key_definitions VALUES (297, NULL, NULL, NULL, false, NULL, NULL, 70, 'QuickTime:CreateDate', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'create date', 'io_interface');
INSERT INTO meta_key_definitions VALUES (299, NULL, NULL, NULL, false, NULL, NULL, 71, 'QuickTime:CurrentTime', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'current time', 'io_interface');
INSERT INTO meta_key_definitions VALUES (301, NULL, NULL, NULL, false, NULL, NULL, 72, 'QuickTime:Duration', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'duration', 'io_interface');
INSERT INTO meta_key_definitions VALUES (303, NULL, NULL, NULL, false, NULL, NULL, 73, 'QuickTime:Free', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'free', 'io_interface');
INSERT INTO meta_key_definitions VALUES (305, NULL, NULL, NULL, false, NULL, NULL, 74, 'QuickTime:MatrixStructure', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'matrix structure', 'io_interface');
INSERT INTO meta_key_definitions VALUES (307, NULL, NULL, NULL, false, NULL, NULL, 75, 'QuickTime:ModifyDate', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'modify date', 'io_interface');
INSERT INTO meta_key_definitions VALUES (309, NULL, NULL, NULL, false, NULL, NULL, 76, 'QuickTime:MovieData', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'movie data', 'io_interface');
INSERT INTO meta_key_definitions VALUES (311, NULL, NULL, NULL, false, NULL, NULL, 77, 'QuickTime:MovieDataSize', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'movie data size', 'io_interface');
INSERT INTO meta_key_definitions VALUES (313, NULL, NULL, NULL, false, NULL, NULL, 78, 'QuickTime:MovieHeaderVersion', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'movie header version', 'io_interface');
INSERT INTO meta_key_definitions VALUES (315, NULL, NULL, NULL, false, NULL, NULL, 79, 'QuickTime:NextTrackID', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'next track id', 'io_interface');
INSERT INTO meta_key_definitions VALUES (317, NULL, NULL, NULL, false, NULL, NULL, 80, 'QuickTime:PosterTime', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'poster time', 'io_interface');
INSERT INTO meta_key_definitions VALUES (319, NULL, NULL, NULL, false, NULL, NULL, 81, 'QuickTime:PreferredRate', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'preferred rate', 'io_interface');
INSERT INTO meta_key_definitions VALUES (321, NULL, NULL, NULL, false, NULL, NULL, 82, 'QuickTime:PreferredVolume', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'preferred volume', 'io_interface');
INSERT INTO meta_key_definitions VALUES (323, NULL, NULL, NULL, false, NULL, NULL, 83, 'QuickTime:PreviewDuration', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'preview duration', 'io_interface');
INSERT INTO meta_key_definitions VALUES (325, NULL, NULL, NULL, false, NULL, NULL, 84, 'QuickTime:PreviewTime', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'preview time', 'io_interface');
INSERT INTO meta_key_definitions VALUES (327, NULL, NULL, NULL, false, NULL, NULL, 85, 'QuickTime:SelectionDuration', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'selection duration', 'io_interface');
INSERT INTO meta_key_definitions VALUES (329, NULL, NULL, NULL, false, NULL, NULL, 86, 'QuickTime:SelectionTime', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'selection time', 'io_interface');
INSERT INTO meta_key_definitions VALUES (331, NULL, NULL, NULL, false, NULL, NULL, 87, 'QuickTime:TimeScale', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'time scale', 'io_interface');
INSERT INTO meta_key_definitions VALUES (333, NULL, NULL, NULL, false, NULL, NULL, 88, 'QuickTime:Wide', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'wide', 'io_interface');
INSERT INTO meta_key_definitions VALUES (335, NULL, NULL, NULL, false, NULL, NULL, 89, 'Track1:AudioBitsPerSample', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'audio bits per sample', 'io_interface');
INSERT INTO meta_key_definitions VALUES (337, NULL, NULL, NULL, false, NULL, NULL, 90, 'Track1:AudioChannels', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'audio channels', 'io_interface');
INSERT INTO meta_key_definitions VALUES (339, NULL, NULL, NULL, false, NULL, NULL, 91, 'Track1:AudioFormat', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'audio format', 'io_interface');
INSERT INTO meta_key_definitions VALUES (341, NULL, NULL, NULL, false, NULL, NULL, 92, 'Track1:AudioSampleRate', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'audio sample rate', 'io_interface');
INSERT INTO meta_key_definitions VALUES (343, NULL, NULL, NULL, false, NULL, NULL, 93, 'Track1:Balance', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'balance', 'io_interface');
INSERT INTO meta_key_definitions VALUES (345, NULL, NULL, NULL, false, NULL, NULL, 94, 'Track1:ChunkOffset', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'chunk offset', 'io_interface');
INSERT INTO meta_key_definitions VALUES (347, NULL, NULL, NULL, false, NULL, NULL, 95, 'Track1:HandlerClass', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'handler class', 'io_interface');
INSERT INTO meta_key_definitions VALUES (349, NULL, NULL, NULL, false, NULL, NULL, 96, 'Track1:HandlerDescription', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'handler description', 'io_interface');
INSERT INTO meta_key_definitions VALUES (351, NULL, NULL, NULL, false, NULL, NULL, 97, 'Track1:HandlerType', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'handler type', 'io_interface');
INSERT INTO meta_key_definitions VALUES (353, NULL, NULL, NULL, false, NULL, NULL, 98, 'Track1:HandlerVendorID', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'handler vendor id', 'io_interface');
INSERT INTO meta_key_definitions VALUES (355, NULL, NULL, NULL, false, NULL, NULL, 99, 'Track1:MediaCreateDate', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'media create date', 'io_interface');
INSERT INTO meta_key_definitions VALUES (357, NULL, NULL, NULL, false, NULL, NULL, 100, 'Track1:MediaDuration', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'media duration', 'io_interface');
INSERT INTO meta_key_definitions VALUES (359, NULL, NULL, NULL, false, NULL, NULL, 101, 'Track1:MediaHeaderVersion', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'media header version', 'io_interface');
INSERT INTO meta_key_definitions VALUES (361, NULL, NULL, NULL, false, NULL, NULL, 102, 'Track1:MediaModifyDate', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'media modify date', 'io_interface');
INSERT INTO meta_key_definitions VALUES (363, NULL, NULL, NULL, false, NULL, NULL, 103, 'Track1:MediaTimeScale', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'media time scale', 'io_interface');
INSERT INTO meta_key_definitions VALUES (365, NULL, NULL, NULL, false, NULL, NULL, 104, 'Track1:SampleSizes', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'sample sizes', 'io_interface');
INSERT INTO meta_key_definitions VALUES (367, NULL, NULL, NULL, false, NULL, NULL, 105, 'Track1:SampleToChunk', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'sample to chunk', 'io_interface');
INSERT INTO meta_key_definitions VALUES (369, NULL, NULL, NULL, false, NULL, NULL, 106, 'Track1:TimeToSampleTable', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'time to sample table', 'io_interface');
INSERT INTO meta_key_definitions VALUES (371, NULL, NULL, NULL, false, NULL, NULL, 107, 'Track1:TrackCreateDate', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'track create date', 'io_interface');
INSERT INTO meta_key_definitions VALUES (373, NULL, NULL, NULL, false, NULL, NULL, 108, 'Track1:TrackDuration', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'track duration', 'io_interface');
INSERT INTO meta_key_definitions VALUES (375, NULL, NULL, NULL, false, NULL, NULL, 109, 'Track1:TrackHeaderVersion', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'track header version', 'io_interface');
INSERT INTO meta_key_definitions VALUES (377, NULL, NULL, NULL, false, NULL, NULL, 110, 'Track1:TrackID', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'track id', 'io_interface');
INSERT INTO meta_key_definitions VALUES (379, NULL, NULL, NULL, false, NULL, NULL, 111, 'Track1:TrackLayer', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'track layer', 'io_interface');
INSERT INTO meta_key_definitions VALUES (381, NULL, NULL, NULL, false, NULL, NULL, 112, 'Track1:TrackModifyDate', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'track modify date', 'io_interface');
INSERT INTO meta_key_definitions VALUES (383, NULL, NULL, NULL, false, NULL, NULL, 113, 'Track1:TrackVolume', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'track volume', 'io_interface');
INSERT INTO meta_key_definitions VALUES (385, NULL, NULL, NULL, false, NULL, NULL, 114, 'Track1:Unknown_alis', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown alis', 'io_interface');
INSERT INTO meta_key_definitions VALUES (387, NULL, NULL, NULL, false, NULL, NULL, 115, 'Track1:Unknown_edts', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown edts', 'io_interface');
INSERT INTO meta_key_definitions VALUES (389, NULL, NULL, NULL, false, NULL, NULL, 116, 'Track2:BitDepth', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'bit depth', 'io_interface');
INSERT INTO meta_key_definitions VALUES (391, NULL, NULL, NULL, false, NULL, NULL, 117, 'Track2:CompressorID', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'compressor id', 'io_interface');
INSERT INTO meta_key_definitions VALUES (393, NULL, NULL, NULL, false, NULL, NULL, 118, 'Track2:CompressorName', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'compressor name', 'io_interface');
INSERT INTO meta_key_definitions VALUES (395, NULL, NULL, NULL, false, NULL, NULL, 119, 'Track2:GraphicsMode', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'graphics mode', 'io_interface');
INSERT INTO meta_key_definitions VALUES (397, NULL, NULL, NULL, false, NULL, NULL, 120, 'Track2:ImageHeight', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'image height', 'io_interface');
INSERT INTO meta_key_definitions VALUES (399, NULL, NULL, NULL, false, NULL, NULL, 121, 'Track2:ImageWidth', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'image width', 'io_interface');
INSERT INTO meta_key_definitions VALUES (401, NULL, NULL, NULL, false, NULL, NULL, 122, 'Track2:OpColor', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'op color', 'io_interface');
INSERT INTO meta_key_definitions VALUES (403, NULL, NULL, NULL, false, NULL, NULL, 123, 'Track2:SourceImageHeight', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'source image height', 'io_interface');
INSERT INTO meta_key_definitions VALUES (405, NULL, NULL, NULL, false, NULL, NULL, 124, 'Track2:SourceImageWidth', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'source image width', 'io_interface');
INSERT INTO meta_key_definitions VALUES (407, NULL, NULL, NULL, false, NULL, NULL, 125, 'Track2:SyncSampleTable', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'sync sample table', 'io_interface');
INSERT INTO meta_key_definitions VALUES (409, NULL, NULL, NULL, false, NULL, NULL, 126, 'Track2:VendorID', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'vendor id', 'io_interface');
INSERT INTO meta_key_definitions VALUES (411, NULL, NULL, NULL, false, NULL, NULL, 127, 'Track2:VideoFrameRate', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'video frame rate', 'io_interface');
INSERT INTO meta_key_definitions VALUES (413, NULL, NULL, NULL, false, NULL, NULL, 128, 'Track2:XResolution', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'x resolution', 'io_interface');
INSERT INTO meta_key_definitions VALUES (415, NULL, NULL, NULL, false, NULL, NULL, 129, 'Track2:YResolution', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'y resolution', 'io_interface');
INSERT INTO meta_key_definitions VALUES (417, NULL, NULL, NULL, false, NULL, NULL, 130, 'Composite:AvgBitrate', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'avg bitrate', 'io_interface');
INSERT INTO meta_key_definitions VALUES (419, NULL, NULL, NULL, false, NULL, NULL, 131, 'Composite:ImageSize', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'image size', 'io_interface');
INSERT INTO meta_key_definitions VALUES (421, NULL, NULL, NULL, false, NULL, NULL, 132, 'Composite:Rotation', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'rotation', 'io_interface');
INSERT INTO meta_key_definitions VALUES (423, NULL, NULL, NULL, false, NULL, NULL, 133, 'QuickTime:TrackNumber', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'track number', 'io_interface');
INSERT INTO meta_key_definitions VALUES (425, NULL, NULL, NULL, false, NULL, NULL, 134, 'Track1:MediaLanguageCode', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'media language code', 'io_interface');
INSERT INTO meta_key_definitions VALUES (427, NULL, NULL, NULL, false, NULL, NULL, 135, 'QuickTime:CompatibleBrands', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'compatible brands', 'io_interface');
INSERT INTO meta_key_definitions VALUES (429, NULL, NULL, NULL, false, NULL, NULL, 136, 'QuickTime:MajorBrand', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'major brand', 'io_interface');
INSERT INTO meta_key_definitions VALUES (431, NULL, NULL, NULL, false, NULL, NULL, 137, 'QuickTime:MinorVersion', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'minor version', 'io_interface');
INSERT INTO meta_key_definitions VALUES (433, NULL, NULL, NULL, false, NULL, NULL, 138, 'QuickTime:InitialObjectDescriptor', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'initial object descriptor', 'io_interface');
INSERT INTO meta_key_definitions VALUES (435, NULL, NULL, NULL, false, NULL, NULL, 139, 'QuickTime:Unknown_gshh', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown gshh', 'io_interface');
INSERT INTO meta_key_definitions VALUES (437, NULL, NULL, NULL, false, NULL, NULL, 140, 'QuickTime:Unknown_gspm', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown gspm', 'io_interface');
INSERT INTO meta_key_definitions VALUES (439, NULL, NULL, NULL, false, NULL, NULL, 141, 'QuickTime:Unknown_gspu', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown gspu', 'io_interface');
INSERT INTO meta_key_definitions VALUES (441, NULL, NULL, NULL, false, NULL, NULL, 142, 'QuickTime:Unknown_gssd', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown gssd', 'io_interface');
INSERT INTO meta_key_definitions VALUES (443, NULL, NULL, NULL, false, NULL, NULL, 143, 'QuickTime:Unknown_gsst', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown gsst', 'io_interface');
INSERT INTO meta_key_definitions VALUES (445, NULL, NULL, NULL, false, NULL, NULL, 144, 'QuickTime:Unknown_gstd', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown gstd', 'io_interface');
INSERT INTO meta_key_definitions VALUES (447, NULL, NULL, NULL, false, NULL, NULL, 145, 'MPEG:AudioBitrate', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'audio bitrate', 'io_interface');
INSERT INTO meta_key_definitions VALUES (449, NULL, NULL, NULL, false, NULL, NULL, 146, 'MPEG:AudioLayer', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'audio layer', 'io_interface');
INSERT INTO meta_key_definitions VALUES (451, NULL, NULL, NULL, false, NULL, NULL, 147, 'MPEG:ChannelMode', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'channel mode', 'io_interface');
INSERT INTO meta_key_definitions VALUES (453, NULL, NULL, NULL, false, NULL, NULL, 148, 'MPEG:CopyrightFlag', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'copyright flag', 'io_interface');
INSERT INTO meta_key_definitions VALUES (455, NULL, NULL, NULL, false, NULL, NULL, 149, 'MPEG:Emphasis', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'emphasis', 'io_interface');
INSERT INTO meta_key_definitions VALUES (457, NULL, NULL, NULL, false, NULL, NULL, 150, 'MPEG:Encoder', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'encoder', 'io_interface');
INSERT INTO meta_key_definitions VALUES (459, NULL, NULL, NULL, false, NULL, NULL, 151, 'MPEG:IntensityStereo', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'intensity stereo', 'io_interface');
INSERT INTO meta_key_definitions VALUES (461, NULL, NULL, NULL, false, NULL, NULL, 152, 'MPEG:LameBitrate', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'lame bitrate', 'io_interface');
INSERT INTO meta_key_definitions VALUES (463, NULL, NULL, NULL, false, NULL, NULL, 153, 'MPEG:LameLowPassFilter', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'lame low pass filter', 'io_interface');
INSERT INTO meta_key_definitions VALUES (465, NULL, NULL, NULL, false, NULL, NULL, 154, 'MPEG:LameMethod', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'lame method', 'io_interface');
INSERT INTO meta_key_definitions VALUES (467, NULL, NULL, NULL, false, NULL, NULL, 155, 'MPEG:LameQuality', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'lame quality', 'io_interface');
INSERT INTO meta_key_definitions VALUES (469, NULL, NULL, NULL, false, NULL, NULL, 156, 'MPEG:LameStereoMode', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'lame stereo mode', 'io_interface');
INSERT INTO meta_key_definitions VALUES (471, NULL, NULL, NULL, false, NULL, NULL, 157, 'MPEG:LameVBRQuality', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'lame vbr quality', 'io_interface');
INSERT INTO meta_key_definitions VALUES (473, NULL, NULL, NULL, false, NULL, NULL, 158, 'MPEG:MPEGAudioVersion', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'mpeg audio version', 'io_interface');
INSERT INTO meta_key_definitions VALUES (475, NULL, NULL, NULL, false, NULL, NULL, 159, 'MPEG:MSStereo', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'ms stereo', 'io_interface');
INSERT INTO meta_key_definitions VALUES (477, NULL, NULL, NULL, false, NULL, NULL, 160, 'MPEG:OriginalMedia', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'original media', 'io_interface');
INSERT INTO meta_key_definitions VALUES (479, NULL, NULL, NULL, false, NULL, NULL, 161, 'MPEG:SampleRate', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'sample rate', 'io_interface');
INSERT INTO meta_key_definitions VALUES (481, NULL, NULL, NULL, false, NULL, NULL, 162, 'File:ID3Size', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'id3 size', 'io_interface');
INSERT INTO meta_key_definitions VALUES (483, NULL, NULL, NULL, false, NULL, NULL, 163, 'ID3v1:Album', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'album', 'io_interface');
INSERT INTO meta_key_definitions VALUES (485, NULL, NULL, NULL, false, NULL, NULL, 164, 'ID3v1:Artist', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'artist', 'io_interface');
INSERT INTO meta_key_definitions VALUES (487, NULL, NULL, NULL, false, NULL, NULL, 165, 'ID3v1:Comment', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'comment', 'io_interface');
INSERT INTO meta_key_definitions VALUES (489, NULL, NULL, NULL, false, NULL, NULL, 166, 'ID3v1:Genre', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'genre', 'io_interface');
INSERT INTO meta_key_definitions VALUES (491, NULL, NULL, NULL, false, NULL, NULL, 167, 'ID3v1:Track', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'track', 'io_interface');
INSERT INTO meta_key_definitions VALUES (493, NULL, NULL, NULL, false, NULL, NULL, 168, 'ID3v1:Year', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'year', 'io_interface');
INSERT INTO meta_key_definitions VALUES (495, NULL, NULL, NULL, false, NULL, NULL, 169, 'Composite:DateTimeOriginal', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'date time original', 'io_interface');
INSERT INTO meta_key_definitions VALUES (497, NULL, NULL, 1981, false, NULL, NULL, 5, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'epoch', 'VFO');
INSERT INTO meta_key_definitions VALUES (499, NULL, NULL, 1981, false, NULL, NULL, 13, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'epoch', 'Landschaftsvisualisierung');
INSERT INTO meta_key_definitions VALUES (501, NULL, NULL, 1993, false, NULL, NULL, 4, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'style', 'VFO');
INSERT INTO meta_key_definitions VALUES (505, NULL, NULL, 1811, false, NULL, NULL, 3, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'genre', 'VFO');
INSERT INTO meta_key_definitions VALUES (507, NULL, 2035, 2157, false, NULL, NULL, 7, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'Zett_Ansprechsperson', 'Zett');
INSERT INTO meta_key_definitions VALUES (509, NULL, 2033, 2031, false, NULL, NULL, 5, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'Zett_Artikel', 'Zett');
INSERT INTO meta_key_definitions VALUES (511, NULL, NULL, 2037, false, NULL, NULL, 1, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'Zett_Ausgabe', 'Zett');
INSERT INTO meta_key_definitions VALUES (513, NULL, 2041, 2039, false, NULL, NULL, 6, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'Zett_Autorinnen', 'Zett');
INSERT INTO meta_key_definitions VALUES (515, NULL, 2045, 2043, false, NULL, NULL, 11, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'Zett_Kommentar', 'Zett');
INSERT INTO meta_key_definitions VALUES (517, NULL, 2049, 2047, false, NULL, NULL, 9, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'Zett_Produktion', 'Zett');
INSERT INTO meta_key_definitions VALUES (519, NULL, 2159, 2051, false, NULL, NULL, 8, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'Zett_Redaktion', 'Zett');
INSERT INTO meta_key_definitions VALUES (521, NULL, 2057, 2055, false, NULL, NULL, 2, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'Zett_Sparte', 'Zett');
INSERT INTO meta_key_definitions VALUES (523, NULL, NULL, 2059, false, NULL, NULL, 10, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'Zett_Status', 'Zett');
INSERT INTO meta_key_definitions VALUES (525, NULL, NULL, NULL, false, NULL, NULL, 170, 'Track2:CompositionTimeToSample', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'composition time to sample', 'io_interface');
INSERT INTO meta_key_definitions VALUES (527, NULL, NULL, NULL, false, NULL, NULL, 171, 'Track2:CompositionToDecodeTimelineMapping', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'composition to decode timeline mapping', 'io_interface');
INSERT INTO meta_key_definitions VALUES (529, NULL, NULL, NULL, false, NULL, NULL, 172, 'Track2:IdependentAndDisposableSamples', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'idependent and disposable samples', 'io_interface');
INSERT INTO meta_key_definitions VALUES (531, NULL, NULL, NULL, false, NULL, NULL, 173, 'Track2:Unknown_tapt', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown tapt', 'io_interface');
INSERT INTO meta_key_definitions VALUES (533, NULL, NULL, NULL, false, NULL, NULL, 174, 'QuickTime:ComAppleFinalcutstudioMediaUuid', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'com apple finalcutstudio media uuid', 'io_interface');
INSERT INTO meta_key_definitions VALUES (535, NULL, NULL, NULL, false, NULL, NULL, 175, 'Track1:Unknown_stps', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown stps', 'io_interface');
INSERT INTO meta_key_definitions VALUES (537, NULL, NULL, NULL, false, NULL, NULL, 176, 'Track1:Unknown_tmcd', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown tmcd', 'io_interface');
INSERT INTO meta_key_definitions VALUES (539, NULL, NULL, NULL, false, NULL, NULL, 177, 'Track3:GenBalance', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'gen balance', 'io_interface');
INSERT INTO meta_key_definitions VALUES (541, NULL, NULL, NULL, false, NULL, NULL, 178, 'Track3:GenFlags', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'gen flags', 'io_interface');
INSERT INTO meta_key_definitions VALUES (543, NULL, NULL, NULL, false, NULL, NULL, 179, 'Track3:GenGraphicsMode', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'gen graphics mode', 'io_interface');
INSERT INTO meta_key_definitions VALUES (545, NULL, NULL, NULL, false, NULL, NULL, 180, 'Track3:GenMediaVersion', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'gen media version', 'io_interface');
INSERT INTO meta_key_definitions VALUES (547, NULL, NULL, NULL, false, NULL, NULL, 181, 'Track3:GenOpColor', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'gen op color', 'io_interface');
INSERT INTO meta_key_definitions VALUES (549, NULL, NULL, NULL, false, NULL, NULL, 182, 'Track3:OtherFormat', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'other format', 'io_interface');
INSERT INTO meta_key_definitions VALUES (551, NULL, NULL, NULL, false, NULL, NULL, 183, 'Track3:Unknown_kgtt', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown kgtt', 'io_interface');
INSERT INTO meta_key_definitions VALUES (553, NULL, NULL, NULL, false, NULL, NULL, 184, 'XMP-photoshop:SupplementalCategories', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'supplemental categories', 'io_interface');
INSERT INTO meta_key_definitions VALUES (555, NULL, NULL, NULL, false, NULL, NULL, 185, 'XMP-photoshop:Urgency', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'urgency', 'io_interface');
INSERT INTO meta_key_definitions VALUES (557, NULL, NULL, 1811, false, NULL, NULL, 11, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'genre', 'Landschaftsvisualisierung');
INSERT INTO meta_key_definitions VALUES (559, NULL, NULL, 2235, false, NULL, NULL, 0, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'Toni_Blickrichtung', 'Toni');
INSERT INTO meta_key_definitions VALUES (561, NULL, NULL, 2237, false, NULL, NULL, 1, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'Toni_Objekt', 'Toni');
INSERT INTO meta_key_definitions VALUES (563, NULL, NULL, 2239, false, NULL, NULL, 2, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'Toni_Prozess', 'Toni');
INSERT INTO meta_key_definitions VALUES (565, NULL, NULL, 1993, false, NULL, NULL, 6, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'style', 'Columns');
INSERT INTO meta_key_definitions VALUES (567, NULL, NULL, 1811, false, NULL, NULL, 5, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'genre', 'Columns');
INSERT INTO meta_key_definitions VALUES (569, NULL, 2335, 2331, false, NULL, NULL, 3, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'Zett_Artikelbildnr', 'Zett');
INSERT INTO meta_key_definitions VALUES (571, NULL, 2407, 2405, false, NULL, NULL, 4, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'Zett_Artikel_Arbeitstitel', 'Zett');
INSERT INTO meta_key_definitions VALUES (573, NULL, NULL, NULL, false, NULL, NULL, 186, 'QuickTime:AudioGain', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'audio gain', 'io_interface');
INSERT INTO meta_key_definitions VALUES (575, NULL, NULL, NULL, false, NULL, NULL, 187, 'QuickTime:Bass', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'bass', 'io_interface');
INSERT INTO meta_key_definitions VALUES (577, NULL, NULL, NULL, false, NULL, NULL, 188, 'QuickTime:Brightness', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'brightness', 'io_interface');
INSERT INTO meta_key_definitions VALUES (579, NULL, NULL, NULL, false, NULL, NULL, 189, 'QuickTime:Color', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'color', 'io_interface');
INSERT INTO meta_key_definitions VALUES (581, NULL, NULL, NULL, false, NULL, NULL, 190, 'QuickTime:Contrast', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'contrast', 'io_interface');
INSERT INTO meta_key_definitions VALUES (583, NULL, NULL, NULL, false, NULL, NULL, 191, 'QuickTime:Mute', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'mute', 'io_interface');
INSERT INTO meta_key_definitions VALUES (585, NULL, NULL, NULL, false, NULL, NULL, 192, 'QuickTime:PitchShift', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'pitch shift', 'io_interface');
INSERT INTO meta_key_definitions VALUES (587, NULL, NULL, NULL, false, NULL, NULL, 193, 'QuickTime:PlayAllFrames', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'play all frames', 'io_interface');
INSERT INTO meta_key_definitions VALUES (589, NULL, NULL, NULL, false, NULL, NULL, 194, 'QuickTime:PlaySelection', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'play selection', 'io_interface');
INSERT INTO meta_key_definitions VALUES (591, NULL, NULL, NULL, false, NULL, NULL, 195, 'QuickTime:PlayerVersion', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'player version', 'io_interface');
INSERT INTO meta_key_definitions VALUES (593, NULL, NULL, NULL, false, NULL, NULL, 196, 'QuickTime:Tint', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'tint', 'io_interface');
INSERT INTO meta_key_definitions VALUES (595, NULL, NULL, NULL, false, NULL, NULL, 197, 'QuickTime:Trebel', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'trebel', 'io_interface');
INSERT INTO meta_key_definitions VALUES (597, NULL, NULL, NULL, false, NULL, NULL, 198, 'QuickTime:Version', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'version', 'io_interface');
INSERT INTO meta_key_definitions VALUES (599, NULL, NULL, NULL, false, NULL, NULL, 199, 'QuickTime:WindowLocation', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'window location', 'io_interface');
INSERT INTO meta_key_definitions VALUES (601, NULL, NULL, NULL, false, NULL, NULL, 200, 'Track2:Unknown_load', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown load', 'io_interface');
INSERT INTO meta_key_definitions VALUES (603, NULL, NULL, NULL, false, NULL, NULL, 201, 'XMP-photoshop:Instructions', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'instructions', 'io_interface');
INSERT INTO meta_key_definitions VALUES (605, NULL, NULL, NULL, false, NULL, NULL, 202, 'QuickTime:Unknown_0x009b', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown 0x009b', 'io_interface');
INSERT INTO meta_key_definitions VALUES (607, NULL, NULL, NULL, false, NULL, NULL, 203, 'QuickTime:Unknown_apmd', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown apmd', 'io_interface');
INSERT INTO meta_key_definitions VALUES (609, NULL, NULL, NULL, false, NULL, NULL, 204, 'QuickTime:UserData_TSC', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'user data tsc', 'io_interface');
INSERT INTO meta_key_definitions VALUES (611, NULL, NULL, NULL, false, NULL, NULL, 205, 'QuickTime:UserData_TSZ', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'user data tsz', 'io_interface');
INSERT INTO meta_key_definitions VALUES (613, NULL, NULL, NULL, false, NULL, NULL, 206, 'Track1:Unknown_cios', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown cios', 'io_interface');
INSERT INTO meta_key_definitions VALUES (615, NULL, NULL, NULL, false, NULL, NULL, 207, 'ID3v2_2:EncodedBy', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'encoded by', 'io_interface');
INSERT INTO meta_key_definitions VALUES (617, NULL, NULL, NULL, false, NULL, NULL, 208, 'XMP-photoshop:DocumentAncestors', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'document ancestors', 'io_interface');
INSERT INTO meta_key_definitions VALUES (619, NULL, NULL, NULL, false, NULL, NULL, 209, 'XMP-photoshop:TextLayerName', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'text layer name', 'io_interface');
INSERT INTO meta_key_definitions VALUES (621, NULL, NULL, NULL, false, NULL, NULL, 210, 'XMP-photoshop:TextLayerText', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'text layer text', 'io_interface');
INSERT INTO meta_key_definitions VALUES (623, NULL, NULL, NULL, false, NULL, NULL, 211, 'QuickTime:UserData_enc', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'user data enc', 'io_interface');
INSERT INTO meta_key_definitions VALUES (625, NULL, 235, 237, false, NULL, NULL, 26, 'ObjRights.copyright', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'copyright status', 'tms');
INSERT INTO meta_key_definitions VALUES (627, NULL, NULL, NULL, false, NULL, NULL, 212, 'QuickTime:SourceCredits', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'source credits', 'io_interface');
INSERT INTO meta_key_definitions VALUES (629, NULL, NULL, NULL, false, NULL, NULL, 213, 'QuickTime:UserData_PRD', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'user data prd', 'io_interface');
INSERT INTO meta_key_definitions VALUES (631, NULL, NULL, NULL, false, NULL, NULL, 214, 'QuickTime:UserData_key', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'user data key', 'io_interface');
INSERT INTO meta_key_definitions VALUES (633, NULL, NULL, NULL, false, NULL, NULL, 215, 'QuickTime:CompressorVersion', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'compressor version', 'io_interface');
INSERT INTO meta_key_definitions VALUES (635, NULL, NULL, NULL, false, NULL, NULL, 216, 'QuickTime:Unknown_CNDM', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown cndm', 'io_interface');
INSERT INTO meta_key_definitions VALUES (637, NULL, NULL, NULL, false, NULL, NULL, 217, 'QuickTime:Unknown_free', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown free', 'io_interface');
INSERT INTO meta_key_definitions VALUES (639, NULL, NULL, NULL, false, NULL, NULL, 218, 'Composite:Aperture', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'aperture', 'io_interface');
INSERT INTO meta_key_definitions VALUES (641, NULL, NULL, NULL, false, NULL, NULL, 219, 'Composite:DriveMode', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'drive mode', 'io_interface');
INSERT INTO meta_key_definitions VALUES (643, NULL, NULL, NULL, false, NULL, NULL, 220, 'Composite:FocalLength35efl', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'focal length35efl', 'io_interface');
INSERT INTO meta_key_definitions VALUES (645, NULL, NULL, NULL, false, NULL, NULL, 221, 'Composite:Lens', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'lens', 'io_interface');
INSERT INTO meta_key_definitions VALUES (647, NULL, NULL, NULL, false, NULL, NULL, 222, 'Composite:Lens35efl', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'lens35efl', 'io_interface');
INSERT INTO meta_key_definitions VALUES (649, NULL, NULL, NULL, false, NULL, NULL, 223, 'Composite:LensID', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'lens id', 'io_interface');
INSERT INTO meta_key_definitions VALUES (651, NULL, NULL, NULL, false, NULL, NULL, 224, 'Composite:ShootingMode', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'shooting mode', 'io_interface');
INSERT INTO meta_key_definitions VALUES (653, NULL, NULL, NULL, false, NULL, NULL, 225, 'Composite:ShutterSpeed', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'shutter speed', 'io_interface');
INSERT INTO meta_key_definitions VALUES (655, NULL, NULL, NULL, false, NULL, NULL, 226, 'Canon:CanonFlashInfo', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'canon flash info', 'io_interface');
INSERT INTO meta_key_definitions VALUES (657, NULL, NULL, NULL, false, NULL, NULL, 227, 'Canon:CanonFlashMode', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'canon flash mode', 'io_interface');
INSERT INTO meta_key_definitions VALUES (659, NULL, NULL, NULL, false, NULL, NULL, 228, 'Canon:FlashActivity', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'flash activity', 'io_interface');
INSERT INTO meta_key_definitions VALUES (661, NULL, NULL, NULL, false, NULL, NULL, 229, 'Canon:FlashBits', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'flash bits', 'io_interface');
INSERT INTO meta_key_definitions VALUES (663, NULL, NULL, NULL, false, NULL, NULL, 230, 'Canon:FlashExposureComp', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'flash exposure comp', 'io_interface');
INSERT INTO meta_key_definitions VALUES (665, NULL, NULL, NULL, false, NULL, NULL, 231, 'Canon:FlashGuideNumber', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'flash guide number', 'io_interface');
INSERT INTO meta_key_definitions VALUES (667, NULL, NULL, NULL, false, NULL, NULL, 232, 'Canon:FlashOutput', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'flash output', 'io_interface');
INSERT INTO meta_key_definitions VALUES (669, NULL, NULL, NULL, false, NULL, NULL, 233, 'Canon:ManualFlashOutput', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'manual flash output', 'io_interface');
INSERT INTO meta_key_definitions VALUES (671, NULL, NULL, NULL, false, NULL, NULL, 234, 'ExifIFD:Flash', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'flash', 'io_interface');
INSERT INTO meta_key_definitions VALUES (673, NULL, NULL, NULL, false, NULL, NULL, 235, 'ExifIFD:FlashpixVersion', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'flashpix version', 'io_interface');
INSERT INTO meta_key_definitions VALUES (675, NULL, NULL, NULL, false, NULL, NULL, 236, 'RIFF:FrameCount', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'frame count', 'io_interface');
INSERT INTO meta_key_definitions VALUES (677, NULL, NULL, NULL, false, NULL, NULL, 237, 'RIFF:FrameRate', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'frame rate', 'io_interface');
INSERT INTO meta_key_definitions VALUES (679, NULL, NULL, NULL, false, NULL, NULL, 238, 'RIFF:MaxDataRate', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'max data rate', 'io_interface');
INSERT INTO meta_key_definitions VALUES (681, NULL, NULL, NULL, false, NULL, NULL, 239, 'RIFF:Quality', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'quality', 'io_interface');
INSERT INTO meta_key_definitions VALUES (683, NULL, NULL, NULL, false, NULL, NULL, 240, 'RIFF:SampleSize', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'sample size', 'io_interface');
INSERT INTO meta_key_definitions VALUES (685, NULL, NULL, NULL, false, NULL, NULL, 241, 'RIFF:Software', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'software', 'io_interface');
INSERT INTO meta_key_definitions VALUES (687, NULL, NULL, NULL, false, NULL, NULL, 242, 'RIFF:StreamCount', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'stream count', 'io_interface');
INSERT INTO meta_key_definitions VALUES (689, NULL, NULL, NULL, false, NULL, NULL, 243, 'RIFF:StreamType', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'stream type', 'io_interface');
INSERT INTO meta_key_definitions VALUES (691, NULL, NULL, NULL, false, NULL, NULL, 244, 'RIFF:VideoCodec', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'video codec', 'io_interface');
INSERT INTO meta_key_definitions VALUES (693, NULL, NULL, NULL, false, NULL, NULL, 245, 'RIFF:VideoFrameCount', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'video frame count', 'io_interface');
INSERT INTO meta_key_definitions VALUES (694, NULL, NULL, NULL, false, NULL, NULL, 246, 'MPEG:VBRBytes', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'vbr bytes', 'io_interface');
INSERT INTO meta_key_definitions VALUES (696, NULL, NULL, NULL, false, NULL, NULL, 247, 'MPEG:VBRFrames', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'vbr frames', 'io_interface');
INSERT INTO meta_key_definitions VALUES (698, NULL, NULL, NULL, false, NULL, NULL, 248, 'ID3v2_4:EncoderSettings', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'encoder settings', 'io_interface');
INSERT INTO meta_key_definitions VALUES (700, NULL, NULL, NULL, false, NULL, NULL, 249, 'ID3v2_4:EncodingTime', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'encoding time', 'io_interface');
INSERT INTO meta_key_definitions VALUES (702, NULL, NULL, NULL, false, NULL, NULL, 250, 'ID3v2_4:ReleaseTime', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'release time', 'io_interface');
INSERT INTO meta_key_definitions VALUES (704, NULL, NULL, NULL, false, NULL, NULL, 251, 'ID3v2_4:UserDefinedText', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'user defined text', 'io_interface');
INSERT INTO meta_key_definitions VALUES (709, NULL, NULL, 3269, false, NULL, NULL, 9, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'FI_Drittmittel', 'Forschung ZHdK');
INSERT INTO meta_key_definitions VALUES (711, NULL, 3273, 3271, false, NULL, NULL, 3, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'FI_Fachveranstaltungen', 'Forschung ZHdK');
INSERT INTO meta_key_definitions VALUES (713, NULL, 3277, 3275, false, NULL, NULL, 6, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'FI_Transfer', 'Forschung ZHdK');
INSERT INTO meta_key_definitions VALUES (715, NULL, 3281, 3279, false, NULL, NULL, 5, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'FI_Verbreitung', 'Forschung ZHdK');
INSERT INTO meta_key_definitions VALUES (717, NULL, NULL, 3283, false, NULL, NULL, 7, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'FI_Vernetzung', 'Forschung ZHdK');
INSERT INTO meta_key_definitions VALUES (719, NULL, NULL, 3285, false, NULL, NULL, 1, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'FI_Veröffentlichungen', 'Forschung ZHdK');
INSERT INTO meta_key_definitions VALUES (721, NULL, 3369, 3287, false, NULL, NULL, 8, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'FI_Wissenschaftsbetrieb', 'Forschung ZHdK');
INSERT INTO meta_key_definitions VALUES (723, NULL, NULL, 3373, false, NULL, NULL, 4, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'FI_Fachveranstaltungen_Text', 'Forschung ZHdK');
INSERT INTO meta_key_definitions VALUES (725, NULL, NULL, 3375, false, NULL, NULL, 2, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'FI_Veröffentlichungen_Text', 'Forschung ZHdK');
INSERT INTO meta_key_definitions VALUES (727, NULL, NULL, NULL, false, NULL, NULL, 252, 'QuickTime:Unknown_Cr8r', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown cr8r', 'io_interface');
INSERT INTO meta_key_definitions VALUES (729, NULL, NULL, NULL, false, NULL, NULL, 253, 'QuickTime:Unknown_FIEL', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown fiel', 'io_interface');
INSERT INTO meta_key_definitions VALUES (731, NULL, NULL, NULL, false, NULL, NULL, 254, 'QuickTime:Unknown_FXTC', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown fxtc', 'io_interface');
INSERT INTO meta_key_definitions VALUES (733, NULL, NULL, NULL, false, NULL, NULL, 255, 'QuickTime:Unknown_aeLK', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown ae lk', 'io_interface');
INSERT INTO meta_key_definitions VALUES (735, NULL, NULL, NULL, false, NULL, NULL, 256, 'RIFF:TextJunk', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'text junk', 'io_interface');
INSERT INTO meta_key_definitions VALUES (737, NULL, NULL, NULL, false, NULL, NULL, 257, 'RIFF:TotalFrameCount', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'total frame count', 'io_interface');
INSERT INTO meta_key_definitions VALUES (739, NULL, NULL, NULL, false, NULL, NULL, 258, 'QuickTime:Requirements', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'requirements', 'io_interface');
INSERT INTO meta_key_definitions VALUES (741, NULL, NULL, NULL, false, NULL, NULL, 259, 'QuickTime:CreationDate-deu', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'creation date deu', 'io_interface');
INSERT INTO meta_key_definitions VALUES (743, NULL, NULL, NULL, false, NULL, NULL, 260, 'QuickTime:Make-deu', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'make deu', 'io_interface');
INSERT INTO meta_key_definitions VALUES (745, NULL, NULL, NULL, false, NULL, NULL, 261, 'QuickTime:Model-deu', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'model deu', 'io_interface');
INSERT INTO meta_key_definitions VALUES (747, NULL, NULL, NULL, false, NULL, NULL, 262, 'QuickTime:Software-deu', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'software deu', 'io_interface');
INSERT INTO meta_key_definitions VALUES (749, NULL, NULL, NULL, false, NULL, NULL, 263, 'RIFF:AudioCodec', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'audio codec', 'io_interface');
INSERT INTO meta_key_definitions VALUES (751, NULL, NULL, NULL, false, NULL, NULL, 264, 'RIFF:AudioSampleCount', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'audio sample count', 'io_interface');
INSERT INTO meta_key_definitions VALUES (753, NULL, NULL, NULL, false, NULL, NULL, 265, 'RIFF:AvgBytesPerSec', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'avg bytes per sec', 'io_interface');
INSERT INTO meta_key_definitions VALUES (755, NULL, NULL, NULL, false, NULL, NULL, 266, 'RIFF:BitsPerSample', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'bits per sample', 'io_interface');
INSERT INTO meta_key_definitions VALUES (757, NULL, NULL, NULL, false, NULL, NULL, 267, 'RIFF:Encoding', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'encoding', 'io_interface');
INSERT INTO meta_key_definitions VALUES (759, NULL, NULL, NULL, false, NULL, NULL, 268, 'RIFF:NumChannels', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'num channels', 'io_interface');
INSERT INTO meta_key_definitions VALUES (761, NULL, NULL, 3839, false, NULL, NULL, 0, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'PA_Artefakttyp', 'Performance-Artefakte');
INSERT INTO meta_key_definitions VALUES (763, NULL, NULL, 3841, false, NULL, NULL, 1, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'PA_ArtefakttypDifferenzierung', 'Performance-Artefakte');
INSERT INTO meta_key_definitions VALUES (765, NULL, NULL, 3843, false, NULL, NULL, 2, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'PA_Überlieferungsleistung', 'Performance-Artefakte');
INSERT INTO meta_key_definitions VALUES (767, NULL, NULL, 3851, false, NULL, NULL, 3, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'PA_Vermittlungspotential', 'Performance-Artefakte');
INSERT INTO meta_key_definitions VALUES (769, NULL, NULL, 3849, false, NULL, NULL, 4, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'PA_KommentarArtefakte', 'Performance-Artefakte');
INSERT INTO meta_key_definitions VALUES (771, NULL, NULL, NULL, false, NULL, NULL, 269, 'QuickTime:UserData_TIM', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'user data tim', 'io_interface');
INSERT INTO meta_key_definitions VALUES (773, NULL, NULL, NULL, false, NULL, NULL, 270, 'Track1:ChunkOffset64', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'chunk offset64', 'io_interface');
INSERT INTO meta_key_definitions VALUES (775, NULL, NULL, NULL, false, NULL, NULL, 271, 'Track2:NullMediaHeader', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'null media header', 'io_interface');
INSERT INTO meta_key_definitions VALUES (777, NULL, NULL, NULL, false, NULL, NULL, 272, 'XMP-xmpMM:PantryFlashFired', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'pantry flash fired', 'io_interface');
INSERT INTO meta_key_definitions VALUES (779, NULL, NULL, NULL, false, NULL, NULL, 273, 'XMP-xmpMM:PantryFlashFunction', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'pantry flash function', 'io_interface');
INSERT INTO meta_key_definitions VALUES (781, NULL, NULL, NULL, false, NULL, NULL, 274, 'XMP-xmpMM:PantryFlashMode', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'pantry flash mode', 'io_interface');
INSERT INTO meta_key_definitions VALUES (783, NULL, NULL, NULL, false, NULL, NULL, 275, 'XMP-xmpMM:PantryFlashRedEyeMode', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'pantry flash red eye mode', 'io_interface');
INSERT INTO meta_key_definitions VALUES (785, NULL, NULL, NULL, false, NULL, NULL, 276, 'XMP-xmpMM:PantryFlashReturn', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'pantry flash return', 'io_interface');
INSERT INTO meta_key_definitions VALUES (787, NULL, NULL, NULL, false, NULL, NULL, 277, 'QuickTime:ComAppleFinalcutstudioMediaHistoryUuid', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'com apple finalcutstudio media history uuid', 'io_interface');
INSERT INTO meta_key_definitions VALUES (789, NULL, NULL, NULL, false, NULL, NULL, 278, 'QuickTime:Unknown_0x010a', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown 0x010a', 'io_interface');
INSERT INTO meta_key_definitions VALUES (791, NULL, NULL, NULL, false, NULL, NULL, 279, 'Track1:ChapterList', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'chapter list', 'io_interface');
INSERT INTO meta_key_definitions VALUES (793, NULL, NULL, NULL, false, NULL, NULL, 280, 'Track4:Text', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'text', 'io_interface');
INSERT INTO meta_key_definitions VALUES (795, NULL, NULL, NULL, false, NULL, NULL, 281, 'Track4:Unknown_kgit', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown kgit', 'io_interface');
INSERT INTO meta_key_definitions VALUES (797, NULL, NULL, 4365, false, NULL, NULL, 6, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'owner', 'core');
INSERT INTO meta_key_definitions VALUES (799, NULL, NULL, 4355, false, NULL, NULL, 5, NULL, NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'owner', 'media_set');
INSERT INTO meta_key_definitions VALUES (801, NULL, NULL, NULL, false, NULL, NULL, 282, 'QuickTime:ComAppleProappsClipID', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'com apple proapps clip id', 'io_interface');
INSERT INTO meta_key_definitions VALUES (803, NULL, NULL, NULL, false, NULL, NULL, 283, 'QuickTime:ComAppleProappsIsGood', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'com apple proapps is good', 'io_interface');
INSERT INTO meta_key_definitions VALUES (805, NULL, NULL, NULL, false, NULL, NULL, 284, 'QuickTime:ComAppleProappsOriginalFormat', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'com apple proapps original format', 'io_interface');
INSERT INTO meta_key_definitions VALUES (807, NULL, NULL, NULL, false, NULL, NULL, 285, 'QuickTime:ComAppleProappsReel', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'com apple proapps reel', 'io_interface');
INSERT INTO meta_key_definitions VALUES (809, NULL, NULL, NULL, false, NULL, NULL, 286, 'QuickTime:ComSonyBprlMxfUmid', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'com sony bprl mxf umid', 'io_interface');
INSERT INTO meta_key_definitions VALUES (811, NULL, NULL, NULL, false, NULL, NULL, 287, 'QuickTime:ComSonyBprlXdcamradplugVersion', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'com sony bprl xdcamradplug version', 'io_interface');
INSERT INTO meta_key_definitions VALUES (813, NULL, NULL, NULL, false, NULL, NULL, 288, 'QuickTime:ComSonyProfessionaldiscNonrealtimemetaLastupdate', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'com sony professionaldisc nonrealtimemeta lastupdate', 'io_interface');
INSERT INTO meta_key_definitions VALUES (815, NULL, NULL, NULL, false, NULL, NULL, 289, 'QuickTime:OrgSmpteMxfPackageMaterialPackageid', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'org smpte mxf package material packageid', 'io_interface');
INSERT INTO meta_key_definitions VALUES (817, NULL, NULL, NULL, false, NULL, NULL, 290, 'QuickTime:Unknown_kgcg', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown kgcg', 'io_interface');
INSERT INTO meta_key_definitions VALUES (819, NULL, NULL, NULL, false, NULL, NULL, 291, 'QuickTime:Unknown_kgsi', NULL, '2012-04-20 12:01:53', '2012-04-20 12:01:53', 'unknown kgsi', 'io_interface');
INSERT INTO meta_key_definitions VALUES (821, NULL, NULL, 4561, false, NULL, NULL, 0, NULL, NULL, '2012-06-12 13:00:04', '2012-06-12 13:00:04', 'owner', 'Nutzung');
INSERT INTO meta_key_definitions VALUES (823, NULL, NULL, 4563, false, NULL, NULL, 1, NULL, NULL, '2012-06-12 13:00:22', '2012-06-12 13:00:22', 'edited by', 'Nutzung');
INSERT INTO meta_key_definitions VALUES (825, NULL, NULL, 347, false, NULL, NULL, 2, NULL, NULL, '2012-06-12 13:03:46', '2012-06-12 13:03:46', 'uploaded at', 'Nutzung');
INSERT INTO meta_key_definitions VALUES (827, NULL, NULL, 4565, false, NULL, NULL, 3, NULL, NULL, '2012-06-12 13:05:00', '2012-06-12 13:05:00', 'modify date', 'Nutzung');
INSERT INTO meta_key_definitions VALUES (829, NULL, NULL, 206, false, NULL, NULL, 0, NULL, NULL, '2012-06-12 13:15:25', '2012-06-12 13:15:25', 'type', 'Institution');
INSERT INTO meta_key_definitions VALUES (831, NULL, NULL, 200, false, NULL, NULL, 1, NULL, NULL, '2012-06-12 13:15:49', '2012-06-12 13:15:49', 'institutional affiliation', 'Institution');
INSERT INTO meta_key_definitions VALUES (833, NULL, NULL, 189, false, NULL, NULL, 2, NULL, NULL, '2012-06-12 13:16:10', '2012-06-12 13:16:10', 'project type', 'Institution');
INSERT INTO meta_key_definitions VALUES (835, NULL, NULL, 4569, false, NULL, NULL, 4, NULL, NULL, '2012-06-12 13:42:53', '2012-06-12 13:42:53', 'parent media_resources', 'Nutzung');
INSERT INTO meta_key_definitions VALUES (837, NULL, NULL, 4571, false, NULL, NULL, 5, NULL, NULL, '2012-06-12 13:43:18', '2012-06-12 13:43:18', 'child media_resources', 'Nutzung');


--
-- Data for Name: meta_keys; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO meta_keys VALUES (NULL, 'identifier', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'urn', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'title', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'subtitle', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'author', 'MetaDatumPeople');
INSERT INTO meta_keys VALUES (NULL, 'additional authors', 'MetaDatumPeople');
INSERT INTO meta_keys VALUES (NULL, 'institutional affiliation', 'MetaDatumDepartments');
INSERT INTO meta_keys VALUES (NULL, 'portrayed object dates', 'MetaDatumDate');
INSERT INTO meta_keys VALUES (NULL, 'keywords', 'MetaDatumKeywords');
INSERT INTO meta_keys VALUES (NULL, 'classification', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'portrayed object location', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'portrayed object city', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'portrayed object state', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'portrayed object country', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'portrayed object country code', 'MetaDatumCountry');
INSERT INTO meta_keys VALUES (NULL, 'portrayed person', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'portrayed institution', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'other creative participants', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'participating institution', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'patron', 'MetaDatumString');
INSERT INTO meta_keys VALUES (false, 'academic year', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (NULL, 'project leader', 'MetaDatumString');
INSERT INTO meta_keys VALUES (false, 'project type', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (NULL, 'description', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'short description', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'public caption', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'remark', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'hyperlinks', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'tags', 'MetaDatumString');
INSERT INTO meta_keys VALUES (false, 'type', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (NULL, 'scene', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'subject code', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'coverage', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'language', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'relation', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'creator', 'MetaDatumPeople');
INSERT INTO meta_keys VALUES (NULL, 'creator address', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'creator city', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'creator state', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'creator postal code', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'creator country', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'creator work telephone', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'creator work email', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'creator work url', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'creator position', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'source', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'source side', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'source image', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'source plate', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'source isbn', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'copyright notice', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'copyright status', 'MetaDatumCopyright');
INSERT INTO meta_keys VALUES (NULL, 'copyright usage', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'copyright url', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'provider', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'portrayed object dimensions', 'MetaDatumString');
INSERT INTO meta_keys VALUES (true, 'portrayed object materials', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (NULL, 'rating', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'uploaded by', 'MetaDatumUsers');
INSERT INTO meta_keys VALUES (NULL, 'uploaded at', 'MetaDatumDate');
INSERT INTO meta_keys VALUES (NULL, 'description author', 'MetaDatumPeople');
INSERT INTO meta_keys VALUES (NULL, 'publisher', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'format', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'date created', 'MetaDatumDate');
INSERT INTO meta_keys VALUES (NULL, 'transmission reference', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'objectnumber', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'objectname', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'color mode', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'history', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'intellectual genre', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'creator contact info', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'project title', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'public access', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'edited by', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'media type', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'description author before import', 'MetaDatumPeople');
INSERT INTO meta_keys VALUES (NULL, 'sidecar for extension', 'MetaDatumString');
INSERT INTO meta_keys VALUES (true, 'LV_Landschaftstyp', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (true, 'LV_Verwendungszweck', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (true, 'LV_Bildwirkung', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (false, 'LV_Bildzeit', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (true, 'LV_Farbe', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (true, 'LV_Landschaftselemente', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (true, 'LV_Wetter/Klima', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (false, 'LV_Horizontlinie', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (false, 'LV_Ra?umliche Wahrnehmung', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (false, 'LV_Abstraktionsgrad', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (NULL, 'category', 'MetaDatumString');
INSERT INTO meta_keys VALUES (true, 'SL_Resourcen', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (true, 'SO_Ordnungen', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (true, 'CA_Konzept', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (true, 'CA_Informationstechnologie', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (true, 'CA_Zweck', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (true, 'CA_Thema', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (true, 'CA_Kontext', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (true, 'CA_Ausgangsmaterial', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (true, 'CA_Daten', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (true, 'CA_Sinnstiftung', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (true, 'epoch', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (true, 'SO_Elemente', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (true, 'SO_Kontext', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (true, 'SO_Medium', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (true, 'VFO_Ansätze', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (true, 'VFO_Ausstellungen', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (NULL, 'create date', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'current time', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'duration', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'free', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'matrix structure', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'modify date', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'movie data', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'movie data size', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'movie header version', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'next track id', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'poster time', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'preferred rate', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'preferred volume', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'preview duration', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'preview time', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'selection duration', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'selection time', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'time scale', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'wide', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'audio bits per sample', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'audio channels', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'audio format', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'audio sample rate', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'balance', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'chunk offset', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'handler class', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'handler description', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'handler type', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'handler vendor id', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'media create date', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'media duration', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'media header version', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'media modify date', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'media time scale', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'sample sizes', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'sample to chunk', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'time to sample table', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'track create date', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'track duration', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'track header version', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'track id', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'track layer', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'track modify date', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'track volume', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown alis', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown edts', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'bit depth', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'compressor id', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'compressor name', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'graphics mode', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'image height', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'image width', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'op color', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'source image height', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'source image width', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'sync sample table', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'vendor id', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'video frame rate', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'x resolution', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'y resolution', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'avg bitrate', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'image size', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'rotation', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'track number', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'media language code', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'compatible brands', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'major brand', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'minor version', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'initial object descriptor', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown gshh', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown gspm', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown gspu', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown gssd', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown gsst', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown gstd', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'audio bitrate', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'audio layer', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'channel mode', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'copyright flag', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'emphasis', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'encoder', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'intensity stereo', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'lame bitrate', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'lame low pass filter', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'lame method', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'lame quality', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'lame stereo mode', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'lame vbr quality', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'mpeg audio version', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'ms stereo', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'original media', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'sample rate', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'id3 size', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'album', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'artist', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'comment', 'MetaDatumString');
INSERT INTO meta_keys VALUES (true, 'genre', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (NULL, 'track', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'year', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'date time original', 'MetaDatumString');
INSERT INTO meta_keys VALUES (true, 'style', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (NULL, 'Zett_Ansprechsperson', 'MetaDatumPeople');
INSERT INTO meta_keys VALUES (NULL, 'Zett_Artikel', 'MetaDatumString');
INSERT INTO meta_keys VALUES (false, 'Zett_Ausgabe', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (NULL, 'Zett_Autorinnen', 'MetaDatumPeople');
INSERT INTO meta_keys VALUES (NULL, 'Zett_Kommentar', 'MetaDatumString');
INSERT INTO meta_keys VALUES (false, 'Zett_Sparte', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (false, 'Zett_Status', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (NULL, 'Zett_Redaktion', 'MetaDatumPeople');
INSERT INTO meta_keys VALUES (NULL, 'Zett_Produktion', 'MetaDatumPeople');
INSERT INTO meta_keys VALUES (NULL, 'composition time to sample', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'composition to decode timeline mapping', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'idependent and disposable samples', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown tapt', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'com apple finalcutstudio media uuid', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown stps', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown tmcd', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'gen balance', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'gen flags', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'gen graphics mode', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'gen media version', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'gen op color', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'other format', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown kgtt', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'supplemental categories', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'urgency', 'MetaDatumString');
INSERT INTO meta_keys VALUES (true, 'Toni_Blickrichtung', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (NULL, 'Toni_Prozess', 'MetaDatumString');
INSERT INTO meta_keys VALUES (true, 'Toni_Objekt', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (NULL, 'Zett_Artikelbildnr', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'Zett_Artikel_Arbeitstitel', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'audio gain', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'bass', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'brightness', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'color', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'contrast', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'mute', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'pitch shift', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'play all frames', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'play selection', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'player version', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'tint', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'trebel', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'version', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'window location', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown load', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'instructions', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown 0x009b', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown apmd', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'user data tsc', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'user data tsz', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown cios', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'encoded by', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'document ancestors', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'text layer name', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'text layer text', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'user data enc', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'source credits', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'user data prd', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'user data key', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'compressor version', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown cndm', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown free', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'aperture', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'drive mode', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'focal length35efl', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'lens', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'lens35efl', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'lens id', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'shooting mode', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'shutter speed', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'canon flash info', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'canon flash mode', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'flash activity', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'flash bits', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'flash exposure comp', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'flash guide number', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'flash output', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'manual flash output', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'flash', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'flashpix version', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'frame count', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'frame rate', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'max data rate', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'quality', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'sample size', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'software', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'stream count', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'stream type', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'video codec', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'video frame count', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'vbr bytes', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'vbr frames', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'encoder settings', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'encoding time', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'release time', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'user defined text', 'MetaDatumString');
INSERT INTO meta_keys VALUES (false, 'FI_Veröffentlichungen', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (false, 'FI_Fachveranstaltungen', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (false, 'FI_Verbreitung', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (false, 'FI_Transfer', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (false, 'FI_Vernetzung', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (false, 'FI_Wissenschaftsbetrieb', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (false, 'FI_Drittmittel', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (NULL, 'FI_Veröffentlichungen_Text', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'FI_Fachveranstaltungen_Text', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown cr8r', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown fiel', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown fxtc', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown ae lk', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'text junk', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'total frame count', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'requirements', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'creation date deu', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'make deu', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'model deu', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'software deu', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'audio codec', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'audio sample count', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'avg bytes per sec', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'bits per sample', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'encoding', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'num channels', 'MetaDatumString');
INSERT INTO meta_keys VALUES (false, 'PA_Artefakttyp', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (true, 'PA_Überlieferungsleistung', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (true, 'PA_Vermittlungspotential', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (NULL, 'PA_KommentarArtefakte', 'MetaDatumString');
INSERT INTO meta_keys VALUES (true, 'PA_ArtefakttypDifferenzierung', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (NULL, 'user data tim', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'chunk offset64', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'null media header', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'pantry flash fired', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'pantry flash function', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'pantry flash mode', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'pantry flash red eye mode', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'pantry flash return', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'Status Archivierung', 'MetaDatumMetaTerms');
INSERT INTO meta_keys VALUES (NULL, 'owner', 'MetaDatumUsers');
INSERT INTO meta_keys VALUES (NULL, 'com apple finalcutstudio media history uuid', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown 0x010a', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'chapter list', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'text', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown kgit', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'com apple proapps clip id', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'com apple proapps is good', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'com apple proapps original format', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'com apple proapps reel', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'com sony bprl mxf umid', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'com sony bprl xdcamradplug version', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'com sony professionaldisc nonrealtimemeta lastupdate', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'org smpte mxf package material packageid', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown kgcg', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'unknown kgsi', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'parent media_resources', 'MetaDatumString');
INSERT INTO meta_keys VALUES (NULL, 'child media_resources', 'MetaDatumString');


--
-- Data for Name: meta_keys_meta_terms; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO meta_keys_meta_terms VALUES (1, 60, 0, 'academic year');
INSERT INTO meta_keys_meta_terms VALUES (2, 61, 1, 'academic year');
INSERT INTO meta_keys_meta_terms VALUES (3, 62, 2, 'academic year');
INSERT INTO meta_keys_meta_terms VALUES (4, 63, 3, 'academic year');
INSERT INTO meta_keys_meta_terms VALUES (5, 64, 4, 'academic year');
INSERT INTO meta_keys_meta_terms VALUES (6, 340, 5, 'academic year');
INSERT INTO meta_keys_meta_terms VALUES (7, 341, 6, 'academic year');
INSERT INTO meta_keys_meta_terms VALUES (8, 2131, 7, 'academic year');
INSERT INTO meta_keys_meta_terms VALUES (9, 2321, 8, 'academic year');
INSERT INTO meta_keys_meta_terms VALUES (10, 2666, 9, 'academic year');
INSERT INTO meta_keys_meta_terms VALUES (11, 2668, 10, 'academic year');
INSERT INTO meta_keys_meta_terms VALUES (12, 85, 0, 'project type');
INSERT INTO meta_keys_meta_terms VALUES (13, 86, 1, 'project type');
INSERT INTO meta_keys_meta_terms VALUES (14, 87, 2, 'project type');
INSERT INTO meta_keys_meta_terms VALUES (15, 88, 3, 'project type');
INSERT INTO meta_keys_meta_terms VALUES (16, 89, 4, 'project type');
INSERT INTO meta_keys_meta_terms VALUES (17, 90, 5, 'project type');
INSERT INTO meta_keys_meta_terms VALUES (18, 91, 6, 'project type');
INSERT INTO meta_keys_meta_terms VALUES (19, 73, 0, 'type');
INSERT INTO meta_keys_meta_terms VALUES (20, 74, 1, 'type');
INSERT INTO meta_keys_meta_terms VALUES (21, 75, 2, 'type');
INSERT INTO meta_keys_meta_terms VALUES (22, 76, 3, 'type');
INSERT INTO meta_keys_meta_terms VALUES (23, 77, 4, 'type');
INSERT INTO meta_keys_meta_terms VALUES (24, 78, 5, 'type');
INSERT INTO meta_keys_meta_terms VALUES (25, 79, 6, 'type');
INSERT INTO meta_keys_meta_terms VALUES (26, 80, 7, 'type');
INSERT INTO meta_keys_meta_terms VALUES (27, 83, 8, 'type');
INSERT INTO meta_keys_meta_terms VALUES (28, 801, 0, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (29, 885, 1, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (30, 1387, 2, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (31, 1571, 3, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (32, 2161, 4, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (33, 2163, 5, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (34, 2165, 6, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (35, 2167, 7, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (36, 2169, 8, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (37, 2171, 9, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (38, 2173, 10, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (39, 2175, 11, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (40, 2177, 12, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (41, 2179, 13, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (42, 2181, 14, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (43, 2183, 15, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (44, 2185, 16, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (45, 2187, 17, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (46, 2189, 18, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (47, 2191, 19, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (48, 2193, 20, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (49, 2195, 21, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (50, 2197, 22, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (51, 2199, 23, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (52, 2201, 24, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (53, 2203, 25, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (54, 2205, 26, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (55, 2207, 27, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (56, 2209, 28, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (57, 2211, 29, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (58, 2339, 30, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (59, 2351, 31, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (60, 2353, 32, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (61, 2355, 33, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (62, 2591, 34, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (63, 2706, 35, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (64, 3140, 36, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (65, 3235, 37, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (66, 3543, 38, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (67, 3637, 39, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (68, 3639, 40, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (69, 3647, 41, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (70, 3651, 42, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (71, 3707, 43, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (72, 3709, 44, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (73, 3711, 45, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (74, 3713, 46, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (75, 3925, 47, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (76, 4361, 48, 'portrayed object materials');
INSERT INTO meta_keys_meta_terms VALUES (77, 443, 0, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (78, 1063, 1, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (79, 1065, 2, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (80, 1081, 3, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (81, 1083, 4, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (82, 1085, 5, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (83, 1087, 6, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (84, 1089, 7, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (85, 1091, 8, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (86, 1093, 9, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (87, 1095, 10, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (88, 1097, 11, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (89, 1191, 12, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (90, 1225, 13, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (91, 1227, 14, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (92, 1229, 15, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (93, 1263, 16, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (94, 1363, 17, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (95, 2369, 18, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (96, 2371, 19, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (97, 2377, 20, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (98, 2379, 21, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (99, 2395, 22, 'LV_Landschaftstyp');
INSERT INTO meta_keys_meta_terms VALUES (100, 79, 0, 'LV_Verwendungszweck');
INSERT INTO meta_keys_meta_terms VALUES (101, 1017, 1, 'LV_Verwendungszweck');
INSERT INTO meta_keys_meta_terms VALUES (102, 1019, 2, 'LV_Verwendungszweck');
INSERT INTO meta_keys_meta_terms VALUES (103, 1067, 3, 'LV_Verwendungszweck');
INSERT INTO meta_keys_meta_terms VALUES (104, 1069, 4, 'LV_Verwendungszweck');
INSERT INTO meta_keys_meta_terms VALUES (105, 1071, 5, 'LV_Verwendungszweck');
INSERT INTO meta_keys_meta_terms VALUES (106, 1073, 6, 'LV_Verwendungszweck');
INSERT INTO meta_keys_meta_terms VALUES (107, 1075, 7, 'LV_Verwendungszweck');
INSERT INTO meta_keys_meta_terms VALUES (108, 1077, 8, 'LV_Verwendungszweck');
INSERT INTO meta_keys_meta_terms VALUES (109, 1079, 9, 'LV_Verwendungszweck');
INSERT INTO meta_keys_meta_terms VALUES (110, 1111, 10, 'LV_Verwendungszweck');
INSERT INTO meta_keys_meta_terms VALUES (111, 1113, 11, 'LV_Verwendungszweck');
INSERT INTO meta_keys_meta_terms VALUES (112, 1115, 12, 'LV_Verwendungszweck');
INSERT INTO meta_keys_meta_terms VALUES (113, 1021, 0, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (114, 1153, 1, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (115, 1161, 2, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (116, 1163, 3, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (117, 1165, 4, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (118, 1167, 5, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (119, 1205, 6, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (120, 1207, 7, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (121, 1209, 8, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (122, 1249, 9, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (123, 1251, 10, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (124, 1253, 11, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (125, 1285, 12, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (126, 1287, 13, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (127, 1289, 14, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (128, 1311, 15, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (129, 1313, 16, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (130, 1315, 17, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (131, 1335, 18, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (132, 1361, 19, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (133, 1371, 20, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (134, 1377, 21, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (135, 1391, 22, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (136, 1393, 23, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (137, 1399, 24, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (138, 1401, 25, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (139, 1403, 26, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (140, 1425, 27, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (141, 1429, 28, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (142, 1449, 29, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (143, 1451, 30, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (144, 1453, 31, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (145, 1455, 32, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (146, 2385, 33, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (147, 2397, 34, 'LV_Bildwirkung');
INSERT INTO meta_keys_meta_terms VALUES (148, 1033, 0, 'LV_Bildzeit');
INSERT INTO meta_keys_meta_terms VALUES (149, 1035, 1, 'LV_Bildzeit');
INSERT INTO meta_keys_meta_terms VALUES (150, 1037, 2, 'LV_Bildzeit');
INSERT INTO meta_keys_meta_terms VALUES (151, 1039, 3, 'LV_Bildzeit');
INSERT INTO meta_keys_meta_terms VALUES (152, 1043, 4, 'LV_Bildzeit');
INSERT INTO meta_keys_meta_terms VALUES (153, 1045, 5, 'LV_Bildzeit');
INSERT INTO meta_keys_meta_terms VALUES (154, 1047, 6, 'LV_Bildzeit');
INSERT INTO meta_keys_meta_terms VALUES (155, 1049, 7, 'LV_Bildzeit');
INSERT INTO meta_keys_meta_terms VALUES (156, 1051, 8, 'LV_Bildzeit');
INSERT INTO meta_keys_meta_terms VALUES (157, 1053, 9, 'LV_Bildzeit');
INSERT INTO meta_keys_meta_terms VALUES (158, 1195, 10, 'LV_Bildzeit');
INSERT INTO meta_keys_meta_terms VALUES (159, 1197, 11, 'LV_Bildzeit');
INSERT INTO meta_keys_meta_terms VALUES (160, 1413, 12, 'LV_Bildzeit');
INSERT INTO meta_keys_meta_terms VALUES (161, 741, 0, 'LV_Farbe');
INSERT INTO meta_keys_meta_terms VALUES (162, 1149, 1, 'LV_Farbe');
INSERT INTO meta_keys_meta_terms VALUES (163, 1169, 2, 'LV_Farbe');
INSERT INTO meta_keys_meta_terms VALUES (164, 1171, 3, 'LV_Farbe');
INSERT INTO meta_keys_meta_terms VALUES (165, 1173, 4, 'LV_Farbe');
INSERT INTO meta_keys_meta_terms VALUES (166, 1211, 5, 'LV_Farbe');
INSERT INTO meta_keys_meta_terms VALUES (167, 1213, 6, 'LV_Farbe');
INSERT INTO meta_keys_meta_terms VALUES (168, 1231, 7, 'LV_Farbe');
INSERT INTO meta_keys_meta_terms VALUES (169, 1241, 8, 'LV_Farbe');
INSERT INTO meta_keys_meta_terms VALUES (170, 1243, 9, 'LV_Farbe');
INSERT INTO meta_keys_meta_terms VALUES (171, 1245, 10, 'LV_Farbe');
INSERT INTO meta_keys_meta_terms VALUES (172, 1255, 11, 'LV_Farbe');
INSERT INTO meta_keys_meta_terms VALUES (173, 1261, 12, 'LV_Farbe');
INSERT INTO meta_keys_meta_terms VALUES (174, 1267, 13, 'LV_Farbe');
INSERT INTO meta_keys_meta_terms VALUES (175, 1305, 14, 'LV_Farbe');
INSERT INTO meta_keys_meta_terms VALUES (176, 1323, 15, 'LV_Farbe');
INSERT INTO meta_keys_meta_terms VALUES (177, 1331, 16, 'LV_Farbe');
INSERT INTO meta_keys_meta_terms VALUES (178, 1367, 17, 'LV_Farbe');
INSERT INTO meta_keys_meta_terms VALUES (179, 1457, 18, 'LV_Farbe');
INSERT INTO meta_keys_meta_terms VALUES (180, 2389, 19, 'LV_Farbe');
INSERT INTO meta_keys_meta_terms VALUES (181, 2555, 20, 'LV_Farbe');
INSERT INTO meta_keys_meta_terms VALUES (182, 336, 0, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (183, 431, 1, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (184, 433, 2, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (185, 435, 3, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (186, 443, 4, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (187, 461, 5, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (188, 1175, 6, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (189, 1177, 7, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (190, 1179, 8, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (191, 1181, 9, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (192, 1183, 10, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (193, 1215, 11, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (194, 1217, 12, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (195, 1219, 13, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (196, 1221, 14, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (197, 1223, 15, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (198, 1233, 16, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (199, 1235, 17, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (200, 1247, 18, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (201, 1257, 19, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (202, 1259, 20, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (203, 1269, 21, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (204, 1273, 22, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (205, 1275, 23, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (206, 1277, 24, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (207, 1279, 25, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (208, 1291, 26, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (209, 1293, 27, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (210, 1295, 28, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (211, 1297, 29, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (212, 1299, 30, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (213, 1301, 31, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (214, 1303, 32, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (215, 1307, 33, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (216, 1309, 34, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (217, 1317, 35, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (218, 1319, 36, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (219, 1321, 37, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (220, 1325, 38, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (221, 1327, 39, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (222, 1329, 40, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (223, 1337, 41, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (224, 1339, 42, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (225, 1341, 43, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (226, 1343, 44, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (227, 1345, 45, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (228, 1347, 46, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (229, 1349, 47, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (230, 1351, 48, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (231, 1355, 49, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (232, 1357, 50, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (233, 1359, 51, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (234, 1365, 52, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (235, 1375, 53, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (236, 1379, 54, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (237, 1395, 55, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (238, 1397, 56, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (239, 1405, 57, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (240, 1407, 58, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (241, 1409, 59, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (242, 1427, 60, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (243, 1459, 61, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (244, 2367, 62, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (245, 2373, 63, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (246, 2381, 64, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (247, 2383, 65, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (248, 2387, 66, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (249, 2391, 67, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (250, 2393, 68, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (251, 2399, 69, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (252, 2547, 70, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (253, 2553, 71, 'LV_Landschaftselemente');
INSERT INTO meta_keys_meta_terms VALUES (254, 1117, 0, 'LV_Wetter/Klima');
INSERT INTO meta_keys_meta_terms VALUES (255, 1119, 1, 'LV_Wetter/Klima');
INSERT INTO meta_keys_meta_terms VALUES (256, 1121, 2, 'LV_Wetter/Klima');
INSERT INTO meta_keys_meta_terms VALUES (257, 1125, 3, 'LV_Wetter/Klima');
INSERT INTO meta_keys_meta_terms VALUES (258, 1127, 4, 'LV_Wetter/Klima');
INSERT INTO meta_keys_meta_terms VALUES (259, 1129, 5, 'LV_Wetter/Klima');
INSERT INTO meta_keys_meta_terms VALUES (260, 1131, 6, 'LV_Wetter/Klima');
INSERT INTO meta_keys_meta_terms VALUES (261, 1133, 7, 'LV_Wetter/Klima');
INSERT INTO meta_keys_meta_terms VALUES (262, 1135, 8, 'LV_Wetter/Klima');
INSERT INTO meta_keys_meta_terms VALUES (263, 1139, 9, 'LV_Wetter/Klima');
INSERT INTO meta_keys_meta_terms VALUES (264, 1159, 10, 'LV_Wetter/Klima');
INSERT INTO meta_keys_meta_terms VALUES (265, 1239, 11, 'LV_Wetter/Klima');
INSERT INTO meta_keys_meta_terms VALUES (266, 1265, 12, 'LV_Wetter/Klima');
INSERT INTO meta_keys_meta_terms VALUES (267, 1333, 13, 'LV_Wetter/Klima');
INSERT INTO meta_keys_meta_terms VALUES (268, 1417, 14, 'LV_Wetter/Klima');
INSERT INTO meta_keys_meta_terms VALUES (269, 1057, 0, 'LV_Horizontlinie');
INSERT INTO meta_keys_meta_terms VALUES (270, 1059, 1, 'LV_Horizontlinie');
INSERT INTO meta_keys_meta_terms VALUES (271, 1061, 2, 'LV_Horizontlinie');
INSERT INTO meta_keys_meta_terms VALUES (272, 1199, 3, 'LV_Horizontlinie');
INSERT INTO meta_keys_meta_terms VALUES (273, 1099, 0, 'LV_Ra?umliche Wahrnehmung');
INSERT INTO meta_keys_meta_terms VALUES (274, 1101, 1, 'LV_Ra?umliche Wahrnehmung');
INSERT INTO meta_keys_meta_terms VALUES (275, 1103, 2, 'LV_Ra?umliche Wahrnehmung');
INSERT INTO meta_keys_meta_terms VALUES (276, 1105, 3, 'LV_Ra?umliche Wahrnehmung');
INSERT INTO meta_keys_meta_terms VALUES (277, 1107, 4, 'LV_Ra?umliche Wahrnehmung');
INSERT INTO meta_keys_meta_terms VALUES (278, 1109, 5, 'LV_Ra?umliche Wahrnehmung');
INSERT INTO meta_keys_meta_terms VALUES (279, 1201, 6, 'LV_Ra?umliche Wahrnehmung');
INSERT INTO meta_keys_meta_terms VALUES (280, 1021, 0, 'LV_Abstraktionsgrad');
INSERT INTO meta_keys_meta_terms VALUES (281, 1023, 1, 'LV_Abstraktionsgrad');
INSERT INTO meta_keys_meta_terms VALUES (282, 1025, 2, 'LV_Abstraktionsgrad');
INSERT INTO meta_keys_meta_terms VALUES (283, 1027, 3, 'LV_Abstraktionsgrad');
INSERT INTO meta_keys_meta_terms VALUES (284, 1029, 4, 'LV_Abstraktionsgrad');
INSERT INTO meta_keys_meta_terms VALUES (285, 1031, 5, 'LV_Abstraktionsgrad');
INSERT INTO meta_keys_meta_terms VALUES (286, 1479, 0, 'SL_Resourcen');
INSERT INTO meta_keys_meta_terms VALUES (287, 1481, 1, 'SL_Resourcen');
INSERT INTO meta_keys_meta_terms VALUES (288, 1483, 2, 'SL_Resourcen');
INSERT INTO meta_keys_meta_terms VALUES (289, 1485, 3, 'SL_Resourcen');
INSERT INTO meta_keys_meta_terms VALUES (290, 1487, 4, 'SL_Resourcen');
INSERT INTO meta_keys_meta_terms VALUES (291, 1493, 0, 'SO_Ordnungen');
INSERT INTO meta_keys_meta_terms VALUES (292, 1495, 1, 'SO_Ordnungen');
INSERT INTO meta_keys_meta_terms VALUES (293, 1497, 2, 'SO_Ordnungen');
INSERT INTO meta_keys_meta_terms VALUES (294, 1499, 3, 'SO_Ordnungen');
INSERT INTO meta_keys_meta_terms VALUES (295, 1501, 4, 'SO_Ordnungen');
INSERT INTO meta_keys_meta_terms VALUES (296, 1593, 0, 'CA_Konzept');
INSERT INTO meta_keys_meta_terms VALUES (297, 1771, 1, 'CA_Konzept');
INSERT INTO meta_keys_meta_terms VALUES (298, 1773, 2, 'CA_Konzept');
INSERT INTO meta_keys_meta_terms VALUES (299, 1775, 3, 'CA_Konzept');
INSERT INTO meta_keys_meta_terms VALUES (300, 1777, 4, 'CA_Konzept');
INSERT INTO meta_keys_meta_terms VALUES (301, 1791, 5, 'CA_Konzept');
INSERT INTO meta_keys_meta_terms VALUES (302, 1387, 0, 'CA_Informationstechnologie');
INSERT INTO meta_keys_meta_terms VALUES (303, 1551, 1, 'CA_Informationstechnologie');
INSERT INTO meta_keys_meta_terms VALUES (304, 1561, 2, 'CA_Informationstechnologie');
INSERT INTO meta_keys_meta_terms VALUES (305, 1589, 3, 'CA_Informationstechnologie');
INSERT INTO meta_keys_meta_terms VALUES (306, 1725, 4, 'CA_Informationstechnologie');
INSERT INTO meta_keys_meta_terms VALUES (307, 1727, 5, 'CA_Informationstechnologie');
INSERT INTO meta_keys_meta_terms VALUES (308, 1729, 6, 'CA_Informationstechnologie');
INSERT INTO meta_keys_meta_terms VALUES (309, 1731, 7, 'CA_Informationstechnologie');
INSERT INTO meta_keys_meta_terms VALUES (310, 1733, 8, 'CA_Informationstechnologie');
INSERT INTO meta_keys_meta_terms VALUES (311, 1735, 9, 'CA_Informationstechnologie');
INSERT INTO meta_keys_meta_terms VALUES (312, 1737, 10, 'CA_Informationstechnologie');
INSERT INTO meta_keys_meta_terms VALUES (313, 1739, 11, 'CA_Informationstechnologie');
INSERT INTO meta_keys_meta_terms VALUES (314, 1741, 12, 'CA_Informationstechnologie');
INSERT INTO meta_keys_meta_terms VALUES (315, 1743, 13, 'CA_Informationstechnologie');
INSERT INTO meta_keys_meta_terms VALUES (316, 1747, 14, 'CA_Informationstechnologie');
INSERT INTO meta_keys_meta_terms VALUES (317, 1749, 15, 'CA_Informationstechnologie');
INSERT INTO meta_keys_meta_terms VALUES (318, 1751, 16, 'CA_Informationstechnologie');
INSERT INTO meta_keys_meta_terms VALUES (319, 88, 0, 'CA_Zweck');
INSERT INTO meta_keys_meta_terms VALUES (320, 1671, 1, 'CA_Zweck');
INSERT INTO meta_keys_meta_terms VALUES (321, 1701, 2, 'CA_Zweck');
INSERT INTO meta_keys_meta_terms VALUES (322, 1705, 3, 'CA_Zweck');
INSERT INTO meta_keys_meta_terms VALUES (323, 1709, 4, 'CA_Zweck');
INSERT INTO meta_keys_meta_terms VALUES (324, 1715, 5, 'CA_Zweck');
INSERT INTO meta_keys_meta_terms VALUES (325, 3613, 6, 'CA_Zweck');
INSERT INTO meta_keys_meta_terms VALUES (326, 1543, 0, 'CA_Thema');
INSERT INTO meta_keys_meta_terms VALUES (327, 1663, 1, 'CA_Thema');
INSERT INTO meta_keys_meta_terms VALUES (328, 1675, 2, 'CA_Thema');
INSERT INTO meta_keys_meta_terms VALUES (329, 1685, 3, 'CA_Thema');
INSERT INTO meta_keys_meta_terms VALUES (330, 1687, 4, 'CA_Thema');
INSERT INTO meta_keys_meta_terms VALUES (331, 1689, 5, 'CA_Thema');
INSERT INTO meta_keys_meta_terms VALUES (332, 1691, 6, 'CA_Thema');
INSERT INTO meta_keys_meta_terms VALUES (333, 1693, 7, 'CA_Thema');
INSERT INTO meta_keys_meta_terms VALUES (334, 1695, 8, 'CA_Thema');
INSERT INTO meta_keys_meta_terms VALUES (335, 1697, 9, 'CA_Thema');
INSERT INTO meta_keys_meta_terms VALUES (336, 1699, 10, 'CA_Thema');
INSERT INTO meta_keys_meta_terms VALUES (337, 1805, 11, 'CA_Thema');
INSERT INTO meta_keys_meta_terms VALUES (338, 89, 0, 'CA_Kontext');
INSERT INTO meta_keys_meta_terms VALUES (339, 1463, 1, 'CA_Kontext');
INSERT INTO meta_keys_meta_terms VALUES (340, 1659, 2, 'CA_Kontext');
INSERT INTO meta_keys_meta_terms VALUES (341, 1717, 3, 'CA_Kontext');
INSERT INTO meta_keys_meta_terms VALUES (342, 1793, 4, 'CA_Kontext');
INSERT INTO meta_keys_meta_terms VALUES (343, 1655, 0, 'CA_Ausgangsmaterial');
INSERT INTO meta_keys_meta_terms VALUES (344, 1721, 1, 'CA_Ausgangsmaterial');
INSERT INTO meta_keys_meta_terms VALUES (345, 1723, 2, 'CA_Ausgangsmaterial');
INSERT INTO meta_keys_meta_terms VALUES (346, 1789, 3, 'CA_Ausgangsmaterial');
INSERT INTO meta_keys_meta_terms VALUES (347, 3593, 4, 'CA_Ausgangsmaterial');
INSERT INTO meta_keys_meta_terms VALUES (348, 3595, 5, 'CA_Ausgangsmaterial');
INSERT INTO meta_keys_meta_terms VALUES (349, 3597, 6, 'CA_Ausgangsmaterial');
INSERT INTO meta_keys_meta_terms VALUES (350, 1521, 0, 'CA_Daten');
INSERT INTO meta_keys_meta_terms VALUES (351, 1657, 1, 'CA_Daten');
INSERT INTO meta_keys_meta_terms VALUES (352, 1753, 2, 'CA_Daten');
INSERT INTO meta_keys_meta_terms VALUES (353, 1755, 3, 'CA_Daten');
INSERT INTO meta_keys_meta_terms VALUES (354, 1757, 4, 'CA_Daten');
INSERT INTO meta_keys_meta_terms VALUES (355, 1561, 0, 'CA_Sinnstiftung');
INSERT INTO meta_keys_meta_terms VALUES (356, 1623, 1, 'CA_Sinnstiftung');
INSERT INTO meta_keys_meta_terms VALUES (357, 1629, 2, 'CA_Sinnstiftung');
INSERT INTO meta_keys_meta_terms VALUES (358, 1661, 3, 'CA_Sinnstiftung');
INSERT INTO meta_keys_meta_terms VALUES (359, 1759, 4, 'CA_Sinnstiftung');
INSERT INTO meta_keys_meta_terms VALUES (360, 1761, 5, 'CA_Sinnstiftung');
INSERT INTO meta_keys_meta_terms VALUES (361, 1763, 6, 'CA_Sinnstiftung');
INSERT INTO meta_keys_meta_terms VALUES (362, 1765, 7, 'CA_Sinnstiftung');
INSERT INTO meta_keys_meta_terms VALUES (363, 1767, 8, 'CA_Sinnstiftung');
INSERT INTO meta_keys_meta_terms VALUES (364, 1769, 9, 'CA_Sinnstiftung');
INSERT INTO meta_keys_meta_terms VALUES (365, 1795, 10, 'CA_Sinnstiftung');
INSERT INTO meta_keys_meta_terms VALUES (366, 1797, 11, 'CA_Sinnstiftung');
INSERT INTO meta_keys_meta_terms VALUES (367, 1799, 12, 'CA_Sinnstiftung');
INSERT INTO meta_keys_meta_terms VALUES (368, 1801, 13, 'CA_Sinnstiftung');
INSERT INTO meta_keys_meta_terms VALUES (369, 667, 0, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (370, 1535, 1, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (371, 1653, 2, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (372, 1941, 3, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (373, 1947, 4, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (374, 1949, 5, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (375, 1951, 6, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (376, 1953, 7, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (377, 1955, 8, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (378, 1961, 9, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (379, 1963, 10, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (380, 1967, 11, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (381, 1969, 12, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (382, 1971, 13, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (383, 1973, 14, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (384, 1977, 15, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (385, 1979, 16, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (386, 1983, 17, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (387, 1985, 18, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (388, 1987, 19, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (389, 1989, 20, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (390, 1991, 21, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (391, 2551, 22, 'epoch');
INSERT INTO meta_keys_meta_terms VALUES (392, 1647, 0, 'SO_Elemente');
INSERT INTO meta_keys_meta_terms VALUES (393, 1905, 1, 'SO_Elemente');
INSERT INTO meta_keys_meta_terms VALUES (394, 2005, 2, 'SO_Elemente');
INSERT INTO meta_keys_meta_terms VALUES (395, 2007, 3, 'SO_Elemente');
INSERT INTO meta_keys_meta_terms VALUES (396, 2009, 4, 'SO_Elemente');
INSERT INTO meta_keys_meta_terms VALUES (397, 1649, 0, 'SO_Kontext');
INSERT INTO meta_keys_meta_terms VALUES (398, 2001, 1, 'SO_Kontext');
INSERT INTO meta_keys_meta_terms VALUES (399, 2003, 2, 'SO_Kontext');
INSERT INTO meta_keys_meta_terms VALUES (400, 1651, 0, 'SO_Medium');
INSERT INTO meta_keys_meta_terms VALUES (401, 1999, 1, 'SO_Medium');
INSERT INTO meta_keys_meta_terms VALUES (402, 1609, 0, 'VFO_Ansätze');
INSERT INTO meta_keys_meta_terms VALUES (403, 1613, 1, 'VFO_Ansätze');
INSERT INTO meta_keys_meta_terms VALUES (404, 1843, 2, 'VFO_Ansätze');
INSERT INTO meta_keys_meta_terms VALUES (405, 1845, 3, 'VFO_Ansätze');
INSERT INTO meta_keys_meta_terms VALUES (406, 1847, 4, 'VFO_Ansätze');
INSERT INTO meta_keys_meta_terms VALUES (407, 1849, 5, 'VFO_Ansätze');
INSERT INTO meta_keys_meta_terms VALUES (408, 1851, 6, 'VFO_Ansätze');
INSERT INTO meta_keys_meta_terms VALUES (409, 1853, 7, 'VFO_Ansätze');
INSERT INTO meta_keys_meta_terms VALUES (410, 1855, 8, 'VFO_Ansätze');
INSERT INTO meta_keys_meta_terms VALUES (411, 1857, 9, 'VFO_Ansätze');
INSERT INTO meta_keys_meta_terms VALUES (412, 1859, 10, 'VFO_Ansätze');
INSERT INTO meta_keys_meta_terms VALUES (413, 1861, 11, 'VFO_Ansätze');
INSERT INTO meta_keys_meta_terms VALUES (414, 1863, 12, 'VFO_Ansätze');
INSERT INTO meta_keys_meta_terms VALUES (415, 1865, 13, 'VFO_Ansätze');
INSERT INTO meta_keys_meta_terms VALUES (416, 1867, 14, 'VFO_Ansätze');
INSERT INTO meta_keys_meta_terms VALUES (417, 1869, 0, 'VFO_Ausstellungen');
INSERT INTO meta_keys_meta_terms VALUES (418, 1871, 1, 'VFO_Ausstellungen');
INSERT INTO meta_keys_meta_terms VALUES (419, 1873, 2, 'VFO_Ausstellungen');
INSERT INTO meta_keys_meta_terms VALUES (420, 1875, 3, 'VFO_Ausstellungen');
INSERT INTO meta_keys_meta_terms VALUES (421, 1877, 4, 'VFO_Ausstellungen');
INSERT INTO meta_keys_meta_terms VALUES (422, 447, 0, 'genre');
INSERT INTO meta_keys_meta_terms VALUES (423, 669, 1, 'genre');
INSERT INTO meta_keys_meta_terms VALUES (424, 1619, 2, 'genre');
INSERT INTO meta_keys_meta_terms VALUES (425, 1879, 3, 'genre');
INSERT INTO meta_keys_meta_terms VALUES (426, 1881, 4, 'genre');
INSERT INTO meta_keys_meta_terms VALUES (427, 2225, 5, 'genre');
INSERT INTO meta_keys_meta_terms VALUES (428, 655, 0, 'style');
INSERT INTO meta_keys_meta_terms VALUES (429, 1827, 1, 'style');
INSERT INTO meta_keys_meta_terms VALUES (430, 1831, 2, 'style');
INSERT INTO meta_keys_meta_terms VALUES (431, 1833, 3, 'style');
INSERT INTO meta_keys_meta_terms VALUES (432, 1835, 4, 'style');
INSERT INTO meta_keys_meta_terms VALUES (433, 1837, 5, 'style');
INSERT INTO meta_keys_meta_terms VALUES (434, 1839, 6, 'style');
INSERT INTO meta_keys_meta_terms VALUES (435, 1841, 7, 'style');
INSERT INTO meta_keys_meta_terms VALUES (436, 1995, 8, 'style');
INSERT INTO meta_keys_meta_terms VALUES (437, 1997, 9, 'style');
INSERT INTO meta_keys_meta_terms VALUES (438, 2549, 10, 'style');
INSERT INTO meta_keys_meta_terms VALUES (439, 2557, 11, 'style');
INSERT INTO meta_keys_meta_terms VALUES (440, 2097, 1, 'Zett_Ausgabe');
INSERT INTO meta_keys_meta_terms VALUES (441, 2099, 2, 'Zett_Ausgabe');
INSERT INTO meta_keys_meta_terms VALUES (442, 2101, 3, 'Zett_Ausgabe');
INSERT INTO meta_keys_meta_terms VALUES (443, 2103, 4, 'Zett_Ausgabe');
INSERT INTO meta_keys_meta_terms VALUES (444, 2105, 5, 'Zett_Ausgabe');
INSERT INTO meta_keys_meta_terms VALUES (445, 2409, 6, 'Zett_Ausgabe');
INSERT INTO meta_keys_meta_terms VALUES (446, 74, 0, 'Zett_Sparte');
INSERT INTO meta_keys_meta_terms VALUES (447, 83, 1, 'Zett_Sparte');
INSERT INTO meta_keys_meta_terms VALUES (448, 2075, 2, 'Zett_Sparte');
INSERT INTO meta_keys_meta_terms VALUES (449, 2077, 3, 'Zett_Sparte');
INSERT INTO meta_keys_meta_terms VALUES (450, 2079, 4, 'Zett_Sparte');
INSERT INTO meta_keys_meta_terms VALUES (451, 2081, 5, 'Zett_Sparte');
INSERT INTO meta_keys_meta_terms VALUES (452, 2083, 6, 'Zett_Sparte');
INSERT INTO meta_keys_meta_terms VALUES (453, 2085, 7, 'Zett_Sparte');
INSERT INTO meta_keys_meta_terms VALUES (454, 2087, 8, 'Zett_Sparte');
INSERT INTO meta_keys_meta_terms VALUES (455, 2089, 9, 'Zett_Sparte');
INSERT INTO meta_keys_meta_terms VALUES (456, 2091, 10, 'Zett_Sparte');
INSERT INTO meta_keys_meta_terms VALUES (457, 2093, 11, 'Zett_Sparte');
INSERT INTO meta_keys_meta_terms VALUES (458, 2095, 12, 'Zett_Sparte');
INSERT INTO meta_keys_meta_terms VALUES (459, 2061, 0, 'Zett_Status');
INSERT INTO meta_keys_meta_terms VALUES (460, 2063, 1, 'Zett_Status');
INSERT INTO meta_keys_meta_terms VALUES (461, 2065, 2, 'Zett_Status');
INSERT INTO meta_keys_meta_terms VALUES (462, 2067, 3, 'Zett_Status');
INSERT INTO meta_keys_meta_terms VALUES (463, 2069, 4, 'Zett_Status');
INSERT INTO meta_keys_meta_terms VALUES (464, 2071, 5, 'Zett_Status');
INSERT INTO meta_keys_meta_terms VALUES (465, 2073, 6, 'Zett_Status');
INSERT INTO meta_keys_meta_terms VALUES (466, 2107, 7, 'Zett_Status');
INSERT INTO meta_keys_meta_terms VALUES (467, 2243, 0, 'Toni_Blickrichtung');
INSERT INTO meta_keys_meta_terms VALUES (468, 2249, 1, 'Toni_Blickrichtung');
INSERT INTO meta_keys_meta_terms VALUES (469, 2253, 2, 'Toni_Blickrichtung');
INSERT INTO meta_keys_meta_terms VALUES (470, 2241, 0, 'Toni_Objekt');
INSERT INTO meta_keys_meta_terms VALUES (471, 2245, 1, 'Toni_Objekt');
INSERT INTO meta_keys_meta_terms VALUES (472, 2247, 2, 'Toni_Objekt');
INSERT INTO meta_keys_meta_terms VALUES (473, 2251, 3, 'Toni_Objekt');
INSERT INTO meta_keys_meta_terms VALUES (474, 1603, 0, 'FI_Veröffentlichungen');
INSERT INTO meta_keys_meta_terms VALUES (475, 3289, 1, 'FI_Veröffentlichungen');
INSERT INTO meta_keys_meta_terms VALUES (476, 3291, 2, 'FI_Veröffentlichungen');
INSERT INTO meta_keys_meta_terms VALUES (477, 3293, 3, 'FI_Veröffentlichungen');
INSERT INTO meta_keys_meta_terms VALUES (478, 3295, 4, 'FI_Veröffentlichungen');
INSERT INTO meta_keys_meta_terms VALUES (479, 3297, 5, 'FI_Veröffentlichungen');
INSERT INTO meta_keys_meta_terms VALUES (480, 3299, 6, 'FI_Veröffentlichungen');
INSERT INTO meta_keys_meta_terms VALUES (481, 3301, 7, 'FI_Veröffentlichungen');
INSERT INTO meta_keys_meta_terms VALUES (482, 3303, 8, 'FI_Veröffentlichungen');
INSERT INTO meta_keys_meta_terms VALUES (483, 3305, 9, 'FI_Veröffentlichungen');
INSERT INTO meta_keys_meta_terms VALUES (484, 3307, 10, 'FI_Veröffentlichungen');
INSERT INTO meta_keys_meta_terms VALUES (485, 3309, 11, 'FI_Veröffentlichungen');
INSERT INTO meta_keys_meta_terms VALUES (486, 3311, 0, 'FI_Fachveranstaltungen');
INSERT INTO meta_keys_meta_terms VALUES (487, 3313, 1, 'FI_Fachveranstaltungen');
INSERT INTO meta_keys_meta_terms VALUES (488, 3315, 2, 'FI_Fachveranstaltungen');
INSERT INTO meta_keys_meta_terms VALUES (489, 3317, 3, 'FI_Fachveranstaltungen');
INSERT INTO meta_keys_meta_terms VALUES (490, 3319, 4, 'FI_Fachveranstaltungen');
INSERT INTO meta_keys_meta_terms VALUES (491, 3321, 0, 'FI_Verbreitung');
INSERT INTO meta_keys_meta_terms VALUES (492, 3323, 1, 'FI_Verbreitung');
INSERT INTO meta_keys_meta_terms VALUES (493, 3325, 2, 'FI_Verbreitung');
INSERT INTO meta_keys_meta_terms VALUES (494, 3327, 3, 'FI_Verbreitung');
INSERT INTO meta_keys_meta_terms VALUES (495, 3329, 4, 'FI_Verbreitung');
INSERT INTO meta_keys_meta_terms VALUES (496, 3331, 5, 'FI_Verbreitung');
INSERT INTO meta_keys_meta_terms VALUES (497, 3333, 0, 'FI_Transfer');
INSERT INTO meta_keys_meta_terms VALUES (498, 3335, 1, 'FI_Transfer');
INSERT INTO meta_keys_meta_terms VALUES (499, 3337, 2, 'FI_Transfer');
INSERT INTO meta_keys_meta_terms VALUES (500, 3339, 3, 'FI_Transfer');
INSERT INTO meta_keys_meta_terms VALUES (501, 3341, 0, 'FI_Vernetzung');
INSERT INTO meta_keys_meta_terms VALUES (502, 3343, 1, 'FI_Vernetzung');
INSERT INTO meta_keys_meta_terms VALUES (503, 3345, 2, 'FI_Vernetzung');
INSERT INTO meta_keys_meta_terms VALUES (504, 3347, 3, 'FI_Vernetzung');
INSERT INTO meta_keys_meta_terms VALUES (505, 3349, 0, 'FI_Wissenschaftsbetrieb');
INSERT INTO meta_keys_meta_terms VALUES (506, 3351, 1, 'FI_Wissenschaftsbetrieb');
INSERT INTO meta_keys_meta_terms VALUES (507, 3353, 2, 'FI_Wissenschaftsbetrieb');
INSERT INTO meta_keys_meta_terms VALUES (508, 3355, 3, 'FI_Wissenschaftsbetrieb');
INSERT INTO meta_keys_meta_terms VALUES (509, 3357, 0, 'FI_Drittmittel');
INSERT INTO meta_keys_meta_terms VALUES (510, 3359, 1, 'FI_Drittmittel');
INSERT INTO meta_keys_meta_terms VALUES (511, 3361, 2, 'FI_Drittmittel');
INSERT INTO meta_keys_meta_terms VALUES (512, 3363, 3, 'FI_Drittmittel');
INSERT INTO meta_keys_meta_terms VALUES (513, 3365, 4, 'FI_Drittmittel');
INSERT INTO meta_keys_meta_terms VALUES (514, 3367, 5, 'FI_Drittmittel');
INSERT INTO meta_keys_meta_terms VALUES (515, 879, 0, 'PA_Artefakttyp');
INSERT INTO meta_keys_meta_terms VALUES (516, 3859, 1, 'PA_Artefakttyp');
INSERT INTO meta_keys_meta_terms VALUES (517, 3861, 2, 'PA_Artefakttyp');
INSERT INTO meta_keys_meta_terms VALUES (518, 3863, 3, 'PA_Artefakttyp');
INSERT INTO meta_keys_meta_terms VALUES (519, 3865, 4, 'PA_Artefakttyp');
INSERT INTO meta_keys_meta_terms VALUES (520, 4299, 5, 'PA_Artefakttyp');
INSERT INTO meta_keys_meta_terms VALUES (521, 4301, 6, 'PA_Artefakttyp');
INSERT INTO meta_keys_meta_terms VALUES (522, 4303, 7, 'PA_Artefakttyp');
INSERT INTO meta_keys_meta_terms VALUES (523, 4573, 7, 'Zett_Ausgabe');
INSERT INTO meta_keys_meta_terms VALUES (525, 4575, 8, 'Zett_Ausgabe');
INSERT INTO meta_keys_meta_terms VALUES (527, 4577, 9, 'Zett_Ausgabe');
INSERT INTO meta_keys_meta_terms VALUES (529, 4579, 10, 'Zett_Ausgabe');
INSERT INTO meta_keys_meta_terms VALUES (531, 4581, 11, 'Zett_Ausgabe');
INSERT INTO meta_keys_meta_terms VALUES (533, 4583, 12, 'Zett_Ausgabe');
INSERT INTO meta_keys_meta_terms VALUES (535, 4585, 13, 'Zett_Ausgabe');
INSERT INTO meta_keys_meta_terms VALUES (537, 4587, 14, 'Zett_Ausgabe');
INSERT INTO meta_keys_meta_terms VALUES (539, 4589, 15, 'Zett_Ausgabe');
INSERT INTO meta_keys_meta_terms VALUES (541, 4591, 16, 'Zett_Ausgabe');
INSERT INTO meta_keys_meta_terms VALUES (543, 4593, 17, 'Zett_Ausgabe');
INSERT INTO meta_keys_meta_terms VALUES (545, 4595, 18, 'Zett_Ausgabe');
INSERT INTO meta_keys_meta_terms VALUES (547, 4597, 19, 'Zett_Ausgabe');
INSERT INTO meta_keys_meta_terms VALUES (548, 4609, 49, 'portrayed object materials');


--
-- Data for Name: meta_terms; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO meta_terms VALUES (1, 'Title', 'Titel');
INSERT INTO meta_terms VALUES (2, 'The title of the media entry', 'Titel des Medieneintrags');
INSERT INTO meta_terms VALUES (3, 'Author', 'Autor/in');
INSERT INTO meta_terms VALUES (4, 'Creator of the depicted work', 'Urheber/in des abgebildeten Werkes');
INSERT INTO meta_terms VALUES (5, 'Date Created', 'Datum');
INSERT INTO meta_terms VALUES (6, 'Date of creation of media content (e.g. 1878, 1.3.2003 or Spring semester 2011) - not of the media file.', 'Datum der Erstellung des Medieninhalts (z.B. 1878, 1.3.2003 oder Frühlingssemester 2011) - Nicht das Datum, an dem die Datei entstanden ist.');
INSERT INTO meta_terms VALUES (7, 'Content Keywords', 'Schlagworte zu Inhalt und Motiv');
INSERT INTO meta_terms VALUES (8, 'Keywords describing the media entry content', 'Schlagworte zu Inhalt und Motiv des Medieneintrags');
INSERT INTO meta_terms VALUES (9, 'Copyright', 'Copyright');
INSERT INTO meta_terms VALUES (10, 'Copyright owner', 'Besitzer/in der Nutzungs- und Verwertungsrechte');
INSERT INTO meta_terms VALUES (11, 'Uploaded by', 'Hochgeladen von');
INSERT INTO meta_terms VALUES (12, 'Uploaded at', 'Hochgeladen am');
INSERT INTO meta_terms VALUES (13, 'Archive number', 'Archivnummer');
INSERT INTO meta_terms VALUES (14, 'Object Name', 'Objektbezeichnung');
INSERT INTO meta_terms VALUES (15, 'The title of the media entry.', 'Titel des Medieneintrags.');
INSERT INTO meta_terms VALUES (16, 'Subtitle', 'Untertitel');
INSERT INTO meta_terms VALUES (17, 'The subtitle or other titles of the media entry.', 'Untertitel oder weitere Titel des Medieneintrags.');
INSERT INTO meta_terms VALUES (18, 'Description', 'Beschreibung');
INSERT INTO meta_terms VALUES (19, 'Description of the media content.', 'Eine frei zu wählende Beschreibung des Medieninhalts.');
INSERT INTO meta_terms VALUES (20, 'Classification', 'Klassification');
INSERT INTO meta_terms VALUES (21, 'Remark', 'Bemerkung');
INSERT INTO meta_terms VALUES (22, 'Internal Remark - Free Text.', 'Interne Bemerkung - Freier Text.');
INSERT INTO meta_terms VALUES (23, 'Datierung/Darstellungsdatum', 'Datierung/Darstellungsdatum');
INSERT INTO meta_terms VALUES (24, 'Description (objects.chat)', 'Beschreibung (objects.chat)');
INSERT INTO meta_terms VALUES (25, 'Copyright', 'Rechte');
INSERT INTO meta_terms VALUES (26, 'Dimensions', 'Bemaßungsetikett');
INSERT INTO meta_terms VALUES (27, 'Material/Technik', 'Material/Technik');
INSERT INTO meta_terms VALUES (28, 'The subtitle of the media entry', 'Untertitel des Medieneintrags');
INSERT INTO meta_terms VALUES (29, 'Creator of the depicted work', 'Urheber/in des abgebildeten Werkes.
Wer hat das abgebildete Werk erschaffen? Handelt es sich um einen historischen Künstler oder eine zeitgenössische Komponistin? Sind Sie selbst die Urheberin / der Urheber des Werkes?
Es können auch Künstlernamen einge');
INSERT INTO meta_terms VALUES (30, 'Institutional Affiliation', 'Bereich ZHdK');
INSERT INTO meta_terms VALUES (31, 'Institutional Affiliation of the Author of the work to the ZHdK.', 'Der Bereich an der ZHdK, in dem das abgebildete Werk entstanden ist.');
INSERT INTO meta_terms VALUES (32, 'Dates', 'Datum');
INSERT INTO meta_terms VALUES (33, 'Location', 'Standort');
INSERT INTO meta_terms VALUES (34, 'Location of the depicted object', 'Standort des abgebildeten Objektes');
INSERT INTO meta_terms VALUES (35, 'City', 'Stadt');
INSERT INTO meta_terms VALUES (36, 'City of the depicted object', 'Stadt des abgebildeten Objektes');
INSERT INTO meta_terms VALUES (37, 'County', 'Kanton/Bundesland');
INSERT INTO meta_terms VALUES (38, 'County of the depicted object', 'Kanton/Bundesland des abgebildeten Objektes');
INSERT INTO meta_terms VALUES (39, 'Country', 'Land');
INSERT INTO meta_terms VALUES (40, 'Country of the depicted object', 'Land des abgebildeten Objektes');
INSERT INTO meta_terms VALUES (41, 'ISO-Country code', 'ISO-Ländercode');
INSERT INTO meta_terms VALUES (42, 'ISO-Country code of the depicted object', 'ISO-Ländercode des abgebildeten Objektes');
INSERT INTO meta_terms VALUES (43, 'Portrayed Person', 'Porträtierte Person/en');
INSERT INTO meta_terms VALUES (44, 'Portrayed Institution', 'Porträtierte Institution');
INSERT INTO meta_terms VALUES (45, 'E.g. Zürich Museum of Art', 'Z.B. Gebäude oder Innenräume einer Institution');
INSERT INTO meta_terms VALUES (46, 'Other participants', 'Mitwirkende / weitere Personen');
INSERT INTO meta_terms VALUES (47, 'Persons, who contributed to the shown contents of, e.g. Scenery maker or Assistant Director.', 'Personen, die zum abgebildeten Inhalt beigetragen haben, z.B. Bühnenbildner oder die Regieassistenz.');
INSERT INTO meta_terms VALUES (48, 'Partner Institution', 'Partner / beteiligte Institutionen');
INSERT INTO meta_terms VALUES (49, 'Patron', 'Auftrag durch');
INSERT INTO meta_terms VALUES (50, 'Study Year', 'Studienjahr');
INSERT INTO meta_terms VALUES (51, '1. Semester Bachelor', '1. Semester Bachelor');
INSERT INTO meta_terms VALUES (52, '2. Semester Bachelor', '2. Semester Bachelor');
INSERT INTO meta_terms VALUES (53, '3. Semester Bachelor', '3. Semester Bachelor');
INSERT INTO meta_terms VALUES (54, '4. Semester Bachelor', '4. Semester Bachelor');
INSERT INTO meta_terms VALUES (55, '5. Semester Bachelor', '5. Semester Bachelor');
INSERT INTO meta_terms VALUES (57, '1. Semester Master', '1. Semester Master');
INSERT INTO meta_terms VALUES (58, '2. Semester Master', '2. Semester Master');
INSERT INTO meta_terms VALUES (59, '3. Semester Master', '3. Semester Master');
INSERT INTO meta_terms VALUES (60, 'MAS (Master of Advanced Studies)', 'MAS (Master of Advanced Studies)');
INSERT INTO meta_terms VALUES (61, 'DAS (Diploma of Advanced Studies)', 'DAS (Diploma of Advanced Studies)');
INSERT INTO meta_terms VALUES (62, 'CAS (Certificate of Advanced Studies)', 'CAS (Certificate of Advanced Studies)');
INSERT INTO meta_terms VALUES (63, 'Doktoratsprogramm', 'Doktoratsprogramm');
INSERT INTO meta_terms VALUES (64, 'sonstiges', 'sonstiges');
INSERT INTO meta_terms VALUES (65, 'Lecturer/Project Leader', 'Dozierende/Projektleitung');
INSERT INTO meta_terms VALUES (66, 'Public Caption', 'Bildlegende');
INSERT INTO meta_terms VALUES (67, 'Public Caption - For use in the media and press.', 'Bildunterschrift, die für einen bestimmten Kontext Gültigkeit hat, z.B. für Publikation in Jahrbuch, Presse oder Website. Bildlegende ist nicht identisch mit dem Titel des Medieneintrags.');
INSERT INTO meta_terms VALUES (68, 'Remarks about the Media Entry.', 'Beschreibung des Medieninhalts.');
INSERT INTO meta_terms VALUES (69, 'Remarks about the Media Entry.', 'Bemerkungen zum Medieninhalt.');
INSERT INTO meta_terms VALUES (70, 'Internet Links (URL)', 'Internet Links (URL)');
INSERT INTO meta_terms VALUES (71, 'Art type', 'Gattung');
INSERT INTO meta_terms VALUES (72, 'General category of the art portrayed', 'Allgemeine Gattung der Kunst in Bezug auf das Ausdrucksmedium');
INSERT INTO meta_terms VALUES (73, 'Architektur', 'Architektur');
INSERT INTO meta_terms VALUES (74, 'Design', 'Design');
INSERT INTO meta_terms VALUES (75, 'Film', 'Film');
INSERT INTO meta_terms VALUES (76, 'Fotografie', 'Fotografie');
INSERT INTO meta_terms VALUES (77, 'Tanz', 'Tanz');
INSERT INTO meta_terms VALUES (78, 'Theater', 'Theater');
INSERT INTO meta_terms VALUES (79, 'Kunst', 'Kunst');
INSERT INTO meta_terms VALUES (80, 'Literatur', 'Literatur');
INSERT INTO meta_terms VALUES (83, 'Musik', 'Musik');
INSERT INTO meta_terms VALUES (84, 'ZHdK Project Type', 'ZHdK-Projekttyp');
INSERT INTO meta_terms VALUES (85, 'Abschlussarbeit', 'Abschlussarbeit');
INSERT INTO meta_terms VALUES (86, 'Ausstellung', 'Ausstellung');
INSERT INTO meta_terms VALUES (87, 'Dokumentation', 'Dokumentation');
INSERT INTO meta_terms VALUES (88, '', 'Forschung');
INSERT INTO meta_terms VALUES (89, 'Lehre', 'im Studienverlauf entstanden');
INSERT INTO meta_terms VALUES (90, 'Lehrmittel', 'Lehrmittel');
INSERT INTO meta_terms VALUES (91, 'Recherche', 'Recherche');
INSERT INTO meta_terms VALUES (92, 'Photographer', 'Fotograf/in');
INSERT INTO meta_terms VALUES (93, 'Creator of the digital file (e.g. Photographer).', 'Urheber/in der Abbildung.');
INSERT INTO meta_terms VALUES (94, 'Address of Creator', 'Adresse');
INSERT INTO meta_terms VALUES (95, 'Post-Code', 'Postleitzahl');
INSERT INTO meta_terms VALUES (96, 'Telephone', 'Telefonnummer');
INSERT INTO meta_terms VALUES (97, 'Email Address', 'E-Mail-Adresse');
INSERT INTO meta_terms VALUES (98, 'Website of the Creator', 'Website');
INSERT INTO meta_terms VALUES (99, 'Job-title', 'Berufsbezeichnung');
INSERT INTO meta_terms VALUES (100, 'Other participants', 'Weitere Personen Medienerstellung');
INSERT INTO meta_terms VALUES (277, 'Creator of the depicted work', '');
INSERT INTO meta_terms VALUES (101, 'People who contributed to the creation of the illustrating medium, e.g. photographic assistant, stylist, cutter, image editor.', 'Personen, die zur Erstellung des Medieninhalts beigetragen haben: z.B. Assisstenz, Stylist, Cutter, Bildbearbeitung.');
INSERT INTO meta_terms VALUES (102, 'Date Created', 'Erstellungsdatum');
INSERT INTO meta_terms VALUES (103, 'Date of creation of media object', 'Datum der Erstellung des Medienobjektes resp. der Datei');
INSERT INTO meta_terms VALUES (104, 'Source', 'Quelle');
INSERT INTO meta_terms VALUES (105, 'The described resource may be derived from the related resource in whole or in part. z.B. a URL or a book.', 'Quelle, aus der das Medium stammt z.B. URL, Buch, Sender.');
INSERT INTO meta_terms VALUES (106, 'Provider', 'Angeboten durch');
INSERT INTO meta_terms VALUES (107, 'E.g. Studio Publikationen, ZHdK Kommunikation', 'Z.B. Studio Publikationen, ZHdK Kommunikation');
INSERT INTO meta_terms VALUES (108, 'Dimensions', 'Dimensionen');
INSERT INTO meta_terms VALUES (109, 'E.g. 60 x 80 cm, 5 x 18 x 17 m, 5:22 h, 32 min.', 'flächig, räumlich, zeitlich, z.B. 60 x 80 cm, 5 x 18 x 17 m, 5:22 h, 32 min');
INSERT INTO meta_terms VALUES (110, 'Material / Format', 'Material / Format');
INSERT INTO meta_terms VALUES (111, 'e.g. Oil on Canvas, PAL, Paper', 'z.B. Öl auf Leinwand, PAL, Baryt-Abzug');
INSERT INTO meta_terms VALUES (112, 'Title of the set.', 'Titel des Sets');
INSERT INTO meta_terms VALUES (113, 'Author of the set.', 'Autor/in des Sets');
INSERT INTO meta_terms VALUES (114, 'Date of creation of the set (e.g. 1.3.2003 or spring semester 2011) - not of the media files.', 'Datum der Erstellung des Sets (z.B. 1.3.2003 oder Frühlingssemester 2011) - Nicht das Datum, an dem die Dateien entstanden sind.');
INSERT INTO meta_terms VALUES (115, 'Copyright owner', 'Besitzer/in der Nutzungs- und Verwertungsrechte. Diese können z.B. beim Autor/Urheber des Werkes oder bei einer Institution liegen. Handelt es sich um Werke, die an der ZHdK im Rahmen von Lehre und Forschung entstanden sind, liegt ohne Sonderregelung das ');
INSERT INTO meta_terms VALUES (116, 'Copyright Status', 'Copyright-Status');
INSERT INTO meta_terms VALUES (117, NULL, 'Ist das Werk urheberrechtlich geschützt oder gemeinfrei?');
INSERT INTO meta_terms VALUES (118, 'Usage conditions', 'Nutzungsbedingungen');
INSERT INTO meta_terms VALUES (119, 'Copyright-Info URL', 'URL für Copyright-Informationen');
INSERT INTO meta_terms VALUES (120, 'Copyright URL for detailed description of usage rights of the work.', 'Internetlink zur detaillierten Beschreibung der Nutzungsbedingungen wie z.B. Lizenztexte und Publikationsdisclaimer.');
INSERT INTO meta_terms VALUES (121, '', 'Ist das Werk urheberrechtlich geschützt oder gemeinfrei?');
INSERT INTO meta_terms VALUES (122, 'Creator of the depicted work', 'Urheber/in des abgebildeten Werkes.
Wer hat das abgebildete Werk erschaffen? Handelt es sich um einen historischen Künstler oder eine zeitgenössische Komponistin? Sind Sie selbst die Urheberin / der Urheber des Werkes?
Es können auch Künstlernamen einge');
INSERT INTO meta_terms VALUES (123, 'Creator of the depicted work', 'Urheber/in des abgebildeten Werkes.
Wer hat das abgebildete Werk erschaffen? Handelt es sich um einen historischen Künstler oder eine zeitgenössische Komponistin? Sind Sie selbst die Urheberin / der Urheber des Werkes?
Auch Künstlernamen sind möglich.');
INSERT INTO meta_terms VALUES (124, 'Creator of the depicted work', 'Urheber/in des Werkes. Wer hat das Werk erschaffen? Handelt es sich um einen historischen Künstler oder eine zeitgenössische Komponistin? Sind Sie selbst die Urheberin / der Urheber des Werkes? Auch Künstlernamen sind möglich.');
INSERT INTO meta_terms VALUES (125, 'Date of creation of media content (e.g. 1878, 1.3.2003 or Spring semester 2011) - not of the media file.', 'Datum der Erschaffung des Werkes (z.B. 1878, 2.3.2008 oder Frühlingssemester 2011) - Nicht das Datum, an dem die Datei oder die Abbildung des Werkes entstanden ist.');
INSERT INTO meta_terms VALUES (126, 'Keywords describing the media entry content', 'Schlagworte zu Inhalt und Motiv des Medieneintrags. Was ist zu sehen oder zu hören? Welche Themen behandelt das Werk? Welche bildlichen oder muskalischen Motive lassen sich benennen? ');
INSERT INTO meta_terms VALUES (127, 'General category of the art portrayed', 'Allgemeine Gattung der Kunst in Bezug auf das Ausdrucksmedium. Mit welchen künstlerischen Medien arbeitet das Werk?');
INSERT INTO meta_terms VALUES (128, 'Public Caption - For use in the media and press.', 'Bildunterschrift, die nur für einen bestimmten Kontext Gültigkeit hat, z.B. für eine Publikation in Jahrbuch, Presse oder Website. Die Bildlegende ist nicht identisch mit dem Titel des Medieneintrags.');
INSERT INTO meta_terms VALUES (129, 'Remarks about the Media Entry.', 'Beschreibung des Medieninhalts. Hier können Sie eine ausführliche Beschreibung des Werkes einbringen.');
INSERT INTO meta_terms VALUES (130, 'Remarks about the Media Entry.', 'Bemerkungen zum Medieninhalt. Hier ist Platz für individuelle oder projektbezogene Bemerkungen. Diese können auch vorläufig sein oder von mehreren Personen editiert werden. ');
INSERT INTO meta_terms VALUES (131, '', 'Gibt es auf einer Internetseite weitere Informationen zum Medieneintrag? Ist das Werk etwa Bestandteil einer Internetanwendung?');
INSERT INTO meta_terms VALUES (132, 'Location of the depicted object', 'Standort des Werkes, z.B. eine Institution oder ein historischer Ort. In welchem Museum / welcher Sammlung befindet sich das Werk? Wo genau steht das abgebildete Gebäude? (Frage: auch Aufführungsort?)');
INSERT INTO meta_terms VALUES (133, '', 'Wer ist auf der Fotografie abgebildet? Welche Person thematisiert der Film?');
INSERT INTO meta_terms VALUES (134, 'E.g. Zürich Museum of Art', 'Ist eine Institution Thema des Werkes? Sind Gebäude oder Innenräume abgebildet? Ist die Institution durch ihre Mitarbeiter/innen oder durch ihre Tätigkeit vorgestellt?');
INSERT INTO meta_terms VALUES (135, 'Persons, who contributed to the shown contents of, e.g. Scenery maker or Assistant Director.', 'Personen, die zum Werk beigetragen haben, z.B. Bühnenbildner oder die Regieassistenz.');
INSERT INTO meta_terms VALUES (136, '', 'Eingabehilfe: Departement, Studienvertiefung');
INSERT INTO meta_terms VALUES (137, 'Institutional Affiliation of the Author of the work to the ZHdK.', 'Der Bereich an der ZHdK, in dem das Werk entstanden ist. ');
INSERT INTO meta_terms VALUES (138, '', 'Einzelne Schlagworte, durch Return/Enter getrennt.');
INSERT INTO meta_terms VALUES (139, '', 'Eingabeform: Nachname, Vorname');
INSERT INTO meta_terms VALUES (140, '', 'Freie Eingabe');
INSERT INTO meta_terms VALUES (141, '', 'Welche Person hat den Auftrag für das Werk gegeben? Welche Institution hat das Werk gefördert?');
INSERT INTO meta_terms VALUES (142, '', 'Wurde mit einem Forschungspartner zusammengearbeitet? Ist eine Institution an der Entstehung beteiligt?');
INSERT INTO meta_terms VALUES (143, '', 'Ausführliche Beschreibung');
INSERT INTO meta_terms VALUES (144, '', 'Umfangreicher Freitext');
INSERT INTO meta_terms VALUES (145, '', 'Wer hat das Projekt geleitet? Hier können Dozierende, Mentoren oder Projektverantwortliche eingetragen werden.');
INSERT INTO meta_terms VALUES (146, '', 'Wer hat das Projekt geleitet? Hier können Dozierende, Mentor/innen oder Projektverantwortliche eingetragen werden.');
INSERT INTO meta_terms VALUES (147, '', 'In welchem Studienjahr wurde das Werk erstellt? - Für Abschlussarbeiten kann zusätzlich bei ZHdK-Projekttyp das entsprechende Feld ausgewählt werden.');
INSERT INTO meta_terms VALUES (148, '', 'In welchem Studienjahr wurde das Werk erstellt? - Für Abschlussarbeiten kann zusätzlich bei "ZHdK-Projekttyp" das entsprechende Feld ausgewählt werden.');
INSERT INTO meta_terms VALUES (149, '', 'Mehrfachauswahl möglich');
INSERT INTO meta_terms VALUES (150, '', 'Um was für eine Art von Arbeit handelt es sich bei dem Werk?');
INSERT INTO meta_terms VALUES (151, '', 'Mehrfachauswahl bei längeren Projekten möglich');
INSERT INTO meta_terms VALUES (152, 'People who contributed to the creation of the illustrating medium, e.g. photographic assistant, stylist, cutter, image editor.', 'Personen, die zur Erstellung des Medienobjekts beigetragen haben: z.B. Assisstenz, Stylist, Cutter, Bildbearbeitung.');
INSERT INTO meta_terms VALUES (153, 'The title of the media entry', 'Titel des Werkes');
INSERT INTO meta_terms VALUES (154, 'The subtitle of the media entry', 'Untertitel des Werkes');
INSERT INTO meta_terms VALUES (155, 'Keywords describing the media entry content', 'Schlagworte zu Inhalt und Motiv des Werkes. Was ist zu sehen oder zu hören? Welche Themen behandelt das Werk? Welche bildlichen oder muskalischen Motive lassen sich benennen? ');
INSERT INTO meta_terms VALUES (156, 'Keywords describing the media entry content', 'Schlagworte zu Inhalt und Motiv des Werkes. Was ist zu sehen oder zu hören? Welche Themen behandelt das Werk? Welche bildlichen, dramaturgischen, filmischen oder musikalischen Motive lassen sich benennen? ');
INSERT INTO meta_terms VALUES (157, 'General category of the art portrayed', 'Allgemeine Gattung der Kunst in Bezug auf das Ausdrucksmedium. In welchem künstlerischen Medium artikuliert sich das Werk?');
INSERT INTO meta_terms VALUES (158, '', 'Umfangreicher Freitext möglich');
INSERT INTO meta_terms VALUES (159, '', 'Gibt es auf einer Internetseite weitere Informationen zum Werk? Ist das Werk etwa Bestandteil einer Internetanwendung?');
INSERT INTO meta_terms VALUES (160, '', 'Gibt es auf einer Internetseite weitere Informationen zum Werk? Ist es etwa Bestandteil einer Internetanwendung?');
INSERT INTO meta_terms VALUES (161, 'City of the depicted object', '');
INSERT INTO meta_terms VALUES (162, 'County of the depicted object', '');
INSERT INTO meta_terms VALUES (163, 'Country of the depicted object', '');
INSERT INTO meta_terms VALUES (164, 'ISO-Country code of the depicted object', '');
INSERT INTO meta_terms VALUES (165, 'Remarks about the Media Entry.', 'Bemerkungen zum Medieninhalt. Diese können individuell, projektbezogen oder vorläufig sein und von mehreren Personen editiert werden. ');
INSERT INTO meta_terms VALUES (166, 'Institutional Affiliation of the Author of the work to the ZHdK.', 'Der Bereich an der ZHdK, in dem das Werk entstanden ist. Hier können Studienvertiefungen, Institute und Abteilungen genannt werden.');
INSERT INTO meta_terms VALUES (167, '', 'Eingabevorschlag: Assistenz Köstumprobe: Barbara Beispiel');
INSERT INTO meta_terms VALUES (168, 'Persons, who contributed to the shown contents of, e.g. Scenery maker or Assistant Director.', 'Personen, die zum Werk beigetragen haben, z.B. Bühnenbildner oder die Regieassistenz. Die entsprechende Funktion sollte ebenfalls genannt werden.');
INSERT INTO meta_terms VALUES (169, '', 'In welchem Studienjahr wurde das Werk erstellt?');
INSERT INTO meta_terms VALUES (170, 'Creator of the digital file (e.g. Photographer).', 'Urheber/in der Abbildung');
INSERT INTO meta_terms VALUES (171, 'E.g. Studio Publikationen, ZHdK Kommunikation', 'Wer stellt das Medienobjekt zur Verfügung? Z.B. Lehrmittel können durch eine Studienverstiefung oder Pressematerialien durch das Studio Publikationen bereitgestellt werden.');
INSERT INTO meta_terms VALUES (172, 'E.g. Studio Publikationen, ZHdK Kommunikation', 'Wer stellt das Medienobjekt zur Verfügung? Z.B. Lehrmittel können durch eine Studienvertiefung oder Pressematerialien durch die Services bereitgestellt werden. Aber auch externe Anbieter können hier genannt werden.');
INSERT INTO meta_terms VALUES (173, 'E.g. Studio Publikationen, ZHdK Kommunikation', 'Wer stellt das Medienobjekt zur Verfügung? Z.B. Lehrmittel können durch eine Studienvertiefung oder Pressematerialien durch die Services bereitgestellt werden. Aber auch externe Anbieter dürfen hier genannt werden.');
INSERT INTO meta_terms VALUES (174, '', 'Eingabemöglichkeiten: z.B. 60 x 80 cm, 5 x 18 x 17 m, 5:22 h, 32 min');
INSERT INTO meta_terms VALUES (175, 'E.g. 60 x 80 cm, 5 x 18 x 17 m, 5:22 h, 32 min.', 'Wie groß ist das Kunstwerk? Wie lange dauert das Musikstück? Angaben zu Fläche, Raum und Zeit können hier eingetragen werden.');
INSERT INTO meta_terms VALUES (176, 'People who contributed to the creation of the illustrating medium, e.g. photographic assistant, stylist, cutter, image editor.', 'Personen, die zur Erstellung des Medienobjekts beigetragen haben: z.B. Assisstenz, Stylist, Cutter, Bildbearbeitung. Die entsprechende Funktion sollte ebenfalls genannt werden.');
INSERT INTO meta_terms VALUES (177, '', 'Eingabevorschlag: Bildbearbeitung: Mirco Muster');
INSERT INTO meta_terms VALUES (178, 'People who contributed to the creation of the illustrating medium, e.g. photographic assistant, stylist, cutter, image editor.', 'Personen, die zur Erstellung des Medienobjekts beigetragen haben: z.B. Assistenz, Stylist, Cutter, Bildbearbeitung. Die entsprechende Funktion sollte ebenfalls genannt werden.');
INSERT INTO meta_terms VALUES (179, 'Date of creation of media object', 'Datum der Erstellung des Medienobjektes resp. der Datei. Wann wurde die Fotografie aufgenommen oder das Computerrendering erzeugt? - Das Erstelldatum des Medienobjekts kann verschieden sein zum Erstelldatum des Werkes.');
INSERT INTO meta_terms VALUES (180, '', 'Freie Eingabe oder Übernahme der technischen Information.');
INSERT INTO meta_terms VALUES (181, 'e.g. Oil on Canvas, PAL, Paper', 'Auf welchem physikalischen Träger befindet sich das Medium? z.B. Öl auf Leinwand, PAL, Baryt-Abzug. Auch digitale Formate können genant werden.');
INSERT INTO meta_terms VALUES (182, 'Creator of the digital file (e.g. Photographer).', 'Urheber/in des Mediums. Dies kann eine Fotografin, ein Filmer, eine Zeichnerin sein. Die Person wird genannt, wenn sie sich vom Urhber/in des Werkes unterscheidet.');
INSERT INTO meta_terms VALUES (183, 'Creator of the digital file (e.g. Photographer).', 'Urheber/in des Mediums. Dies kann eine Fotografin, ein Filmer, eine Zeichnerin sein. Die Person wird genannt, wenn sie sich von der Urheber/in des Werkes unterscheidet.');
INSERT INTO meta_terms VALUES (184, 'Photographer', 'Medienersteller/in');
INSERT INTO meta_terms VALUES (185, '', 'Eingabevorschläge: z.B. 60 x 80 cm, 5 x 18 x 17 m, 5:22 h, 32 min');
INSERT INTO meta_terms VALUES (186, '', 'Eingabeformat: http://www.beispiel.ch');
INSERT INTO meta_terms VALUES (187, 'The title of the work', 'Titel des Werkes');
INSERT INTO meta_terms VALUES (188, '', 'Der Bereich an der ZHdK, in dem das Werk entstanden ist. Hier können Studienvertiefungen, Institute und Abteilungen genannt werden.');
INSERT INTO meta_terms VALUES (189, '', 'ZHdK-Projekttyp');
INSERT INTO meta_terms VALUES (190, '', 'Projektname');
INSERT INTO meta_terms VALUES (191, '', 'Wie war der Titel des Lehr- oder Forschungsprojektes? ');
INSERT INTO meta_terms VALUES (192, '', 'Eingabehilfe für Literaturnachweise: Nachname, Vorname: Titel, Ort Jahr');
INSERT INTO meta_terms VALUES (193, '', 'Wer stellt das Medienobjekt zur Verfügung? Z.B. Lehrmittel können durch eine Studienvertiefung oder Pressematerialien durch die Services bereitgestellt werden. Aber auch externe Anbieter dürfen hier genannt werden.');
INSERT INTO meta_terms VALUES (194, '', 'Titel');
INSERT INTO meta_terms VALUES (195, '', 'MIZ-Archiv: Titel');
INSERT INTO meta_terms VALUES (196, '', 'Untertitel');
INSERT INTO meta_terms VALUES (197, '', 'MIZ-Archiv: Untertitel');
INSERT INTO meta_terms VALUES (198, '', 'Autor/in');
INSERT INTO meta_terms VALUES (199, '', 'MIZ-Archiv: Urheber/in');
INSERT INTO meta_terms VALUES (200, '', 'Bereich ZHdK');
INSERT INTO meta_terms VALUES (201, '', 'MIZ-Archiv: Bereich');
INSERT INTO meta_terms VALUES (202, '', 'Datum');
INSERT INTO meta_terms VALUES (203, '', 'MIZ-Archiv: Datierung/Darstellungsdatum');
INSERT INTO meta_terms VALUES (204, '', 'Schlagworte zu Inhalt und Motiv');
INSERT INTO meta_terms VALUES (205, '', 'MIZ-Archiv: Stichworte');
INSERT INTO meta_terms VALUES (206, '', 'Gattung');
INSERT INTO meta_terms VALUES (207, '', 'MIZ-Archiv: Gattung');
INSERT INTO meta_terms VALUES (208, '', 'Beschreibung');
INSERT INTO meta_terms VALUES (209, '', 'MIZ-Archiv: Kurzbeschreibung');
INSERT INTO meta_terms VALUES (210, '', 'Bildlegende');
INSERT INTO meta_terms VALUES (211, '', 'MIZ-Archiv: Legende');
INSERT INTO meta_terms VALUES (212, '', 'Bemerkung');
INSERT INTO meta_terms VALUES (213, '', 'MIZ-Archiv: Bemerkung');
INSERT INTO meta_terms VALUES (214, '', 'Internet Links (URL)');
INSERT INTO meta_terms VALUES (215, '', 'MIZ-Archiv: Web-Link');
INSERT INTO meta_terms VALUES (216, '', 'Porträtierte Person/en');
INSERT INTO meta_terms VALUES (217, '', 'MIZ-Archiv: Porträtierte Person');
INSERT INTO meta_terms VALUES (218, '', 'Porträtierte Institution');
INSERT INTO meta_terms VALUES (219, '', 'MIZ-Archiv: Porträtierte Institution');
INSERT INTO meta_terms VALUES (220, '', 'Mitwirkende / weitere Personen');
INSERT INTO meta_terms VALUES (221, '', 'MIZ-Archiv: Beteiligte Personen');
INSERT INTO meta_terms VALUES (222, '', 'Partner / beteiligte Institutionen');
INSERT INTO meta_terms VALUES (223, '', 'MIZ-Archiv: Beteiligte Institution');
INSERT INTO meta_terms VALUES (224, '', 'Auftrag durch');
INSERT INTO meta_terms VALUES (225, '', 'MIZ-Archiv: Auftraggeber');
INSERT INTO meta_terms VALUES (226, '', 'Studienjahr');
INSERT INTO meta_terms VALUES (227, '', 'MIZ-Archiv: Studienjahr');
INSERT INTO meta_terms VALUES (228, '', 'Doz');
INSERT INTO meta_terms VALUES (229, '', 'Dozierende/Projektleitung');
INSERT INTO meta_terms VALUES (230, '', 'MIZ-Archiv: Projektleitung');
INSERT INTO meta_terms VALUES (231, '', 'Medienersteller/in');
INSERT INTO meta_terms VALUES (232, '', 'MIZ-Archiv: FotografIn');
INSERT INTO meta_terms VALUES (233, '', 'Weitere Personen Medienerstellung');
INSERT INTO meta_terms VALUES (234, '', 'MIZ-Archiv: Weitere Personen');
INSERT INTO meta_terms VALUES (235, '', 'Copyright');
INSERT INTO meta_terms VALUES (236, '', 'MIZ-Archiv: Rechte');
INSERT INTO meta_terms VALUES (237, '', 'Copyright-Status');
INSERT INTO meta_terms VALUES (238, '', 'MIZ-Archiv: Art der Objektrechte');
INSERT INTO meta_terms VALUES (239, '', 'Nutzungsbedingungen');
INSERT INTO meta_terms VALUES (240, '', 'MIZ-Archiv: Einschränkungen');
INSERT INTO meta_terms VALUES (241, '', 'URL für Copyright-Informationen');
INSERT INTO meta_terms VALUES (242, '', 'Angeboten durch');
INSERT INTO meta_terms VALUES (243, '', 'MIZ-Archiv: Verwaltet durch');
INSERT INTO meta_terms VALUES (244, '', 'Dimensionen');
INSERT INTO meta_terms VALUES (245, '', 'MIZ-Archiv: Bemaßungsetikett');
INSERT INTO meta_terms VALUES (246, '', 'Material/Format');
INSERT INTO meta_terms VALUES (247, '', 'MIZ-Archiv: Material/Technik');
INSERT INTO meta_terms VALUES (248, 'Keywords describing the media entry content', 'Schlagworte zu Inhalt und Motiv des Werkes. Was ist zu sehen oder zu hören? Welche Themen behandelt das Werk?');
INSERT INTO meta_terms VALUES (249, 'Public Caption - For use in the media and press.', 'Bildunterschrift, die nur für einen bestimmten Kontext Gültigkeit hat, z.B. für eine Publikation in einem Jahrbuch, durch die Presse oder auf einer Website. Die Bildlegende ist nicht identisch mit dem Titel des Medieneintrags.');
INSERT INTO meta_terms VALUES (250, 'Public Caption - For use in the media and press.', 'Bildunterschrift, die nur für einen bestimmten Kontext Gültigkeit hat, z.B. für eine Publikation in einem Jahrbuch, durch die Presse oder auf einer Website. Die Bildlegende ist nicht identisch mit dem Titel des Werks.');
INSERT INTO meta_terms VALUES (251, 'Remarks about the Media Entry.', 'Beschreibung des Werks. Hier können Sie eine ausführliche Beschreibung des Werkes einfügen.');
INSERT INTO meta_terms VALUES (252, 'Remarks about the Media Entry.', 'Bemerkungen zum Werk. Diese können individuell, projektbezogen oder vorläufig sein. ');
INSERT INTO meta_terms VALUES (253, '', 'Gibt es auf einer Internetseite weitere Informationen zum Werk? Ist es etwa Bestandteil einer Internetanwendung? Oder besteht eine Projektwebsite?');
INSERT INTO meta_terms VALUES (254, 'Dates', 'Datierung');
INSERT INTO meta_terms VALUES (255, 'Location', 'Standort/Aufführungsort');
INSERT INTO meta_terms VALUES (256, 'Location of the depicted object', 'Standort des Werkes, z.B. eine Institution oder ein historischer Ort. In welchem Museum / welcher Sammlung befindet sich das Werk? Wo genau steht das abgebildete Gebäude?');
INSERT INTO meta_terms VALUES (257, 'Creator of the digital file (e.g. Photographer).', 'Urheber/in des Mediums. Dies kann z.B. eine Fotografin, ein Filmer, eine Zeichnerin sein. Die Person wird genannt, wenn sie sich von der Urheber/in des Werkes unterscheidet. - Es ist nicht notwendig, Personen einzutragen, die z.B. die Reprografie, Kopie o');
INSERT INTO meta_terms VALUES (258, 'Creator of the digital file (e.g. Photographer).', 'Urheber/in des Mediums. Dies kann z.B. eine Fotografin, ein Filmer, eine Zeichnerin sein. Die Person wird genannt, wenn sie sich von der Urheber/in des Werkes unterscheidet. - Nicht eingetragen werden Personen, welche lediglich die digitale Reproduktion d');
INSERT INTO meta_terms VALUES (259, 'Creator of the digital file (e.g. Photographer).', 'Urheber/in des Mediums, z.B. eine Fotografin, ein Filmer, eine Zeichnerin. Die Person wird genannt, wenn sie sich von der Urheber/in des Werkes unterscheidet. - Nicht eingetragen werden Personen, welche lediglich die digitale Reproduktion des Werkes erste');
INSERT INTO meta_terms VALUES (260, 'Creator of the digital file (e.g. Photographer).', 'Urheber/in des Mediums, z.B. eine Fotografin, ein Filmer, eine Zeichnerin. Diese Person unterscheidet sich von der Urheber/in des Werkes. - Nicht eingetragen werden Personen, welche lediglich die digitale Reproduktion des Werkes erstellt haben.');
INSERT INTO meta_terms VALUES (261, 'The described resource may be derived from the related resource in whole or in part. z.B. a URL or a book.', 'Quelle, aus der das Medium stammt z.B. eine URL, ein Buch, ein Radio- oder TV-Sender.');
INSERT INTO meta_terms VALUES (262, 'The described resource may be derived from the related resource in whole or in part. z.B. a URL or a book.', 'Die Quelle, aus der das Medium stammt, z.B. eine URL, ein Buch, ein Radio- oder TV-Sender.');
INSERT INTO meta_terms VALUES (263, 'e.g. Oil on Canvas, PAL, Paper', 'Auf welchem physikalischen Träger befindet sich das Medium? Z.B. Öl auf Leinwand, PAL, Baryt-Abzug. Auch digitale Formate können genannt werden.');
INSERT INTO meta_terms VALUES (264, 'Date of creation of media object', 'Datum der Erstellung des Medienobjektes resp. der Datei. Wann wurde die Fotografie aufgenommen oder das Computerrendering erzeugt? - Das Erstelldatum des Medienobjekts kann verschieden sein zur Datierung des Werkes.');
INSERT INTO meta_terms VALUES (265, 'Date of creation of media object', 'Datum der Erstellung des Medienobjektes resp. der Datei. Wann wurde die Fotografie aufgenommen oder das Computerrendering erzeugt? - Das Erstellungsdatum des Medienobjekts kann verschieden sein zur Datierung des Werkes.');
INSERT INTO meta_terms VALUES (266, 'Material / Format', 'Material/Format');
INSERT INTO meta_terms VALUES (267, 'Date of creation of media object', 'Datum der Erstellung des Mediums. Wann wurde die Fotografie aufgenommen oder das Computerrendering erzeugt? - Das Erstellungsdatum des Mediums kann verschieden sein zur Datierung des Werkes.');
INSERT INTO meta_terms VALUES (268, 'Creator of the depicted work', 'Urheber/in des Werkes. Wer hat das Werk erschaffen? Handelt es sich um einen historischen Künstler oder eine zeitgenössische Komponistin? Sind Sie selbst Urheber/in des Werkes? Auch Künstlernamen sind möglich.');
INSERT INTO meta_terms VALUES (269, 'Date of creation of media content (e.g. 1878, 1.3.2003 or Spring semester 2011) - not of the media file.', 'Datum der Erschaffung des Werkes (z.B. 1878, 2.3.2008 oder Frühlingssemester 2011) - Nicht das Datum, an dem die Datei oder das Medium der Abbildung oder der Wiedergabe des Werkes entstanden ist.');
INSERT INTO meta_terms VALUES (270, 'General category of the art portrayed', 'Allgemeine Gattung der Kunst. In welchem künstlerischen Medium artikuliert sich das Werk? Welche künstlerischen Mittel werden zum Ausdruck genutzt?');
INSERT INTO meta_terms VALUES (271, 'Public Caption - For use in the media and press.', 'Bildunterschrift, die nur für einen bestimmten Kontext Gültigkeit hat, z.B. für eine Publikation in einem Jahrbuch, durch die Presse oder auf einer Website. - Die Bildlegende ist nicht identisch mit dem Titel des Werks.');
INSERT INTO meta_terms VALUES (272, 'Remarks about the Media Entry.', 'Hier können Sie eine ausführliche Beschreibung des Werkes einfügen.');
INSERT INTO meta_terms VALUES (273, 'Remarks about the Media Entry.', 'Bemerkungen zum Werk können individuell, projektbezogen oder vorläufig sein. ');
INSERT INTO meta_terms VALUES (274, 'Date Created', 'Datierung');
INSERT INTO meta_terms VALUES (275, 'Date of creation of media content (e.g. 1878, 1.3.2003 or Spring semester 2011) - not of the media file.', '');
INSERT INTO meta_terms VALUES (276, 'The title of the work', '');
INSERT INTO meta_terms VALUES (278, 'Keywords describing the media entry content', '');
INSERT INTO meta_terms VALUES (279, 'Copyright owner', '');
INSERT INTO meta_terms VALUES (280, 'Author of the set.', '');
INSERT INTO meta_terms VALUES (281, 'Title of the set.', '');
INSERT INTO meta_terms VALUES (282, 'Date of creation of the set (e.g. 1.3.2003 or spring semester 2011) - not of the media files.', '');
INSERT INTO meta_terms VALUES (283, '', 'Um was für eine Art von Arbeit handelt es sich bei dem Werk? In welchem Zusammenhang steht es zu Lehre und Forschung an der ZHdK?');
INSERT INTO meta_terms VALUES (284, 'Core', 'Core');
INSERT INTO meta_terms VALUES (285, 'TMS', 'TMS');
INSERT INTO meta_terms VALUES (286, 'IO Interface', 'IO Interface');
INSERT INTO meta_terms VALUES (287, 'Media Content', 'Media Content');
INSERT INTO meta_terms VALUES (288, 'Media Object', 'Media Object');
INSERT INTO meta_terms VALUES (289, 'Album', 'Album');
INSERT INTO meta_terms VALUES (290, 'Upload', 'Upload');
INSERT INTO meta_terms VALUES (291, 'ZHdK-Bereich', 'ZHdK-Bereich');
INSERT INTO meta_terms VALUES (292, 'MIZ-Archiv', 'MIZ-Archiv');
INSERT INTO meta_terms VALUES (293, 'Media Content', 'Werk');
INSERT INTO meta_terms VALUES (294, 'Media Object', 'Medium');
INSERT INTO meta_terms VALUES (295, 'Album', 'Set');
INSERT INTO meta_terms VALUES (296, 'Copyright', 'Credits');
INSERT INTO meta_terms VALUES (297, 'ZHdK', 'ZHdK');
INSERT INTO meta_terms VALUES (298, 'Credits', 'Credits');
INSERT INTO meta_terms VALUES (299, 'Set', 'Set');
INSERT INTO meta_terms VALUES (300, 'project title', 'Projekttitel');
INSERT INTO meta_terms VALUES (301, '', 'Ist das Werk im Kontext eines Projektes entstanden? Wie lautet der Titel dieses Projektes? Das kann eine Lehrveranstaltung, ein Forschungsprojekt oder eine persönliche Arbeit sein.');
INSERT INTO meta_terms VALUES (302, 'Keywords', 'Schlagworte zu Inhalt und Motiv');
INSERT INTO meta_terms VALUES (303, 'Title', 'Titel des Sets');
INSERT INTO meta_terms VALUES (304, 'only MIZ-Archive', 'nur MIZ-Archiv');
INSERT INTO meta_terms VALUES (305, '', 'Projekttitel');
INSERT INTO meta_terms VALUES (306, '', 'Titel/Projekttitel');
INSERT INTO meta_terms VALUES (307, '', 'UrheberIn');
INSERT INTO meta_terms VALUES (308, '', 'Offen für Internet');
INSERT INTO meta_terms VALUES (309, '', 'public access=1');
INSERT INTO meta_terms VALUES (310, '', 'Bereich');
INSERT INTO meta_terms VALUES (311, '', 'Datierung');
INSERT INTO meta_terms VALUES (312, 'MIZ-Archiv', 'MIZ-Archiv_alt');
INSERT INTO meta_terms VALUES (313, '', 'Titel/Projektname');
INSERT INTO meta_terms VALUES (314, '', 'Kurzbeschreibung');
INSERT INTO meta_terms VALUES (315, '', 'Datierung/Darstellungsdatum');
INSERT INTO meta_terms VALUES (316, '', 'Stichworte');
INSERT INTO meta_terms VALUES (317, 'type', 'Gattung');
INSERT INTO meta_terms VALUES (318, '', 'Legende');
INSERT INTO meta_terms VALUES (319, '', 'Web-Link');
INSERT INTO meta_terms VALUES (320, '', 'Porträtierte Person');
INSERT INTO meta_terms VALUES (321, '', 'Beteiligte Personen');
INSERT INTO meta_terms VALUES (322, '', 'Beteiligte Institution');
INSERT INTO meta_terms VALUES (323, '', 'Auftraggeber');
INSERT INTO meta_terms VALUES (324, '', 'Projektleitung');
INSERT INTO meta_terms VALUES (325, '', 'FotografIn');
INSERT INTO meta_terms VALUES (326, '', 'Weitere Personen');
INSERT INTO meta_terms VALUES (327, '', 'Rechte');
INSERT INTO meta_terms VALUES (328, '', 'Art der Objektrechte');
INSERT INTO meta_terms VALUES (329, '', 'Einschränkungen');
INSERT INTO meta_terms VALUES (330, '', 'Verwaltet durch');
INSERT INTO meta_terms VALUES (331, '', 'Bemaßungsetikett');
INSERT INTO meta_terms VALUES (332, 'material/format', 'Material/Format');
INSERT INTO meta_terms VALUES (333, '', 'Material/Technik');
INSERT INTO meta_terms VALUES (334, '', 'Standort/Aufführungsort');
INSERT INTO meta_terms VALUES (335, '', 'Geografie');
INSERT INTO meta_terms VALUES (336, '', 'Stadt');
INSERT INTO meta_terms VALUES (337, '', 'Kanton/Bundesland');
INSERT INTO meta_terms VALUES (338, '', 'Land');
INSERT INTO meta_terms VALUES (339, '', 'ISO-Ländercode');
INSERT INTO meta_terms VALUES (340, 'Grundstudium Diplom', 'Grundstudium Diplom');
INSERT INTO meta_terms VALUES (341, 'Hauptstudium Diplom', 'Hauptstudium Diplom');
INSERT INTO meta_terms VALUES (342, '', 'Letzte Aktualisierung durch');
INSERT INTO meta_terms VALUES (343, '', 'ErfasserIn');
INSERT INTO meta_terms VALUES (344, '', 'Medienart');
INSERT INTO meta_terms VALUES (345, 'Uploaded by', 'Hochgeladen von / am');
INSERT INTO meta_terms VALUES (346, '', 'Public access');
INSERT INTO meta_terms VALUES (347, '', 'Hochgeladen am');
INSERT INTO meta_terms VALUES (348, 'description author', 'Beschreibung durch');
INSERT INTO meta_terms VALUES (349, '', 'Beschreibung durch');
INSERT INTO meta_terms VALUES (350, '', 'Erfasser/in');
INSERT INTO meta_terms VALUES (351, '', 'Beschreibung durch (vor dem Import ins Medienarchiv)');
INSERT INTO meta_terms VALUES (352, '', 'Erfasser/in (vor dem Import ins Medienarchiv)');
INSERT INTO meta_terms VALUES (353, '', 'Beschreibung durch (vor dem Kopieren fürs MIZ-Archiv)');
INSERT INTO meta_terms VALUES (354, '', 'Erfasser/in (vor dem vor dem Kopieren fürs MIZ-Achiv)');
INSERT INTO meta_terms VALUES (355, '', 'Beschreibung durch (vor dem Hochladen ins Medienarchiv)');
INSERT INTO meta_terms VALUES (356, '', 'Erfasser/in (vor dem Hochladen ins Medienarchiv)');
INSERT INTO meta_terms VALUES (357, '', 'In welchem Zusammenhang steht das Werk zu Lehre und Forschung an der ZHdK? Was für ein Typ ist das Werk?');
INSERT INTO meta_terms VALUES (358, '', 'In welchem Zusammenhang steht das Werk zu Lehre und Forschung an der ZHdK?');
INSERT INTO meta_terms VALUES (359, '', 'Eingabeformat: http://www.beispiel.ch [Datum des letzten Zugriffs]');
INSERT INTO meta_terms VALUES (360, '', 'Gibt es auf einer Internetseite weitere Informationen zum Werk? Ist es etwa Bestandteil einer Internetanwendung? Oder besteht eine Projektwebsite? Bitte fügen Sie unbedingt das Datum des letzten Zugriffs hinzu!');
INSERT INTO meta_terms VALUES (361, 'Copyright owner', 'Besitzer/in der Nutzungs- und Verwertungsrechte. Diese können z.B. beim Autor/Urheber des Werkes oder bei einer Institution liegen. Bei Werken, die an der ZHdK in Lehre und Forschung entstanden sind, liegt ohne Sonderregelung das Copyright bei der ZHdK.');
INSERT INTO meta_terms VALUES (362, '', 'Eingabevorschläge: z.B. Videostill, Öl auf Leinwand, PAL, Baryt-Abzug');
INSERT INTO meta_terms VALUES (363, 'e.g. Oil on Canvas, PAL, Paper', 'Auf welchem physikalischen Träger befindet sich das Medium? Auch digitale Formate können genannt werden.');
INSERT INTO meta_terms VALUES (364, '', 'Name oder Institution: z.B. Barbara Beispiel, Archiv der Künste Zürich, unbekannt');
INSERT INTO meta_terms VALUES (365, '', 'Unter welchen Bedingungen ist die Nutzung des Werkes erlaubt?');
INSERT INTO meta_terms VALUES (366, '', 'Name oder Institution: z.B. ZHdK MIZ, Agentur für Medien Zürich, Archiv Prof. Müller');
INSERT INTO meta_terms VALUES (367, 'Copyright URL for detailed description of usage rights of the work.', 'Internetlink zur detaillierten Beschreibung der Nutzungsbedingungen wie z.B. Lizenztexte und Publikationsdisclaimer. Bitte fügen Sie unbedingt das Datum des letzten Zugriffs hinzu!');
INSERT INTO meta_terms VALUES (368, '', 'Autor/in der Metadaten. Wer hat die Verschlagwortung im Medienarchiv vorgenommen?');
INSERT INTO meta_terms VALUES (369, '', 'Autor/in der Metadaten. Wer hat die Verschlagwortung vorgenommen, bevor das File ins Medienarchiv geladen wurde?');
INSERT INTO meta_terms VALUES (370, '', 'Autor/in der Metadaten. Wer hat die Verschlagwortung im Medienarchiv vorgenommen, bevor eine Kopie fürs MIZ-Archiv erstellt wurde?');
INSERT INTO meta_terms VALUES (371, '', 'Autor/in der Metadaten. Wer hat die Verschlagwortung der vorliegenden Kopie fürs MIZ-Archiv vorgenommen?');
INSERT INTO meta_terms VALUES (372, '', 'Urheber/in der Werke des Sets. Wer hat diese erschaffen? Handelt es sich um einen historischen Künstler oder eine zeitgenössische Komponistin? Sind Sie selbst Urheber/in der Werke? Auch Künstlernamen sind möglich.');
INSERT INTO meta_terms VALUES (373, '', 'Titel des Sets ODER Titel der gesammelten Werke des Sets');
INSERT INTO meta_terms VALUES (374, '', 'Sind die Werkw im Kontext eines Projektes entstanden? Wie lautet der Titel dieses Projektes? Das kann eine Lehrveranstaltung, ein Forschungsprojekt oder eine persönliche Arbeit sein.');
INSERT INTO meta_terms VALUES (375, '', 'Sind die Werke im Kontext eines Projektes entstanden? Wie lautet der Titel dieses Projektes? Das kann eine Lehrveranstaltung, ein Forschungsprojekt oder eine persönliche Arbeit sein.');
INSERT INTO meta_terms VALUES (537, 'Helligkeit hinten', 'Helligkeit hinten');
INSERT INTO meta_terms VALUES (376, 'Date of creation of the set (e.g. 1.3.2003 or spring semester 2011) - not of the media files.', 'Datum der Erschaffung der zusammengestellten Werke (z.B. 1878, 2.3.2008 oder Frühlingssemester 2011) - Nicht das Datum, an dem die Datei oder das Medium der Abbildung oder der Wiedergabe des Werkes entstanden ist.');
INSERT INTO meta_terms VALUES (377, '', 'Schlagworte zu Inhalt und Motiv der zusammengestellten Werke. Was ist zu sehen oder zu hören? Welche Themen behandeln die Werke?');
INSERT INTO meta_terms VALUES (378, '', 'Hier können Sie eine ausführliche Beschreibung des Werkes einfügen.');
INSERT INTO meta_terms VALUES (379, '', 'Set bearbeitet durch');
INSERT INTO meta_terms VALUES (380, '', 'Autor/in des Sets. Wer hat die Zusammenstellung und Verschlagwortung des Sets vorgenommen?');
INSERT INTO meta_terms VALUES (381, '', 'Set zusammengestellt durch');
INSERT INTO meta_terms VALUES (382, '', 'Hier können Sie eine ausführliche Beschreibung der Werke oder des Sets einfügen.');
INSERT INTO meta_terms VALUES (383, '', 'Zusammenstellung durch');
INSERT INTO meta_terms VALUES (384, '', 'Der Titel des Sets bezeichnet entweder die enthaltene Zusammenstellung der Werke (z.B. Vorlesung "Internationale Kunstpraxis") oder den Titel des Werkes, das darin in mehreren Ansichten zu sehen ist (z.B. Grossmünster Zürich).');
INSERT INTO meta_terms VALUES (385, 'Date of creation of the set (e.g. 1.3.2003 or spring semester 2011) - not of the media files.', 'Datum der Erschaffung der zusammengestellten Werke (z.B. 1878, 2.3.2008 oder Frühlingssemester 2011)');
INSERT INTO meta_terms VALUES (386, '', 'Urheber/in der Werke, die in dem Sets gruppiert sind. Wer hat diese erschaffen? Handelt es sich um einen historischen Künstler oder eine zeitgenössische Komponistin? Sind Sie selbst Urheber/in der Werke? Auch Künstlernamen sind möglich.');
INSERT INTO meta_terms VALUES (387, '', 'Sind die zusammengestellte Werke oder das Set im Kontext eines Projektes entstanden? Wie lautet der Titel dieses Projektes? Das kann eine Lehrveranstaltung, ein Forschungsprojekt oder eine persönliche Arbeit sein.');
INSERT INTO meta_terms VALUES (388, '', 'Sind die zusammengestellten Werke oder ist das Set im Kontext eines Projektes entstanden? Wie lautet der Titel dieses Projektes? Das kann eine Lehrveranstaltung, ein Forschungsprojekt oder eine persönliche Arbeit sein.');
INSERT INTO meta_terms VALUES (389, 'Date of creation of the set (e.g. 1.3.2003 or spring semester 2011) - not of the media files.', 'Datum der Zusammenstellung des Sets (z.B. Frühlingssemester 2011) oder der Erschaffung der Werke (z.B. 1878, 2.3.2008).');
INSERT INTO meta_terms VALUES (390, '', 'Schlagworte zur Zusammenstellung der Werke als Set bzw. zu Inhalt und Motiv der einzelnen Werke. Was ist zu sehen oder zu hören? Welche Themen behandeln das Set bzw. welche die Werke?');
INSERT INTO meta_terms VALUES (391, '', 'Hier können Sie eine ausführliche Beschreibung des Sets oder der Werke einfügen.');
INSERT INTO meta_terms VALUES (392, 'Author', 'Autor/in der Werke');
INSERT INTO meta_terms VALUES (393, '', 'Erstellt von');
INSERT INTO meta_terms VALUES (394, '', 'Erstellt am');
INSERT INTO meta_terms VALUES (395, '', 'Der Titel des Sets bezeichnet die Zusammenstellung der Medieneinträge.');
INSERT INTO meta_terms VALUES (396, 'Author', 'Autor/in des Sets');
INSERT INTO meta_terms VALUES (397, '', 'Wer hat das Set zusammengestellt?');
INSERT INTO meta_terms VALUES (398, '', 'Schlagworte zum Set bzw. zu Inhalt und Motiv der einzelnen Werke. Was ist zu sehen oder zu hören? Welche Themen behandeln das Set bzw. welche die Werke?');
INSERT INTO meta_terms VALUES (399, '', 'Hier können Sie eine ausführliche Beschreibung des Sets einfügen.');
INSERT INTO meta_terms VALUES (400, '', 'Schlagworte zum Set. Was ist zu sehen oder zu hören? Welche Themen behandelt das Set?');
INSERT INTO meta_terms VALUES (401, '', 'Wer hat die Zusammenstellung und Verschlagwortung des Sets vorgenommen?');
INSERT INTO meta_terms VALUES (403, 'madek core Inhalt und Motiv (bezieht sich auf den Medieninhalt)', 'madek core Inhalt und Motiv (bezieht sich auf den Medieninhalt)');
INSERT INTO meta_terms VALUES (405, 'Diplomarbeit', 'Diplomarbeit');
INSERT INTO meta_terms VALUES (407, 'Portrait', 'Portrait');
INSERT INTO meta_terms VALUES (409, 'Menschenbild', 'Menschenbild');
INSERT INTO meta_terms VALUES (411, 'Buch', 'Buch');
INSERT INTO meta_terms VALUES (413, 'Intimität', 'Intimität');
INSERT INTO meta_terms VALUES (415, 'Sticker', 'Sticker');
INSERT INTO meta_terms VALUES (417, 'madek Inhalt', 'madek Inhalt');
INSERT INTO meta_terms VALUES (419, 'Stefanie Ammann - Portrait aus der Serie Studentenportraits fürs Zett', 'Stefanie Ammann - Portrait aus der Serie Studentenportraits fürs Zett');
INSERT INTO meta_terms VALUES (421, 'irgendwas', 'irgendwas');
INSERT INTO meta_terms VALUES (423, 'Hase', 'Hase');
INSERT INTO meta_terms VALUES (425, 'Rüebli', 'Rüebli');
INSERT INTO meta_terms VALUES (427, 'Tanne', 'Tanne');
INSERT INTO meta_terms VALUES (429, 'Sonne', 'Sonne');
INSERT INTO meta_terms VALUES (431, 'Blumen', 'Blumen');
INSERT INTO meta_terms VALUES (433, 'Wiese', 'Wiese');
INSERT INTO meta_terms VALUES (435, 'Wolken', 'Wolken');
INSERT INTO meta_terms VALUES (437, 'dies und das', 'dies und das');
INSERT INTO meta_terms VALUES (439, 'Shanghai Weltausstellung 2010', 'Shanghai Weltausstellung 2010');
INSERT INTO meta_terms VALUES (441, 'Shanghai Weltausstellung', 'Shanghai Weltausstellung');
INSERT INTO meta_terms VALUES (443, 'Bucht', 'Bucht');
INSERT INTO meta_terms VALUES (445, 'Berlin', 'Berlin');
INSERT INTO meta_terms VALUES (447, 'Landschaft', 'Landschaft');
INSERT INTO meta_terms VALUES (449, 'Aufsicht', 'Aufsicht');
INSERT INTO meta_terms VALUES (451, 'Landschaftsvisualisierung', 'Landschaftsvisualisierung');
INSERT INTO meta_terms VALUES (453, 'Park', 'Park');
INSERT INTO meta_terms VALUES (455, 'Ponton', 'Ponton');
INSERT INTO meta_terms VALUES (457, 'Jahresausstellung', 'Jahresausstellung');
INSERT INTO meta_terms VALUES (459, 'See', 'See');
INSERT INTO meta_terms VALUES (461, 'Fluss', 'Fluss');
INSERT INTO meta_terms VALUES (463, 'Deich', 'Deich');
INSERT INTO meta_terms VALUES (465, 'Farn', 'Farn');
INSERT INTO meta_terms VALUES (467, 'Gras', 'Gras');
INSERT INTO meta_terms VALUES (469, 'Helikopter', 'Helikopter');
INSERT INTO meta_terms VALUES (471, 'Feuer', 'Feuer');
INSERT INTO meta_terms VALUES (473, 'Vernissage', 'Vernissage');
INSERT INTO meta_terms VALUES (475, 'Museum für Gestaltung', 'Museum für Gestaltung');
INSERT INTO meta_terms VALUES (477, 'Farbe', 'Farbe');
INSERT INTO meta_terms VALUES (479, 'Indien', 'Indien');
INSERT INTO meta_terms VALUES (481, 'Reise', 'Reise');
INSERT INTO meta_terms VALUES (483, 'Pigmente', 'Pigmente');
INSERT INTO meta_terms VALUES (485, 'Sexualität', 'Sexualität');
INSERT INTO meta_terms VALUES (487, 'Liebe', 'Liebe');
INSERT INTO meta_terms VALUES (489, 'Körper', 'Körper');
INSERT INTO meta_terms VALUES (491, 'Macht', 'Macht');
INSERT INTO meta_terms VALUES (493, 'Linienfuehrung diagonal', 'Linienfuehrung diagonal');
INSERT INTO meta_terms VALUES (495, 'Linienfuehrung vertikal', 'Linienfuehrung vertikal');
INSERT INTO meta_terms VALUES (497, 'perspektivische Konvergenz', 'perspektivische Konvergenz');
INSERT INTO meta_terms VALUES (499, 'relative Groesse', 'relative Groesse');
INSERT INTO meta_terms VALUES (501, 'relative Hoehe', 'relative Hoehe');
INSERT INTO meta_terms VALUES (503, 'Schatten', 'Schatten');
INSERT INTO meta_terms VALUES (505, 'print', 'print');
INSERT INTO meta_terms VALUES (507, 'Landschaftsmalerei', 'Landschaftsmalerei');
INSERT INTO meta_terms VALUES (509, 'aus Harenberg Museum der Malerei', 'aus Harenberg Museum der Malerei');
INSERT INTO meta_terms VALUES (511, 'Ebenen', 'Ebenen');
INSERT INTO meta_terms VALUES (513, 'Farbigkeit vorne', 'Farbigkeit vorne');
INSERT INTO meta_terms VALUES (515, 'Figur Grund', 'Figur Grund');
INSERT INTO meta_terms VALUES (517, 'Linienfuehrung horizontal', 'Linienfuehrung horizontal');
INSERT INTO meta_terms VALUES (519, 'Prinzip Aehnlichkeit', 'Prinzip Aehnlichkeit');
INSERT INTO meta_terms VALUES (521, 'Prinzip Naehe', 'Prinzip Naehe');
INSERT INTO meta_terms VALUES (523, 'Prinzip Nähe', 'Prinzip Nähe');
INSERT INTO meta_terms VALUES (525, 'Prinzip Ähnlichkeit', 'Prinzip Ähnlichkeit');
INSERT INTO meta_terms VALUES (527, 'Strukturreichtum vorne', 'Strukturreichtum vorne');
INSERT INTO meta_terms VALUES (529, 'Vorder- Hintergrund', 'Vorder- Hintergrund');
INSERT INTO meta_terms VALUES (531, 'Prinzip gute Fortsetzung', 'Prinzip gute Fortsetzung');
INSERT INTO meta_terms VALUES (533, 'Dunkelheit vorne', 'Dunkelheit vorne');
INSERT INTO meta_terms VALUES (535, 'Durchgang', 'Durchgang');
INSERT INTO meta_terms VALUES (539, 'Kontrast vorne', 'Kontrast vorne');
INSERT INTO meta_terms VALUES (541, 'Schaerfe vorne', 'Schaerfe vorne');
INSERT INTO meta_terms VALUES (543, 'Unschaerfe hinten', 'Unschaerfe hinten');
INSERT INTO meta_terms VALUES (545, 'Vorder-Mittelgrund', 'Vorder-Mittelgrund');
INSERT INTO meta_terms VALUES (547, 'Luftperspektive', 'Luftperspektive');
INSERT INTO meta_terms VALUES (549, 'Verblauung', 'Verblauung');
INSERT INTO meta_terms VALUES (551, 'Symmetrie', 'Symmetrie');
INSERT INTO meta_terms VALUES (553, 'Texturgradient', 'Texturgradient');
INSERT INTO meta_terms VALUES (555, 'Buch gemalte Gärten', 'Buch gemalte Gärten');
INSERT INTO meta_terms VALUES (557, 'Verdeckung, Staffelung', 'Verdeckung, Staffelung');
INSERT INTO meta_terms VALUES (559, 'Vorder-Mittel-Hintergrund', 'Vorder-Mittel-Hintergrund');
INSERT INTO meta_terms VALUES (561, 'kalt warm', 'kalt warm');
INSERT INTO meta_terms VALUES (563, 'Linienführung diagonal', 'Linienführung diagonal');
INSERT INTO meta_terms VALUES (565, 'Prinzip gemeinsames Schicksal', 'Prinzip gemeinsames Schicksal');
INSERT INTO meta_terms VALUES (567, 'Staffelung', 'Staffelung');
INSERT INTO meta_terms VALUES (569, 'Ungewoehnliche Perspektive', 'Ungewoehnliche Perspektive');
INSERT INTO meta_terms VALUES (571, 'Vogelschau', 'Vogelschau');
INSERT INTO meta_terms VALUES (573, 'Vogelschauperspektive', 'Vogelschauperspektive');
INSERT INTO meta_terms VALUES (575, 'hell dunkel', 'hell dunkel');
INSERT INTO meta_terms VALUES (577, 'Perspektive', 'Perspektive');
INSERT INTO meta_terms VALUES (579, 'Schärfe vorne', 'Schärfe vorne');
INSERT INTO meta_terms VALUES (581, 'Gegenlicht', 'Gegenlicht');
INSERT INTO meta_terms VALUES (583, 'Horizont tief', 'Horizont tief');
INSERT INTO meta_terms VALUES (585, 'Optischer Rahmen', 'Optischer Rahmen');
INSERT INTO meta_terms VALUES (587, 'Goldener Schnitt', 'Goldener Schnitt');
INSERT INTO meta_terms VALUES (589, 'Linienführung horizontal', 'Linienführung horizontal');
INSERT INTO meta_terms VALUES (591, 'Linienführung vertikal', 'Linienführung vertikal');
INSERT INTO meta_terms VALUES (593, 'Horizont hoch', 'Horizont hoch');
INSERT INTO meta_terms VALUES (595, 'relative Grösse', 'relative Grösse');
INSERT INTO meta_terms VALUES (597, 'relative Höhe', 'relative Höhe');
INSERT INTO meta_terms VALUES (599, 'Vorder-Hintergrund', 'Vorder-Hintergrund');
INSERT INTO meta_terms VALUES (601, 'Prinzip Vertrautheit', 'Prinzip Vertrautheit');
INSERT INTO meta_terms VALUES (603, 'Schweizer Maler', 'Schweizer Maler');
INSERT INTO meta_terms VALUES (605, 'von Anker bis Zünd', 'von Anker bis Zünd');
INSERT INTO meta_terms VALUES (607, 'Linienführung Vertikale', 'Linienführung Vertikale');
INSERT INTO meta_terms VALUES (609, 'Unschärfe hinten', 'Unschärfe hinten');
INSERT INTO meta_terms VALUES (611, 'Prinzip der guten Fortsetzung', 'Prinzip der guten Fortsetzung');
INSERT INTO meta_terms VALUES (613, 'Garten', 'Garten');
INSERT INTO meta_terms VALUES (615, 'Unschärfe hinen', 'Unschärfe hinen');
INSERT INTO meta_terms VALUES (617, 'Mittel- Hintergrund', 'Mittel- Hintergrund');
INSERT INTO meta_terms VALUES (619, 'Farbliche Auszeichnung', 'Farbliche Auszeichnung');
INSERT INTO meta_terms VALUES (621, 'Fotomontage', 'Fotomontage');
INSERT INTO meta_terms VALUES (623, 'Reduktion', 'Reduktion');
INSERT INTO meta_terms VALUES (625, 'Abstrakte 3D-Visualisierung', 'Abstrakte 3D-Visualisierung');
INSERT INTO meta_terms VALUES (627, 'Typische 3D-Visualisierung', 'Typische 3D-Visualisierung');
INSERT INTO meta_terms VALUES (629, 'Realitätsnahe 3D-Visualisierung', 'Realitätsnahe 3D-Visualisierung');
INSERT INTO meta_terms VALUES (631, 'Landschaftsplanung', 'Landschaftsplanung');
INSERT INTO meta_terms VALUES (633, 'Umweltplanung', 'Umweltplanung');
INSERT INTO meta_terms VALUES (635, 'Mischtechnik', 'Mischtechnik');
INSERT INTO meta_terms VALUES (637, 'Physikalische Modelle', 'Physikalische Modelle');
INSERT INTO meta_terms VALUES (639, 'Schnitte', 'Schnitte');
INSERT INTO meta_terms VALUES (641, 'Karten', 'Karten');
INSERT INTO meta_terms VALUES (643, 'Pläne', 'Pläne');
INSERT INTO meta_terms VALUES (645, 'Schnitt', 'Schnitt');
INSERT INTO meta_terms VALUES (647, 'Räumliche Zeichnung', 'Räumliche Zeichnung');
INSERT INTO meta_terms VALUES (649, 'Gruppenporträt', 'Gruppenporträt');
INSERT INTO meta_terms VALUES (651, 'Projekt MAdeK', 'Projekt MAdeK');
INSERT INTO meta_terms VALUES (653, 'Leonardo Da Vinci', 'Leonardo Da Vinci');
INSERT INTO meta_terms VALUES (655, 'Konzeptkunst', 'Konzeptkunst');
INSERT INTO meta_terms VALUES (657, 'Beispiel', 'Beispiel');
INSERT INTO meta_terms VALUES (659, 'Verschlagwortung', 'Verschlagwortung');
INSERT INTO meta_terms VALUES (661, 'Medienarchiv', 'Medienarchiv');
INSERT INTO meta_terms VALUES (663, 'Nutzung', 'Nutzung');
INSERT INTO meta_terms VALUES (665, 'digital', 'digital');
INSERT INTO meta_terms VALUES (667, '20. Jahrhundert', '20. Jahrhundert');
INSERT INTO meta_terms VALUES (669, 'Porträt', 'Porträt');
INSERT INTO meta_terms VALUES (671, 'tandoori', 'tandoori');
INSERT INTO meta_terms VALUES (673, 'indian food', 'indian food');
INSERT INTO meta_terms VALUES (675, 'india', 'india');
INSERT INTO meta_terms VALUES (677, 'asia', 'asia');
INSERT INTO meta_terms VALUES (679, 'chili', 'chili');
INSERT INTO meta_terms VALUES (681, 'chili pepper', 'chili pepper');
INSERT INTO meta_terms VALUES (683, 'red', 'red');
INSERT INTO meta_terms VALUES (685, 'ingredient', 'ingredient');
INSERT INTO meta_terms VALUES (687, 'pepper', 'pepper');
INSERT INTO meta_terms VALUES (689, 'paprika', 'paprika');
INSERT INTO meta_terms VALUES (691, 'cumin', 'cumin');
INSERT INTO meta_terms VALUES (693, 'curry', 'curry');
INSERT INTO meta_terms VALUES (695, 'powder', 'powder');
INSERT INTO meta_terms VALUES (697, 'tropical', 'tropical');
INSERT INTO meta_terms VALUES (699, 'exotic', 'exotic');
INSERT INTO meta_terms VALUES (701, 'island', 'island');
INSERT INTO meta_terms VALUES (703, 'sun', 'sun');
INSERT INTO meta_terms VALUES (705, 'vegetable', 'vegetable');
INSERT INTO meta_terms VALUES (707, 'vegetarian', 'vegetarian');
INSERT INTO meta_terms VALUES (709, 'chicken', 'chicken');
INSERT INTO meta_terms VALUES (711, 'lamb', 'lamb');
INSERT INTO meta_terms VALUES (713, 'herbal', 'herbal');
INSERT INTO meta_terms VALUES (715, 'cuisine', 'cuisine');
INSERT INTO meta_terms VALUES (717, 'restaurant', 'restaurant');
INSERT INTO meta_terms VALUES (719, 'hot', 'hot');
INSERT INTO meta_terms VALUES (721, 'background', 'background');
INSERT INTO meta_terms VALUES (723, 'spice', 'spice');
INSERT INTO meta_terms VALUES (725, 'spicy', 'spicy');
INSERT INTO meta_terms VALUES (727, 'healthiness', 'healthiness');
INSERT INTO meta_terms VALUES (729, 'paste', 'paste');
INSERT INTO meta_terms VALUES (731, 'kebab', 'kebab');
INSERT INTO meta_terms VALUES (733, 'yaourt', 'yaourt');
INSERT INTO meta_terms VALUES (735, 'yoghurt', 'yoghurt');
INSERT INTO meta_terms VALUES (737, 'barbecue', 'barbecue');
INSERT INTO meta_terms VALUES (739, 'BBQ', 'BBQ');
INSERT INTO meta_terms VALUES (741, 'blau', 'blau');
INSERT INTO meta_terms VALUES (743, 'Keramik', 'Keramik');
INSERT INTO meta_terms VALUES (745, 'Form', 'Form');
INSERT INTO meta_terms VALUES (747, 'Gussform', 'Gussform');
INSERT INTO meta_terms VALUES (749, 'Volume3', 'Volume3');
INSERT INTO meta_terms VALUES (751, 'BAE', 'BAE');
INSERT INTO meta_terms VALUES (753, 'volume trois', 'volume trois');
INSERT INTO meta_terms VALUES (755, 'Profil Design', 'Profil Design');
INSERT INTO meta_terms VALUES (757, 'LED-ColourLab', 'LED-ColourLab');
INSERT INTO meta_terms VALUES (759, 'Zürcher Hochschule der Künste', 'Zürcher Hochschule der Künste');
INSERT INTO meta_terms VALUES (761, 'FarbLicht', 'FarbLicht');
INSERT INTO meta_terms VALUES (763, 'Gewerbemuseum Winterthur', 'Gewerbemuseum Winterthur');
INSERT INTO meta_terms VALUES (765, 'Farb-Licht Zentrum (FLZ)', 'Farb-Licht Zentrum (FLZ)');
INSERT INTO meta_terms VALUES (767, 'FarbLicht-Muster', 'FarbLicht-Muster');
INSERT INTO meta_terms VALUES (769, 'Bauen', 'Bauen');
INSERT INTO meta_terms VALUES (771, 'Kooperationsprojekt', 'Kooperationsprojekt');
INSERT INTO meta_terms VALUES (773, 'Lebensraum Schule', 'Lebensraum Schule');
INSERT INTO meta_terms VALUES (775, 'Partizipation', 'Partizipation');
INSERT INTO meta_terms VALUES (777, 'Raumgestaltung', 'Raumgestaltung');
INSERT INTO meta_terms VALUES (779, 'Schulische Freizeit', 'Schulische Freizeit');
INSERT INTO meta_terms VALUES (781, 'Untersiggenthal', 'Untersiggenthal');
INSERT INTO meta_terms VALUES (783, 'Zett', 'Zett');
INSERT INTO meta_terms VALUES (785, 'Bildvorschläge', 'Bildvorschläge');
INSERT INTO meta_terms VALUES (787, 'Artikel', 'Artikel');
INSERT INTO meta_terms VALUES (789, 'Medienarchiv der Künste', 'Medienarchiv der Künste');
INSERT INTO meta_terms VALUES (791, 'Workshop', 'Workshop');
INSERT INTO meta_terms VALUES (793, 'Partizipative Designstrategien', 'Partizipative Designstrategien');
INSERT INTO meta_terms VALUES (795, 'Partizipatives Design', 'Partizipatives Design');
INSERT INTO meta_terms VALUES (797, 'Designmethoden', 'Designmethoden');
INSERT INTO meta_terms VALUES (799, 'Partizipative Designtrategien', 'Partizipative Designtrategien');
INSERT INTO meta_terms VALUES (801, 'Screenshot', 'Screenshot');
INSERT INTO meta_terms VALUES (803, 'Interface', 'Interface');
INSERT INTO meta_terms VALUES (805, 'Projektteam', 'Projektteam');
INSERT INTO meta_terms VALUES (807, 'iBrowsing', 'iBrowsing');
INSERT INTO meta_terms VALUES (809, 'Interaktionsformen', 'Interaktionsformen');
INSERT INTO meta_terms VALUES (811, 'Arbeitsfläche', 'Arbeitsfläche');
INSERT INTO meta_terms VALUES (813, 'Wissensanordnung', 'Wissensanordnung');
INSERT INTO meta_terms VALUES (815, 'Visualisierung', 'Visualisierung');
INSERT INTO meta_terms VALUES (817, 'Pra?sentationsformen', 'Pra?sentationsformen');
INSERT INTO meta_terms VALUES (819, 'Seminar', 'Seminar');
INSERT INTO meta_terms VALUES (821, 'Video', 'Video');
INSERT INTO meta_terms VALUES (823, 'Projektion', 'Projektion');
INSERT INTO meta_terms VALUES (825, 'Text', 'Text');
INSERT INTO meta_terms VALUES (827, 'Medienkunst', 'Medienkunst');
INSERT INTO meta_terms VALUES (829, 'Papier', 'Papier');
INSERT INTO meta_terms VALUES (831, 'Material/Medium', 'Material/Medium');
INSERT INTO meta_terms VALUES (833, 'Offsetdruck', 'Offsetdruck');
INSERT INTO meta_terms VALUES (835, 'Druck', 'Druck');
INSERT INTO meta_terms VALUES (837, 'Bildtechnik/Herstellungsverfahren Original', 'Bildtechnik/Herstellungsverfahren Original');
INSERT INTO meta_terms VALUES (839, 'Tortendiagramm', 'Tortendiagramm');
INSERT INTO meta_terms VALUES (841, 'Diagrammatisch', 'Diagrammatisch');
INSERT INTO meta_terms VALUES (843, 'Darstellungsmodus/graphische Methode', 'Darstellungsmodus/graphische Methode');
INSERT INTO meta_terms VALUES (845, 'Fachpresse', 'Fachpresse');
INSERT INTO meta_terms VALUES (847, 'Presse/Medien', 'Presse/Medien');
INSERT INTO meta_terms VALUES (849, 'Gebrauchskontext', 'Gebrauchskontext');
INSERT INTO meta_terms VALUES (851, 'populärwissenschaftliches Sachbuch', 'populärwissenschaftliches Sachbuch');
INSERT INTO meta_terms VALUES (853, 'Veranschaulichung', 'Veranschaulichung');
INSERT INTO meta_terms VALUES (855, 'Funktion', 'Funktion');
INSERT INTO meta_terms VALUES (857, 'Popularisierung', 'Popularisierung');
INSERT INTO meta_terms VALUES (859, 'Klimatologie', 'Klimatologie');
INSERT INTO meta_terms VALUES (861, 'Disziplinärer Hintergrund', 'Disziplinärer Hintergrund');
INSERT INTO meta_terms VALUES (863, 'Kurve/Graph', 'Kurve/Graph');
INSERT INTO meta_terms VALUES (865, 'Temperatur', 'Temperatur');
INSERT INTO meta_terms VALUES (867, 'Motiv', 'Motiv');
INSERT INTO meta_terms VALUES (869, 'Emissionen/Atmosphäre/Luft', 'Emissionen/Atmosphäre/Luft');
INSERT INTO meta_terms VALUES (871, 'Karte', 'Karte');
INSERT INTO meta_terms VALUES (873, 'Farbskala', 'Farbskala');
INSERT INTO meta_terms VALUES (875, 'Farbigkeit', 'Farbigkeit');
INSERT INTO meta_terms VALUES (877, 'Balkendiagramm', 'Balkendiagramm');
INSERT INTO meta_terms VALUES (879, 'Anderes', 'Anderes');
INSERT INTO meta_terms VALUES (881, 'wasserfarben', 'wasserfarben');
INSERT INTO meta_terms VALUES (883, 'haus', 'haus');
INSERT INTO meta_terms VALUES (885, 'zeichnung', 'zeichnung');
INSERT INTO meta_terms VALUES (887, 'Klima', 'Klima');
INSERT INTO meta_terms VALUES (889, 'Grafik', 'Grafik');
INSERT INTO meta_terms VALUES (891, 'Statistik', 'Statistik');
INSERT INTO meta_terms VALUES (893, 'test', 'test');
INSERT INTO meta_terms VALUES (895, 'Dialog', 'Dialog');
INSERT INTO meta_terms VALUES (897, 'Palaver', 'Palaver');
INSERT INTO meta_terms VALUES (899, 'Installation', 'Installation');
INSERT INTO meta_terms VALUES (901, 'Performance', 'Performance');
INSERT INTO meta_terms VALUES (903, 'Closed Circuit', 'Closed Circuit');
INSERT INTO meta_terms VALUES (905, 'knowbotic research', 'knowbotic research');
INSERT INTO meta_terms VALUES (907, 'Inszenierungen', 'Inszenierungen');
INSERT INTO meta_terms VALUES (909, 'Creator of the depicted work', 'Urheber/in des Werkes. Wer hat das Werk erschaffen? Handelt es sich um einen historischen Künstler oder eine zeitgenössische Komponistin? Sind Sie selbst Urheber/in des Werkes? Auch Pseudonyme und Personengruppen (z.B. Künstlergruppen, Ateliers, Firmen) s');
INSERT INTO meta_terms VALUES (911, 'Creator of the depicted work', 'Urheber/in des Werkes. Wer hat das Werk erschaffen? Handelt es sich um einen historischen Künstler oder eine zeitgenössische Komponistin? Sind Sie selbst Urheber/in des Werkes? Auch Pseudonyme und Personengruppen (z.B. Künstlergruppen, Ateliers, Firmen) s');
INSERT INTO meta_terms VALUES (913, 'Creator of the depicted work', 'Urheber/in des Werkes. Wer hat das Werk erschaffen? Handelt es sich um einen historischen Künstler oder eine zeitgenössische Komponistin? Sind Sie selbst Urheber/in? Auch Pseudonyme und Personengruppen (z.B. Künstlergruppen, Ateliers, Firmen) sind möglich');
INSERT INTO meta_terms VALUES (915, 'Creator of the depicted work', 'Urheber/in des Werkes. Wer hat das Werk erschaffen? Handelt es sich um einen historischen Künstler oder eine zeitgenössische Komponistin? Sind Sie selbst Urheber/in? Auch Pseudonyme und Personengruppen (z.B. Künstlergruppen, Ateliers, Firmen) sind möglich');
INSERT INTO meta_terms VALUES (917, 'Creator of the depicted work', 'Urheber/in des Werkes. Wer hat das Werk erschaffen? Handelt es sich um einen historischen Künstler oder eine zeitgenössische Komponistin? Sind Sie selbst Urheber/in? Auch Pseudonyme und Personengruppen (z.B. Künstlergruppe, Atelier, Firma) sind möglich.');
INSERT INTO meta_terms VALUES (919, 'Projects ZHdK', 'Projekte ZHdK');
INSERT INTO meta_terms VALUES (921, 'Ausstellung Museum für Gestaltung', 'Ausstellung Museum für Gestaltung');
INSERT INTO meta_terms VALUES (923, 'Cynthia Gavranic', 'Cynthia Gavranic');
INSERT INTO meta_terms VALUES (925, 'ExoMars', 'ExoMars');
INSERT INTO meta_terms VALUES (927, 'Roboter - Von Motion zu Emotion', 'Roboter - Von Motion zu Emotion');
INSERT INTO meta_terms VALUES (929, 'Date of creation of media content - not of the media file.', 'Datum der Erschaffung des Werkes - nicht das Datum, an dem die Datei oder das Medium der Abbildung / der Wiedergabe des Werkes entstanden ist. Eingabe einer Zeitspanne: Leerzeichen Bindestrich Leerzeichen / " - ".');
INSERT INTO meta_terms VALUES (931, 'Date of creation of media content - not of the media file.', 'Datum der Erschaffung des Werkes - nicht das Datum, an dem die Datei oder das Medium der Abbildung / der Wiedergabe entstanden ist. Eingabe einer Zeitspanne: Leerzeichen Bindestrich Leerzeichen / " - ".');
INSERT INTO meta_terms VALUES (933, 'Date of creation of media content - not of the media file.', 'Datum der Erschaffung des Werkes - nicht das Datum, an dem die Datei oder das Medium der Abbildung / der Wiedergabe entstanden ist.
Eingabe einer Zeitspanne: Leerzeichen Bindestrich Leerzeichen / " - ".');
INSERT INTO meta_terms VALUES (935, 'Date of creation of media content - not of the media file.', 'Datum der Erschaffung des Werkes - nicht das Datum, an dem die Datei oder das Medium der Abbildung / der Wiedergabe entstanden ist.
Eingabe einer Zeitspanne: 1923 - 1929 (Leerzeichen Bindestrich Leerzeichen).');
INSERT INTO meta_terms VALUES (937, '', 'Wenn vorhanden, wird das Kamera-Datum angezeigt.');
INSERT INTO meta_terms VALUES (939, 'Polizei- & Fahndungsfotografie', 'Polizei- & Fahndungsfotografie');
INSERT INTO meta_terms VALUES (941, 'Selbstportrait', 'Selbstportrait');
INSERT INTO meta_terms VALUES (947, 'Stichwörter', 'Stichwörter');
INSERT INTO meta_terms VALUES (949, 'Projektdokumentation', 'Projektdokumentation');
INSERT INTO meta_terms VALUES (951, 'Sachaufnahme', 'Sachaufnahme');
INSERT INTO meta_terms VALUES (953, 'Bachelor-Diplom  Industrial Design 2010', 'Bachelor-Diplom  Industrial Design 2010');
INSERT INTO meta_terms VALUES (955, 'Ausstellungsdokumentation', 'Ausstellungsdokumentation');
INSERT INTO meta_terms VALUES (957, 'who is who', 'who is who');
INSERT INTO meta_terms VALUES (959, 'Gruppenportrait', 'Gruppenportrait');
INSERT INTO meta_terms VALUES (961, 'Zett 2-10', 'Zett 2-10');
INSERT INTO meta_terms VALUES (963, 'Toni Areal', 'Toni Areal');
INSERT INTO meta_terms VALUES (965, 'Opening Scene', 'Opening Scene');
INSERT INTO meta_terms VALUES (967, 'Studentenportaits', 'Studentenportaits');
INSERT INTO meta_terms VALUES (969, 'Zett 1-10', 'Zett 1-10');
INSERT INTO meta_terms VALUES (973, 'Scientific Visualization', 'Scientific Visualization');
INSERT INTO meta_terms VALUES (975, '', 'Mehrfachauswahl möglich durch Halten der shift-Taste oder der ctrl- bzw. cmd-Taste.');
INSERT INTO meta_terms VALUES (977, 'Visualization of Landscape', 'Landschaftsvisualisierung');
INSERT INTO meta_terms VALUES (979, '', 'Landschaftstyp');
INSERT INTO meta_terms VALUES (981, '', 'Mehrfachauswahl und Hinzufügen von Werten möglich');
INSERT INTO meta_terms VALUES (983, '', 'Verwendungszweck');
INSERT INTO meta_terms VALUES (985, '', 'Bildwirkung');
INSERT INTO meta_terms VALUES (987, '', 'Einzelne Schlagworte, durch Return/Enter getrennt');
INSERT INTO meta_terms VALUES (989, '', 'Gesamteindruck der Darstellung, Ausdrucksqualita?t, Atmospha?re');
INSERT INTO meta_terms VALUES (991, '', 'Bildzeit');
INSERT INTO meta_terms VALUES (993, '', 'Jahreszeit bzw. Tageszeit');
INSERT INTO meta_terms VALUES (995, '', 'Farbe');
INSERT INTO meta_terms VALUES (997, '', 'Zentraler Farbton des Bildes, vorherrschende Farben.');
INSERT INTO meta_terms VALUES (999, '', 'Landschaftselemente');
INSERT INTO meta_terms VALUES (1001, '', 'Angaben zu Gela?ndeformation, Gewa?sser, Infrastruktur, Mensch/Tier, Vegetation usw.');
INSERT INTO meta_terms VALUES (1003, '', 'Wetter/Klima');
INSERT INTO meta_terms VALUES (1005, '', 'Horizontlinie');
INSERT INTO meta_terms VALUES (1007, '', 'Wo liegt der Horizont im Bild?');
INSERT INTO meta_terms VALUES (1009, '', 'Räumliche Wahrnehmung');
INSERT INTO meta_terms VALUES (1011, '', 'Abstraktionsgrad');
INSERT INTO meta_terms VALUES (1013, '', 'Beschreibt den Grad der A?hnlichkeit zwischen dem abgebildeten und realen Gegenstand. ');
INSERT INTO meta_terms VALUES (1015, '', 'Zentraler Farbton des Bildes, vorherrschende Farben');
INSERT INTO meta_terms VALUES (1017, '', 'Ausstellung');
INSERT INTO meta_terms VALUES (1019, '', 'Abstimmungsunterlagen');
INSERT INTO meta_terms VALUES (1021, '', 'abstrakt');
INSERT INTO meta_terms VALUES (1023, '', 'schematisch');
INSERT INTO meta_terms VALUES (1025, '', 'stilisiert');
INSERT INTO meta_terms VALUES (1027, '', 'realistisch');
INSERT INTO meta_terms VALUES (1029, '', 'naturalistisch');
INSERT INTO meta_terms VALUES (1031, '', 'fotografisch');
INSERT INTO meta_terms VALUES (1033, '', 'Frühling');
INSERT INTO meta_terms VALUES (1035, '', 'Sommer');
INSERT INTO meta_terms VALUES (1037, '', 'Herbst');
INSERT INTO meta_terms VALUES (1039, '', 'Winter');
INSERT INTO meta_terms VALUES (1043, '', 'Morgen');
INSERT INTO meta_terms VALUES (1045, '', 'Vormittag');
INSERT INTO meta_terms VALUES (1047, '', 'Mittag');
INSERT INTO meta_terms VALUES (1049, '', 'Nachmittag');
INSERT INTO meta_terms VALUES (1051, '', 'Abend');
INSERT INTO meta_terms VALUES (1053, '', 'Nacht');
INSERT INTO meta_terms VALUES (1057, '', 'oben');
INSERT INTO meta_terms VALUES (1059, '', 'mittig');
INSERT INTO meta_terms VALUES (1061, '', 'unten');
INSERT INTO meta_terms VALUES (1063, '', 'Agglomeration');
INSERT INTO meta_terms VALUES (1065, '', 'Erholungszone');
INSERT INTO meta_terms VALUES (1067, '', 'Architekturbild');
INSERT INTO meta_terms VALUES (1069, '', 'Illustration');
INSERT INTO meta_terms VALUES (1071, '', 'Computerspiel');
INSERT INTO meta_terms VALUES (1073, '', 'Dekoration');
INSERT INTO meta_terms VALUES (1075, '', 'Dokumentation');
INSERT INTO meta_terms VALUES (1077, '', 'Forschung');
INSERT INTO meta_terms VALUES (1079, '', 'Lehrmittel');
INSERT INTO meta_terms VALUES (1081, '', 'Gebirgslandschaft');
INSERT INTO meta_terms VALUES (1083, '', 'Industrielandschaft');
INSERT INTO meta_terms VALUES (1085, '', 'Landwirtschaft');
INSERT INTO meta_terms VALUES (1087, '', 'Naturlandschaft');
INSERT INTO meta_terms VALUES (1089, '', 'Parklandschaft');
INSERT INTO meta_terms VALUES (1091, '', 'Siedlungsgebiet');
INSERT INTO meta_terms VALUES (1093, '', 'Stadtlandschaft');
INSERT INTO meta_terms VALUES (1095, '', 'Tourismusgebiet');
INSERT INTO meta_terms VALUES (1097, '', 'Verkehrslandschaft');
INSERT INTO meta_terms VALUES (1099, '', 'Vogelperspektive');
INSERT INTO meta_terms VALUES (1101, '', 'Zentralperspektive');
INSERT INTO meta_terms VALUES (1103, '', 'Froschperspektive');
INSERT INTO meta_terms VALUES (1105, '', 'Atmosphärische Perspektive');
INSERT INTO meta_terms VALUES (1107, '', 'Verblauung');
INSERT INTO meta_terms VALUES (1109, '', 'Texturgradient');
INSERT INTO meta_terms VALUES (1111, '', 'Projektvisualisierung');
INSERT INTO meta_terms VALUES (1113, '', 'Wandbild');
INSERT INTO meta_terms VALUES (1115, '', 'Wettbewerb');
INSERT INTO meta_terms VALUES (1117, '', 'Abendrot');
INSERT INTO meta_terms VALUES (1119, '', 'Bewölkung/wolkig');
INSERT INTO meta_terms VALUES (1121, '', 'Gewitter');
INSERT INTO meta_terms VALUES (1125, '', 'Morgenrot');
INSERT INTO meta_terms VALUES (1127, '', 'Nebel');
INSERT INTO meta_terms VALUES (1129, '', 'Regen');
INSERT INTO meta_terms VALUES (1131, '', 'Schnee');
INSERT INTO meta_terms VALUES (1133, '', 'Sonnenschein');
INSERT INTO meta_terms VALUES (1135, '', 'Sturm');
INSERT INTO meta_terms VALUES (1139, '', 'Wind');
INSERT INTO meta_terms VALUES (1141, 'Ausstellung Bibiotheksgang', 'Ausstellung Bibiotheksgang');
INSERT INTO meta_terms VALUES (1143, 'Jérome Sprenger', 'Jérome Sprenger');
INSERT INTO meta_terms VALUES (1145, 'Student Vertiefung Interaction Design', 'Student Vertiefung Interaction Design');
INSERT INTO meta_terms VALUES (1147, 'Studentenportrait aus Zett-Serie', 'Studentenportrait aus Zett-Serie');
INSERT INTO meta_terms VALUES (1149, 'rot', 'rot');
INSERT INTO meta_terms VALUES (1151, 'bunt', 'bunt');
INSERT INTO meta_terms VALUES (1153, 'farbig', 'farbig');
INSERT INTO meta_terms VALUES (1155, 'Gletscher', 'Gletscher');
INSERT INTO meta_terms VALUES (1157, 'Schneeflanke', 'Schneeflanke');
INSERT INTO meta_terms VALUES (1159, 'unbestimmt', 'unbestimmt');
INSERT INTO meta_terms VALUES (1161, 'idyllisch', 'idyllisch');
INSERT INTO meta_terms VALUES (1163, 'verlassen', 'verlassen');
INSERT INTO meta_terms VALUES (1165, 'friedlich', 'friedlich');
INSERT INTO meta_terms VALUES (1167, 'ländlich', 'ländlich');
INSERT INTO meta_terms VALUES (1169, 'grün', 'grün');
INSERT INTO meta_terms VALUES (1171, 'braun', 'braun');
INSERT INTO meta_terms VALUES (1173, 'gedeckte Farben', 'gedeckte Farben');
INSERT INTO meta_terms VALUES (1175, 'Hügel', 'Hügel');
INSERT INTO meta_terms VALUES (1177, 'Hecken', 'Hecken');
INSERT INTO meta_terms VALUES (1179, 'Bäume', 'Bäume');
INSERT INTO meta_terms VALUES (1181, 'Bauernhof', 'Bauernhof');
INSERT INTO meta_terms VALUES (1183, 'Zäune', 'Zäune');
INSERT INTO meta_terms VALUES (1187, '', 'ghjgkjhgk');
INSERT INTO meta_terms VALUES (1189, '', 'hinweis');
INSERT INTO meta_terms VALUES (1191, 'Wüste', 'Wüste');
INSERT INTO meta_terms VALUES (1193, 'landwirtschaftlich', 'landwirtschaftlich');
INSERT INTO meta_terms VALUES (1195, '', 'unbestimmte Jahreszeit');
INSERT INTO meta_terms VALUES (1197, '', 'unbestimmte Tageszeit');
INSERT INTO meta_terms VALUES (1199, '', 'unbestimmt');
INSERT INTO meta_terms VALUES (1201, '', 'unbestimmt');
INSERT INTO meta_terms VALUES (1203, 'Landschaftsarchitektur', 'Landschaftsarchitektur');
INSERT INTO meta_terms VALUES (1205, 'kühl', 'kühl');
INSERT INTO meta_terms VALUES (1207, 'distanziert', 'distanziert');
INSERT INTO meta_terms VALUES (1209, 'modern', 'modern');
INSERT INTO meta_terms VALUES (1211, 'weiss', 'weiss');
INSERT INTO meta_terms VALUES (1213, 'hellblau', 'hellblau');
INSERT INTO meta_terms VALUES (1215, 'Palmen', 'Palmen');
INSERT INTO meta_terms VALUES (1217, 'Gebäude', 'Gebäude');
INSERT INTO meta_terms VALUES (1219, 'Menschen', 'Menschen');
INSERT INTO meta_terms VALUES (1221, 'Autos', 'Autos');
INSERT INTO meta_terms VALUES (1223, 'Strasse', 'Strasse');
INSERT INTO meta_terms VALUES (1225, 'Küstenlandschaft', 'Küstenlandschaft');
INSERT INTO meta_terms VALUES (1227, 'Savannenlandschaft', 'Savannenlandschaft');
INSERT INTO meta_terms VALUES (1229, 'Ebene', 'Ebene');
INSERT INTO meta_terms VALUES (1231, 'Gelb', 'Gelb');
INSERT INTO meta_terms VALUES (1233, 'Mensch', 'Mensch');
INSERT INTO meta_terms VALUES (1235, 'Kaktus', 'Kaktus');
INSERT INTO meta_terms VALUES (1237, 'Gebirge', 'Gebirge');
INSERT INTO meta_terms VALUES (1239, 'Dunst', 'Dunst');
INSERT INTO meta_terms VALUES (1241, 'Blautöne', 'Blautöne');
INSERT INTO meta_terms VALUES (1243, 'Grautöne', 'Grautöne');
INSERT INTO meta_terms VALUES (1245, 'Oker', 'Oker');
INSERT INTO meta_terms VALUES (1247, 'Berge', 'Berge');
INSERT INTO meta_terms VALUES (1249, 'Stille', 'Stille');
INSERT INTO meta_terms VALUES (1251, 'Erhabenheit', 'Erhabenheit');
INSERT INTO meta_terms VALUES (1253, 'Einsamkeit', 'Einsamkeit');
INSERT INTO meta_terms VALUES (1255, 'Grüntöne', 'Grüntöne');
INSERT INTO meta_terms VALUES (1257, 'Weg', 'Weg');
INSERT INTO meta_terms VALUES (1259, 'Himmel', 'Himmel');
INSERT INTO meta_terms VALUES (1261, 'Brauntöne', 'Brauntöne');
INSERT INTO meta_terms VALUES (1263, 'Hügellandschaft', 'Hügellandschaft');
INSERT INTO meta_terms VALUES (1265, '', 'bedeckt');
INSERT INTO meta_terms VALUES (1267, 'Gelbtöne', 'Gelbtöne');
INSERT INTO meta_terms VALUES (1269, 'Büsche', 'Büsche');
INSERT INTO meta_terms VALUES (1271, 'Ruhe', 'Ruhe');
INSERT INTO meta_terms VALUES (1273, 'Reiter', 'Reiter');
INSERT INTO meta_terms VALUES (1275, 'Wald', 'Wald');
INSERT INTO meta_terms VALUES (1277, 'Tiere', 'Tiere');
INSERT INTO meta_terms VALUES (1279, 'Schloss', 'Schloss');
INSERT INTO meta_terms VALUES (1281, 'Audio', 'Audio');
INSERT INTO meta_terms VALUES (1283, 'öffentlicher Raum', 'öffentlicher Raum');
INSERT INTO meta_terms VALUES (1285, 'unwirtlich', 'unwirtlich');
INSERT INTO meta_terms VALUES (1287, 'technisch', 'technisch');
INSERT INTO meta_terms VALUES (1289, 'unfreundlich', 'unfreundlich');
INSERT INTO meta_terms VALUES (1291, 'Wohnblöcke', 'Wohnblöcke');
INSERT INTO meta_terms VALUES (1293, 'Kinder', 'Kinder');
INSERT INTO meta_terms VALUES (1295, 'Krahn', 'Krahn');
INSERT INTO meta_terms VALUES (1297, 'Baustelle', 'Baustelle');
INSERT INTO meta_terms VALUES (1299, 'Sandkasten', 'Sandkasten');
INSERT INTO meta_terms VALUES (1301, 'Schaukel', 'Schaukel');
INSERT INTO meta_terms VALUES (1303, 'Platz ', 'Platz ');
INSERT INTO meta_terms VALUES (1305, 'Weisstöne', 'Weisstöne');
INSERT INTO meta_terms VALUES (1307, 'Mauer', 'Mauer');
INSERT INTO meta_terms VALUES (1309, 'Mittelgebirge', 'Mittelgebirge');
INSERT INTO meta_terms VALUES (1311, 'utopisch', 'utopisch');
INSERT INTO meta_terms VALUES (1313, 'fantastisch', 'fantastisch');
INSERT INTO meta_terms VALUES (1315, 'futuristisch', 'futuristisch');
INSERT INTO meta_terms VALUES (1317, 'Küste', 'Küste');
INSERT INTO meta_terms VALUES (1319, 'Felsen', 'Felsen');
INSERT INTO meta_terms VALUES (1321, 'Meer', 'Meer');
INSERT INTO meta_terms VALUES (1323, 'Rottöne', 'Rottöne');
INSERT INTO meta_terms VALUES (1325, 'Gewässer', 'Gewässer');
INSERT INTO meta_terms VALUES (1327, 'Wege', 'Wege');
INSERT INTO meta_terms VALUES (1329, 'Flachland', 'Flachland');
INSERT INTO meta_terms VALUES (1331, 'Beige', 'Beige');
INSERT INTO meta_terms VALUES (1333, 'Nachthimmel', 'Nachthimmel');
INSERT INTO meta_terms VALUES (1335, 'ruhig', 'ruhig');
INSERT INTO meta_terms VALUES (1337, 'Kanal', 'Kanal');
INSERT INTO meta_terms VALUES (1339, 'Boot', 'Boot');
INSERT INTO meta_terms VALUES (1341, 'Brücke', 'Brücke');
INSERT INTO meta_terms VALUES (1343, 'Gebirge', 'Gebirge');
INSERT INTO meta_terms VALUES (1345, 'Schiffe', 'Schiffe');
INSERT INTO meta_terms VALUES (1347, 'Grünfläche', 'Grünfläche');
INSERT INTO meta_terms VALUES (1349, 'Plätze', 'Plätze');
INSERT INTO meta_terms VALUES (1351, 'Tannen', 'Tannen');
INSERT INTO meta_terms VALUES (1353, 'Natur', 'Natur');
INSERT INTO meta_terms VALUES (1355, 'Häuser', 'Häuser');
INSERT INTO meta_terms VALUES (1357, 'Berg', 'Berg');
INSERT INTO meta_terms VALUES (1359, 'Bach', 'Bach');
INSERT INTO meta_terms VALUES (1361, 'naturnah', 'naturnah');
INSERT INTO meta_terms VALUES (1363, 'Uferlandschaft', 'Uferlandschaft');
INSERT INTO meta_terms VALUES (1365, 'Hafen', 'Hafen');
INSERT INTO meta_terms VALUES (1367, 'Violetttöne', 'Violetttöne');
INSERT INTO meta_terms VALUES (1369, 'Raumplanung', 'Raumplanung');
INSERT INTO meta_terms VALUES (1371, 'technologisch', 'technologisch');
INSERT INTO meta_terms VALUES (1375, 'Wiesen', 'Wiesen');
INSERT INTO meta_terms VALUES (1377, 'reduziert', 'reduziert');
INSERT INTO meta_terms VALUES (1379, 'Strassen', 'Strassen');
INSERT INTO meta_terms VALUES (1381, 'Vision', 'Vision');
INSERT INTO meta_terms VALUES (1383, 'Game', 'Game');
INSERT INTO meta_terms VALUES (1385, 'Fantasy', 'Fantasy');
INSERT INTO meta_terms VALUES (1387, 'Rendering', 'Rendering');
INSERT INTO meta_terms VALUES (1389, 'Landschaftsviualisierung', 'Landschaftsviualisierung');
INSERT INTO meta_terms VALUES (1391, 'einladend', 'einladend');
INSERT INTO meta_terms VALUES (1393, 'verspielt', 'verspielt');
INSERT INTO meta_terms VALUES (1395, 'Steg', 'Steg');
INSERT INTO meta_terms VALUES (1397, 'Hütten', 'Hütten');
INSERT INTO meta_terms VALUES (1399, 'künstlich', 'künstlich');
INSERT INTO meta_terms VALUES (1401, 'dramatisch', 'dramatisch');
INSERT INTO meta_terms VALUES (1403, 'düster', 'düster');
INSERT INTO meta_terms VALUES (1405, 'Brücken', 'Brücken');
INSERT INTO meta_terms VALUES (1407, 'Flussbett', 'Flussbett');
INSERT INTO meta_terms VALUES (1409, 'Hochgebirge', 'Hochgebirge');
INSERT INTO meta_terms VALUES (1411, 'sauber', 'sauber');
INSERT INTO meta_terms VALUES (1413, '', 'Tag');
INSERT INTO meta_terms VALUES (1415, '', 'Subjektiver Eindruck der Darstellung, Ausdrucksqualita?t oder Atmospha?re, z.B. dramatisch, kalt, einladend.');
INSERT INTO meta_terms VALUES (1417, '', 'wolkenlos');
INSERT INTO meta_terms VALUES (1419, 'Nutzungspolicy', 'Nutzungspolicy');
INSERT INTO meta_terms VALUES (1421, 'Beispiele', 'Beispiele');
INSERT INTO meta_terms VALUES (1423, 'Diskussionsgrundlage', 'Diskussionsgrundlage');
INSERT INTO meta_terms VALUES (1425, 'clean', 'clean');
INSERT INTO meta_terms VALUES (1427, 'Hirsch', 'Hirsch');
INSERT INTO meta_terms VALUES (1429, 'perfekt', 'perfekt');
INSERT INTO meta_terms VALUES (1431, 'Rights', 'Rechte');
INSERT INTO meta_terms VALUES (1433, 'Deutschland', 'Deutschland');
INSERT INTO meta_terms VALUES (1435, 'Dorf', 'Dorf');
INSERT INTO meta_terms VALUES (1437, 'Fachwerk', 'Fachwerk');
INSERT INTO meta_terms VALUES (1439, 'Frühe Neuzeit', 'Frühe Neuzeit');
INSERT INTO meta_terms VALUES (1441, 'Horizont', 'Horizont');
INSERT INTO meta_terms VALUES (1443, 'Malerei', 'Malerei');
INSERT INTO meta_terms VALUES (1445, 'whiteboard', 'whiteboard');
INSERT INTO meta_terms VALUES (1447, 'Gemüse', 'Gemüse');
INSERT INTO meta_terms VALUES (1449, 'warm', 'warm');
INSERT INTO meta_terms VALUES (1451, 'romantisch', 'romantisch');
INSERT INTO meta_terms VALUES (1453, 'befremdend', 'befremdend');
INSERT INTO meta_terms VALUES (1455, 'irritierend', 'irritierend');
INSERT INTO meta_terms VALUES (1457, 'Rosa', 'Rosa');
INSERT INTO meta_terms VALUES (1459, 'Strand', 'Strand');
INSERT INTO meta_terms VALUES (1461, 'Produktmanagement', 'Produktmanagement');
INSERT INTO meta_terms VALUES (1463, '', 'öffentliche Institution');
INSERT INTO meta_terms VALUES (1465, 'Vögel', 'Vögel');
INSERT INTO meta_terms VALUES (1467, 'Schweiz', 'Schweiz');
INSERT INTO meta_terms VALUES (1469, 'Schweizer', 'Schweizer');
INSERT INTO meta_terms VALUES (1471, 'Supply Lines', 'Supply Lines');
INSERT INTO meta_terms VALUES (1473, 'Visions of Global Resource Circulation. A Collaborative Art, Research and Exhibition Project', 'Visions of Global Resource Circulation. A Collaborative Art, Research and Exhibition Project');
INSERT INTO meta_terms VALUES (1475, 'oil', 'oil');
INSERT INTO meta_terms VALUES (1477, 'niger delta', 'niger delta');
INSERT INTO meta_terms VALUES (1479, 'silver', 'Silber');
INSERT INTO meta_terms VALUES (1481, 'gold', 'Gold');
INSERT INTO meta_terms VALUES (1483, 'water', 'Wasser');
INSERT INTO meta_terms VALUES (1485, 'oil', 'Öl');
INSERT INTO meta_terms VALUES (1487, 'cotton', 'Baumwolle');
INSERT INTO meta_terms VALUES (1489, 'Resources', 'Ressourcen');
INSERT INTO meta_terms VALUES (1491, 'Orders of Columns', 'Säulenordnungen');
INSERT INTO meta_terms VALUES (1493, '', 'Tuskische Ordnung');
INSERT INTO meta_terms VALUES (1495, '', 'Dorica');
INSERT INTO meta_terms VALUES (1497, '', 'Ionica');
INSERT INTO meta_terms VALUES (1499, '', 'Corinthia');
INSERT INTO meta_terms VALUES (1501, '', 'Composita');
INSERT INTO meta_terms VALUES (1503, '', 'Ordnung');
INSERT INTO meta_terms VALUES (1505, 'Hello', 'Hello');
INSERT INTO meta_terms VALUES (1507, '', 'Mehrfachauswahl möglich. Tippen Sie den Teil einer ZHdK-Abkürzung oder eines ZHdK-Bereichs in das Eingabefeld, um Vorschläge zu erhalten.');
INSERT INTO meta_terms VALUES (1509, 'Grünzeug', 'Grünzeug');
INSERT INTO meta_terms VALUES (1511, 'Flachdach', 'Flachdach');
INSERT INTO meta_terms VALUES (1513, 'Licht', 'Licht');
INSERT INTO meta_terms VALUES (1515, 'Thesaurus', 'Thesaurus');
INSERT INTO meta_terms VALUES (1517, 'Hierarchie', 'Hierarchie');
INSERT INTO meta_terms VALUES (1519, 'Datenbank', 'Datenbank');
INSERT INTO meta_terms VALUES (1521, 'Metadaten', 'Metadaten');
INSERT INTO meta_terms VALUES (1523, 'Architekturtraktat', 'Architekturtraktat');
INSERT INTO meta_terms VALUES (1525, 'online', 'online');
INSERT INTO meta_terms VALUES (1527, 'Vignola', 'Vignola');
INSERT INTO meta_terms VALUES (1529, 'Blum', 'Blum');
INSERT INTO meta_terms VALUES (1531, 'Palladio', 'Palladio');
INSERT INTO meta_terms VALUES (1533, 'Antike', 'Antike');
INSERT INTO meta_terms VALUES (1535, 'Renaissance', 'Renaissance');
INSERT INTO meta_terms VALUES (1537, 'Screenshots', 'Screenshots');
INSERT INTO meta_terms VALUES (1539, 'HyperImage', 'HyperImage');
INSERT INTO meta_terms VALUES (1541, 'Bilddatenbank', 'Bilddatenbank');
INSERT INTO meta_terms VALUES (1543, 'Architekturtheorie', 'Architekturtheorie');
INSERT INTO meta_terms VALUES (1545, 'Architekturzeichnungen', 'Architekturzeichnungen');
INSERT INTO meta_terms VALUES (1547, 'Hierarchischer Zugang', 'Hierarchischer Zugang');
INSERT INTO meta_terms VALUES (1549, 'Regeln', 'Regeln');
INSERT INTO meta_terms VALUES (1551, 'Shape Grammar', 'Formengrammatik');
INSERT INTO meta_terms VALUES (1553, 'Shape Grammar', 'Shape Grammar');
INSERT INTO meta_terms VALUES (1555, 'Volute', 'Volute');
INSERT INTO meta_terms VALUES (1557, 'Frontispiz', 'Frontispiz');
INSERT INTO meta_terms VALUES (1559, 'Säulen', 'Säulen');
INSERT INTO meta_terms VALUES (1561, '', 'Bildbearbeitung');
INSERT INTO meta_terms VALUES (1563, 'Grundrisse', 'Grundrisse');
INSERT INTO meta_terms VALUES (1565, 'XML', 'XML');
INSERT INTO meta_terms VALUES (1567, 'CBIR', 'CBIR');
INSERT INTO meta_terms VALUES (1569, 'CAD', 'CAD');
INSERT INTO meta_terms VALUES (1571, 'Reprint', 'Reprint');
INSERT INTO meta_terms VALUES (1573, 'Cesariano', 'Cesariano');
INSERT INTO meta_terms VALUES (1575, 'Forssman', 'Forssman');
INSERT INTO meta_terms VALUES (1577, 'Analyse', 'Analyse');
INSERT INTO meta_terms VALUES (1579, 'Vergleich', 'Vergleich');
INSERT INTO meta_terms VALUES (1581, 'Terminologie', 'Terminologie');
INSERT INTO meta_terms VALUES (1583, 'E-Learning', 'E-Learning');
INSERT INTO meta_terms VALUES (1585, 'Vernetzung', 'Vernetzung');
INSERT INTO meta_terms VALUES (1587, '', 'Digitale Architekturgeschichte');
INSERT INTO meta_terms VALUES (1589, '', 'Computergrafik 2D');
INSERT INTO meta_terms VALUES (1591, '', '---Analyse');
INSERT INTO meta_terms VALUES (1593, '', 'Netz, Netzwerk, Vernetzung');
INSERT INTO meta_terms VALUES (1595, '', 'Konzept');
INSERT INTO meta_terms VALUES (1597, '', 'Informationstechnologie');
INSERT INTO meta_terms VALUES (1599, '', 'Zweck und Absicht');
INSERT INTO meta_terms VALUES (1601, 'Villen', 'Villen');
INSERT INTO meta_terms VALUES (1603, 'Software', 'Software');
INSERT INTO meta_terms VALUES (1605, 'Generative Architektur', 'Generative Architektur');
INSERT INTO meta_terms VALUES (1607, 'Hilfe', 'Hilfe');
INSERT INTO meta_terms VALUES (1609, 'Selbstporträt', 'Selbstporträt');
INSERT INTO meta_terms VALUES (1611, '1990er', '1990er');
INSERT INTO meta_terms VALUES (1613, 'Inszenierte Fotografie', 'Inszenierte Fotografie');
INSERT INTO meta_terms VALUES (1615, '1980er Jahre', '1980er Jahre');
INSERT INTO meta_terms VALUES (1617, 'Reisefotografie', 'Reisefotografie');
INSERT INTO meta_terms VALUES (1619, 'Objekt', 'Objekt');
INSERT INTO meta_terms VALUES (1621, 'HyperColumn', 'HyperColumn');
INSERT INTO meta_terms VALUES (1623, '', 'Bildbeschreibung');
INSERT INTO meta_terms VALUES (1625, 'Visuelles Browsen', 'Visuelles Browsen');
INSERT INTO meta_terms VALUES (1627, 'Index-Browser', 'Index-Browser');
INSERT INTO meta_terms VALUES (1629, '', 'Bildanordnung');
INSERT INTO meta_terms VALUES (1631, '', 'Computergestützte Architekturgeschichte');
INSERT INTO meta_terms VALUES (1633, '', 'Konzepte einer computergestützten Architekturgeschichte');
INSERT INTO meta_terms VALUES (1635, '', 'Zweck');
INSERT INTO meta_terms VALUES (1637, '', 'Ausgangsmaterial');
INSERT INTO meta_terms VALUES (1639, '', 'Erzeugte Daten');
INSERT INTO meta_terms VALUES (1641, '', 'Kontext');
INSERT INTO meta_terms VALUES (1643, '', 'Techniken der Sinnstiftung');
INSERT INTO meta_terms VALUES (1645, '', 'Thema');
INSERT INTO meta_terms VALUES (1647, '', 'Basis');
INSERT INTO meta_terms VALUES (1649, '', 'Architekturtraktat');
INSERT INTO meta_terms VALUES (1651, '', 'Holzschnitt');
INSERT INTO meta_terms VALUES (1653, '', 'Frührenaissance');
INSERT INTO meta_terms VALUES (1655, '', 'Architekturtraktat');
INSERT INTO meta_terms VALUES (1657, '', 'Punkte');
INSERT INTO meta_terms VALUES (1659, '', 'Universität');
INSERT INTO meta_terms VALUES (1661, '', 'Hierarchische Wissensordnung');
INSERT INTO meta_terms VALUES (1663, '', 'Säulenlehre');
INSERT INTO meta_terms VALUES (1665, '', 'Stil-Epoche');
INSERT INTO meta_terms VALUES (1667, '', 'Elemente');
INSERT INTO meta_terms VALUES (1669, '', 'Medium');
INSERT INTO meta_terms VALUES (1671, '', 'Lehre und Vermittlung');
INSERT INTO meta_terms VALUES (1673, 'Darstellung', 'Darstellung');
INSERT INTO meta_terms VALUES (1675, 'Antike Architektur', 'Antike Architektur');
INSERT INTO meta_terms VALUES (1677, 'Chitham', 'Chitham');
INSERT INTO meta_terms VALUES (1679, 'Sagredo', 'Sagredo');
INSERT INTO meta_terms VALUES (1681, 'Säulenbuch', 'Säulenbuch');
INSERT INTO meta_terms VALUES (1683, 'Vill', 'Vill');
INSERT INTO meta_terms VALUES (1685, '', 'Terminologie Säulenordnungen');
INSERT INTO meta_terms VALUES (1687, '', 'Entwicklung der Ordnungen');
INSERT INTO meta_terms VALUES (1689, '', 'Aufbau der Ordnungen');
INSERT INTO meta_terms VALUES (1691, '', 'Monografie');
INSERT INTO meta_terms VALUES (1693, '', 'Stil-Epoche');
INSERT INTO meta_terms VALUES (1695, '', 'Systematisierung in der Architektur');
INSERT INTO meta_terms VALUES (1697, '', 'Antikenrezeption');
INSERT INTO meta_terms VALUES (1699, '', 'Verhältnis Architekturtheorie und Baupraxis');
INSERT INTO meta_terms VALUES (1701, '', 'Publikation');
INSERT INTO meta_terms VALUES (1705, 'Archivierung', 'Archivierung');
INSERT INTO meta_terms VALUES (1709, 'Bereitstellung / Open Access', 'Bereitstellung / Open Access');
INSERT INTO meta_terms VALUES (1711, '', '--- Darstellung / Visualisierung');
INSERT INTO meta_terms VALUES (1715, '', 'Erfassen');
INSERT INTO meta_terms VALUES (1717, '', 'staatliche Förderung');
INSERT INTO meta_terms VALUES (1719, '', '---Experiment');
INSERT INTO meta_terms VALUES (1721, '', 'Messdaten');
INSERT INTO meta_terms VALUES (1723, '', 'weitere historische Quellen');
INSERT INTO meta_terms VALUES (1725, '', 'Beschreibungssprache');
INSERT INTO meta_terms VALUES (1727, '', 'Datenbanksystem');
INSERT INTO meta_terms VALUES (1729, '', 'Hypertext');
INSERT INTO meta_terms VALUES (1731, '', 'Semantic Web');
INSERT INTO meta_terms VALUES (1733, '', 'Geoinformationssystem (GIS)');
INSERT INTO meta_terms VALUES (1735, '', 'Social Web / Web 2.0');
INSERT INTO meta_terms VALUES (1737, '', 'Content Based Image Retrival (CBIR)');
INSERT INTO meta_terms VALUES (1739, '', 'Digitalisierung');
INSERT INTO meta_terms VALUES (1741, '', 'Generative Algorithmen');
INSERT INTO meta_terms VALUES (1743, '', 'Internet');
INSERT INTO meta_terms VALUES (1747, '', 'Computergrafik 3D');
INSERT INTO meta_terms VALUES (1749, '', 'Animation');
INSERT INTO meta_terms VALUES (1751, '', 'Hypermedia / Multimedia');
INSERT INTO meta_terms VALUES (1753, 'Linien', 'Linien');
INSERT INTO meta_terms VALUES (1755, 'Pixel', 'Pixel');
INSERT INTO meta_terms VALUES (1757, 'Links', 'Links');
INSERT INTO meta_terms VALUES (1759, '', 'Bottom-Up-Wissen');
INSERT INTO meta_terms VALUES (1761, '', 'Netzwerk');
INSERT INTO meta_terms VALUES (1763, '', 'Regel (Ontologie, Formengrammatik usw.)');
INSERT INTO meta_terms VALUES (1765, '', 'Erkenntnis redaktionell erzeugt');
INSERT INTO meta_terms VALUES (1767, '', 'Ergebnis berechnet');
INSERT INTO meta_terms VALUES (1769, '', 'Simulation');
INSERT INTO meta_terms VALUES (1771, 'Vektor, Linie, Visualisierung', 'Vektor, Linie, Visualisierung');
INSERT INTO meta_terms VALUES (1773, 'Archiv, Speicher, Datenbank', 'Archiv, Speicher, Datenbank');
INSERT INTO meta_terms VALUES (1775, 'Regel, Grammatik, Logik', 'Regel, Grammatik, Logik');
INSERT INTO meta_terms VALUES (1777, 'Struktur - Inhalt - Form', 'Struktur - Inhalt - Form');
INSERT INTO meta_terms VALUES (1789, '', 'architekturgeschichtliches Wissen');
INSERT INTO meta_terms VALUES (1791, 'Digitale Architekturgeschichte', 'Digitale Architekturgeschichte');
INSERT INTO meta_terms VALUES (1793, '', 'private Initiative');
INSERT INTO meta_terms VALUES (1795, '', 'Analyse');
INSERT INTO meta_terms VALUES (1797, '', 'Rekonstruktion');
INSERT INTO meta_terms VALUES (1799, '', 'Überblick');
INSERT INTO meta_terms VALUES (1801, '', 'Darstellung / Visualisierung');
INSERT INTO meta_terms VALUES (1803, '', 'Techniken der Sinnstiftung / Vorgehensweise');
INSERT INTO meta_terms VALUES (1805, 'Entwurfsprozess in der Architektur', 'Entwurfsprozess in der Architektur');
INSERT INTO meta_terms VALUES (1807, 'Computer Aided Design', 'Computer Aided Design');
INSERT INTO meta_terms VALUES (1809, '', 'Lehrmittel Fotografie');
INSERT INTO meta_terms VALUES (1811, '', 'Genre');
INSERT INTO meta_terms VALUES (1813, '', 'Ansätze/Phänomene');
INSERT INTO meta_terms VALUES (1815, '', 'Anwendungs- und Kunstrichtungen');
INSERT INTO meta_terms VALUES (1817, '', 'Namen/Gruppen');
INSERT INTO meta_terms VALUES (1819, '', 'Ausstellungen/Projekte');
INSERT INTO meta_terms VALUES (1821, '', 'Chronometrische Kategorien');
INSERT INTO meta_terms VALUES (1823, '', 'Technik');
INSERT INTO meta_terms VALUES (1825, '', 'Geografische Kategorien');
INSERT INTO meta_terms VALUES (1827, 'Piktoralismus', 'Piktoralismus');
INSERT INTO meta_terms VALUES (1829, 'Futurismus & Vortizismus', 'Futurismus & Vortizismus');
INSERT INTO meta_terms VALUES (1831, 'Das Neue Sehen', 'Das Neue Sehen');
INSERT INTO meta_terms VALUES (1833, 'Reine Fotografie', 'Reine Fotografie');
INSERT INTO meta_terms VALUES (1835, 'Fotografie & Propaganda', 'Fotografie & Propaganda');
INSERT INTO meta_terms VALUES (1837, 'Surrealismus', 'Surrealismus');
INSERT INTO meta_terms VALUES (1839, 'Subjektive Fotografie', 'Subjektive Fotografie');
INSERT INTO meta_terms VALUES (1841, 'Neorealismus', 'Neorealismus');
INSERT INTO meta_terms VALUES (1843, 'Bildjournalismus', 'Bildjournalismus');
INSERT INTO meta_terms VALUES (1845, 'Kriegsfotografie', 'Kriegsfotografie');
INSERT INTO meta_terms VALUES (1847, 'Dokumentarfotografie', 'Dokumentarfotografie');
INSERT INTO meta_terms VALUES (1849, 'Strassenfotografie', 'Strassenfotografie');
INSERT INTO meta_terms VALUES (1851, 'Soziale Fotografie', 'Soziale Fotografie');
INSERT INTO meta_terms VALUES (1853, 'Magazinfotografie', 'Magazinfotografie');
INSERT INTO meta_terms VALUES (1855, 'Modefotografie', 'Modefotografie');
INSERT INTO meta_terms VALUES (1857, 'Akt- und Erotikfotografie', 'Akt- und Erotikfotografie');
INSERT INTO meta_terms VALUES (1859, 'Architekturfotografie', 'Architekturfotografie');
INSERT INTO meta_terms VALUES (1861, 'Wissenschaftliche Fotografie', 'Wissenschaftliche Fotografie');
INSERT INTO meta_terms VALUES (2109, '', 'Ansprechsperson Abbildung');
INSERT INTO meta_terms VALUES (1863, 'Polizei- und Fahndungsfotografie', 'Polizei- und Fahndungsfotografie');
INSERT INTO meta_terms VALUES (1865, 'Amateurfotografie', 'Amateurfotografie');
INSERT INTO meta_terms VALUES (1867, 'Chronofotografie', 'Chronofotografie');
INSERT INTO meta_terms VALUES (1869, 'FSA', 'FSA');
INSERT INTO meta_terms VALUES (1871, 'Film und Foto', 'Film und Foto');
INSERT INTO meta_terms VALUES (1873, 'Family of Man', 'Family of Man');
INSERT INTO meta_terms VALUES (1875, 'New Topographic', 'New Topographic');
INSERT INTO meta_terms VALUES (1877, 'Photokina', 'Photokina');
INSERT INTO meta_terms VALUES (1879, 'Stadt', 'Stadt');
INSERT INTO meta_terms VALUES (1881, 'Ereignis', 'Ereignis');
INSERT INTO meta_terms VALUES (1883, '', 'Angaben sind identische mit "Datierung" (Werk).');
INSERT INTO meta_terms VALUES (1885, '', 'Eingefügte Werte sind identisch mit "Land" (Werk).');
INSERT INTO meta_terms VALUES (1887, '', 'Angaben sind identisch mit "Datierung" (Werk).');
INSERT INTO meta_terms VALUES (1889, '', 'Eingefügte Werte sind identisch mit "Datierung" (Werk).');
INSERT INTO meta_terms VALUES (1891, '', 'Eingefügte Werte sind identische mit "Material/Format" (Medium).');
INSERT INTO meta_terms VALUES (1893, '', 'Hier kann der Editor für Personengruppen genutzt werden. Eingefügte Werte sind identisch mit "Autor/in" (Werk).');
INSERT INTO meta_terms VALUES (1895, 'Brudermord', 'Brudermord');
INSERT INTO meta_terms VALUES (1897, 'Guitarre', 'Guitarre');
INSERT INTO meta_terms VALUES (1899, 'Blutrache', 'Blutrache');
INSERT INTO meta_terms VALUES (1901, 'Western', 'Western');
INSERT INTO meta_terms VALUES (1903, 'Präsentation', 'Präsentation');
INSERT INTO meta_terms VALUES (1905, 'Säule', 'Säule');
INSERT INTO meta_terms VALUES (1907, 'Geschichte ZHdK', 'Geschichte ZHdK');
INSERT INTO meta_terms VALUES (1909, 'Title', 'Titel des Werkes');
INSERT INTO meta_terms VALUES (1911, '', 'auch ein Serientitel kann hier eingetragen werden');
INSERT INTO meta_terms VALUES (1913, 'The title of the work', 'Titel des Werkes oder einer Werkserie. ');
INSERT INTO meta_terms VALUES (1915, '', 'oder Titel einer Werkserie');
INSERT INTO meta_terms VALUES (1917, 'The subtitle of the media entry', 'Der Untertitel erweitert den Titel des Werks oder der Werkserie mit zusätzlichen Informationen. Nicht zu verwechseln mit der Bildlegende oder dem Untertitel eines Films (siehe dort).');
INSERT INTO meta_terms VALUES (1919, 'Title', 'Titel des Werks');
INSERT INTO meta_terms VALUES (1921, 'Gitarre', 'Gitarre');
INSERT INTO meta_terms VALUES (1923, 'Uranium', 'Uranium');
INSERT INTO meta_terms VALUES (1925, 'Sahara Chronicle', 'Sahara Chronicle');
INSERT INTO meta_terms VALUES (1927, 'Caspian oil geography ', 'Caspian oil geography ');
INSERT INTO meta_terms VALUES (1929, 'pipeline', 'pipeline');
INSERT INTO meta_terms VALUES (1931, 'oil workers', 'oil workers');
INSERT INTO meta_terms VALUES (1933, 'farmers', 'farmers');
INSERT INTO meta_terms VALUES (1935, 'prostitutes', 'prostitutes');
INSERT INTO meta_terms VALUES (1937, 'Bachelor of Arts in Design', 'Bachelor of Arts in Design');
INSERT INTO meta_terms VALUES (1939, 'Altes Ägypten', 'Altes Ägypten');
INSERT INTO meta_terms VALUES (1941, 'Barock', 'Barock');
INSERT INTO meta_terms VALUES (1943, 'Byzantinisch', 'Byzantinisch');
INSERT INTO meta_terms VALUES (1945, 'Etruskisch', 'Etruskisch');
INSERT INTO meta_terms VALUES (1947, 'Gotik', 'Gotik');
INSERT INTO meta_terms VALUES (1949, 'Griechische Antike', 'Griechische Antike');
INSERT INTO meta_terms VALUES (1951, 'Hellenismus', 'Hellenismus');
INSERT INTO meta_terms VALUES (1953, 'Klassizismus', 'Klassizismus');
INSERT INTO meta_terms VALUES (1955, 'Magna Graeca', 'Magna Graeca');
INSERT INTO meta_terms VALUES (1957, 'Mesopotamien', 'Mesopotamien');
INSERT INTO meta_terms VALUES (1959, 'Minoisch', 'Minoisch');
INSERT INTO meta_terms VALUES (1961, 'Mittelalter', 'Mittelalter');
INSERT INTO meta_terms VALUES (1963, 'Moderne', 'Moderne');
INSERT INTO meta_terms VALUES (1965, 'Mykenisch', 'Mykenisch');
INSERT INTO meta_terms VALUES (1967, 'Postmoderne', 'Postmoderne');
INSERT INTO meta_terms VALUES (1969, 'Rokoko', 'Rokoko');
INSERT INTO meta_terms VALUES (1971, 'Romanik', 'Romanik');
INSERT INTO meta_terms VALUES (1973, 'Römische Antike', 'Römische Antike');
INSERT INTO meta_terms VALUES (1975, 'Spätantike', 'Spätantike');
INSERT INTO meta_terms VALUES (1977, 'unbekannt', 'unbekannt');
INSERT INTO meta_terms VALUES (1979, 'seit 1990', 'seit 1990');
INSERT INTO meta_terms VALUES (1981, '', 'Epoche');
INSERT INTO meta_terms VALUES (1983, '19. Jahrhundert', '19. Jahrhundert');
INSERT INTO meta_terms VALUES (1985, 'Jahrhundertwende', 'Jahrhundertwende');
INSERT INTO meta_terms VALUES (1987, '1920er', '1920er');
INSERT INTO meta_terms VALUES (1989, '1930er', '1930er');
INSERT INTO meta_terms VALUES (1991, '1940er', '1940er');
INSERT INTO meta_terms VALUES (1993, '', 'Stil- und Kunstrichtungen');
INSERT INTO meta_terms VALUES (1995, 'Futurismus', 'Futurismus');
INSERT INTO meta_terms VALUES (1997, 'Vortizismus', 'Vortizismus');
INSERT INTO meta_terms VALUES (1999, 'Stein', 'Stein');
INSERT INTO meta_terms VALUES (2001, 'Palast', 'Palast');
INSERT INTO meta_terms VALUES (2003, 'Repräsentationsbau', 'Repräsentationsbau');
INSERT INTO meta_terms VALUES (2005, 'Basis', 'Basis');
INSERT INTO meta_terms VALUES (2007, 'Kapitell', 'Kapitell');
INSERT INTO meta_terms VALUES (2009, 'Gebälk', 'Gebälk');
INSERT INTO meta_terms VALUES (2011, 'Study Year', 'Studienabschnitt');
INSERT INTO meta_terms VALUES (2013, '', 'In welchem Studienabschnitt wurde das Werk erstellt?');
INSERT INTO meta_terms VALUES (2015, 'Fotorgrafiegeschichte', 'Fotorgrafiegeschichte');
INSERT INTO meta_terms VALUES (2017, 'Studio Publikationen', 'Studio Publikationen');
INSERT INTO meta_terms VALUES (2019, 'Industrial Design', 'Industrial Design');
INSERT INTO meta_terms VALUES (2021, 'Lautsprecher', 'Lautsprecher');
INSERT INTO meta_terms VALUES (2023, 'Sound', 'Sound');
INSERT INTO meta_terms VALUES (2025, '', 'Produktion Zett');
INSERT INTO meta_terms VALUES (2027, '', 'Ansprechsperson');
INSERT INTO meta_terms VALUES (2029, '', 'Für Rückfragen, welche die Abbildung betreffen.');
INSERT INTO meta_terms VALUES (2031, '', 'Artikel');
INSERT INTO meta_terms VALUES (2033, '', 'Titel des Artikels, zu dem das Bild gehört.');
INSERT INTO meta_terms VALUES (2035, '', 'Für Rückfragen, welche das Bild betreffen.');
INSERT INTO meta_terms VALUES (2037, '', 'Ausgabe Zett');
INSERT INTO meta_terms VALUES (2039, '', 'Autor/innen des Artikels');
INSERT INTO meta_terms VALUES (2041, '', 'Autor/innen des Artikels, dem das Bild zugeordnet wird.');
INSERT INTO meta_terms VALUES (2043, '', 'Kommentar');
INSERT INTO meta_terms VALUES (2045, '', 'Kommentar zum Bild');
INSERT INTO meta_terms VALUES (2047, '', 'Verantwortliche/r Produktion');
INSERT INTO meta_terms VALUES (2049, '', 'Wer ist verantwortlich für dieses Bild im Prozess der Produktion?');
INSERT INTO meta_terms VALUES (2051, '', 'Verantwortliche/r Redaktion');
INSERT INTO meta_terms VALUES (2053, '', 'Wer ist verantwortlich für dieses Bild im Prozess der Redaktion??');
INSERT INTO meta_terms VALUES (2055, '', 'Sparte');
INSERT INTO meta_terms VALUES (2057, '', 'Zu welcher Sparte im Zett gehört das Bild?');
INSERT INTO meta_terms VALUES (2059, '', 'Status');
INSERT INTO meta_terms VALUES (2061, 'Vorschlag von Redaktionsteam', 'Vorschlag von Redaktionsteam');
INSERT INTO meta_terms VALUES (2063, 'Materialsuche', 'Materialsuche');
INSERT INTO meta_terms VALUES (2065, 'Vorauswahl', 'Vorauswahl');
INSERT INTO meta_terms VALUES (2067, 'Engere Auswahl', 'Engere Auswahl');
INSERT INTO meta_terms VALUES (2069, 'Definitive Auswahl', 'Definitive Auswahl');
INSERT INTO meta_terms VALUES (2071, 'Online-Ergänzung zum Artikel', 'Online-Ergänzung zum Artikel');
INSERT INTO meta_terms VALUES (2073, 'nicht geeignet', 'nicht geeignet');
INSERT INTO meta_terms VALUES (2075, 'Coverbild', 'Coverbild');
INSERT INTO meta_terms VALUES (2077, 'Kurzmeldungen', 'Kurzmeldungen');
INSERT INTO meta_terms VALUES (2079, 'Leute', 'Leute');
INSERT INTO meta_terms VALUES (2081, 'Alumni', 'Alumni');
INSERT INTO meta_terms VALUES (2083, 'Services', 'Services');
INSERT INTO meta_terms VALUES (2085, 'Museum', 'Museum');
INSERT INTO meta_terms VALUES (2087, 'Kulturanalyse und Vermittlung', 'Kulturanalyse und Vermittlung');
INSERT INTO meta_terms VALUES (2089, 'Kunst & Medien', 'Kunst & Medien');
INSERT INTO meta_terms VALUES (2091, 'Darstellende Künste und Film', 'Darstellende Künste und Film');
INSERT INTO meta_terms VALUES (2093, 'Hochschule', 'Hochschule');
INSERT INTO meta_terms VALUES (2095, 'Letzte Seite', 'Letzte Seite');
INSERT INTO meta_terms VALUES (2097, 'zett 3-2010', 'zett 3-2010');
INSERT INTO meta_terms VALUES (2099, 'zett 1-2011', 'zett 1-2011');
INSERT INTO meta_terms VALUES (2101, 'zett 2-2011', 'zett 2-2011');
INSERT INTO meta_terms VALUES (2103, 'zett 3-2011', 'zett 3-2011');
INSERT INTO meta_terms VALUES (2105, 'zett 1-2012', 'zett 1-2012');
INSERT INTO meta_terms VALUES (2107, 'Vorschlag von Autor/innen', 'Vorschlag von Autor/innen');
INSERT INTO meta_terms VALUES (2111, 'nightingale', 'nightingale');
INSERT INTO meta_terms VALUES (2113, 'birds', 'birds');
INSERT INTO meta_terms VALUES (2115, 'whistling', 'whistling');
INSERT INTO meta_terms VALUES (2117, 'bird', 'bird');
INSERT INTO meta_terms VALUES (2119, 'Orgel', 'Orgel');
INSERT INTO meta_terms VALUES (2121, 'Orgelsymposium', 'Orgelsymposium');
INSERT INTO meta_terms VALUES (2123, 'Grossmünster', 'Grossmünster');
INSERT INTO meta_terms VALUES (2125, 'Orgelsymposium Flyer', 'Orgelsymposium Flyer');
INSERT INTO meta_terms VALUES (2127, 'Logo', 'Logo');
INSERT INTO meta_terms VALUES (2129, 'Fraumünster', 'Fraumünster');
INSERT INTO meta_terms VALUES (2131, 'Bachelor', 'Bachelor');
INSERT INTO meta_terms VALUES (2133, 'Identität', 'Identität');
INSERT INTO meta_terms VALUES (2135, 'Geschichte', 'Geschichte');
INSERT INTO meta_terms VALUES (2137, 'Gesellschaft', 'Gesellschaft');
INSERT INTO meta_terms VALUES (2139, 'Schuld', 'Schuld');
INSERT INTO meta_terms VALUES (2141, 'Narration', 'Narration');
INSERT INTO meta_terms VALUES (2143, 'Familie', 'Familie');
INSERT INTO meta_terms VALUES (2145, ':rel:d:bm:GF2E5551F7T01', ':rel:d:bm:GF2E5551F7T01');
INSERT INTO meta_terms VALUES (2147, '', 'Der Titel des Sets bzw. des Projekts bezeichnet die Zusammenstellung der Medieneinträge.');
INSERT INTO meta_terms VALUES (2149, '', 'Wer nimmt die Zusammenstellung und Verschlagwortung des Sets bzw. des vor?');
INSERT INTO meta_terms VALUES (2151, '', 'Schlagworte zum Set bzw. zum Projekt. Was ist zu sehen oder zu hören? Welche Themen behandelt das Set / das Projekt?');
INSERT INTO meta_terms VALUES (2153, '', 'Hier können Sie eine ausführliche Beschreibung des Sets bzw. des Projekts einfügen.');
INSERT INTO meta_terms VALUES (2155, '', 'Wer nimmt die Zusammenstellung und Verschlagwortung des Sets bzw. des Projekts vor?');
INSERT INTO meta_terms VALUES (2157, '', 'Ansprechperson Abbildung');
INSERT INTO meta_terms VALUES (2159, '', 'Wer ist verantwortlich für dieses Bild im Prozess der Redaktion?');
INSERT INTO meta_terms VALUES (2161, 'Öl auf Leinwand', 'Öl auf Leinwand');
INSERT INTO meta_terms VALUES (2163, 'Bleistift auf Papier, digitale Nachbearbeitung', 'Bleistift auf Papier, digitale Nachbearbeitung');
INSERT INTO meta_terms VALUES (2165, 'Tusche und Airbrush auf Karton', 'Tusche und Airbrush auf Karton');
INSERT INTO meta_terms VALUES (2167, 'Buntstift auf gelbem Skizzenpapier', 'Buntstift auf gelbem Skizzenpapier');
INSERT INTO meta_terms VALUES (2169, 'Tusche und Aquarell auf Bütenpapier', 'Tusche und Aquarell auf Bütenpapier');
INSERT INTO meta_terms VALUES (2171, 'Buntstift und Acrylfarbe auf Karton', 'Buntstift und Acrylfarbe auf Karton');
INSERT INTO meta_terms VALUES (2173, 'Tusche, Aquarellfarbe, Buntstifte und Kohle auf Transparentfolie', 'Tusche, Aquarellfarbe, Buntstifte und Kohle auf Transparentfolie');
INSERT INTO meta_terms VALUES (2175, 'Fineliner auf Papier, digitale Nachbearbeitung', 'Fineliner auf Papier, digitale Nachbearbeitung');
INSERT INTO meta_terms VALUES (2177, 'Aquarellfarben auf Papier', 'Aquarellfarben auf Papier');
INSERT INTO meta_terms VALUES (2179, 'Digitale Fotografie', 'Digitale Fotografie');
INSERT INTO meta_terms VALUES (2181, 'Collage', 'Collage');
INSERT INTO meta_terms VALUES (2183, 'Wasser- und Deckfarben (Aquarell & Gouache = Deckfarben und lasierender Farbauftrag) auf Papier', 'Wasser- und Deckfarben (Aquarell & Gouache = Deckfarben und lasierender Farbauftrag) auf Papier');
INSERT INTO meta_terms VALUES (2185, 'Kombination von 3D-Konstruktion, Fotografie und digitale Bildbearbeitung', 'Kombination von 3D-Konstruktion, Fotografie und digitale Bildbearbeitung');
INSERT INTO meta_terms VALUES (2187, 'Ilfocolor Mittelformat Polyester Farbfilm', 'Ilfocolor Mittelformat Polyester Farbfilm');
INSERT INTO meta_terms VALUES (2189, 'Fotomappe mit 20 S/W-Positiven', 'Fotomappe mit 20 S/W-Positiven');
INSERT INTO meta_terms VALUES (2191, 'Fotobuch', 'Fotobuch');
INSERT INTO meta_terms VALUES (2193, 'Grafik erstellt in OmniGraffle', 'Grafik erstellt in OmniGraffle');
INSERT INTO meta_terms VALUES (2195, 'Original: JPEG', 'Original: JPEG');
INSERT INTO meta_terms VALUES (2197, 'Original: Kleinbilddia Farbe; Digitalisat: TIFF', 'Original: Kleinbilddia Farbe; Digitalisat: TIFF');
INSERT INTO meta_terms VALUES (2199, 'Video HD 1080p', 'Video HD 1080p');
INSERT INTO meta_terms VALUES (2201, 'Video (HDV, 1080i, 16:9)', 'Video (HDV, 1080i, 16:9)');
INSERT INTO meta_terms VALUES (2203, 'Daguerreotypie', 'Daguerreotypie');
INSERT INTO meta_terms VALUES (2205, 'Stereoskopie', 'Stereoskopie');
INSERT INTO meta_terms VALUES (2207, 'Gummidruck', 'Gummidruck');
INSERT INTO meta_terms VALUES (2209, 'Experiment', 'Experiment');
INSERT INTO meta_terms VALUES (2211, 'Polaroid', 'Polaroid');
INSERT INTO meta_terms VALUES (2213, 'Algerienkrieg', 'Algerienkrieg');
INSERT INTO meta_terms VALUES (2215, 'Vietnamkrieg', 'Vietnamkrieg');
INSERT INTO meta_terms VALUES (2217, 'Amerikanischer Bürgerkrieg', 'Amerikanischer Bürgerkrieg');
INSERT INTO meta_terms VALUES (2219, '1. Weltkrieg', '1. Weltkrieg');
INSERT INTO meta_terms VALUES (2221, '2. Weltkrieg', '2. Weltkrieg');
INSERT INTO meta_terms VALUES (2223, 'Computergenerierte Landschaftsbilder', 'Computergenerierte Landschaftsbilder');
INSERT INTO meta_terms VALUES (2225, 'Punk Rock', 'Punk Rock');
INSERT INTO meta_terms VALUES (2227, 'Toni', 'Toni');
INSERT INTO meta_terms VALUES (2229, 'Umbau', 'Umbau');
INSERT INTO meta_terms VALUES (2231, 'Stadtentwicklung', 'Stadtentwicklung');
INSERT INTO meta_terms VALUES (2233, '', 'Umbau Toni-Areal');
INSERT INTO meta_terms VALUES (2235, '', 'Blickrichtung');
INSERT INTO meta_terms VALUES (2237, '', 'Objekt');
INSERT INTO meta_terms VALUES (2239, '', 'Prozess');
INSERT INTO meta_terms VALUES (2241, 'Migros Verteilzentrum Herdern mit Pfingstweidstrasse', 'Migros Verteilzentrum Herdern mit Pfingstweidstrasse');
INSERT INTO meta_terms VALUES (2243, 'Süd Ost / Zürich City', 'Süd Ost / Zürich City');
INSERT INTO meta_terms VALUES (2245, 'SBB Herdern Viadukt', 'SBB Herdern Viadukt');
INSERT INTO meta_terms VALUES (2247, 'Sockelgeschoss Toni-Areal Westseite mit Graffiti-Kunst', 'Sockelgeschoss Toni-Areal Westseite mit Graffiti-Kunst');
INSERT INTO meta_terms VALUES (2249, 'Süd Ost', 'Süd Ost');
INSERT INTO meta_terms VALUES (2251, 'Geländeturm Hardturm-Areal mit Pfingstweidstrasse', 'Geländeturm Hardturm-Areal mit Pfingstweidstrasse');
INSERT INTO meta_terms VALUES (2253, 'Nord Ost', 'Nord Ost');
INSERT INTO meta_terms VALUES (2255, 'Umgebung', 'Umgebung');
INSERT INTO meta_terms VALUES (2257, 'Erzählung', 'Erzählung');
INSERT INTO meta_terms VALUES (2259, 'Wiederholung', 'Wiederholung');
INSERT INTO meta_terms VALUES (2261, '', 'Das Medienarchiv der Künste ist eine Plattform für mediales Arbeiten an der ZHdK. Das Open-Source-Entwicklungsprojekt des ITZ und des MIZ steht gegenwärtig in der Version 0.3 für Pilotprojekte der ZHdK zur Verfügung. Schritt für Schritt wird es nun für ei');
INSERT INTO meta_terms VALUES (2263, '', 'Visualisierungen in der Wissenschaftskommunikation – Der Bildeinsatz in der Landschafts- und Umweltplanung');
INSERT INTO meta_terms VALUES (2265, 'Praktikum', 'Praktikum');
INSERT INTO meta_terms VALUES (2267, 'Werken', 'Werken');
INSERT INTO meta_terms VALUES (2269, 'GZ Hirzenbach', 'GZ Hirzenbach');
INSERT INTO meta_terms VALUES (2271, 'Bildnerisches Gestalten', 'Bildnerisches Gestalten');
INSERT INTO meta_terms VALUES (2273, 'Videokurs', 'Videokurs');
INSERT INTO meta_terms VALUES (2275, 'Museumspädagogik', 'Museumspädagogik');
INSERT INTO meta_terms VALUES (2277, 'Vorschulstufe', 'Vorschulstufe');
INSERT INTO meta_terms VALUES (2279, 'Ausserschulische Vermittlung', 'Ausserschulische Vermittlung');
INSERT INTO meta_terms VALUES (2281, 'Kindergarten', 'Kindergarten');
INSERT INTO meta_terms VALUES (2283, 'Museum für Gegenwartskunst Basel', 'Museum für Gegenwartskunst Basel');
INSERT INTO meta_terms VALUES (2285, 'Freizeitbereich', 'Freizeitbereich');
INSERT INTO meta_terms VALUES (2287, 'GZ Hirzenbach Zürich', 'GZ Hirzenbach Zürich');
INSERT INTO meta_terms VALUES (2289, 'Jugendliche', 'Jugendliche');
INSERT INTO meta_terms VALUES (2291, 'Integration', 'Integration');
INSERT INTO meta_terms VALUES (2293, 'Berufsvorbereitung', 'Berufsvorbereitung');
INSERT INTO meta_terms VALUES (2295, 'Schulische Bildung', 'Schulische Bildung');
INSERT INTO meta_terms VALUES (2297, 'Kantonsschule Küsnacht', 'Kantonsschule Küsnacht');
INSERT INTO meta_terms VALUES (2299, 'Gestalten mit digitalen Medien', 'Gestalten mit digitalen Medien');
INSERT INTO meta_terms VALUES (2301, 'Erwachsenenbildung', 'Erwachsenenbildung');
INSERT INTO meta_terms VALUES (2303, 'Justizvollzugsanstalt Realta GR', 'Justizvollzugsanstalt Realta GR');
INSERT INTO meta_terms VALUES (2305, 'Radio', 'Radio');
INSERT INTO meta_terms VALUES (2307, 'Kollegium Schwyz', 'Kollegium Schwyz');
INSERT INTO meta_terms VALUES (2309, 'Bezirksschule Turgi', 'Bezirksschule Turgi');
INSERT INTO meta_terms VALUES (2311, 'Atelierschule Zürich', 'Atelierschule Zürich');
INSERT INTO meta_terms VALUES (2313, 'Sekundarstufe 2', 'Sekundarstufe 2');
INSERT INTO meta_terms VALUES (2315, 'Kantonsschule Stadelhofen Zürich', 'Kantonsschule Stadelhofen Zürich');
INSERT INTO meta_terms VALUES (2317, 'Spitalschule', 'Spitalschule');
INSERT INTO meta_terms VALUES (2319, 'BVS Biel', 'BVS Biel');
INSERT INTO meta_terms VALUES (2321, 'Master', 'Master');
INSERT INTO meta_terms VALUES (2323, 'Nach dem Krieg', 'Nach dem Krieg');
INSERT INTO meta_terms VALUES (2325, 'Ehemaliges Jugoslawien', 'Ehemaliges Jugoslawien');
INSERT INTO meta_terms VALUES (2327, 'Leben', 'Leben');
INSERT INTO meta_terms VALUES (2329, 'Balkan', 'Balkan');
INSERT INTO meta_terms VALUES (2331, '', 'Artikelbild-Nr.');
INSERT INTO meta_terms VALUES (2333, '', 'Identifikationsnummer für das Produktionsteam');
INSERT INTO meta_terms VALUES (2335, '', 'Identifikationsnummer für das Produktionsteam.');
INSERT INTO meta_terms VALUES (2337, 'Klang', 'Klang');
INSERT INTO meta_terms VALUES (2339, 'Glas', 'Glas');
INSERT INTO meta_terms VALUES (2341, 'Kanne', 'Kanne');
INSERT INTO meta_terms VALUES (2343, 'Golddekor', 'Golddekor');
INSERT INTO meta_terms VALUES (2345, 'Archäologie', 'Archäologie');
INSERT INTO meta_terms VALUES (2347, 'Liao-Dynastie', 'Liao-Dynastie');
INSERT INTO meta_terms VALUES (2349, 'China', 'China');
INSERT INTO meta_terms VALUES (2351, 'realistische Computergrafik', 'realistische Computergrafik');
INSERT INTO meta_terms VALUES (2353, 'computergenieriertes Bild', 'computergenieriertes Bild');
INSERT INTO meta_terms VALUES (2355, 'Game-Screenshot', 'Game-Screenshot');
INSERT INTO meta_terms VALUES (2357, 'Politik', 'Politik');
INSERT INTO meta_terms VALUES (2359, 'Ho?rspiel', 'Ho?rspiel');
INSERT INTO meta_terms VALUES (2361, 'Sund', 'Sund');
INSERT INTO meta_terms VALUES (2363, 'Super-8', 'Super-8');
INSERT INTO meta_terms VALUES (2365, 'VMK', 'VMK');
INSERT INTO meta_terms VALUES (2367, 'Boden', 'Boden');
INSERT INTO meta_terms VALUES (2369, 'Historische Besiedlung', 'Historische Besiedlung');
INSERT INTO meta_terms VALUES (2371, 'Virtuelle Landschaft', 'Virtuelle Landschaft');
INSERT INTO meta_terms VALUES (2373, 'Ruinen', 'Ruinen');
INSERT INTO meta_terms VALUES (2375, 'Büsch', 'Büsch');
INSERT INTO meta_terms VALUES (2377, 'Wildnis', 'Wildnis');
INSERT INTO meta_terms VALUES (2379, 'Fiktive Landschaft', 'Fiktive Landschaft');
INSERT INTO meta_terms VALUES (2381, 'Windmühle', 'Windmühle');
INSERT INTO meta_terms VALUES (2383, 'Regenbogen', 'Regenbogen');
INSERT INTO meta_terms VALUES (2385, 'märchenhaft', 'märchenhaft');
INSERT INTO meta_terms VALUES (2387, 'Turm', 'Turm');
INSERT INTO meta_terms VALUES (2389, 'schwarz', 'schwarz');
INSERT INTO meta_terms VALUES (2391, 'Mond', 'Mond');
INSERT INTO meta_terms VALUES (2393, 'Gräser', 'Gräser');
INSERT INTO meta_terms VALUES (2395, 'Waldlandschaft', 'Waldlandschaft');
INSERT INTO meta_terms VALUES (2397, 'unbelebt', 'unbelebt');
INSERT INTO meta_terms VALUES (2399, 'Auto', 'Auto');
INSERT INTO meta_terms VALUES (2401, 'Künstlerisches Forschungsprojekt', 'Künstlerisches Forschungsprojekt');
INSERT INTO meta_terms VALUES (2403, 'Globalisierung', 'Globalisierung');
INSERT INTO meta_terms VALUES (2405, '', 'Artikel Arbeitstitel');
INSERT INTO meta_terms VALUES (2407, '', 'Unter diesem Titel wird der Artikel während der Redaktion und Produktion geführt.');
INSERT INTO meta_terms VALUES (2409, 'zett 2-2012', 'zett 2-2012');
INSERT INTO meta_terms VALUES (2413, 'Tier', 'Tier');
INSERT INTO meta_terms VALUES (2415, 'Dia', 'Dia');
INSERT INTO meta_terms VALUES (2417, 'Zeit', 'Zeit');
INSERT INTO meta_terms VALUES (2419, 'Mediale Künste', 'Mediale Künste');
INSERT INTO meta_terms VALUES (2421, 'Sprache', 'Sprache');
INSERT INTO meta_terms VALUES (2423, 'Schrift', 'Schrift');
INSERT INTO meta_terms VALUES (2425, 'Pop', 'Pop');
INSERT INTO meta_terms VALUES (2427, 'Musikvideo', 'Musikvideo');
INSERT INTO meta_terms VALUES (2429, 'SNM Diplom 03', 'SNM Diplom 03');
INSERT INTO meta_terms VALUES (2431, 'HGKZ', 'HGKZ');
INSERT INTO meta_terms VALUES (2433, 'SNM - Studienbereich Neue Medien', 'SNM - Studienbereich Neue Medien');
INSERT INTO meta_terms VALUES (2435, 'Beatween', 'Beatween');
INSERT INTO meta_terms VALUES (2437, 'Michael Hampel', 'Michael Hampel');
INSERT INTO meta_terms VALUES (2439, 'Between', 'Between');
INSERT INTO meta_terms VALUES (2441, 'L''esprit d''escalier', 'L''esprit d''escalier');
INSERT INTO meta_terms VALUES (2443, 'Roman Abt', 'Roman Abt');
INSERT INTO meta_terms VALUES (2445, 'L''esprit l''escalier', 'L''esprit l''escalier');
INSERT INTO meta_terms VALUES (2447, 'Loogie.net TV', 'Loogie.net TV');
INSERT INTO meta_terms VALUES (2449, 'Marc Lee', 'Marc Lee');
INSERT INTO meta_terms VALUES (2451, 'Newslounge', 'Newslounge');
INSERT INTO meta_terms VALUES (2453, 'Philipp Oettli', 'Philipp Oettli');
INSERT INTO meta_terms VALUES (2455, 'Inside out / Outside in', 'Inside out / Outside in');
INSERT INTO meta_terms VALUES (2457, 'Marco Ryser', 'Marco Ryser');
INSERT INTO meta_terms VALUES (2459, 'Conservix', 'Conservix');
INSERT INTO meta_terms VALUES (2461, 'Fabian Thommen', 'Fabian Thommen');
INSERT INTO meta_terms VALUES (2463, 'Mami, ich will auch Super-Algorithmen', 'Mami, ich will auch Super-Algorithmen');
INSERT INTO meta_terms VALUES (2465, 'Niki Schawalder', 'Niki Schawalder');
INSERT INTO meta_terms VALUES (2467, 'Mami, ich will auch Super-Algorthmen', 'Mami, ich will auch Super-Algorthmen');
INSERT INTO meta_terms VALUES (2469, 'TRACK-THE-TRACKERS', 'TRACK-THE-TRACKERS');
INSERT INTO meta_terms VALUES (2471, 'Annina Rüst', 'Annina Rüst');
INSERT INTO meta_terms VALUES (2473, 'Storytool', 'Storytool');
INSERT INTO meta_terms VALUES (2475, 'Gino Filadoro', 'Gino Filadoro');
INSERT INTO meta_terms VALUES (2477, 'Mami, ich will auch Super-Algorithmen...!', 'Mami, ich will auch Super-Algorithmen...!');
INSERT INTO meta_terms VALUES (2479, 'Flyer', 'Flyer');
INSERT INTO meta_terms VALUES (2481, 'Artikel Instant Muve', 'Artikel Instant Muve');
INSERT INTO meta_terms VALUES (2483, 'Bewegung', 'Bewegung');
INSERT INTO meta_terms VALUES (2485, 'Videoinstallation', 'Videoinstallation');
INSERT INTO meta_terms VALUES (2487, 'Damaskus', 'Damaskus');
INSERT INTO meta_terms VALUES (2489, 'Artikel "Die Innenwelt der Aussenwelt der Stimme"', 'Artikel "Die Innenwelt der Aussenwelt der Stimme"');
INSERT INTO meta_terms VALUES (2491, 'Zett 2-11', 'Zett 2-11');
INSERT INTO meta_terms VALUES (2493, 'Bild zu Kurzartikel', 'Bild zu Kurzartikel');
INSERT INTO meta_terms VALUES (2495, 'Konzert', 'Konzert');
INSERT INTO meta_terms VALUES (2497, 'Basel', 'Basel');
INSERT INTO meta_terms VALUES (2499, 'plug.in', 'plug.in');
INSERT INTO meta_terms VALUES (2501, 'Personen', 'Personen');
INSERT INTO meta_terms VALUES (2503, 'SF Schweizer Film', 'SF Schweizer Film');
INSERT INTO meta_terms VALUES (2505, 'Innenaufnahme', 'Innenaufnahme');
INSERT INTO meta_terms VALUES (2507, 'Schauspieler', 'Schauspieler');
INSERT INTO meta_terms VALUES (2509, 'Der Patient', 'Der Patient');
INSERT INTO meta_terms VALUES (2511, 'Szene 53', 'Szene 53');
INSERT INTO meta_terms VALUES (2513, 'Szene 18X', 'Szene 18X');
INSERT INTO meta_terms VALUES (2515, 'Martin Rapold', 'Martin Rapold');
INSERT INTO meta_terms VALUES (2517, 'Rebecca Indermaur', 'Rebecca Indermaur');
INSERT INTO meta_terms VALUES (2519, 'Peter Freiburghaus', 'Peter Freiburghaus');
INSERT INTO meta_terms VALUES (2521, 'Dominique Devenport', 'Dominique Devenport');
INSERT INTO meta_terms VALUES (2523, 'Elia Bruellhart', 'Elia Bruellhart');
INSERT INTO meta_terms VALUES (2525, 'Max Gertsch', 'Max Gertsch');
INSERT INTO meta_terms VALUES (2527, 'Barbara Terpoorten', 'Barbara Terpoorten');
INSERT INTO meta_terms VALUES (2529, 'Barbara Kulcsar', 'Barbara Kulcsar');
INSERT INTO meta_terms VALUES (2531, 'Pierre Mennel', 'Pierre Mennel');
INSERT INTO meta_terms VALUES (2533, 'Host Club', 'Host Club');
INSERT INTO meta_terms VALUES (2535, 'archiv performativ', 'archiv performativ');
INSERT INTO meta_terms VALUES (2537, '2010 HS', '2010 HS');
INSERT INTO meta_terms VALUES (2539, 'Skill - Illustration, Layout und Produktion - LEUTE VON HEUTE, W45', 'Skill - Illustration, Layout und Produktion - LEUTE VON HEUTE, W45');
INSERT INTO meta_terms VALUES (2541, 'Skills W45/46', 'Skills W45/46');
INSERT INTO meta_terms VALUES (2543, 'Skill Clips', 'Skill Clips');
INSERT INTO meta_terms VALUES (2545, '2011 FS', '2011 FS');
INSERT INTO meta_terms VALUES (2547, 'Schwimmbad', 'Schwimmbad');
INSERT INTO meta_terms VALUES (2549, 'Pop Art', 'Pop Art');
INSERT INTO meta_terms VALUES (2551, '1970er ', '1970er ');
INSERT INTO meta_terms VALUES (2553, 'Feld', 'Feld');
INSERT INTO meta_terms VALUES (2555, 'Orange', 'Orange');
INSERT INTO meta_terms VALUES (2557, 'Post Impressionismus', 'Post Impressionismus');
INSERT INTO meta_terms VALUES (2559, 'fliegenpilz', 'fliegenpilz');
INSERT INTO meta_terms VALUES (2561, 'fly agaric', 'fly agaric');
INSERT INTO meta_terms VALUES (2563, 'Diplom', 'Diplom');
INSERT INTO meta_terms VALUES (2565, 'olut', 'olut');
INSERT INTO meta_terms VALUES (2567, 'bier', 'bier');
INSERT INTO meta_terms VALUES (2569, 'cans', 'cans');
INSERT INTO meta_terms VALUES (2571, 'büchsen', 'büchsen');
INSERT INTO meta_terms VALUES (2573, 'Zentralbibliothek', 'Zentralbibliothek');
INSERT INTO meta_terms VALUES (2575, 'Oper', 'Oper');
INSERT INTO meta_terms VALUES (2577, 'Folter', 'Folter');
INSERT INTO meta_terms VALUES (2579, 'Werbung', 'Werbung');
INSERT INTO meta_terms VALUES (2581, 'Erinnerung', 'Erinnerung');
INSERT INTO meta_terms VALUES (2583, 'Heimat', 'Heimat');
INSERT INTO meta_terms VALUES (2585, 'Gender', 'Gender');
INSERT INTO meta_terms VALUES (2587, 'Wien', 'Wien');
INSERT INTO meta_terms VALUES (2589, 'Andres Bosshardt', 'Andres Bosshardt');
INSERT INTO meta_terms VALUES (2591, 'Super-16mm', 'Super-16mm');
INSERT INTO meta_terms VALUES (2593, 'San Francisco', 'San Francisco');
INSERT INTO meta_terms VALUES (2595, 'Oldtimer', 'Oldtimer');
INSERT INTO meta_terms VALUES (2597, 'Bus', 'Bus');
INSERT INTO meta_terms VALUES (2599, 'Toy Story', 'Toy Story');
INSERT INTO meta_terms VALUES (2601, 'Filmplakat', 'Filmplakat');
INSERT INTO meta_terms VALUES (2603, 'Öffentliche Verkehrsmittel', 'Öffentliche Verkehrsmittel');
INSERT INTO meta_terms VALUES (2605, 'Strassenbahn', 'Strassenbahn');
INSERT INTO meta_terms VALUES (2607, 'Garage', 'Garage');
INSERT INTO meta_terms VALUES (2609, 'Brunnen', 'Brunnen');
INSERT INTO meta_terms VALUES (2611, 'Kloster', 'Kloster');
INSERT INTO meta_terms VALUES (2613, 'Kirche', 'Kirche');
INSERT INTO meta_terms VALUES (2615, 'Filmmusik', 'Filmmusik');
INSERT INTO meta_terms VALUES (2617, 'FTM-Projekte', 'FTM-Projekte');
INSERT INTO meta_terms VALUES (2619, 'FTM Schaufenster', 'FTM Schaufenster');
INSERT INTO meta_terms VALUES (2621, 'Horror Movie', 'Horror Movie');
INSERT INTO meta_terms VALUES (2623, 'Solothurn 2012 ', 'Solothurn 2012 ');
INSERT INTO meta_terms VALUES (2625, 'Horrorfilm', 'Horrorfilm');
INSERT INTO meta_terms VALUES (2627, 'Kollaboration', 'Kollaboration');
INSERT INTO meta_terms VALUES (2629, 'IT-Pool', 'IT-Pool');
INSERT INTO meta_terms VALUES (2631, 'Weiterbildung', 'Weiterbildung');
INSERT INTO meta_terms VALUES (2633, 'Einladung', 'Einladung');
INSERT INTO meta_terms VALUES (2635, 'Kreativität', 'Kreativität');
INSERT INTO meta_terms VALUES (2637, 'Event', 'Event');
INSERT INTO meta_terms VALUES (2639, 'zoo', 'zoo');
INSERT INTO meta_terms VALUES (2641, 'waran', 'waran');
INSERT INTO meta_terms VALUES (2643, 'tiger', 'tiger');
INSERT INTO meta_terms VALUES (2645, '', 'Kurzbeschreibung/Abstract');
INSERT INTO meta_terms VALUES (2647, '', 'Beteiligte Institutionen');
INSERT INTO meta_terms VALUES (2649, '', 'Porträtierte Personen');
INSERT INTO meta_terms VALUES (2651, '', 'Abteilung/Vertiefung ZHdK');
INSERT INTO meta_terms VALUES (2653, '', 'Erwähnung RechteinhaberIn');
INSERT INTO meta_terms VALUES (2655, '', 'Offen für Internet (ja/nein)');
INSERT INTO meta_terms VALUES (2657, '', 'Offen für Internet (ja = 1 / nein = 0)');
INSERT INTO meta_terms VALUES (2659, '', 'Beschreibung durch (vor dem vor dem Kopieren fürs MIZ-Achiv)');
INSERT INTO meta_terms VALUES (2661, 'Szenografie', 'Szenografie');
INSERT INTO meta_terms VALUES (2663, 'Freilichtspektakel', 'Freilichtspektakel');
INSERT INTO meta_terms VALUES (2665, 'Inszenierung', 'Inszenierung');
INSERT INTO meta_terms VALUES (2666, '', 'Vorbildung');
INSERT INTO meta_terms VALUES (2668, '', 'Weiterbildung');
INSERT INTO meta_terms VALUES (2670, 'CAST', 'CAST');
INSERT INTO meta_terms VALUES (2672, 'Bachelor 2011', 'Bachelor 2011');
INSERT INTO meta_terms VALUES (2674, 'Istanbul', 'Istanbul');
INSERT INTO meta_terms VALUES (2676, 'Webisodes', 'Webisodes');
INSERT INTO meta_terms VALUES (2678, 'Webdokumentation', 'Webdokumentation');
INSERT INTO meta_terms VALUES (2680, 'Sinnesbegegnungen', 'Sinnesbegegnungen');
INSERT INTO meta_terms VALUES (2682, 'Theoriearbiet', 'Theoriearbiet');
INSERT INTO meta_terms VALUES (2684, 'David Lynch', 'David Lynch');
INSERT INTO meta_terms VALUES (2686, 'Web', 'Web');
INSERT INTO meta_terms VALUES (2688, 'Isanbul', 'Isanbul');
INSERT INTO meta_terms VALUES (2690, 'Webdoku', 'Webdoku');
INSERT INTO meta_terms VALUES (2692, 'Bachelorausstellung CAST 2011', 'Bachelorausstellung CAST 2011');
INSERT INTO meta_terms VALUES (2694, 'Plakat', 'Plakat');
INSERT INTO meta_terms VALUES (2696, 'Radamisto', 'Radamisto');
INSERT INTO meta_terms VALUES (2698, 'Material-Archiv', 'Material-Archiv');
INSERT INTO meta_terms VALUES (2700, 'Werkstatt', 'Werkstatt');
INSERT INTO meta_terms VALUES (2702, 'DDE', 'DDE');
INSERT INTO meta_terms VALUES (2704, 'Provisorium', 'Provisorium');
INSERT INTO meta_terms VALUES (2706, 'Material', 'Material');
INSERT INTO meta_terms VALUES (2708, 'Graph', 'Graph');
INSERT INTO meta_terms VALUES (2710, 'RFID', 'RFID');
INSERT INTO meta_terms VALUES (2712, 'Materialmuster', 'Materialmuster');
INSERT INTO meta_terms VALUES (2714, 'Zett 3/11', 'Zett 3/11');
INSERT INTO meta_terms VALUES (2716, 'Museumskonzerte', 'Museumskonzerte');
INSERT INTO meta_terms VALUES (2718, 'Mobimo', 'Mobimo');
INSERT INTO meta_terms VALUES (2720, 'Badi Tiefenbrunnen', 'Badi Tiefenbrunnen');
INSERT INTO meta_terms VALUES (2722, 'Partitur John Cage', 'Partitur John Cage');
INSERT INTO meta_terms VALUES (2724, '3/11 Zett', '3/11 Zett');
INSERT INTO meta_terms VALUES (2726, 'Artikel Komposition', 'Artikel Komposition');
INSERT INTO meta_terms VALUES (2728, 'Bildschirm', 'Bildschirm');
INSERT INTO meta_terms VALUES (2730, 'Bilder Musik 11/12', 'Bilder Musik 11/12');
INSERT INTO meta_terms VALUES (2731, 'HELMRINDERKNECHT contemporary design gallery', 'HELMRINDERKNECHT contemporary design gallery');
INSERT INTO meta_terms VALUES (2733, 'www.helmrinderknecht.com', 'www.helmrinderknecht.com');
INSERT INTO meta_terms VALUES (2735, 'SS09', 'SS09');
INSERT INTO meta_terms VALUES (2737, 'PARIS', 'PARIS');
INSERT INTO meta_terms VALUES (2739, 'RTW', 'RTW');
INSERT INTO meta_terms VALUES (2741, 'SPRING SUMMER', 'SPRING SUMMER');
INSERT INTO meta_terms VALUES (2743, 'GARETH PUGH', 'GARETH PUGH');
INSERT INTO meta_terms VALUES (2745, 'Kolonialismus', 'Kolonialismus');
INSERT INTO meta_terms VALUES (2747, 'KulturMedienZukunft 2011', 'KulturMedienZukunft 2011');
INSERT INTO meta_terms VALUES (2749, 'Diedrich Diederichsen', 'Diedrich Diederichsen');
INSERT INTO meta_terms VALUES (2751, 'Plattform Kulturpublizistik', 'Plattform Kulturpublizistik');
INSERT INTO meta_terms VALUES (2753, 'Sommerakademie', 'Sommerakademie');
INSERT INTO meta_terms VALUES (2755, 'Workshop 2: Kultur deuten oder verkaufen', 'Workshop 2: Kultur deuten oder verkaufen');
INSERT INTO meta_terms VALUES (2757, 'Manfred Papst', 'Manfred Papst');
INSERT INTO meta_terms VALUES (2759, 'Jean-Martin Büttner', 'Jean-Martin Büttner');
INSERT INTO meta_terms VALUES (2761, 'TheaterMedienZukunft', 'TheaterMedienZukunft');
INSERT INTO meta_terms VALUES (2763, 'Tobi Müller', 'Tobi Müller');
INSERT INTO meta_terms VALUES (2765, 'Ursina Greuel', 'Ursina Greuel');
INSERT INTO meta_terms VALUES (2767, 'Lukas Bärfuss', 'Lukas Bärfuss');
INSERT INTO meta_terms VALUES (2769, 'Barbara Weber', 'Barbara Weber');
INSERT INTO meta_terms VALUES (2771, 'Peter Müller', 'Peter Müller');
INSERT INTO meta_terms VALUES (2773, 'Plinio Bachmann', 'Plinio Bachmann');
INSERT INTO meta_terms VALUES (2775, 'Featuretree', 'Featuretree');
INSERT INTO meta_terms VALUES (2777, 'Stakeholder', 'Stakeholder');
INSERT INTO meta_terms VALUES (2779, 'Organisation', 'Organisation');
INSERT INTO meta_terms VALUES (2781, 'OpenType', 'OpenType');
INSERT INTO meta_terms VALUES (2783, 'Klassifikation', 'Klassifikation');
INSERT INTO meta_terms VALUES (2785, 'Helvetica', 'Helvetica');
INSERT INTO meta_terms VALUES (2787, 'red dot', 'red dot');
INSERT INTO meta_terms VALUES (2789, 'Hannes Rickli', 'Hannes Rickli');
INSERT INTO meta_terms VALUES (2791, 'Kunstmuseum Thun', 'Kunstmuseum Thun');
INSERT INTO meta_terms VALUES (2793, 'IFCAR', 'IFCAR');
INSERT INTO meta_terms VALUES (2795, 'künstlerische Forschung', 'künstlerische Forschung');
INSERT INTO meta_terms VALUES (2797, 'Ausstellungsreihe labor', 'Ausstellungsreihe labor');
INSERT INTO meta_terms VALUES (2799, 'Journal für Kunst, Sex und Mathematik', 'Journal für Kunst, Sex und Mathematik');
INSERT INTO meta_terms VALUES (2801, 'Nils Röller', 'Nils Röller');
INSERT INTO meta_terms VALUES (2803, 'Ausstellung Indirekte Erfahrungen', 'Ausstellung Indirekte Erfahrungen');
INSERT INTO meta_terms VALUES (2805, 'search patterns', 'search patterns');
INSERT INTO meta_terms VALUES (2807, 'chapter two', 'chapter two');
INSERT INTO meta_terms VALUES (2809, 'search', 'search');
INSERT INTO meta_terms VALUES (2811, 'topic', 'topic');
INSERT INTO meta_terms VALUES (2813, 'format', 'format');
INSERT INTO meta_terms VALUES (2815, 'keyword', 'keyword');
INSERT INTO meta_terms VALUES (2817, 'portal', 'portal');
INSERT INTO meta_terms VALUES (2819, 'sites', 'sites');
INSERT INTO meta_terms VALUES (2821, 'categories', 'categories');
INSERT INTO meta_terms VALUES (2823, 'collections', 'collections');
INSERT INTO meta_terms VALUES (2825, 'objects', 'objects');
INSERT INTO meta_terms VALUES (2827, 'users', 'users');
INSERT INTO meta_terms VALUES (2829, 'find', 'find');
INSERT INTO meta_terms VALUES (2831, 'brand', 'brand');
INSERT INTO meta_terms VALUES (2833, 'findable', 'findable');
INSERT INTO meta_terms VALUES (2835, 'social', 'social');
INSERT INTO meta_terms VALUES (2837, 'ask', 'ask');
INSERT INTO meta_terms VALUES (2839, 'browse', 'browse');
INSERT INTO meta_terms VALUES (2841, 'paths', 'paths');
INSERT INTO meta_terms VALUES (2843, 'patterns', 'patterns');
INSERT INTO meta_terms VALUES (2845, 'incentives', 'incentives');
INSERT INTO meta_terms VALUES (2847, 'about', 'about');
INSERT INTO meta_terms VALUES (2849, 'discovery', 'discovery');
INSERT INTO meta_terms VALUES (2851, 'goal', 'goal');
INSERT INTO meta_terms VALUES (2853, 'gateway', 'gateway');
INSERT INTO meta_terms VALUES (2855, 'collection', 'collection');
INSERT INTO meta_terms VALUES (2857, 'federated', 'federated');
INSERT INTO meta_terms VALUES (2859, 'faceted', 'faceted');
INSERT INTO meta_terms VALUES (2861, 'fast', 'fast');
INSERT INTO meta_terms VALUES (2863, 'learning', 'learning');
INSERT INTO meta_terms VALUES (2865, 'collaboration', 'collaboration');
INSERT INTO meta_terms VALUES (2867, 'user', 'user');
INSERT INTO meta_terms VALUES (2869, 'designer', 'designer');
INSERT INTO meta_terms VALUES (2871, 'engineer', 'engineer');
INSERT INTO meta_terms VALUES (2873, 'content', 'content');
INSERT INTO meta_terms VALUES (2875, 'index', 'index');
INSERT INTO meta_terms VALUES (2877, 'algorithms', 'algorithms');
INSERT INTO meta_terms VALUES (2879, 'engine', 'engine');
INSERT INTO meta_terms VALUES (2881, 'results', 'results');
INSERT INTO meta_terms VALUES (2883, 'response', 'response');
INSERT INTO meta_terms VALUES (2885, 'query', 'query');
INSERT INTO meta_terms VALUES (2887, 'user experience', 'user experience');
INSERT INTO meta_terms VALUES (2889, 'useful', 'useful');
INSERT INTO meta_terms VALUES (2891, 'desireble', 'desireble');
INSERT INTO meta_terms VALUES (2893, 'accessible', 'accessible');
INSERT INTO meta_terms VALUES (2895, 'credible', 'credible');
INSERT INTO meta_terms VALUES (2897, 'usable', 'usable');
INSERT INTO meta_terms VALUES (2899, 'valuable', 'valuable');
INSERT INTO meta_terms VALUES (2901, 'recall', 'recall');
INSERT INTO meta_terms VALUES (2903, 'precision', 'precision');
INSERT INTO meta_terms VALUES (2905, 'interaction', 'interaction');
INSERT INTO meta_terms VALUES (2907, 'affordances', 'affordances');
INSERT INTO meta_terms VALUES (2909, 'language', 'language');
INSERT INTO meta_terms VALUES (2911, 'features', 'features');
INSERT INTO meta_terms VALUES (2913, 'technology', 'technology');
INSERT INTO meta_terms VALUES (2915, 'indexing', 'indexing');
INSERT INTO meta_terms VALUES (2917, 'structure', 'structure');
INSERT INTO meta_terms VALUES (2919, 'metadata', 'metadata');
INSERT INTO meta_terms VALUES (2921, 'goals', 'goals');
INSERT INTO meta_terms VALUES (2923, 'psychology', 'psychology');
INSERT INTO meta_terms VALUES (2925, 'behaviour', 'behaviour');
INSERT INTO meta_terms VALUES (2927, 'creators', 'creators');
INSERT INTO meta_terms VALUES (2929, 'tools', 'tools');
INSERT INTO meta_terms VALUES (2931, 'process', 'process');
INSERT INTO meta_terms VALUES (2933, 'object', 'object');
INSERT INTO meta_terms VALUES (2935, 'subject', 'subject');
INSERT INTO meta_terms VALUES (2937, 'audience', 'audience');
INSERT INTO meta_terms VALUES (2939, 'popularity', 'popularity');
INSERT INTO meta_terms VALUES (2941, 'author', 'author');
INSERT INTO meta_terms VALUES (2943, 'category', 'category');
INSERT INTO meta_terms VALUES (2945, 'tags', 'tags');
INSERT INTO meta_terms VALUES (2947, 'lists', 'lists');
INSERT INTO meta_terms VALUES (2949, 'guides', 'guides');
INSERT INTO meta_terms VALUES (2951, 'phrases', 'phrases');
INSERT INTO meta_terms VALUES (2953, 'citations', 'citations');
INSERT INTO meta_terms VALUES (2955, 'frequently bought togehter', 'frequently bought togehter');
INSERT INTO meta_terms VALUES (2957, 'common next steps', 'common next steps');
INSERT INTO meta_terms VALUES (2959, 'rate', 'rate');
INSERT INTO meta_terms VALUES (2961, 'review', 'review');
INSERT INTO meta_terms VALUES (2963, 'share', 'share');
INSERT INTO meta_terms VALUES (2965, 'self-publishing', 'self-publishing');
INSERT INTO meta_terms VALUES (2967, 'facets', 'facets');
INSERT INTO meta_terms VALUES (2969, 'limited facets', 'limited facets');
INSERT INTO meta_terms VALUES (2971, 'rich facets', 'rich facets');
INSERT INTO meta_terms VALUES (2973, 'haunted house', 'haunted house');
INSERT INTO meta_terms VALUES (2975, 'search & discovery', 'search & discovery');
INSERT INTO meta_terms VALUES (2977, 'knowledge management', 'knowledge management');
INSERT INTO meta_terms VALUES (2979, 'designers', 'designers');
INSERT INTO meta_terms VALUES (2981, 'analytics', 'analytics');
INSERT INTO meta_terms VALUES (2983, 'redundant', 'redundant');
INSERT INTO meta_terms VALUES (2985, 'outdated', 'outdated');
INSERT INTO meta_terms VALUES (2987, 'trivial', 'trivial');
INSERT INTO meta_terms VALUES (2989, 'source', 'source');
INSERT INTO meta_terms VALUES (2991, 'date', 'date');
INSERT INTO meta_terms VALUES (2993, 'location', 'location');
INSERT INTO meta_terms VALUES (2995, 'rating', 'rating');
INSERT INTO meta_terms VALUES (2997, 'creator', 'creator');
INSERT INTO meta_terms VALUES (2999, 'who', 'who');
INSERT INTO meta_terms VALUES (3001, 'where', 'where');
INSERT INTO meta_terms VALUES (3003, 'why', 'why');
INSERT INTO meta_terms VALUES (3005, 'what', 'what');
INSERT INTO meta_terms VALUES (3007, 'when', 'when');
INSERT INTO meta_terms VALUES (3009, 'how', 'how');
INSERT INTO meta_terms VALUES (3011, 'chapter one', 'chapter one');
INSERT INTO meta_terms VALUES (3013, 'context', 'context');
INSERT INTO meta_terms VALUES (3015, 'vertical', 'vertical');
INSERT INTO meta_terms VALUES (3017, 'platform', 'platform');
INSERT INTO meta_terms VALUES (3019, 'result', 'result');
INSERT INTO meta_terms VALUES (3021, 'action', 'action');
INSERT INTO meta_terms VALUES (3023, 'understand', 'understand');
INSERT INTO meta_terms VALUES (3025, 'map', 'map');
INSERT INTO meta_terms VALUES (3027, 'document', 'document');
INSERT INTO meta_terms VALUES (3029, 'learn', 'learn');
INSERT INTO meta_terms VALUES (3031, 'workflow', 'workflow');
INSERT INTO meta_terms VALUES (3033, 'social network', 'social network');
INSERT INTO meta_terms VALUES (3035, 'filter', 'filter');
INSERT INTO meta_terms VALUES (3037, 'lens', 'lens');
INSERT INTO meta_terms VALUES (3039, 'feeds', 'feeds');
INSERT INTO meta_terms VALUES (3041, 'question', 'question');
INSERT INTO meta_terms VALUES (3043, 'Fremde Dichter', 'Fremde Dichter');
INSERT INTO meta_terms VALUES (3045, 'Lecture Performance von Sibylle Peters (Giessen/Hamburg)', 'Lecture Performance von Sibylle Peters (Giessen/Hamburg)');
INSERT INTO meta_terms VALUES (3047, 'IDE', 'IDE');
INSERT INTO meta_terms VALUES (3049, 'Arbeitspapier', 'Arbeitspapier');
INSERT INTO meta_terms VALUES (3051, 'Vektor', 'Vektor');
INSERT INTO meta_terms VALUES (3053, 'Vermessung', 'Vermessung');
INSERT INTO meta_terms VALUES (3055, 'Melodrama', 'Melodrama');
INSERT INTO meta_terms VALUES (3057, 'Sarajevo', 'Sarajevo');
INSERT INTO meta_terms VALUES (3059, 'Krieg', 'Krieg');
INSERT INTO meta_terms VALUES (3061, 'Tanzen', 'Tanzen');
INSERT INTO meta_terms VALUES (3063, 'Kino', 'Kino');
INSERT INTO meta_terms VALUES (3065, 'Bar', 'Bar');
INSERT INTO meta_terms VALUES (3067, 'Akt', 'Akt');
INSERT INTO meta_terms VALUES (3069, 'Frau', 'Frau');
INSERT INTO meta_terms VALUES (3071, 'retromorphosen', 'retromorphosen');
INSERT INTO meta_terms VALUES (3073, 'gamedesign', 'gamedesign');
INSERT INTO meta_terms VALUES (3075, 'atari 2600', 'atari 2600');
INSERT INTO meta_terms VALUES (3077, 'Rauchen', 'Rauchen');
INSERT INTO meta_terms VALUES (3079, 'Postkarten', 'Postkarten');
INSERT INTO meta_terms VALUES (3081, 'Reisen', 'Reisen');
INSERT INTO meta_terms VALUES (3083, 'Sehnsucht', 'Sehnsucht');
INSERT INTO meta_terms VALUES (3085, 'Segeln', 'Segeln');
INSERT INTO meta_terms VALUES (3087, 'Insel', 'Insel');
INSERT INTO meta_terms VALUES (3089, 'Schwimmbecken', 'Schwimmbecken');
INSERT INTO meta_terms VALUES (3091, 'Hotel', 'Hotel');
INSERT INTO meta_terms VALUES (3093, 'Heimweh', 'Heimweh');
INSERT INTO meta_terms VALUES (3095, 'Sepia', 'Sepia');
INSERT INTO meta_terms VALUES (3097, 'Vergangenheit', 'Vergangenheit');
INSERT INTO meta_terms VALUES (3099, 'Indexierung', 'Indexierung');
INSERT INTO meta_terms VALUES (3101, 'Bilder', 'Bilder');
INSERT INTO meta_terms VALUES (3103, 'Farben', 'Farben');
INSERT INTO meta_terms VALUES (3105, 'People', 'People');
INSERT INTO meta_terms VALUES (3107, 'Entwurf', 'Entwurf');
INSERT INTO meta_terms VALUES (3109, 'ODI', 'ODI');
INSERT INTO meta_terms VALUES (3110, 'Urbanismus', 'Urbanismus');
INSERT INTO meta_terms VALUES (3112, 'Syrien', 'Syrien');
INSERT INTO meta_terms VALUES (3114, 'Postkolonialismus', 'Postkolonialismus');
INSERT INTO meta_terms VALUES (3116, 'Datenbanken', 'Datenbanken');
INSERT INTO meta_terms VALUES (3118, 'Hinterface', 'Hinterface');
INSERT INTO meta_terms VALUES (3120, 'Uni', 'Uni');
INSERT INTO meta_terms VALUES (3122, 'Lüneburg', 'Lüneburg');
INSERT INTO meta_terms VALUES (3124, 'Impressionen', 'Impressionen');
INSERT INTO meta_terms VALUES (3126, 'Verkehr', 'Verkehr');
INSERT INTO meta_terms VALUES (3128, 'Typografie', 'Typografie');
INSERT INTO meta_terms VALUES (3130, 'Fremde Kultur', 'Fremde Kultur');
INSERT INTO meta_terms VALUES (3132, 'Kollage', 'Kollage');
INSERT INTO meta_terms VALUES (3134, 'Interaktion', 'Interaktion');
INSERT INTO meta_terms VALUES (3136, 'Verknüpfung', 'Verknüpfung');
INSERT INTO meta_terms VALUES (3138, 'Studie', 'Studie');
INSERT INTO meta_terms VALUES (3140, 'Digitale Kollage', 'Digitale Kollage');
INSERT INTO meta_terms VALUES (3142, 'Bildähnlichkeit', 'Bildähnlichkeit');
INSERT INTO meta_terms VALUES (3144, 'Annotation', 'Annotation');
INSERT INTO meta_terms VALUES (3146, 'Suchmaschine', 'Suchmaschine');
INSERT INTO meta_terms VALUES (3148, 'Suchen', 'Suchen');
INSERT INTO meta_terms VALUES (3150, 'Algorithmus', 'Algorithmus');
INSERT INTO meta_terms VALUES (3152, 'Tagging', 'Tagging');
INSERT INTO meta_terms VALUES (3154, 'Filtern', 'Filtern');
INSERT INTO meta_terms VALUES (3156, 'GIS', 'GIS');
INSERT INTO meta_terms VALUES (3158, 'Skizze', 'Skizze');
INSERT INTO meta_terms VALUES (3160, 'Trails and Traces', 'Trails and Traces');
INSERT INTO meta_terms VALUES (3162, 'Werkzeuge', 'Werkzeuge');
INSERT INTO meta_terms VALUES (3164, 'Modelle', 'Modelle');
INSERT INTO meta_terms VALUES (3166, 'Grundlagen', 'Grundlagen');
INSERT INTO meta_terms VALUES (3168, 'Erklärung', 'Erklärung');
INSERT INTO meta_terms VALUES (3170, 'Interaktionsmodell', 'Interaktionsmodell');
INSERT INTO meta_terms VALUES (3172, 'Organisieren', 'Organisieren');
INSERT INTO meta_terms VALUES (3174, 'Werkzeug', 'Werkzeug');
INSERT INTO meta_terms VALUES (3176, 'Ordnen', 'Ordnen');
INSERT INTO meta_terms VALUES (3178, 'Zugreifen', 'Zugreifen');
INSERT INTO meta_terms VALUES (3180, 'Browsen', 'Browsen');
INSERT INTO meta_terms VALUES (3182, 'Themen', 'Themen');
INSERT INTO meta_terms VALUES (3184, 'Foto', 'Foto');
INSERT INTO meta_terms VALUES (3186, 'Cybu Richli', 'Cybu Richli');
INSERT INTO meta_terms VALUES (3188, 'Welcome2India', 'Welcome2India');
INSERT INTO meta_terms VALUES (3190, 'GloCal', 'GloCal');
INSERT INTO meta_terms VALUES (3192, 'Bachelor Design', 'Bachelor Design');
INSERT INTO meta_terms VALUES (3194, 'Seminarreise', 'Seminarreise');
INSERT INTO meta_terms VALUES (3196, 'interkulturelle Kompetenz', 'interkulturelle Kompetenz');
INSERT INTO meta_terms VALUES (3198, 'Designethnografie', 'Designethnografie');
INSERT INTO meta_terms VALUES (3200, 'Color', 'Color');
INSERT INTO meta_terms VALUES (3202, 'Bharatpur', 'Bharatpur');
INSERT INTO meta_terms VALUES (3204, 'Highway', 'Highway');
INSERT INTO meta_terms VALUES (3206, 'Delhi', 'Delhi');
INSERT INTO meta_terms VALUES (3208, 'Spice Market', 'Spice Market');
INSERT INTO meta_terms VALUES (3210, 'Boy', 'Boy');
INSERT INTO meta_terms VALUES (3212, 'Ahmedabad', 'Ahmedabad');
INSERT INTO meta_terms VALUES (3214, 'Mumbay', 'Mumbay');
INSERT INTO meta_terms VALUES (3216, 'Islam', 'Islam');
INSERT INTO meta_terms VALUES (3219, 'Alter Mann', 'Alter Mann');
INSERT INTO meta_terms VALUES (3221, 'lesen', 'lesen');
INSERT INTO meta_terms VALUES (3223, 'Pfeil', 'Pfeil');
INSERT INTO meta_terms VALUES (3225, 'Hand', 'Hand');
INSERT INTO meta_terms VALUES (3227, 'Winken', 'Winken');
INSERT INTO meta_terms VALUES (3229, 'Stangen', 'Stangen');
INSERT INTO meta_terms VALUES (3231, 'Applikation', 'Applikation');
INSERT INTO meta_terms VALUES (3233, 'Computer', 'Computer');
INSERT INTO meta_terms VALUES (3235, 'Handykamera', 'Handykamera');
INSERT INTO meta_terms VALUES (3237, 'Weisheit', 'Weisheit');
INSERT INTO meta_terms VALUES (3239, 'Junger Mann', 'Junger Mann');
INSERT INTO meta_terms VALUES (3241, 'Händler', 'Händler');
INSERT INTO meta_terms VALUES (3243, 'knieen', 'knieen');
INSERT INTO meta_terms VALUES (3245, 'Tücher', 'Tücher');
INSERT INTO meta_terms VALUES (3247, 'lila', 'lila');
INSERT INTO meta_terms VALUES (3249, 'Gewand', 'Gewand');
INSERT INTO meta_terms VALUES (3251, 'Markt', 'Markt');
INSERT INTO meta_terms VALUES (3253, 'Gewürze', 'Gewürze');
INSERT INTO meta_terms VALUES (3255, '', 'Indikatoren Forschung ZHdK');
INSERT INTO meta_terms VALUES (3265, '', 'sdfd');
INSERT INTO meta_terms VALUES (3269, '', 'Drittmittel');
INSERT INTO meta_terms VALUES (3271, '', 'Fachveranstaltungen');
INSERT INTO meta_terms VALUES (3273, '', 'einschl. Ausstellungen und Konzerte');
INSERT INTO meta_terms VALUES (3275, '', 'Transfer');
INSERT INTO meta_terms VALUES (3277, '', 'In Lehre, Weiterbildung und Dienstleistung');
INSERT INTO meta_terms VALUES (3279, '', 'Verbreitung');
INSERT INTO meta_terms VALUES (3281, '', 'Anwendung und Wirkung in div. gesellschaftlichen Bereichen');
INSERT INTO meta_terms VALUES (3283, '', 'Vernetzung');
INSERT INTO meta_terms VALUES (3285, '', 'Veröffentlichungen');
INSERT INTO meta_terms VALUES (3287, '', 'Wissenschafts- und Institutsbetrieb');
INSERT INTO meta_terms VALUES (3289, 'Monografie', 'Monografie');
INSERT INTO meta_terms VALUES (3291, 'Dissertation', 'Dissertation');
INSERT INTO meta_terms VALUES (3293, 'Buch in Herausgeberschaft', 'Buch in Herausgeberschaft');
INSERT INTO meta_terms VALUES (3295, 'Buchkapitel', 'Buchkapitel');
INSERT INTO meta_terms VALUES (3297, 'Artikel in einem wiss. Journal', 'Artikel in einem wiss. Journal');
INSERT INTO meta_terms VALUES (3299, 'Proceedings', 'Proceedings');
INSERT INTO meta_terms VALUES (3301, 'Unveröffentlichte Dissertation', 'Unveröffentlichte Dissertation');
INSERT INTO meta_terms VALUES (3303, 'Artikel in einem Magazin', 'Artikel in einem Magazin');
INSERT INTO meta_terms VALUES (3305, 'Zeitungsartikel', 'Zeitungsartikel');
INSERT INTO meta_terms VALUES (3307, 'On-line Veröffentlichung', 'On-line Veröffentlichung');
INSERT INTO meta_terms VALUES (3309, 'Blog / Online Diskussionsforum', 'Blog / Online Diskussionsforum');
INSERT INTO meta_terms VALUES (3311, 'Organisation von Tagungen, Konferenzen, Tätigkeit in Wissenschaftsorganisationen', 'Organisation von Tagungen, Konferenzen, Tätigkeit in Wissenschaftsorganisationen');
INSERT INTO meta_terms VALUES (3313, 'Symposium, Tagesveranstaltungen', 'Symposium, Tagesveranstaltungen');
INSERT INTO meta_terms VALUES (3315, 'Ausstellungen, Konzerte, Aufführungen', 'Ausstellungen, Konzerte, Aufführungen');
INSERT INTO meta_terms VALUES (3317, 'Ausstellungsbeteiligung, Konzertbeteiligung', 'Ausstellungsbeteiligung, Konzertbeteiligung');
INSERT INTO meta_terms VALUES (3319, 'Vorträge auf Fachkonferenzen, Universitäten, etc.', 'Vorträge auf Fachkonferenzen, Universitäten, etc.');
INSERT INTO meta_terms VALUES (3321, 'Werke (Kunst, Musik, Design, Film, Video u.a.)', 'Werke (Kunst, Musik, Design, Film, Video u.a.)');
INSERT INTO meta_terms VALUES (3323, 'Sammlungen und Archive', 'Sammlungen und Archive');
INSERT INTO meta_terms VALUES (3325, 'Patente', 'Patente');
INSERT INTO meta_terms VALUES (3327, 'öffentliche Präsentationen (Tag der Forschung, etc.)', 'öffentliche Präsentationen (Tag der Forschung, etc.)');
INSERT INTO meta_terms VALUES (3329, 'Preise, Auszeichnungen, Forschungsstipendien, etc.', 'Preise, Auszeichnungen, Forschungsstipendien, etc.');
INSERT INTO meta_terms VALUES (3331, 'Medienresonanz', 'Medienresonanz');
INSERT INTO meta_terms VALUES (3333, 'Einbindung der Forschung in Studiengänge und Lehrveranstaltungen', 'Einbindung der Forschung in Studiengänge und Lehrveranstaltungen');
INSERT INTO meta_terms VALUES (3335, 'Betreuung Abschlussarbeiten (Master) und Promotionen (PhD)', 'Betreuung Abschlussarbeiten (Master) und Promotionen (PhD)');
INSERT INTO meta_terms VALUES (3337, 'Einbindung der Forschung in Weiterbildungsangebote', 'Einbindung der Forschung in Weiterbildungsangebote');
INSERT INTO meta_terms VALUES (3339, 'Massnahmen zur Nachwuchsförderung', 'Massnahmen zur Nachwuchsförderung');
INSERT INTO meta_terms VALUES (3341, 'Forschungskooperationen (national, international)', 'Forschungskooperationen (national, international)');
INSERT INTO meta_terms VALUES (3343, 'Kooperationen mit Wirtschaft und öffentlichem Sektor', 'Kooperationen mit Wirtschaft und öffentlichem Sektor');
INSERT INTO meta_terms VALUES (3345, 'Institutioneller Fachausstausch (Konferenzteilnahme, Diskussionen, Panels, Symposien, Workshops))', 'Institutioneller Fachausstausch (Konferenzteilnahme, Diskussionen, Panels, Symposien, Workshops))');
INSERT INTO meta_terms VALUES (3347, 'Mitgliedschaft bei Institutionen, Fachschaften, etc.', 'Mitgliedschaft bei Institutionen, Fachschaften, etc.');
INSERT INTO meta_terms VALUES (3349, 'Gutacher- und forschungsbez. Beratertätigkeit', 'Gutacher- und forschungsbez. Beratertätigkeit');
INSERT INTO meta_terms VALUES (3351, 'Beiträge zur Umsetzung von Forschungsergebnissen in Wirtschaft, Politik, Verwaltung, Verbänden, u.a.', 'Beiträge zur Umsetzung von Forschungsergebnissen in Wirtschaft, Politik, Verwaltung, Verbänden, u.a.');
INSERT INTO meta_terms VALUES (3353, 'Wissensvermittlung und -verbreitung', 'Wissensvermittlung und -verbreitung');
INSERT INTO meta_terms VALUES (3355, 'Erhaltene Rufe', 'Erhaltene Rufe');
INSERT INTO meta_terms VALUES (3357, 'Drittmittel für Forschungsprojekte', 'Drittmittel für Forschungsprojekte');
INSERT INTO meta_terms VALUES (3359, 'Drittmittel für Auftragsforschung', 'Drittmittel für Auftragsforschung');
INSERT INTO meta_terms VALUES (3623, 'Transformation 1', 'Transformation 1');
INSERT INTO meta_terms VALUES (3625, 'Altkleider', 'Altkleider');
INSERT INTO meta_terms VALUES (3361, 'Drittmittel von Stiftungen, Firmen, Privaten', 'Drittmittel von Stiftungen, Firmen, Privaten');
INSERT INTO meta_terms VALUES (3363, 'Drittmittel aus Weiterbildung', 'Drittmittel aus Weiterbildung');
INSERT INTO meta_terms VALUES (3365, 'Aus Dienstleistung und Entwicklungsprojekten', 'Aus Dienstleistung und Entwicklungsprojekten');
INSERT INTO meta_terms VALUES (3367, 'Eigenmittel ZHdK', 'Eigenmittel ZHdK');
INSERT INTO meta_terms VALUES (3369, '', 'Personengebundene Aktivitäten');
INSERT INTO meta_terms VALUES (3371, '', 'Forschung ZHdK');
INSERT INTO meta_terms VALUES (3373, '', 'Nennung Fachveranstaltungen');
INSERT INTO meta_terms VALUES (3375, '', 'Nennung Veröffentlichungen');
INSERT INTO meta_terms VALUES (3377, '', '.');
INSERT INTO meta_terms VALUES (3379, 'Börsenkurse', 'Börsenkurse');
INSERT INTO meta_terms VALUES (3381, 'Raumschiff', 'Raumschiff');
INSERT INTO meta_terms VALUES (3383, 'Disco', 'Disco');
INSERT INTO meta_terms VALUES (3385, 'Fast-Food', 'Fast-Food');
INSERT INTO meta_terms VALUES (3387, 'Kraftmaschine', 'Kraftmaschine');
INSERT INTO meta_terms VALUES (3389, 'Überwachungskamera', 'Überwachungskamera');
INSERT INTO meta_terms VALUES (3391, 'Rockkonzert', 'Rockkonzert');
INSERT INTO meta_terms VALUES (3393, 'Unruhen', 'Unruhen');
INSERT INTO meta_terms VALUES (3395, 'Reportagefotografie', 'Reportagefotografie');
INSERT INTO meta_terms VALUES (3397, 'Zuschauer', 'Zuschauer');
INSERT INTO meta_terms VALUES (3399, 'Demonstration', 'Demonstration');
INSERT INTO meta_terms VALUES (3401, 'Hochhaus', 'Hochhaus');
INSERT INTO meta_terms VALUES (3403, 'Jazzkonzert', 'Jazzkonzert');
INSERT INTO meta_terms VALUES (3405, 'Fahrrad', 'Fahrrad');
INSERT INTO meta_terms VALUES (3407, 'Ballon', 'Ballon');
INSERT INTO meta_terms VALUES (3408, 'Serious Games', 'Serious Games');
INSERT INTO meta_terms VALUES (3410, 'Mosaik', 'Mosaik');
INSERT INTO meta_terms VALUES (3412, 'Unterricht', 'Unterricht');
INSERT INTO meta_terms VALUES (3414, 'Puzzle', 'Puzzle');
INSERT INTO meta_terms VALUES (3416, 'Kunststoff', 'Kunststoff');
INSERT INTO meta_terms VALUES (3418, 'Fotoklasse', 'Fotoklasse');
INSERT INTO meta_terms VALUES (3420, 'Kathedrale', 'Kathedrale');
INSERT INTO meta_terms VALUES (3422, 'Dateiformate', 'Dateiformate');
INSERT INTO meta_terms VALUES (3424, 'txt-datei', 'txt-datei');
INSERT INTO meta_terms VALUES (3426, 'java-datei', 'java-datei');
INSERT INTO meta_terms VALUES (3428, 'Studierendenarbeit', 'Studierendenarbeit');
INSERT INTO meta_terms VALUES (3430, 'CD Cover', 'CD Cover');
INSERT INTO meta_terms VALUES (3432, '', 'Informationstechnik');
INSERT INTO meta_terms VALUES (3434, 'Anonymität', 'Anonymität');
INSERT INTO meta_terms VALUES (3436, 'inkognito', 'inkognito');
INSERT INTO meta_terms VALUES (3437, 'Verarbeitungstechniken', 'Verarbeitungstechniken');
INSERT INTO meta_terms VALUES (3439, 'Leder', 'Leder');
INSERT INTO meta_terms VALUES (3441, 'interdisziplinäre', 'interdisziplinäre');
INSERT INTO meta_terms VALUES (3443, 'Traffic / Transport', 'Traffic / Transport');
INSERT INTO meta_terms VALUES (3445, 'Urban Space', 'Urban Space');
INSERT INTO meta_terms VALUES (3447, 'Men', 'Men');
INSERT INTO meta_terms VALUES (3449, 'Jantar Mantar', 'Jantar Mantar');
INSERT INTO meta_terms VALUES (3451, 'Architecture', 'Architecture');
INSERT INTO meta_terms VALUES (3453, 'Colors', 'Colors');
INSERT INTO meta_terms VALUES (3455, 'Children', 'Children');
INSERT INTO meta_terms VALUES (3457, 'white', 'white');
INSERT INTO meta_terms VALUES (3459, 'Typography', 'Typography');
INSERT INTO meta_terms VALUES (3461, 'Old Delhi', 'Old Delhi');
INSERT INTO meta_terms VALUES (3463, 'Wall Painting', 'Wall Painting');
INSERT INTO meta_terms VALUES (3465, 'Cow', 'Cow');
INSERT INTO meta_terms VALUES (3467, 'Sleeping', 'Sleeping');
INSERT INTO meta_terms VALUES (3469, 'Lodhi Garden', 'Lodhi Garden');
INSERT INTO meta_terms VALUES (3471, 'green', 'green');
INSERT INTO meta_terms VALUES (3473, 'blue', 'blue');
INSERT INTO meta_terms VALUES (3475, 'Train', 'Train');
INSERT INTO meta_terms VALUES (3477, '.Ahmedabad', '.Ahmedabad');
INSERT INTO meta_terms VALUES (3479, 'Women', 'Women');
INSERT INTO meta_terms VALUES (3481, 'Heritage House', 'Heritage House');
INSERT INTO meta_terms VALUES (3483, 'Metha', 'Metha');
INSERT INTO meta_terms VALUES (3485, 'BOF', 'BOF');
INSERT INTO meta_terms VALUES (3487, 'Art', 'Art');
INSERT INTO meta_terms VALUES (3489, 'Temple', 'Temple');
INSERT INTO meta_terms VALUES (3491, 'Animal', 'Animal');
INSERT INTO meta_terms VALUES (3493, 'Vegetable / Fruit', 'Vegetable / Fruit');
INSERT INTO meta_terms VALUES (3495, 'Tamil Nadu', 'Tamil Nadu');
INSERT INTO meta_terms VALUES (3497, 'NID', 'NID');
INSERT INTO meta_terms VALUES (3499, 'Dwell', 'Dwell');
INSERT INTO meta_terms VALUES (3501, 'Mumbai', 'Mumbai');
INSERT INTO meta_terms VALUES (3503, 'Art Gallery', 'Art Gallery');
INSERT INTO meta_terms VALUES (3505, 'Sunil Padwal', 'Sunil Padwal');
INSERT INTO meta_terms VALUES (3507, 'Vivandrum', 'Vivandrum');
INSERT INTO meta_terms VALUES (3509, 'yellow', 'yellow');
INSERT INTO meta_terms VALUES (3511, 'Pushkar', 'Pushkar');
INSERT INTO meta_terms VALUES (3513, 'Tag / SIgn', 'Tag / SIgn');
INSERT INTO meta_terms VALUES (3515, 'Doodle', 'Doodle');
INSERT INTO meta_terms VALUES (3517, 'Cochin', 'Cochin');
INSERT INTO meta_terms VALUES (3519, '', 'Welcher Aspekt des Themas der Säulenordnungen wird behandelt? ');
INSERT INTO meta_terms VALUES (3521, '', 'Absicht');
INSERT INTO meta_terms VALUES (3523, '', 'Welche Absicht wird mit dem Projekt verfolgt? ');
INSERT INTO meta_terms VALUES (3525, '', 'In welchem Kontext wird das Projekt realisiert?');
INSERT INTO meta_terms VALUES (3527, '', 'Was ist das Ausgangsmaterial der Untersuchung?');
INSERT INTO meta_terms VALUES (3529, '', 'Welche Informationstechnik kommt zum Einsatz?');
INSERT INTO meta_terms VALUES (3531, '', 'Welche Art von Daten werden beim Einsatz der Informationstechniken erzeugt?');
INSERT INTO meta_terms VALUES (3533, '', 'Auf welche Weise wird aus den Daten eine sinnvoll zu rezipierende Form?');
INSERT INTO meta_terms VALUES (3535, '', 'Welchen Konzepten einer computergestützten Architekturgeschichte ist das Projekt / das Werk zuzuordnen?');
INSERT INTO meta_terms VALUES (3537, '', 'Welchem Konzept einer computergestützten Architekturgeschichte ist das Projekt / das Werk zuzuordnen?');
INSERT INTO meta_terms VALUES (3539, 'NASA', 'NASA');
INSERT INTO meta_terms VALUES (3541, 'Cape Canaveral', 'Cape Canaveral');
INSERT INTO meta_terms VALUES (3543, '[]', '[]');
INSERT INTO meta_terms VALUES (3545, 'madek core: Schlagworte zu Inhalt und Motiv', 'madek core: Schlagworte zu Inhalt und Motiv');
INSERT INTO meta_terms VALUES (3547, 'Re/Okkupation', 'Re/Okkupation');
INSERT INTO meta_terms VALUES (3549, 'Reokkupation', 'Reokkupation');
INSERT INTO meta_terms VALUES (3551, 'reoccupation', 'reoccupation');
INSERT INTO meta_terms VALUES (3553, 're/occupation', 're/occupation');
INSERT INTO meta_terms VALUES (3555, 'Imanuel Schipper', 'Imanuel Schipper');
INSERT INTO meta_terms VALUES (3557, 'Tim Rieniets', 'Tim Rieniets');
INSERT INTO meta_terms VALUES (3559, '19.09.2011', '19.09.2011');
INSERT INTO meta_terms VALUES (3561, 'Jaipur', 'Jaipur');
INSERT INTO meta_terms VALUES (3563, 'Fatehpur Sikrit', 'Fatehpur Sikrit');
INSERT INTO meta_terms VALUES (3565, 'Agra', 'Agra');
INSERT INTO meta_terms VALUES (3567, 'Taj Mahal', 'Taj Mahal');
INSERT INTO meta_terms VALUES (3569, 'Juma Masid', 'Juma Masid');
INSERT INTO meta_terms VALUES (3571, 'Lotus Temple', 'Lotus Temple');
INSERT INTO meta_terms VALUES (3573, 'Pigment', 'Pigment');
INSERT INTO meta_terms VALUES (3575, 'Kerala', 'Kerala');
INSERT INTO meta_terms VALUES (3577, 'Countryside', 'Countryside');
INSERT INTO meta_terms VALUES (3579, 'Nature', 'Nature');
INSERT INTO meta_terms VALUES (3581, 'Dhobi Mumbai', 'Dhobi Mumbai');
INSERT INTO meta_terms VALUES (3583, 'Slums', 'Slums');
INSERT INTO meta_terms VALUES (3585, 'Birla Temple', 'Birla Temple');
INSERT INTO meta_terms VALUES (3587, 'Red Fort', 'Red Fort');
INSERT INTO meta_terms VALUES (3589, 'Music', 'Music');
INSERT INTO meta_terms VALUES (3591, 'Mathura', 'Mathura');
INSERT INTO meta_terms VALUES (3593, 'Fotografien', 'Fotografien');
INSERT INTO meta_terms VALUES (3595, 'Zeichnungen', 'Zeichnungen');
INSERT INTO meta_terms VALUES (3597, 'Stiche', 'Stiche');
INSERT INTO meta_terms VALUES (3599, 'Buch Cover', 'Buch Cover');
INSERT INTO meta_terms VALUES (3601, 'Experimentalfilm', 'Experimentalfilm');
INSERT INTO meta_terms VALUES (3603, 'Found Footage', 'Found Footage');
INSERT INTO meta_terms VALUES (3605, 'Designforschung', 'Designforschung');
INSERT INTO meta_terms VALUES (3607, '23.09.2011', '23.09.2011');
INSERT INTO meta_terms VALUES (3609, 'Statement', 'Statement');
INSERT INTO meta_terms VALUES (3611, 'Bürger Zürich', 'Bürger Zürich');
INSERT INTO meta_terms VALUES (3613, '', 'Publikation online');
INSERT INTO meta_terms VALUES (3615, 'Werner Ehrhardt', 'Werner Ehrhardt');
INSERT INTO meta_terms VALUES (3617, 'Zett 1/12', 'Zett 1/12');
INSERT INTO meta_terms VALUES (3619, 'Zürcher Zentrum Musikerhand ', 'Zürcher Zentrum Musikerhand ');
INSERT INTO meta_terms VALUES (3621, 'JS Bach', 'JS Bach');
INSERT INTO meta_terms VALUES (3627, 'Falten', 'Falten');
INSERT INTO meta_terms VALUES (3629, 'Pressen', 'Pressen');
INSERT INTO meta_terms VALUES (3631, 'Transformation 2', 'Transformation 2');
INSERT INTO meta_terms VALUES (3633, 'Rupfen', 'Rupfen');
INSERT INTO meta_terms VALUES (3635, 'Sägen', 'Sägen');
INSERT INTO meta_terms VALUES (3637, 'Wolle', 'Wolle');
INSERT INTO meta_terms VALUES (3639, 'Draht', 'Draht');
INSERT INTO meta_terms VALUES (3641, 'Rollen', 'Rollen');
INSERT INTO meta_terms VALUES (3643, 'Wickeln', 'Wickeln');
INSERT INTO meta_terms VALUES (3645, 'Malen', 'Malen');
INSERT INTO meta_terms VALUES (3647, 'Kaffee', 'Kaffee');
INSERT INTO meta_terms VALUES (3649, 'Riechen', 'Riechen');
INSERT INTO meta_terms VALUES (3651, 'Rost', 'Rost');
INSERT INTO meta_terms VALUES (3653, 'Stecken', 'Stecken');
INSERT INTO meta_terms VALUES (3655, 'Recycling', 'Recycling');
INSERT INTO meta_terms VALUES (3657, 'machinima', 'machinima');
INSERT INTO meta_terms VALUES (3659, 'unreal tournament', 'unreal tournament');
INSERT INTO meta_terms VALUES (3661, 'rückkopplungseffekt', 'rückkopplungseffekt');
INSERT INTO meta_terms VALUES (3663, 'whitenoise', 'whitenoise');
INSERT INTO meta_terms VALUES (3665, '3D internet', '3D internet');
INSERT INTO meta_terms VALUES (3667, 'metaverse', 'metaverse');
INSERT INTO meta_terms VALUES (3669, 'avatar', 'avatar');
INSERT INTO meta_terms VALUES (3671, 'multiuser', 'multiuser');
INSERT INTO meta_terms VALUES (3673, 'choreographie', 'choreographie');
INSERT INTO meta_terms VALUES (3675, '3D', '3D');
INSERT INTO meta_terms VALUES (3677, 'game engine', 'game engine');
INSERT INTO meta_terms VALUES (3679, 'Vorlage', 'Vorlage');
INSERT INTO meta_terms VALUES (3681, 'Verschlagworten', 'Verschlagworten');
INSERT INTO meta_terms VALUES (3683, 'Expression Media', 'Expression Media');
INSERT INTO meta_terms VALUES (3685, 'IPTC/XMPpro', 'IPTC/XMPpro');
INSERT INTO meta_terms VALUES (3687, 'Research Project on Responsive Materials, IAD, ZHdK, Module', 'Research Project on Responsive Materials, IAD, ZHdK, Module');
INSERT INTO meta_terms VALUES (3689, 'EPFL', 'EPFL');
INSERT INTO meta_terms VALUES (3691, 'IAD', 'IAD');
INSERT INTO meta_terms VALUES (3693, 'Research Project', 'Research Project');
INSERT INTO meta_terms VALUES (3695, 'Robots', 'Robots');
INSERT INTO meta_terms VALUES (3697, 'Robjects', 'Robjects');
INSERT INTO meta_terms VALUES (3699, 'Stephan Müller', 'Stephan Müller');
INSERT INTO meta_terms VALUES (3701, 'Artist-in-Residence Z+', 'Artist-in-Residence Z+');
INSERT INTO meta_terms VALUES (3703, 'RGB', 'RGB');
INSERT INTO meta_terms VALUES (3705, 'CMYK', 'CMYK');
INSERT INTO meta_terms VALUES (3707, 'Textilien', 'Textilien');
INSERT INTO meta_terms VALUES (3709, 'Zucker', 'Zucker');
INSERT INTO meta_terms VALUES (3711, 'Weissleim', 'Weissleim');
INSERT INTO meta_terms VALUES (3713, 'Baumwolle', 'Baumwolle');
INSERT INTO meta_terms VALUES (3715, 'Events', 'Events');
INSERT INTO meta_terms VALUES (3717, 'Artikel Musikvermittlung KR', 'Artikel Musikvermittlung KR');
INSERT INTO meta_terms VALUES (3719, 'Oper "Dialogues des Carmélites" 2011', 'Oper "Dialogues des Carmélites" 2011');
INSERT INTO meta_terms VALUES (3721, 'Markus Eiche', 'Markus Eiche');
INSERT INTO meta_terms VALUES (3723, 'Till Fellner', 'Till Fellner');
INSERT INTO meta_terms VALUES (3725, 'Lawrence Power', 'Lawrence Power');
INSERT INTO meta_terms VALUES (3727, 'Materialspur', 'Materialspur');
INSERT INTO meta_terms VALUES (3729, 'Transformation', 'Transformation');
INSERT INTO meta_terms VALUES (3731, 'Oberfläche', 'Oberfläche');
INSERT INTO meta_terms VALUES (3733, 'Tumbler', 'Tumbler');
INSERT INTO meta_terms VALUES (3735, 'Textilstaub', 'Textilstaub');
INSERT INTO meta_terms VALUES (3737, 'Wäschetrockner', 'Wäschetrockner');
INSERT INTO meta_terms VALUES (3739, 'Stoff', 'Stoff');
INSERT INTO meta_terms VALUES (3741, 'saugfähig', 'saugfähig');
INSERT INTO meta_terms VALUES (3743, 'Bürste', 'Bürste');
INSERT INTO meta_terms VALUES (3745, 'Skelett', 'Skelett');
INSERT INTO meta_terms VALUES (3747, 'biegbar', 'biegbar');
INSERT INTO meta_terms VALUES (3749, 'formbar', 'formbar');
INSERT INTO meta_terms VALUES (3751, 'Leim', 'Leim');
INSERT INTO meta_terms VALUES (3753, 'Ziegel', 'Ziegel');
INSERT INTO meta_terms VALUES (3755, 'Backstein', 'Backstein');
INSERT INTO meta_terms VALUES (3757, 'Bauteil', 'Bauteil');
INSERT INTO meta_terms VALUES (3759, 'Hemd', 'Hemd');
INSERT INTO meta_terms VALUES (3761, 'flüssig', 'flüssig');
INSERT INTO meta_terms VALUES (3763, 'schmelzen', 'schmelzen');
INSERT INTO meta_terms VALUES (3765, 'giessen', 'giessen');
INSERT INTO meta_terms VALUES (3767, 'Schichten', 'Schichten');
INSERT INTO meta_terms VALUES (3769, 'Lasagne', 'Lasagne');
INSERT INTO meta_terms VALUES (3771, 'zerbrechlich', 'zerbrechlich');
INSERT INTO meta_terms VALUES (3773, 'Festigkeit', 'Festigkeit');
INSERT INTO meta_terms VALUES (3775, 'Aufschnitt', 'Aufschnitt');
INSERT INTO meta_terms VALUES (3777, 'kurzfristig', 'kurzfristig');
INSERT INTO meta_terms VALUES (3779, 'Messebau', 'Messebau');
INSERT INTO meta_terms VALUES (3781, 'Raumtrennung', 'Raumtrennung');
INSERT INTO meta_terms VALUES (3783, 'Raumakustik', 'Raumakustik');
INSERT INTO meta_terms VALUES (3785, 'Pressform', 'Pressform');
INSERT INTO meta_terms VALUES (3787, 'Früchteschale', 'Früchteschale');
INSERT INTO meta_terms VALUES (3789, 'Textil', 'Textil');
INSERT INTO meta_terms VALUES (3791, 'Vorhang', 'Vorhang');
INSERT INTO meta_terms VALUES (3793, 'Duschmittel', 'Duschmittel');
INSERT INTO meta_terms VALUES (3795, 'Stoffresten', 'Stoffresten');
INSERT INTO meta_terms VALUES (3797, 'Dosierung', 'Dosierung');
INSERT INTO meta_terms VALUES (3799, 'Schichtung', 'Schichtung');
INSERT INTO meta_terms VALUES (3801, 'Stoffstaub', 'Stoffstaub');
INSERT INTO meta_terms VALUES (3803, 'Wandelement', 'Wandelement');
INSERT INTO meta_terms VALUES (3805, 'Struktur', 'Struktur');
INSERT INTO meta_terms VALUES (3807, 'Möblierung', 'Möblierung');
INSERT INTO meta_terms VALUES (3809, 'öffentlich', 'öffentlich');
INSERT INTO meta_terms VALUES (3811, 'Sitzmöbel', 'Sitzmöbel');
INSERT INTO meta_terms VALUES (3813, 'Modell', 'Modell');
INSERT INTO meta_terms VALUES (3815, 'Verputz', 'Verputz');
INSERT INTO meta_terms VALUES (3817, 'Esswaren', 'Esswaren');
INSERT INTO meta_terms VALUES (3819, 'Artikel ICST in Darmstadt ', 'Artikel ICST in Darmstadt ');
INSERT INTO meta_terms VALUES (3821, 'Gesture_MultiTouchTable', 'Gesture_MultiTouchTable');
INSERT INTO meta_terms VALUES (3823, 'Jan Schacher', 'Jan Schacher');
INSERT INTO meta_terms VALUES (3825, 'Kurzartikel_VeranstaltungenNM', 'Kurzartikel_VeranstaltungenNM');
INSERT INTO meta_terms VALUES (3827, '19April2008-zurich-walcheturm-concerto', '19April2008-zurich-walcheturm-concerto');
INSERT INTO meta_terms VALUES (3829, 'nikonD200-2007-(_8002686.NEF-_8002720.NEF)19April2008-zurich-walcheturm-concerto', 'nikonD200-2007-(_8002686.NEF-_8002720.NEF)19April2008-zurich-walcheturm-concerto');
INSERT INTO meta_terms VALUES (3831, 'nikonD40x-2007-(_DSC5461.NEF-DSC_5490.NEF)19April2008-zurich-walcheturm-concerto-Marcus Maeder', 'nikonD40x-2007-(_DSC5461.NEF-DSC_5490.NEF)19April2008-zurich-walcheturm-concerto-Marcus Maeder');
INSERT INTO meta_terms VALUES (3833, 'Masterthesis', 'Masterthesis');
INSERT INTO meta_terms VALUES (3835, 'Langzeitperformance', 'Langzeitperformance');
INSERT INTO meta_terms VALUES (3837, '', 'Performance-Artefakte');
INSERT INTO meta_terms VALUES (3839, '', 'Artefakttyp');
INSERT INTO meta_terms VALUES (3841, '', 'Differenzierung Artefakttyp');
INSERT INTO meta_terms VALUES (3843, '', 'Überliefungsleistung');
INSERT INTO meta_terms VALUES (3845, '', 'Vermittlungspotential');
INSERT INTO meta_terms VALUES (3847, '', 'Kommentar Performance-Artefakte');
INSERT INTO meta_terms VALUES (3849, '', 'Kommentar Artefakt');
INSERT INTO meta_terms VALUES (3851, '', 'Nutzungspotential');
INSERT INTO meta_terms VALUES (3853, 'Fotografische Aufzeichnung', 'Fotografische Aufzeichnung');
INSERT INTO meta_terms VALUES (3855, 'Audiovisuelle Aufzeichnung', 'Audiovisuelle Aufzeichnung');
INSERT INTO meta_terms VALUES (3857, 'Audio Aufzeichnung', 'Audio Aufzeichnung');
INSERT INTO meta_terms VALUES (3859, 'Schriftliche Sprache', 'Schriftliche Sprache');
INSERT INTO meta_terms VALUES (3861, 'Mündliche Sprache', 'Mündliche Sprache');
INSERT INTO meta_terms VALUES (3863, 'Objekt / Material', 'Objekt / Material');
INSERT INTO meta_terms VALUES (3865, 'Bild-Text-Kombination', 'Bild-Text-Kombination');
INSERT INTO meta_terms VALUES (3867, 'Tagung "Die Künste in der Bildung"', 'Tagung "Die Künste in der Bildung"');
INSERT INTO meta_terms VALUES (3869, 'Ballett', 'Ballett');
INSERT INTO meta_terms VALUES (3871, 'Prix de Lausanne', 'Prix de Lausanne');
INSERT INTO meta_terms VALUES (3873, 'Tanz Akademie Zürich', 'Tanz Akademie Zürich');
INSERT INTO meta_terms VALUES (3875, 'Ballettwettbewerb', 'Ballettwettbewerb');
INSERT INTO meta_terms VALUES (3877, 'Öffentlichkeitsarbeit', 'Öffentlichkeitsarbeit');
INSERT INTO meta_terms VALUES (4151, 'Vollzeit-Propaedeutikum', 'Vollzeit-Propaedeutikum');
INSERT INTO meta_terms VALUES (4399, 'Gandhi Ashram', 'Gandhi Ashram');
INSERT INTO meta_terms VALUES (3879, 'Simon Steen-Andersen, Søren Kjærgaard ', 'Simon Steen-Andersen, Søren Kjærgaard ');
INSERT INTO meta_terms VALUES (3881, 'Asyl', 'Asyl');
INSERT INTO meta_terms VALUES (3883, 'Migration', 'Migration');
INSERT INTO meta_terms VALUES (3885, 'roosegard', 'roosegard');
INSERT INTO meta_terms VALUES (3887, 'interkulturelle kompetenz india 12', 'interkulturelle kompetenz india 12');
INSERT INTO meta_terms VALUES (3889, 'open elective', 'open elective');
INSERT INTO meta_terms VALUES (3891, 'graphic design', 'graphic design');
INSERT INTO meta_terms VALUES (3893, 'book', 'book');
INSERT INTO meta_terms VALUES (3895, 'fotography', 'fotography');
INSERT INTO meta_terms VALUES (3897, 'dt', 'dt');
INSERT INTO meta_terms VALUES (3899, 'kriegenburg', 'kriegenburg');
INSERT INTO meta_terms VALUES (3901, 'Julia Schmalbrock', 'Julia Schmalbrock');
INSERT INTO meta_terms VALUES (3903, 'Schauspielstudentin', 'Schauspielstudentin');
INSERT INTO meta_terms VALUES (3905, 'Lehre', 'Lehre');
INSERT INTO meta_terms VALUES (3907, 'Best Practice', 'Best Practice');
INSERT INTO meta_terms VALUES (3909, 'Elias Arens', 'Elias Arens');
INSERT INTO meta_terms VALUES (3911, 'gözde özgür', 'gözde özgür');
INSERT INTO meta_terms VALUES (3913, 'Orte des Informellen', 'Orte des Informellen');
INSERT INTO meta_terms VALUES (3915, 'DUKTA', 'DUKTA');
INSERT INTO meta_terms VALUES (3917, 'Ajanta', 'Ajanta');
INSERT INTO meta_terms VALUES (3919, 'Anokhi Museum', 'Anokhi Museum');
INSERT INTO meta_terms VALUES (3921, 'Plastik', 'Plastik');
INSERT INTO meta_terms VALUES (3923, 'Umweltverschmutzung', 'Umweltverschmutzung');
INSERT INTO meta_terms VALUES (3925, '[#<Meta::Term id: 2195, en_GB: "Original: JPEG", de_CH: "Original: JPEG">]', '[#<Meta::Term id: 2195, en_GB: "Original: JPEG", de_CH: "Original: JPEG">]');
INSERT INTO meta_terms VALUES (3927, 'Alcazar Palace', 'Alcazar Palace');
INSERT INTO meta_terms VALUES (3929, 'Arabesque', 'Arabesque');
INSERT INTO meta_terms VALUES (3931, 'Arabic Script', 'Arabic Script');
INSERT INTO meta_terms VALUES (3933, 'Architectural Feature', 'Architectural Feature');
INSERT INTO meta_terms VALUES (3935, 'Architectural Styles', 'Architectural Styles');
INSERT INTO meta_terms VALUES (3937, 'Carving', 'Carving');
INSERT INTO meta_terms VALUES (3939, 'Decor', 'Decor');
INSERT INTO meta_terms VALUES (3941, 'Decoration', 'Decoration');
INSERT INTO meta_terms VALUES (3943, 'Macro', 'Macro');
INSERT INTO meta_terms VALUES (3945, 'Moorish', 'Moorish');
INSERT INTO meta_terms VALUES (3947, 'Non-Western Script', 'Non-Western Script');
INSERT INTO meta_terms VALUES (3949, 'Old', 'Old');
INSERT INTO meta_terms VALUES (3951, 'Ornate', 'Ornate');
INSERT INTO meta_terms VALUES (3953, 'Pattern', 'Pattern');
INSERT INTO meta_terms VALUES (3955, 'Reales Alcazares', 'Reales Alcazares');
INSERT INTO meta_terms VALUES (3957, 'Seville', 'Seville');
INSERT INTO meta_terms VALUES (3959, 'Styles', 'Styles');
INSERT INTO meta_terms VALUES (3961, 'Intercultural Competence', 'Intercultural Competence');
INSERT INTO meta_terms VALUES (3963, 'GUI', 'GUI');
INSERT INTO meta_terms VALUES (3965, 'Hindi', 'Hindi');
INSERT INTO meta_terms VALUES (3967, 'Sunset', 'Sunset');
INSERT INTO meta_terms VALUES (3969, 'Sunset', 'Sunset');
INSERT INTO meta_terms VALUES (3971, 'Sik Temple', 'Sik Temple');
INSERT INTO meta_terms VALUES (3973, 'Sik Temple', 'Sik Temple');
INSERT INTO meta_terms VALUES (3975, 'Sunset', 'Sunset');
INSERT INTO meta_terms VALUES (3977, 'Sik Temple', 'Sik Temple');
INSERT INTO meta_terms VALUES (3979, 'Trash', 'Trash');
INSERT INTO meta_terms VALUES (3981, 'Trash', 'Trash');
INSERT INTO meta_terms VALUES (3983, 'Trash', 'Trash');
INSERT INTO meta_terms VALUES (3985, 'Trash', 'Trash');
INSERT INTO meta_terms VALUES (3987, 'IICD Jaipur', 'IICD Jaipur');
INSERT INTO meta_terms VALUES (3989, 'IICD Jaipur', 'IICD Jaipur');
INSERT INTO meta_terms VALUES (3991, 'IICD Jaipur', 'IICD Jaipur');
INSERT INTO meta_terms VALUES (3993, 'Knee Clinic', 'Knee Clinic');
INSERT INTO meta_terms VALUES (3995, 'Block Print', 'Block Print');
INSERT INTO meta_terms VALUES (3997, 'Block Print', 'Block Print');
INSERT INTO meta_terms VALUES (3999, 'Block Print', 'Block Print');
INSERT INTO meta_terms VALUES (4001, 'Block Print', 'Block Print');
INSERT INTO meta_terms VALUES (4003, 'Amber Fort', 'Amber Fort');
INSERT INTO meta_terms VALUES (4005, 'Amber Fort', 'Amber Fort');
INSERT INTO meta_terms VALUES (4007, 'Amber Fort', 'Amber Fort');
INSERT INTO meta_terms VALUES (4009, 'Amber Fort', 'Amber Fort');
INSERT INTO meta_terms VALUES (4011, 'Amber Fort', 'Amber Fort');
INSERT INTO meta_terms VALUES (4013, 'Amber Fort', 'Amber Fort');
INSERT INTO meta_terms VALUES (4015, 'Dileep', 'Dileep');
INSERT INTO meta_terms VALUES (4017, 'Dileep', 'Dileep');
INSERT INTO meta_terms VALUES (4019, 'Dileep', 'Dileep');
INSERT INTO meta_terms VALUES (4021, 'Dileep', 'Dileep');
INSERT INTO meta_terms VALUES (4023, 'Ellora', 'Ellora');
INSERT INTO meta_terms VALUES (4025, 'Ellora', 'Ellora');
INSERT INTO meta_terms VALUES (4027, 'Ellora', 'Ellora');
INSERT INTO meta_terms VALUES (4029, 'Ellora', 'Ellora');
INSERT INTO meta_terms VALUES (4031, 'Ellora', 'Ellora');
INSERT INTO meta_terms VALUES (4033, 'Digitale Rekonstruktion', 'Digitale Rekonstruktion');
INSERT INTO meta_terms VALUES (4035, 'Rom', 'Rom');
INSERT INTO meta_terms VALUES (4037, 'Langzeitbeobachtung Schlieren', 'Langzeitbeobachtung Schlieren');
INSERT INTO meta_terms VALUES (4039, 'Departement Kunst & Medien', 'Departement Kunst & Medien');
INSERT INTO meta_terms VALUES (4041, 'Bildende Kunst', 'Bildende Kunst');
INSERT INTO meta_terms VALUES (4043, 'Testupload', 'Testupload');
INSERT INTO meta_terms VALUES (4045, 'Grenzen', 'Grenzen');
INSERT INTO meta_terms VALUES (4047, 'Machtverhätnisse', 'Machtverhätnisse');
INSERT INTO meta_terms VALUES (4049, 'Pat', 'Pat');
INSERT INTO meta_terms VALUES (4051, 'Reinigen', 'Reinigen');
INSERT INTO meta_terms VALUES (4053, 'Gibs', 'Gibs');
INSERT INTO meta_terms VALUES (4055, 'Amelie Losier', 'Amelie Losier');
INSERT INTO meta_terms VALUES (4057, 'Zentrum feur literatur und Forschung', 'Zentrum feur literatur und Forschung');
INSERT INTO meta_terms VALUES (4059, 'Zentrum für Literatur- und Kulturforschung', 'Zentrum für Literatur- und Kulturforschung');
INSERT INTO meta_terms VALUES (4061, 'Walter Benjamin Archiv', 'Walter Benjamin Archiv');
INSERT INTO meta_terms VALUES (4063, 'Karton', 'Karton');
INSERT INTO meta_terms VALUES (4065, 'Knüpfen', 'Knüpfen');
INSERT INTO meta_terms VALUES (4067, 'Flechten', 'Flechten');
INSERT INTO meta_terms VALUES (4069, 'Flächiges Pattern', 'Flächiges Pattern');
INSERT INTO meta_terms VALUES (4071, 'Wachs', 'Wachs');
INSERT INTO meta_terms VALUES (4073, 'Erhitzen', 'Erhitzen');
INSERT INTO meta_terms VALUES (4075, 'Platte', 'Platte');
INSERT INTO meta_terms VALUES (4077, 'Gips', 'Gips');
INSERT INTO meta_terms VALUES (4079, 'Binden', 'Binden');
INSERT INTO meta_terms VALUES (4081, 'Polyester', 'Polyester');
INSERT INTO meta_terms VALUES (4083, 'Frittieren', 'Frittieren');
INSERT INTO meta_terms VALUES (4085, 'Transparentpapier', 'Transparentpapier');
INSERT INTO meta_terms VALUES (4087, 'Transperentpapier', 'Transperentpapier');
INSERT INTO meta_terms VALUES (4089, 'Textur', 'Textur');
INSERT INTO meta_terms VALUES (4091, 'Seile', 'Seile');
INSERT INTO meta_terms VALUES (4093, 'Häckseln', 'Häckseln');
INSERT INTO meta_terms VALUES (4095, 'Epoxit', 'Epoxit');
INSERT INTO meta_terms VALUES (4097, 'Epoxitharz', 'Epoxitharz');
INSERT INTO meta_terms VALUES (4099, 'Holz', 'Holz');
INSERT INTO meta_terms VALUES (4101, 'Spanplatte', 'Spanplatte');
INSERT INTO meta_terms VALUES (4103, 'Leimen', 'Leimen');
INSERT INTO meta_terms VALUES (4105, 'Kleben', 'Kleben');
INSERT INTO meta_terms VALUES (4107, 'Schnur', 'Schnur');
INSERT INTO meta_terms VALUES (4109, 'Fassade', 'Fassade');
INSERT INTO meta_terms VALUES (4111, 'ätzen', 'ätzen');
INSERT INTO meta_terms VALUES (4113, 'Weben', 'Weben');
INSERT INTO meta_terms VALUES (4115, 'Ahmedinedschad', 'Ahmedinedschad');
INSERT INTO meta_terms VALUES (4117, 'Eastwood', 'Eastwood');
INSERT INTO meta_terms VALUES (4119, 'verdichten', 'verdichten');
INSERT INTO meta_terms VALUES (4121, 'Stuhl', 'Stuhl');
INSERT INTO meta_terms VALUES (4123, 'Schaumstoff', 'Schaumstoff');
INSERT INTO meta_terms VALUES (4125, 'Spannen', 'Spannen');
INSERT INTO meta_terms VALUES (4127, 'Schnüre', 'Schnüre');
INSERT INTO meta_terms VALUES (4129, 'Netzstruktur', 'Netzstruktur');
INSERT INTO meta_terms VALUES (4131, 'Parkbank', 'Parkbank');
INSERT INTO meta_terms VALUES (4133, 'Toni-Areal', 'Toni-Areal');
INSERT INTO meta_terms VALUES (4135, 'Layout', 'Layout');
INSERT INTO meta_terms VALUES (4137, 'Broschüre', 'Broschüre');
INSERT INTO meta_terms VALUES (4139, 'ZKB', 'ZKB');
INSERT INTO meta_terms VALUES (4141, 'Allreal', 'Allreal');
INSERT INTO meta_terms VALUES (4143, 'Datenblatt', 'Datenblatt');
INSERT INTO meta_terms VALUES (4145, 'Generalunternehmer', 'Generalunternehmer');
INSERT INTO meta_terms VALUES (4147, 'Zürich-West', 'Zürich-West');
INSERT INTO meta_terms VALUES (4149, '2012 FS', '2012 FS');
INSERT INTO meta_terms VALUES (4397, 'Gandhi', 'Gandhi');
INSERT INTO meta_terms VALUES (4153, 'Gestalterische Grundlagen 1 - Bild', 'Gestalterische Grundlagen 1 - Bild');
INSERT INTO meta_terms VALUES (4155, 'Dozent: Schlatter David', 'Dozent: Schlatter David');
INSERT INTO meta_terms VALUES (4157, '02.08.2012-03.08.2012', '02.08.2012-03.08.2012');
INSERT INTO meta_terms VALUES (4159, 'Information', 'Information');
INSERT INTO meta_terms VALUES (4161, 'narrow', 'narrow');
INSERT INTO meta_terms VALUES (4163, 'expand', 'expand');
INSERT INTO meta_terms VALUES (4165, 'explode', 'explode');
INSERT INTO meta_terms VALUES (4167, 'boolean', 'boolean');
INSERT INTO meta_terms VALUES (4169, 'related content', 'related content');
INSERT INTO meta_terms VALUES (4171, 'actionable results', 'actionable results');
INSERT INTO meta_terms VALUES (4173, 'quit', 'quit');
INSERT INTO meta_terms VALUES (4175, 'exit', 'exit');
INSERT INTO meta_terms VALUES (4177, 'system status', 'system status');
INSERT INTO meta_terms VALUES (4179, 'original query', 'original query');
INSERT INTO meta_terms VALUES (4181, 'search again', 'search again');
INSERT INTO meta_terms VALUES (4183, 'search within', 'search within');
INSERT INTO meta_terms VALUES (4185, 'sort', 'sort');
INSERT INTO meta_terms VALUES (4187, 'explore', 'explore');
INSERT INTO meta_terms VALUES (4189, 'pearl growing', 'pearl growing');
INSERT INTO meta_terms VALUES (4191, 'find similar', 'find similar');
INSERT INTO meta_terms VALUES (4193, 'iphone', 'iphone');
INSERT INTO meta_terms VALUES (4195, 'desktop', 'desktop');
INSERT INTO meta_terms VALUES (4197, 'recommendation engine', 'recommendation engine');
INSERT INTO meta_terms VALUES (4199, 'pogosticking', 'pogosticking');
INSERT INTO meta_terms VALUES (4201, 'documents', 'documents');
INSERT INTO meta_terms VALUES (4203, 'alternate views', 'alternate views');
INSERT INTO meta_terms VALUES (4205, 'thrashing', 'thrashing');
INSERT INTO meta_terms VALUES (4207, 'anchoring bias', 'anchoring bias');
INSERT INTO meta_terms VALUES (4209, 'netzhdk', 'netzhdk');
INSERT INTO meta_terms VALUES (4211, 'Akustik', 'Akustik');
INSERT INTO meta_terms VALUES (4213, 'Symposium', 'Symposium');
INSERT INTO meta_terms VALUES (4215, 'HMT', 'HMT');
INSERT INTO meta_terms VALUES (4217, 'EM2N', 'EM2N');
INSERT INTO meta_terms VALUES (4219, 'Wichser Akustik & Bauphysik AG', 'Wichser Akustik & Bauphysik AG');
INSERT INTO meta_terms VALUES (4221, 'EMPA', 'EMPA');
INSERT INTO meta_terms VALUES (4223, 'ICST', 'ICST');
INSERT INTO meta_terms VALUES (4225, 'DMU', 'DMU');
INSERT INTO meta_terms VALUES (4227, 'Bauprojekt', 'Bauprojekt');
INSERT INTO meta_terms VALUES (4229, 'Ziegler Consultans', 'Ziegler Consultans');
INSERT INTO meta_terms VALUES (4231, 'Untersuchung', 'Untersuchung');
INSERT INTO meta_terms VALUES (4233, 'Immissionen', 'Immissionen');
INSERT INTO meta_terms VALUES (4235, 'Schwingungen', 'Schwingungen');
INSERT INTO meta_terms VALUES (4237, 'Walt + Galmarini AG', 'Walt + Galmarini AG');
INSERT INTO meta_terms VALUES (4238, 'Handlungsperformance', 'Handlungsperformance');
INSERT INTO meta_terms VALUES (4240, 'Still-Life Performance', 'Still-Life Performance');
INSERT INTO meta_terms VALUES (4242, 'Lecture Performance', 'Lecture Performance');
INSERT INTO meta_terms VALUES (4244, 'performative Improvisation', 'performative Improvisation');
INSERT INTO meta_terms VALUES (4246, 'dramaturgische Performance', 'dramaturgische Performance');
INSERT INTO meta_terms VALUES (4248, 'Site-specific Performance', 'Site-specific Performance');
INSERT INTO meta_terms VALUES (4250, 'performative Installation', 'performative Installation');
INSERT INTO meta_terms VALUES (4252, 'Tableau Vivant', 'Tableau Vivant');
INSERT INTO meta_terms VALUES (4254, 'Performance für die Kamera', 'Performance für die Kamera');
INSERT INTO meta_terms VALUES (4256, 'Partizipative Performance', 'Partizipative Performance');
INSERT INTO meta_terms VALUES (4258, 'interaktive Performance mit Audiotechnik', 'interaktive Performance mit Audiotechnik');
INSERT INTO meta_terms VALUES (4260, 'Sprechperformance', 'Sprechperformance');
INSERT INTO meta_terms VALUES (4262, 'Tanzperformance', 'Tanzperformance');
INSERT INTO meta_terms VALUES (4264, 'Aktion', 'Aktion');
INSERT INTO meta_terms VALUES (4266, 'Happening', 'Happening');
INSERT INTO meta_terms VALUES (4268, 'Fluxus-Performance', 'Fluxus-Performance');
INSERT INTO meta_terms VALUES (4269, 'Technik: Filztift', 'Technik: Filztift');
INSERT INTO meta_terms VALUES (4273, 'Maki Wiederkehr', 'Maki Wiederkehr');
INSERT INTO meta_terms VALUES (4275, 'Sooyoung Yoon', 'Sooyoung Yoon');
INSERT INTO meta_terms VALUES (4277, 'asd', 'asd');
INSERT INTO meta_terms VALUES (4279, 'as', 'as');
INSERT INTO meta_terms VALUES (4281, 'dasd', 'dasd');
INSERT INTO meta_terms VALUES (4283, 'd', 'd');
INSERT INTO meta_terms VALUES (4285, 'asda', 'asda');
INSERT INTO meta_terms VALUES (4287, 'sda', 'sda');
INSERT INTO meta_terms VALUES (4289, 'sd', 'sd');
INSERT INTO meta_terms VALUES (4291, 'a', 'a');
INSERT INTO meta_terms VALUES (4293, 'das', 'das');
INSERT INTO meta_terms VALUES (4295, 'dasdasd', 'dasdasd');
INSERT INTO meta_terms VALUES (4297, 'da', 'da');
INSERT INTO meta_terms VALUES (4299, 'Fotografie / Still', 'Fotografie / Still');
INSERT INTO meta_terms VALUES (4301, 'Videoaufzeichnung', 'Videoaufzeichnung');
INSERT INTO meta_terms VALUES (4303, 'Audioaufzeichnung', 'Audioaufzeichnung');
INSERT INTO meta_terms VALUES (4305, 'FS 2012', 'FS 2012');
INSERT INTO meta_terms VALUES (4307, 'Vollzeitpropädeutikum', 'Vollzeitpropädeutikum');
INSERT INTO meta_terms VALUES (4309, 'Interdisziplinäres Projekt', 'Interdisziplinäres Projekt');
INSERT INTO meta_terms VALUES (4311, 'Bild', 'Bild');
INSERT INTO meta_terms VALUES (4313, 'Visuelle Kommunikation', 'Visuelle Kommunikation');
INSERT INTO meta_terms VALUES (4315, 'Dozent: Volkart Daniel', 'Dozent: Volkart Daniel');
INSERT INTO meta_terms VALUES (4317, 'Interdiszilinäres Projekt', 'Interdiszilinäres Projekt');
INSERT INTO meta_terms VALUES (4319, '12.03.2012 - 22.03.2012', '12.03.2012 - 22.03.2012');
INSERT INTO meta_terms VALUES (4321, 'Blei- und Filzstift', 'Blei- und Filzstift');
INSERT INTO meta_terms VALUES (4323, '2 Wochen', '2 Wochen');
INSERT INTO meta_terms VALUES (4325, 'Frühlingssemester 2012', 'Frühlingssemester 2012');
INSERT INTO meta_terms VALUES (4327, 'Kammerspiele im Alltag', 'Kammerspiele im Alltag');
INSERT INTO meta_terms VALUES (4329, 'Kugelschreiber-Zeichnungen', 'Kugelschreiber-Zeichnungen');
INSERT INTO meta_terms VALUES (4331, 'Dozierende: Schlatter, David und Volkhart, Daniel', 'Dozierende: Schlatter, David und Volkhart, Daniel');
INSERT INTO meta_terms VALUES (4333, '1 semester/2012', '1 semester/2012');
INSERT INTO meta_terms VALUES (4335, 'Vollzietpropädeutikum', 'Vollzietpropädeutikum');
INSERT INTO meta_terms VALUES (4337, 'Kammerspiele des Alltags', 'Kammerspiele des Alltags');
INSERT INTO meta_terms VALUES (4339, 'amore', 'amore');
INSERT INTO meta_terms VALUES (4341, 'L''amore al bar', 'L''amore al bar');
INSERT INTO meta_terms VALUES (4343, 'VisKom', 'VisKom');
INSERT INTO meta_terms VALUES (4345, 'Begegnung zwischen Kind und ausgestopften Tieren', 'Begegnung zwischen Kind und ausgestopften Tieren');
INSERT INTO meta_terms VALUES (4347, 'Dozierende: Schlatter David, Volkart Daniel', 'Dozierende: Schlatter David, Volkart Daniel');
INSERT INTO meta_terms VALUES (4349, 'Skill - Photoshop W34', 'Skill - Photoshop W34');
INSERT INTO meta_terms VALUES (4351, 'Skills W34', 'Skills W34');
INSERT INTO meta_terms VALUES (4353, 'Fineliner, Filzstift', 'Fineliner, Filzstift');
INSERT INTO meta_terms VALUES (4355, 'Owner', 'Eigentümer/in');
INSERT INTO meta_terms VALUES (4357, '', 'Wer nimmt die Zusammenstellung und Verschlagwortung des Sets vor?');
INSERT INTO meta_terms VALUES (4359, 'blueprint', 'blueprint');
INSERT INTO meta_terms VALUES (4361, 'Analoge Fotografie', 'Analoge Fotografie');
INSERT INTO meta_terms VALUES (4363, 'Bildatlas', 'Bildatlas');
INSERT INTO meta_terms VALUES (4365, 'Owner', 'Eigentümer/in im Medienarchiv');
INSERT INTO meta_terms VALUES (4367, 'Bibliothek', 'Bibliothek');
INSERT INTO meta_terms VALUES (4369, 'Social Web', 'Social Web');
INSERT INTO meta_terms VALUES (4371, 'Social Media', 'Social Media');
INSERT INTO meta_terms VALUES (4373, 'iPad', 'iPad');
INSERT INTO meta_terms VALUES (4375, 'Bilderatlas', 'Bilderatlas');
INSERT INTO meta_terms VALUES (4377, 'Sau, Schwein, Spiess, Spanferkel', 'Sau, Schwein, Spiess, Spanferkel');
INSERT INTO meta_terms VALUES (4379, 'Langstrasse, Nachtklub', 'Langstrasse, Nachtklub');
INSERT INTO meta_terms VALUES (4381, 'Visuelle Kommunikation, Web Design', 'Visuelle Kommunikation, Web Design');
INSERT INTO meta_terms VALUES (4383, 'Videokonferenz', 'Videokonferenz');
INSERT INTO meta_terms VALUES (4385, 'Gandhi', 'Gandhi');
INSERT INTO meta_terms VALUES (4387, 'Gandhi Ashram', 'Gandhi Ashram');
INSERT INTO meta_terms VALUES (4389, 'Gandhi', 'Gandhi');
INSERT INTO meta_terms VALUES (4391, 'Gandhi Ashram', 'Gandhi Ashram');
INSERT INTO meta_terms VALUES (4393, 'Gandhi', 'Gandhi');
INSERT INTO meta_terms VALUES (4395, 'Gandhi Ashram', 'Gandhi Ashram');
INSERT INTO meta_terms VALUES (4401, 'Gandhi', 'Gandhi');
INSERT INTO meta_terms VALUES (4403, 'Gandhi Ashram', 'Gandhi Ashram');
INSERT INTO meta_terms VALUES (4405, 'Gandhi', 'Gandhi');
INSERT INTO meta_terms VALUES (4407, 'Gandhi Ashram', 'Gandhi Ashram');
INSERT INTO meta_terms VALUES (4409, 'Textile', 'Textile');
INSERT INTO meta_terms VALUES (4411, 'Louis Kahn', 'Louis Kahn');
INSERT INTO meta_terms VALUES (4413, 'Louis Kahn', 'Louis Kahn');
INSERT INTO meta_terms VALUES (4415, 'Louis Kahn', 'Louis Kahn');
INSERT INTO meta_terms VALUES (4417, 'Indian Institute of Management', 'Indian Institute of Management');
INSERT INTO meta_terms VALUES (4419, 'Indian Institute of Management', 'Indian Institute of Management');
INSERT INTO meta_terms VALUES (4421, 'Indian Institute of Management', 'Indian Institute of Management');
INSERT INTO meta_terms VALUES (4423, 'Indian Institute of Management', 'Indian Institute of Management');
INSERT INTO meta_terms VALUES (4425, 'Fire', 'Fire');
INSERT INTO meta_terms VALUES (4427, 'Fire', 'Fire');
INSERT INTO meta_terms VALUES (4429, 'Fire', 'Fire');
INSERT INTO meta_terms VALUES (4431, 'Fire', 'Fire');
INSERT INTO meta_terms VALUES (4433, 'Fire', 'Fire');
INSERT INTO meta_terms VALUES (4435, 'Fire', 'Fire');
INSERT INTO meta_terms VALUES (4437, 'Corbusier', 'Corbusier');
INSERT INTO meta_terms VALUES (4439, 'Corbusier', 'Corbusier');
INSERT INTO meta_terms VALUES (4441, 'Corbusier', 'Corbusier');
INSERT INTO meta_terms VALUES (4443, 'Corbusier', 'Corbusier');
INSERT INTO meta_terms VALUES (4445, 'Corbusier', 'Corbusier');
INSERT INTO meta_terms VALUES (4447, 'Floor', 'Floor');
INSERT INTO meta_terms VALUES (4449, 'Floor', 'Floor');
INSERT INTO meta_terms VALUES (4451, 'Laxmi Vilas Palace', 'Laxmi Vilas Palace');
INSERT INTO meta_terms VALUES (4453, 'Palace of the Winds', 'Palace of the Winds');
INSERT INTO meta_terms VALUES (4455, 'Elephant', 'Elephant');
INSERT INTO meta_terms VALUES (4457, 'Palace of the Winds', 'Palace of the Winds');
INSERT INTO meta_terms VALUES (4459, 'Palace of the Winds', 'Palace of the Winds');
INSERT INTO meta_terms VALUES (4461, 'Elephant', 'Elephant');
INSERT INTO meta_terms VALUES (4463, 'Elephant', 'Elephant');
INSERT INTO meta_terms VALUES (4465, 'Elephant', 'Elephant');
INSERT INTO meta_terms VALUES (4467, 'Elephant', 'Elephant');
INSERT INTO meta_terms VALUES (4469, 'Anokhi', 'Anokhi');
INSERT INTO meta_terms VALUES (4471, 'Anokhi', 'Anokhi');
INSERT INTO meta_terms VALUES (4473, 'Anokhi', 'Anokhi');
INSERT INTO meta_terms VALUES (4475, 'Anokhi', 'Anokhi');
INSERT INTO meta_terms VALUES (4477, 'Anokhi', 'Anokhi');
INSERT INTO meta_terms VALUES (4479, 'Anokhi', 'Anokhi');
INSERT INTO meta_terms VALUES (4481, 'Bollywood', 'Bollywood');
INSERT INTO meta_terms VALUES (4483, 'Cinema', 'Cinema');
INSERT INTO meta_terms VALUES (4485, 'Bollywood', 'Bollywood');
INSERT INTO meta_terms VALUES (4487, 'Cinema', 'Cinema');
INSERT INTO meta_terms VALUES (4489, 'Bollywood', 'Bollywood');
INSERT INTO meta_terms VALUES (4491, 'Cinema', 'Cinema');
INSERT INTO meta_terms VALUES (4493, 'Bollywood', 'Bollywood');
INSERT INTO meta_terms VALUES (4495, 'Cinema', 'Cinema');
INSERT INTO meta_terms VALUES (4497, 'Bollywood', 'Bollywood');
INSERT INTO meta_terms VALUES (4499, 'Cinema', 'Cinema');
INSERT INTO meta_terms VALUES (4501, 'Bollywood', 'Bollywood');
INSERT INTO meta_terms VALUES (4503, 'Cinema', 'Cinema');
INSERT INTO meta_terms VALUES (4505, 'Udaipur', 'Udaipur');
INSERT INTO meta_terms VALUES (4507, 'Udaipur', 'Udaipur');
INSERT INTO meta_terms VALUES (4509, 'Udaipur', 'Udaipur');
INSERT INTO meta_terms VALUES (4511, 'Udaipur', 'Udaipur');
INSERT INTO meta_terms VALUES (4513, 'Udaipur', 'Udaipur');
INSERT INTO meta_terms VALUES (4515, 'Udaipur', 'Udaipur');
INSERT INTO meta_terms VALUES (4517, 'Mount Abu', 'Mount Abu');
INSERT INTO meta_terms VALUES (4519, 'Hauz Khaz', 'Hauz Khaz');
INSERT INTO meta_terms VALUES (4521, 'Hauz Khaz', 'Hauz Khaz');
INSERT INTO meta_terms VALUES (4523, 'Hauz Khaz', 'Hauz Khaz');
INSERT INTO meta_terms VALUES (4525, 'Hauz Khaz', 'Hauz Khaz');
INSERT INTO meta_terms VALUES (4527, 'Hauz Khaz', 'Hauz Khaz');
INSERT INTO meta_terms VALUES (4529, 'Hauz Khaz', 'Hauz Khaz');
INSERT INTO meta_terms VALUES (4531, 'Devi Art Foundation', 'Devi Art Foundation');
INSERT INTO meta_terms VALUES (4533, 'Devi Art Foundation', 'Devi Art Foundation');
INSERT INTO meta_terms VALUES (4535, 'Devi Art Foundation', 'Devi Art Foundation');
INSERT INTO meta_terms VALUES (4537, 'Devi Art Foundation', 'Devi Art Foundation');
INSERT INTO meta_terms VALUES (4539, 'Devi Art Foundation', 'Devi Art Foundation');
INSERT INTO meta_terms VALUES (4541, 'Samode Palace', 'Samode Palace');
INSERT INTO meta_terms VALUES (4543, 'Samode', 'Samode');
INSERT INTO meta_terms VALUES (4545, 'Samode Palace', 'Samode Palace');
INSERT INTO meta_terms VALUES (4547, 'Samode', 'Samode');
INSERT INTO meta_terms VALUES (4549, 'Samode Palace', 'Samode Palace');
INSERT INTO meta_terms VALUES (4551, 'Samode', 'Samode');
INSERT INTO meta_terms VALUES (4553, 'Samode Palace', 'Samode Palace');
INSERT INTO meta_terms VALUES (4555, 'Samode', 'Samode');
INSERT INTO meta_terms VALUES (4557, 'Archiv', 'Archiv');
INSERT INTO meta_terms VALUES (4558, 'Games', 'Games');
INSERT INTO meta_terms VALUES (4559, '', 'Nutzung');
INSERT INTO meta_terms VALUES (4561, '', 'Eigentümer/in im Medienarchiv ');
INSERT INTO meta_terms VALUES (4563, '', 'Bearbeitet durch ');
INSERT INTO meta_terms VALUES (4565, '', 'Geändert am');
INSERT INTO meta_terms VALUES (4567, '', 'Institution');
INSERT INTO meta_terms VALUES (4569, '', 'Enthalten in');
INSERT INTO meta_terms VALUES (4571, '', 'Enthält');
INSERT INTO meta_terms VALUES (4573, 'zett 3-2012 ', 'zett 3-2012 ');
INSERT INTO meta_terms VALUES (4575, 'zett 4-2012 ', 'zett 4-2012 ');
INSERT INTO meta_terms VALUES (4577, 'zett 5-2012 ', 'zett 5-2012 ');
INSERT INTO meta_terms VALUES (4579, 'zett 6-2012 ', 'zett 6-2012 ');
INSERT INTO meta_terms VALUES (4581, 'zett 7-2012 ', 'zett 7-2012 ');
INSERT INTO meta_terms VALUES (4583, 'zett 8-2012 ', 'zett 8-2012 ');
INSERT INTO meta_terms VALUES (4585, 'zett 9-2012 ', 'zett 9-2012 ');
INSERT INTO meta_terms VALUES (4587, 'zett 10-2012 ', 'zett 10-2012 ');
INSERT INTO meta_terms VALUES (4589, 'zett 11-2012 ', 'zett 11-2012 ');
INSERT INTO meta_terms VALUES (4591, 'zett 12-2012 ', 'zett 12-2012 ');
INSERT INTO meta_terms VALUES (4593, 'zett 13-2013', 'zett 13-2013');
INSERT INTO meta_terms VALUES (4595, ' zett 1-2013', ' zett 1-2013 ');
INSERT INTO meta_terms VALUES (4597, ' zett 2-2013', ' zett 2-2013');
INSERT INTO meta_terms VALUES (4598, 'Hefte', 'Hefte');
INSERT INTO meta_terms VALUES (4599, 'Beobachtung', 'Beobachtung');
INSERT INTO meta_terms VALUES (4600, 'Bild-Text', 'Bild-Text');
INSERT INTO meta_terms VALUES (4601, 'Konsumkultur', 'Konsumkultur');
INSERT INTO meta_terms VALUES (4602, 'Persiflage', 'Persiflage');
INSERT INTO meta_terms VALUES (4603, 'Bildserie', 'Bildserie');
INSERT INTO meta_terms VALUES (4604, 'Sport', 'Sport');
INSERT INTO meta_terms VALUES (4605, 'Sportbekleidung', 'Sportbekleidung');
INSERT INTO meta_terms VALUES (4606, 'Outdoor', 'Outdoor');
INSERT INTO meta_terms VALUES (4607, 'Mode', 'Mode');
INSERT INTO meta_terms VALUES (4608, 'Freizeit', 'Freizeit');
INSERT INTO meta_terms VALUES (4609, '8-Kanal Audio', '8-Kanal Audio');
INSERT INTO meta_terms VALUES (4610, 'Klanginstallation', 'Klanginstallation');
INSERT INTO meta_terms VALUES (4611, 'Audioinstallation', 'Audioinstallation');
INSERT INTO meta_terms VALUES (4612, 'Pflanzen', 'Pflanzen');
INSERT INTO meta_terms VALUES (4613, 'Seerosen', 'Seerosen');
INSERT INTO meta_terms VALUES (2411, 'Zürich', 'Zürich');
INSERT INTO meta_terms VALUES (4614, 'Flugzeug', 'Flugzeug');
INSERT INTO meta_terms VALUES (4615, '', 'SQ6');
INSERT INTO meta_terms VALUES (4616, 'sq6', 'sq6');


--
-- Data for Name: people; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO people VALUES (1, false, NULL, NULL, 'Adam', 'Admin', NULL, '2012-04-20 12:04:17', '2012-04-20 12:04:17');
INSERT INTO people VALUES (2, false, NULL, NULL, 'Normin', 'Normalo', NULL, '2012-04-20 12:04:17', '2012-04-20 12:04:17');
INSERT INTO people VALUES (3, false, NULL, NULL, 'Petra', 'Paula', NULL, '2012-04-20 12:04:17', '2012-04-20 12:04:17');
INSERT INTO people VALUES (4, false, NULL, NULL, 'Norbert', 'Neuerfassung', NULL, '2012-04-20 12:04:20', '2012-04-20 12:04:20');
INSERT INTO people VALUES (5, false, NULL, NULL, 'Beat', 'Raktor', NULL, '2012-04-20 12:04:23', '2012-04-20 12:04:23');
INSERT INTO people VALUES (6, false, NULL, NULL, 'Liselotte', 'Landschaft', NULL, '2012-04-20 12:04:23', '2012-04-20 12:04:23');
INSERT INTO people VALUES (7, false, NULL, NULL, 'Wilhelm', 'Schulte', NULL, '2012-08-31 11:56:03', '2012-08-31 11:56:03');
INSERT INTO people VALUES (9, false, NULL, NULL, 'Hans', 'Memling', NULL, '2012-08-31 12:00:32', '2012-08-31 12:00:32');
INSERT INTO people VALUES (10, false, NULL, NULL, 'Karen', 'Knacknuss', '', '2012-10-16 13:26:25.099886', '2012-10-16 13:26:25.099886');
INSERT INTO people VALUES (11, false, NULL, NULL, 'Peter', 'Tillessen', NULL, '2012-10-16 13:46:53.352967', '2012-10-16 13:46:53.352967');
INSERT INTO people VALUES (12, false, NULL, NULL, 'Peter', 'Tillessen', NULL, '2012-10-16 13:46:53.387645', '2012-10-16 13:46:53.387645');
INSERT INTO people VALUES (13, false, NULL, NULL, 'Felix', 'Jungo', NULL, '2012-10-16 13:46:53.505275', '2012-10-16 13:46:53.505275');
INSERT INTO people VALUES (14, false, NULL, NULL, 'George', 'Osodi', NULL, '2012-10-16 13:47:08.886113', '2012-10-16 13:47:08.886113');
INSERT INTO people VALUES (15, false, NULL, NULL, 'George', 'Osodi', NULL, '2012-10-16 13:47:08.902108', '2012-10-16 13:47:08.902108');
INSERT INTO people VALUES (16, false, NULL, NULL, 'Susanne', 'Schumacher', NULL, '2012-10-16 13:47:08.929097', '2012-10-16 13:47:08.929097');
INSERT INTO people VALUES (17, false, NULL, NULL, 'Andrea', 'Bangerter', NULL, '2012-10-16 13:47:11.356625', '2012-10-16 13:47:11.356625');
INSERT INTO people VALUES (18, false, NULL, NULL, 'Andrea', 'Thal', NULL, '2012-10-16 13:47:11.359798', '2012-10-16 13:47:11.359798');
INSERT INTO people VALUES (19, false, NULL, NULL, 'Andrea', 'Bangerter', NULL, '2012-10-16 13:47:11.385559', '2012-10-16 13:47:11.385559');
INSERT INTO people VALUES (20, false, NULL, NULL, 'Maja', 'Leo', NULL, '2012-10-16 13:47:32.897136', '2012-10-16 13:47:32.897136');
INSERT INTO people VALUES (21, false, NULL, NULL, 'Max', 'Treier', NULL, '2012-10-16 13:47:44.782768', '2012-10-16 13:47:44.782768');
INSERT INTO people VALUES (22, false, NULL, NULL, 'Jon', 'Etter', NULL, '2012-10-16 13:47:44.813276', '2012-10-16 13:47:44.813276');
INSERT INTO people VALUES (23, false, NULL, NULL, 'Melanie M.', 'Kistler', NULL, '2012-10-16 13:47:53.86126', '2012-10-16 13:47:53.86126');
INSERT INTO people VALUES (24, false, NULL, NULL, 'Shima', 'Asa', NULL, '2012-10-16 13:48:01.117435', '2012-10-16 13:48:01.117435');
INSERT INTO people VALUES (25, false, NULL, NULL, 'Jann', 'Clavadetscher', NULL, '2012-10-16 13:48:01.120582', '2012-10-16 13:48:01.120582');
INSERT INTO people VALUES (26, false, NULL, NULL, 'Aylin', 'Filiz', NULL, '2012-10-16 13:48:01.123383', '2012-10-16 13:48:01.123383');
INSERT INTO people VALUES (27, false, NULL, NULL, 'Manuela', 'Müller', NULL, '2012-10-16 13:48:01.126253', '2012-10-16 13:48:01.126253');
INSERT INTO people VALUES (28, false, NULL, NULL, 'Lea', 'Schaffner', NULL, '2012-10-16 13:48:01.129391', '2012-10-16 13:48:01.129391');
INSERT INTO people VALUES (29, false, NULL, NULL, 'Joris', 'Stemmle', NULL, '2012-10-16 13:48:01.13268', '2012-10-16 13:48:01.13268');
INSERT INTO people VALUES (30, false, NULL, NULL, 'Françoise', 'Caraco', NULL, '2012-10-16 13:56:37.706418', '2012-10-16 13:56:37.706418');
INSERT INTO people VALUES (31, false, NULL, NULL, 'Françoise', 'Caraco', NULL, '2012-10-16 13:56:37.721736', '2012-10-16 13:56:37.721736');
INSERT INTO people VALUES (32, false, NULL, NULL, 'Peter', 'Birkhäuser', NULL, '2012-10-16 13:56:47.178002', '2012-10-16 13:56:47.178002');
INSERT INTO people VALUES (33, false, NULL, NULL, 'Derek', 'Stierli', NULL, '2012-10-16 13:56:50.277192', '2012-10-16 13:56:50.277192');
INSERT INTO people VALUES (34, false, NULL, NULL, 'Sebastian', 'Pape', NULL, '2013-03-12 10:32:15.585262', '2013-03-12 10:32:15.585262');


--
-- Data for Name: permission_presets; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO permission_presets VALUES (1, 'Bevollmächtigte/r', true, true, true, true);
INSERT INTO permission_presets VALUES (2, 'Betrachter/in', false, true, false, false);
INSERT INTO permission_presets VALUES (3, 'Betrachter/in & Original', true, true, false, false);
INSERT INTO permission_presets VALUES (4, 'Gesperrt', false, false, false, false);
INSERT INTO permission_presets VALUES (5, 'Redakteur/in', true, true, true, false);


--
-- Data for Name: previews; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO previews VALUES (1, 1, 429, 640, 'image/jpeg', '83d62ab97f1946e6ae2797af0576e0ce_x_large.jpg', 'x_large', '2012-04-20 12:04:18', '2012-04-20 12:04:18');
INSERT INTO previews VALUES (2, 1, 416, 620, 'image/jpeg', '83d62ab97f1946e6ae2797af0576e0ce_large.jpg', 'large', '2012-04-20 12:04:18', '2012-04-20 12:04:18');
INSERT INTO previews VALUES (3, 1, 201, 300, 'image/jpeg', '83d62ab97f1946e6ae2797af0576e0ce_medium.jpg', 'medium', '2012-04-20 12:04:18', '2012-04-20 12:04:18');
INSERT INTO previews VALUES (4, 1, 84, 125, 'image/jpeg', '83d62ab97f1946e6ae2797af0576e0ce_small_125.jpg', 'small_125', '2012-04-20 12:04:18', '2012-04-20 12:04:18');
INSERT INTO previews VALUES (5, 1, 67, 100, 'image/jpeg', '83d62ab97f1946e6ae2797af0576e0ce_small.jpg', 'small', '2012-04-20 12:04:18', '2012-04-20 12:04:18');
INSERT INTO previews VALUES (6, 2, 429, 640, 'image/jpeg', '3682e9a5212b49a7927a5e197c7bb4a9_x_large.jpg', 'x_large', '2012-04-20 12:04:18', '2012-04-20 12:04:18');
INSERT INTO previews VALUES (7, 2, 416, 620, 'image/jpeg', '3682e9a5212b49a7927a5e197c7bb4a9_large.jpg', 'large', '2012-04-20 12:04:18', '2012-04-20 12:04:18');
INSERT INTO previews VALUES (8, 2, 201, 300, 'image/jpeg', '3682e9a5212b49a7927a5e197c7bb4a9_medium.jpg', 'medium', '2012-04-20 12:04:18', '2012-04-20 12:04:18');
INSERT INTO previews VALUES (9, 2, 84, 125, 'image/jpeg', '3682e9a5212b49a7927a5e197c7bb4a9_small_125.jpg', 'small_125', '2012-04-20 12:04:18', '2012-04-20 12:04:18');
INSERT INTO previews VALUES (10, 2, 67, 100, 'image/jpeg', '3682e9a5212b49a7927a5e197c7bb4a9_small.jpg', 'small', '2012-04-20 12:04:18', '2012-04-20 12:04:18');
INSERT INTO previews VALUES (11, 3, 429, 640, 'image/jpeg', '27462e6b17274d20b46b6652c6178d18_x_large.jpg', 'x_large', '2012-04-20 12:04:19', '2012-04-20 12:04:19');
INSERT INTO previews VALUES (12, 3, 416, 620, 'image/jpeg', '27462e6b17274d20b46b6652c6178d18_large.jpg', 'large', '2012-04-20 12:04:19', '2012-04-20 12:04:19');
INSERT INTO previews VALUES (13, 3, 201, 300, 'image/jpeg', '27462e6b17274d20b46b6652c6178d18_medium.jpg', 'medium', '2012-04-20 12:04:19', '2012-04-20 12:04:19');
INSERT INTO previews VALUES (14, 3, 84, 125, 'image/jpeg', '27462e6b17274d20b46b6652c6178d18_small_125.jpg', 'small_125', '2012-04-20 12:04:19', '2012-04-20 12:04:19');
INSERT INTO previews VALUES (15, 3, 67, 100, 'image/jpeg', '27462e6b17274d20b46b6652c6178d18_small.jpg', 'small', '2012-04-20 12:04:19', '2012-04-20 12:04:19');
INSERT INTO previews VALUES (16, 4, 429, 640, 'image/jpeg', '93df27ec55ae4c5aa394fe0d8161a35a_x_large.jpg', 'x_large', '2012-04-20 12:04:19', '2012-04-20 12:04:19');
INSERT INTO previews VALUES (17, 4, 416, 620, 'image/jpeg', '93df27ec55ae4c5aa394fe0d8161a35a_large.jpg', 'large', '2012-04-20 12:04:19', '2012-04-20 12:04:19');
INSERT INTO previews VALUES (18, 4, 201, 300, 'image/jpeg', '93df27ec55ae4c5aa394fe0d8161a35a_medium.jpg', 'medium', '2012-04-20 12:04:19', '2012-04-20 12:04:19');
INSERT INTO previews VALUES (19, 4, 84, 125, 'image/jpeg', '93df27ec55ae4c5aa394fe0d8161a35a_small_125.jpg', 'small_125', '2012-04-20 12:04:19', '2012-04-20 12:04:19');
INSERT INTO previews VALUES (20, 4, 67, 100, 'image/jpeg', '93df27ec55ae4c5aa394fe0d8161a35a_small.jpg', 'small', '2012-04-20 12:04:19', '2012-04-20 12:04:19');
INSERT INTO previews VALUES (21, 5, 429, 640, 'image/jpeg', 'de929612d8f9403d97e4f88c30087dca_x_large.jpg', 'x_large', '2012-04-20 12:04:19', '2012-04-20 12:04:19');
INSERT INTO previews VALUES (22, 5, 416, 620, 'image/jpeg', 'de929612d8f9403d97e4f88c30087dca_large.jpg', 'large', '2012-04-20 12:04:19', '2012-04-20 12:04:19');
INSERT INTO previews VALUES (23, 5, 201, 300, 'image/jpeg', 'de929612d8f9403d97e4f88c30087dca_medium.jpg', 'medium', '2012-04-20 12:04:20', '2012-04-20 12:04:20');
INSERT INTO previews VALUES (24, 5, 84, 125, 'image/jpeg', 'de929612d8f9403d97e4f88c30087dca_small_125.jpg', 'small_125', '2012-04-20 12:04:20', '2012-04-20 12:04:20');
INSERT INTO previews VALUES (25, 5, 67, 100, 'image/jpeg', 'de929612d8f9403d97e4f88c30087dca_small.jpg', 'small', '2012-04-20 12:04:20', '2012-04-20 12:04:20');
INSERT INTO previews VALUES (26, 6, 429, 640, 'image/jpeg', '797417767e0744cb86cd32ffe5f06dda_x_large.jpg', 'x_large', '2012-04-20 12:04:20', '2012-04-20 12:04:20');
INSERT INTO previews VALUES (27, 6, 416, 620, 'image/jpeg', '797417767e0744cb86cd32ffe5f06dda_large.jpg', 'large', '2012-04-20 12:04:20', '2012-04-20 12:04:20');
INSERT INTO previews VALUES (28, 6, 201, 300, 'image/jpeg', '797417767e0744cb86cd32ffe5f06dda_medium.jpg', 'medium', '2012-04-20 12:04:20', '2012-04-20 12:04:20');
INSERT INTO previews VALUES (29, 6, 84, 125, 'image/jpeg', '797417767e0744cb86cd32ffe5f06dda_small_125.jpg', 'small_125', '2012-04-20 12:04:20', '2012-04-20 12:04:20');
INSERT INTO previews VALUES (30, 6, 67, 100, 'image/jpeg', '797417767e0744cb86cd32ffe5f06dda_small.jpg', 'small', '2012-04-20 12:04:20', '2012-04-20 12:04:20');
INSERT INTO previews VALUES (31, 7, 429, 640, 'image/jpeg', 'd7eedd16bbcb4bccb38fec9d94a5edb3_x_large.jpg', 'x_large', '2012-04-20 12:04:20', '2012-04-20 12:04:20');
INSERT INTO previews VALUES (32, 7, 416, 620, 'image/jpeg', 'd7eedd16bbcb4bccb38fec9d94a5edb3_large.jpg', 'large', '2012-04-20 12:04:20', '2012-04-20 12:04:20');
INSERT INTO previews VALUES (33, 7, 201, 300, 'image/jpeg', 'd7eedd16bbcb4bccb38fec9d94a5edb3_medium.jpg', 'medium', '2012-04-20 12:04:20', '2012-04-20 12:04:20');
INSERT INTO previews VALUES (34, 7, 84, 125, 'image/jpeg', 'd7eedd16bbcb4bccb38fec9d94a5edb3_small_125.jpg', 'small_125', '2012-04-20 12:04:21', '2012-04-20 12:04:21');
INSERT INTO previews VALUES (35, 7, 67, 100, 'image/jpeg', 'd7eedd16bbcb4bccb38fec9d94a5edb3_small.jpg', 'small', '2012-04-20 12:04:21', '2012-04-20 12:04:21');
INSERT INTO previews VALUES (36, 8, 429, 640, 'image/jpeg', '91129f3af6ef4431bfa3691ae440ac56_x_large.jpg', 'x_large', '2012-04-20 12:04:21', '2012-04-20 12:04:21');
INSERT INTO previews VALUES (37, 8, 416, 620, 'image/jpeg', '91129f3af6ef4431bfa3691ae440ac56_large.jpg', 'large', '2012-04-20 12:04:21', '2012-04-20 12:04:21');
INSERT INTO previews VALUES (38, 8, 201, 300, 'image/jpeg', '91129f3af6ef4431bfa3691ae440ac56_medium.jpg', 'medium', '2012-04-20 12:04:21', '2012-04-20 12:04:21');
INSERT INTO previews VALUES (39, 8, 84, 125, 'image/jpeg', '91129f3af6ef4431bfa3691ae440ac56_small_125.jpg', 'small_125', '2012-04-20 12:04:21', '2012-04-20 12:04:21');
INSERT INTO previews VALUES (40, 8, 67, 100, 'image/jpeg', '91129f3af6ef4431bfa3691ae440ac56_small.jpg', 'small', '2012-04-20 12:04:21', '2012-04-20 12:04:21');
INSERT INTO previews VALUES (41, 9, 429, 640, 'image/jpeg', 'efa28250a9234a6e9a6c98215497212e_x_large.jpg', 'x_large', '2012-04-20 12:04:21', '2012-04-20 12:04:21');
INSERT INTO previews VALUES (42, 9, 416, 620, 'image/jpeg', 'efa28250a9234a6e9a6c98215497212e_large.jpg', 'large', '2012-04-20 12:04:21', '2012-04-20 12:04:21');
INSERT INTO previews VALUES (43, 9, 201, 300, 'image/jpeg', 'efa28250a9234a6e9a6c98215497212e_medium.jpg', 'medium', '2012-04-20 12:04:21', '2012-04-20 12:04:21');
INSERT INTO previews VALUES (44, 9, 84, 125, 'image/jpeg', 'efa28250a9234a6e9a6c98215497212e_small_125.jpg', 'small_125', '2012-04-20 12:04:21', '2012-04-20 12:04:21');
INSERT INTO previews VALUES (45, 9, 67, 100, 'image/jpeg', 'efa28250a9234a6e9a6c98215497212e_small.jpg', 'small', '2012-04-20 12:04:21', '2012-04-20 12:04:21');
INSERT INTO previews VALUES (51, 11, 429, 640, 'image/jpeg', '00e09e95462e45ecb8f18b8f8b6af9c8_x_large.jpg', 'x_large', '2012-04-20 12:04:22', '2012-04-20 12:04:22');
INSERT INTO previews VALUES (52, 11, 416, 620, 'image/jpeg', '00e09e95462e45ecb8f18b8f8b6af9c8_large.jpg', 'large', '2012-04-20 12:04:22', '2012-04-20 12:04:22');
INSERT INTO previews VALUES (53, 11, 201, 300, 'image/jpeg', '00e09e95462e45ecb8f18b8f8b6af9c8_medium.jpg', 'medium', '2012-04-20 12:04:22', '2012-04-20 12:04:22');
INSERT INTO previews VALUES (54, 11, 84, 125, 'image/jpeg', '00e09e95462e45ecb8f18b8f8b6af9c8_small_125.jpg', 'small_125', '2012-04-20 12:04:22', '2012-04-20 12:04:22');
INSERT INTO previews VALUES (55, 11, 67, 100, 'image/jpeg', '00e09e95462e45ecb8f18b8f8b6af9c8_small.jpg', 'small', '2012-04-20 12:04:22', '2012-04-20 12:04:22');
INSERT INTO previews VALUES (61, 13, 429, 640, 'image/jpeg', '541786d3aee34e9c886c0d89468e15a3_x_large.jpg', 'x_large', '2012-04-20 12:04:23', '2012-04-20 12:04:23');
INSERT INTO previews VALUES (62, 13, 416, 620, 'image/jpeg', '541786d3aee34e9c886c0d89468e15a3_large.jpg', 'large', '2012-04-20 12:04:23', '2012-04-20 12:04:23');
INSERT INTO previews VALUES (63, 13, 201, 300, 'image/jpeg', '541786d3aee34e9c886c0d89468e15a3_medium.jpg', 'medium', '2012-04-20 12:04:23', '2012-04-20 12:04:23');
INSERT INTO previews VALUES (64, 13, 84, 125, 'image/jpeg', '541786d3aee34e9c886c0d89468e15a3_small_125.jpg', 'small_125', '2012-04-20 12:04:23', '2012-04-20 12:04:23');
INSERT INTO previews VALUES (65, 13, 67, 100, 'image/jpeg', '541786d3aee34e9c886c0d89468e15a3_small.jpg', 'small', '2012-04-20 12:04:23', '2012-04-20 12:04:23');
INSERT INTO previews VALUES (66, 14, 429, 640, 'image/jpeg', 'c34ef180441d486397779528617c4d86_x_large.jpg', 'x_large', '2012-04-20 12:04:23', '2012-04-20 12:04:23');
INSERT INTO previews VALUES (67, 14, 416, 620, 'image/jpeg', 'c34ef180441d486397779528617c4d86_large.jpg', 'large', '2012-04-20 12:04:24', '2012-04-20 12:04:24');
INSERT INTO previews VALUES (68, 14, 201, 300, 'image/jpeg', 'c34ef180441d486397779528617c4d86_medium.jpg', 'medium', '2012-04-20 12:04:24', '2012-04-20 12:04:24');
INSERT INTO previews VALUES (69, 14, 84, 125, 'image/jpeg', 'c34ef180441d486397779528617c4d86_small_125.jpg', 'small_125', '2012-04-20 12:04:24', '2012-04-20 12:04:24');
INSERT INTO previews VALUES (70, 14, 67, 100, 'image/jpeg', 'c34ef180441d486397779528617c4d86_small.jpg', 'small', '2012-04-20 12:04:24', '2012-04-20 12:04:24');
INSERT INTO previews VALUES (71, 15, 429, 640, 'image/jpeg', '7006f71d28934c83b16192787d6066a7_x_large.jpg', 'x_large', '2012-04-20 12:04:24', '2012-04-20 12:04:24');
INSERT INTO previews VALUES (72, 15, 416, 620, 'image/jpeg', '7006f71d28934c83b16192787d6066a7_large.jpg', 'large', '2012-04-20 12:04:24', '2012-04-20 12:04:24');
INSERT INTO previews VALUES (73, 15, 201, 300, 'image/jpeg', '7006f71d28934c83b16192787d6066a7_medium.jpg', 'medium', '2012-04-20 12:04:24', '2012-04-20 12:04:24');
INSERT INTO previews VALUES (74, 15, 84, 125, 'image/jpeg', '7006f71d28934c83b16192787d6066a7_small_125.jpg', 'small_125', '2012-04-20 12:04:24', '2012-04-20 12:04:24');
INSERT INTO previews VALUES (75, 15, 67, 100, 'image/jpeg', '7006f71d28934c83b16192787d6066a7_small.jpg', 'small', '2012-04-20 12:04:24', '2012-04-20 12:04:24');
INSERT INTO previews VALUES (76, 16, 375, 500, 'image/jpeg', 'd023b834979043b68400f2ce9f9529c0_x_large.jpg', 'x_large', '2012-04-20 12:04:24', '2012-04-20 12:04:24');
INSERT INTO previews VALUES (77, 16, 375, 500, 'image/jpeg', 'd023b834979043b68400f2ce9f9529c0_large.jpg', 'large', '2012-04-20 12:04:25', '2012-04-20 12:04:25');
INSERT INTO previews VALUES (78, 16, 225, 300, 'image/jpeg', 'd023b834979043b68400f2ce9f9529c0_medium.jpg', 'medium', '2012-04-20 12:04:25', '2012-04-20 12:04:25');
INSERT INTO previews VALUES (79, 16, 94, 125, 'image/jpeg', 'd023b834979043b68400f2ce9f9529c0_small_125.jpg', 'small_125', '2012-04-20 12:04:25', '2012-04-20 12:04:25');
INSERT INTO previews VALUES (80, 16, 75, 100, 'image/jpeg', 'd023b834979043b68400f2ce9f9529c0_small.jpg', 'small', '2012-04-20 12:04:25', '2012-04-20 12:04:25');
INSERT INTO previews VALUES (81, 19, 500, 531, 'image/jpeg', '03c6836c3a5f4bada4bbcb9ea6a49ba0_x_large.jpg', 'x_large', '2012-08-31 09:18:01', '2012-08-31 09:18:01');
INSERT INTO previews VALUES (83, 19, 500, 531, 'image/jpeg', '03c6836c3a5f4bada4bbcb9ea6a49ba0_large.jpg', 'large', '2012-08-31 09:18:01', '2012-08-31 09:18:01');
INSERT INTO previews VALUES (85, 19, 282, 300, 'image/jpeg', '03c6836c3a5f4bada4bbcb9ea6a49ba0_medium.jpg', 'medium', '2012-08-31 09:18:02', '2012-08-31 09:18:02');
INSERT INTO previews VALUES (87, 19, 118, 125, 'image/jpeg', '03c6836c3a5f4bada4bbcb9ea6a49ba0_small_125.jpg', 'small_125', '2012-08-31 09:18:02', '2012-08-31 09:18:02');
INSERT INTO previews VALUES (89, 19, 94, 100, 'image/jpeg', '03c6836c3a5f4bada4bbcb9ea6a49ba0_small.jpg', 'small', '2012-08-31 09:18:02', '2012-08-31 09:18:02');
INSERT INTO previews VALUES (91, 21, 500, 401, 'image/jpeg', '04a2654076114099af6c372e80983612_x_large.jpg', 'x_large', '2012-08-31 12:00:06', '2012-08-31 12:00:06');
INSERT INTO previews VALUES (93, 21, 500, 401, 'image/jpeg', '04a2654076114099af6c372e80983612_large.jpg', 'large', '2012-08-31 12:00:06', '2012-08-31 12:00:06');
INSERT INTO previews VALUES (95, 21, 300, 241, 'image/jpeg', '04a2654076114099af6c372e80983612_medium.jpg', 'medium', '2012-08-31 12:00:07', '2012-08-31 12:00:07');
INSERT INTO previews VALUES (97, 21, 125, 100, 'image/jpeg', '04a2654076114099af6c372e80983612_small_125.jpg', 'small_125', '2012-08-31 12:00:07', '2012-08-31 12:00:07');
INSERT INTO previews VALUES (99, 21, 100, 80, 'image/jpeg', '04a2654076114099af6c372e80983612_small.jpg', 'small', '2012-08-31 12:00:08', '2012-08-31 12:00:08');
INSERT INTO previews VALUES (100, 22, 768, 1024, 'image/jpeg', '0e7735f32d6e4c1a898287d211f3a846_x_large.jpg', 'x_large', '2012-10-16 13:28:21.777964', '2012-10-16 13:28:21.777964');
INSERT INTO previews VALUES (101, 22, 465, 620, 'image/jpeg', '0e7735f32d6e4c1a898287d211f3a846_large.jpg', 'large', '2012-10-16 13:28:22.144127', '2012-10-16 13:28:22.144127');
INSERT INTO previews VALUES (102, 22, 225, 300, 'image/jpeg', '0e7735f32d6e4c1a898287d211f3a846_medium.jpg', 'medium', '2012-10-16 13:28:22.56291', '2012-10-16 13:28:22.56291');
INSERT INTO previews VALUES (103, 22, 94, 125, 'image/jpeg', '0e7735f32d6e4c1a898287d211f3a846_small_125.jpg', 'small_125', '2012-10-16 13:28:22.912195', '2012-10-16 13:28:22.912195');
INSERT INTO previews VALUES (104, 22, 75, 100, 'image/jpeg', '0e7735f32d6e4c1a898287d211f3a846_small.jpg', 'small', '2012-10-16 13:28:23.198416', '2012-10-16 13:28:23.198416');
INSERT INTO previews VALUES (105, 23, 768, 1024, 'image/jpeg', '9d26effa26e4406c8613f0093085d175_x_large.jpg', 'x_large', '2012-10-16 13:28:24.434604', '2012-10-16 13:28:24.434604');
INSERT INTO previews VALUES (106, 23, 465, 620, 'image/jpeg', '9d26effa26e4406c8613f0093085d175_large.jpg', 'large', '2012-10-16 13:28:24.783977', '2012-10-16 13:28:24.783977');
INSERT INTO previews VALUES (107, 23, 225, 300, 'image/jpeg', '9d26effa26e4406c8613f0093085d175_medium.jpg', 'medium', '2012-10-16 13:28:25.278408', '2012-10-16 13:28:25.278408');
INSERT INTO previews VALUES (108, 23, 94, 125, 'image/jpeg', '9d26effa26e4406c8613f0093085d175_small_125.jpg', 'small_125', '2012-10-16 13:28:25.733313', '2012-10-16 13:28:25.733313');
INSERT INTO previews VALUES (109, 23, 75, 100, 'image/jpeg', '9d26effa26e4406c8613f0093085d175_small.jpg', 'small', '2012-10-16 13:28:26.182199', '2012-10-16 13:28:26.182199');
INSERT INTO previews VALUES (110, 24, 675, 1024, 'image/jpeg', 'e9e1671708bf436e840d7845c7aebc54_x_large.jpg', 'x_large', '2012-10-16 13:46:51.398975', '2012-10-16 13:46:51.398975');
INSERT INTO previews VALUES (111, 24, 409, 620, 'image/jpeg', 'e9e1671708bf436e840d7845c7aebc54_large.jpg', 'large', '2012-10-16 13:46:51.745604', '2012-10-16 13:46:51.745604');
INSERT INTO previews VALUES (112, 24, 198, 300, 'image/jpeg', 'e9e1671708bf436e840d7845c7aebc54_medium.jpg', 'medium', '2012-10-16 13:46:52.082394', '2012-10-16 13:46:52.082394');
INSERT INTO previews VALUES (113, 24, 82, 125, 'image/jpeg', 'e9e1671708bf436e840d7845c7aebc54_small_125.jpg', 'small_125', '2012-10-16 13:46:52.400922', '2012-10-16 13:46:52.400922');
INSERT INTO previews VALUES (114, 24, 66, 100, 'image/jpeg', 'e9e1671708bf436e840d7845c7aebc54_small.jpg', 'small', '2012-10-16 13:46:52.801253', '2012-10-16 13:46:52.801253');
INSERT INTO previews VALUES (414, 84, 65, 100, 'image/jpeg', 'dbfb300edaa04bcd960cebeec0c46bc3_small.jpg', 'small', '2012-10-16 13:57:54.29044', '2012-10-16 13:57:54.29044');
INSERT INTO previews VALUES (415, 85, 768, 1024, 'image/jpeg', '7d9de7c4b3a542b7985add2ad385d1f6_x_large.jpg', 'x_large', '2012-10-16 13:57:55.604861', '2012-10-16 13:57:55.604861');
INSERT INTO previews VALUES (416, 85, 465, 620, 'image/jpeg', '7d9de7c4b3a542b7985add2ad385d1f6_large.jpg', 'large', '2012-10-16 13:57:55.990733', '2012-10-16 13:57:55.990733');
INSERT INTO previews VALUES (417, 85, 225, 300, 'image/jpeg', '7d9de7c4b3a542b7985add2ad385d1f6_medium.jpg', 'medium', '2012-10-16 13:57:56.561736', '2012-10-16 13:57:56.561736');
INSERT INTO previews VALUES (418, 85, 94, 125, 'image/jpeg', '7d9de7c4b3a542b7985add2ad385d1f6_small_125.jpg', 'small_125', '2012-10-16 13:57:56.988769', '2012-10-16 13:57:56.988769');
INSERT INTO previews VALUES (419, 85, 75, 100, 'image/jpeg', '7d9de7c4b3a542b7985add2ad385d1f6_small.jpg', 'small', '2012-10-16 13:57:57.482363', '2012-10-16 13:57:57.482363');
INSERT INTO previews VALUES (420, 86, 683, 1024, 'image/jpeg', '70def7abbb32428489befa4578205984_x_large.jpg', 'x_large', '2012-10-16 13:57:58.539196', '2012-10-16 13:57:58.539196');
INSERT INTO previews VALUES (421, 86, 414, 620, 'image/jpeg', '70def7abbb32428489befa4578205984_large.jpg', 'large', '2012-10-16 13:57:59.055639', '2012-10-16 13:57:59.055639');
INSERT INTO previews VALUES (422, 86, 200, 300, 'image/jpeg', '70def7abbb32428489befa4578205984_medium.jpg', 'medium', '2012-10-16 13:57:59.529996', '2012-10-16 13:57:59.529996');
INSERT INTO previews VALUES (423, 86, 83, 125, 'image/jpeg', '70def7abbb32428489befa4578205984_small_125.jpg', 'small_125', '2012-10-16 13:57:59.846998', '2012-10-16 13:57:59.846998');
INSERT INTO previews VALUES (424, 86, 67, 100, 'image/jpeg', '70def7abbb32428489befa4578205984_small.jpg', 'small', '2012-10-16 13:58:00.39418', '2012-10-16 13:58:00.39418');
INSERT INTO previews VALUES (425, 87, 768, 1024, 'image/jpeg', '113b53d839df47638c60286d6ce746f7_x_large.jpg', 'x_large', '2012-10-16 13:58:01.652927', '2012-10-16 13:58:01.652927');
INSERT INTO previews VALUES (426, 87, 465, 620, 'image/jpeg', '113b53d839df47638c60286d6ce746f7_large.jpg', 'large', '2012-10-16 13:58:02.13243', '2012-10-16 13:58:02.13243');
INSERT INTO previews VALUES (427, 87, 225, 300, 'image/jpeg', '113b53d839df47638c60286d6ce746f7_medium.jpg', 'medium', '2012-10-16 13:58:02.589759', '2012-10-16 13:58:02.589759');
INSERT INTO previews VALUES (428, 87, 94, 125, 'image/jpeg', '113b53d839df47638c60286d6ce746f7_small_125.jpg', 'small_125', '2012-10-16 13:58:03.000298', '2012-10-16 13:58:03.000298');
INSERT INTO previews VALUES (429, 87, 75, 100, 'image/jpeg', '113b53d839df47638c60286d6ce746f7_small.jpg', 'small', '2012-10-16 13:58:03.432351', '2012-10-16 13:58:03.432351');
INSERT INTO previews VALUES (135, 29, 675, 1024, 'image/jpeg', 'b46f64181b4a418c9ed2a8101dda2efa_x_large.jpg', 'x_large', '2012-10-16 13:47:04.073409', '2012-10-16 13:47:04.073409');
INSERT INTO previews VALUES (136, 29, 409, 620, 'image/jpeg', 'b46f64181b4a418c9ed2a8101dda2efa_large.jpg', 'large', '2012-10-16 13:47:04.441216', '2012-10-16 13:47:04.441216');
INSERT INTO previews VALUES (137, 29, 198, 300, 'image/jpeg', 'b46f64181b4a418c9ed2a8101dda2efa_medium.jpg', 'medium', '2012-10-16 13:47:04.728155', '2012-10-16 13:47:04.728155');
INSERT INTO previews VALUES (138, 29, 82, 125, 'image/jpeg', 'b46f64181b4a418c9ed2a8101dda2efa_small_125.jpg', 'small_125', '2012-10-16 13:47:05.172244', '2012-10-16 13:47:05.172244');
INSERT INTO previews VALUES (139, 29, 66, 100, 'image/jpeg', 'b46f64181b4a418c9ed2a8101dda2efa_small.jpg', 'small', '2012-10-16 13:47:05.630573', '2012-10-16 13:47:05.630573');
INSERT INTO previews VALUES (140, 30, 683, 1024, 'image/jpeg', '1408c123b58f4d4cb6476218ec885a16_x_large.jpg', 'x_large', '2012-10-16 13:47:07.180546', '2012-10-16 13:47:07.180546');
INSERT INTO previews VALUES (141, 30, 414, 620, 'image/jpeg', '1408c123b58f4d4cb6476218ec885a16_large.jpg', 'large', '2012-10-16 13:47:07.443242', '2012-10-16 13:47:07.443242');
INSERT INTO previews VALUES (142, 30, 200, 300, 'image/jpeg', '1408c123b58f4d4cb6476218ec885a16_medium.jpg', 'medium', '2012-10-16 13:47:07.793023', '2012-10-16 13:47:07.793023');
INSERT INTO previews VALUES (143, 30, 83, 125, 'image/jpeg', '1408c123b58f4d4cb6476218ec885a16_small_125.jpg', 'small_125', '2012-10-16 13:47:08.164539', '2012-10-16 13:47:08.164539');
INSERT INTO previews VALUES (144, 30, 67, 100, 'image/jpeg', '1408c123b58f4d4cb6476218ec885a16_small.jpg', 'small', '2012-10-16 13:47:08.562412', '2012-10-16 13:47:08.562412');
INSERT INTO previews VALUES (145, 31, 768, 621, 'image/jpeg', '9234595eca5646a695afa32e91049490_x_large.jpg', 'x_large', '2012-10-16 13:47:09.812699', '2012-10-16 13:47:09.812699');
INSERT INTO previews VALUES (146, 31, 500, 404, 'image/jpeg', '9234595eca5646a695afa32e91049490_large.jpg', 'large', '2012-10-16 13:47:10.196372', '2012-10-16 13:47:10.196372');
INSERT INTO previews VALUES (147, 31, 300, 243, 'image/jpeg', '9234595eca5646a695afa32e91049490_medium.jpg', 'medium', '2012-10-16 13:47:10.506457', '2012-10-16 13:47:10.506457');
INSERT INTO previews VALUES (148, 31, 125, 101, 'image/jpeg', '9234595eca5646a695afa32e91049490_small_125.jpg', 'small_125', '2012-10-16 13:47:10.817626', '2012-10-16 13:47:10.817626');
INSERT INTO previews VALUES (149, 31, 100, 81, 'image/jpeg', '9234595eca5646a695afa32e91049490_small.jpg', 'small', '2012-10-16 13:47:10.94754', '2012-10-16 13:47:10.94754');
INSERT INTO previews VALUES (435, 89, 706, 1024, 'image/jpeg', 'a96ccdf503334117b44bb6eef9d67001_x_large.jpg', 'x_large', '2012-10-16 13:58:07.376186', '2012-10-16 13:58:07.376186');
INSERT INTO previews VALUES (436, 89, 427, 620, 'image/jpeg', 'a96ccdf503334117b44bb6eef9d67001_large.jpg', 'large', '2012-10-16 13:58:07.768732', '2012-10-16 13:58:07.768732');
INSERT INTO previews VALUES (437, 89, 207, 300, 'image/jpeg', 'a96ccdf503334117b44bb6eef9d67001_medium.jpg', 'medium', '2012-10-16 13:58:08.210185', '2012-10-16 13:58:08.210185');
INSERT INTO previews VALUES (438, 89, 86, 125, 'image/jpeg', 'a96ccdf503334117b44bb6eef9d67001_small_125.jpg', 'small_125', '2012-10-16 13:58:08.579165', '2012-10-16 13:58:08.579165');
INSERT INTO previews VALUES (155, 33, 717, 1024, 'image/jpeg', '9f4813805e5d44c987f3a730b959d3ea_x_large.jpg', 'x_large', '2012-10-16 13:47:14.831142', '2012-10-16 13:47:14.831142');
INSERT INTO previews VALUES (156, 33, 434, 620, 'image/jpeg', '9f4813805e5d44c987f3a730b959d3ea_large.jpg', 'large', '2012-10-16 13:47:15.275524', '2012-10-16 13:47:15.275524');
INSERT INTO previews VALUES (157, 33, 210, 300, 'image/jpeg', '9f4813805e5d44c987f3a730b959d3ea_medium.jpg', 'medium', '2012-10-16 13:47:15.537103', '2012-10-16 13:47:15.537103');
INSERT INTO previews VALUES (158, 33, 88, 125, 'image/jpeg', '9f4813805e5d44c987f3a730b959d3ea_small_125.jpg', 'small_125', '2012-10-16 13:47:15.858112', '2012-10-16 13:47:15.858112');
INSERT INTO previews VALUES (159, 33, 70, 100, 'image/jpeg', '9f4813805e5d44c987f3a730b959d3ea_small.jpg', 'small', '2012-10-16 13:47:16.098931', '2012-10-16 13:47:16.098931');
INSERT INTO previews VALUES (439, 89, 69, 100, 'image/jpeg', 'a96ccdf503334117b44bb6eef9d67001_small.jpg', 'small', '2012-10-16 13:58:08.891401', '2012-10-16 13:58:08.891401');
INSERT INTO previews VALUES (445, 91, 699, 1024, 'image/jpeg', '0f1e2ef7be614044af088b5bb92c581c_x_large.jpg', 'x_large', '2012-10-16 13:58:13.032996', '2012-10-16 13:58:13.032996');
INSERT INTO previews VALUES (446, 91, 423, 620, 'image/jpeg', '0f1e2ef7be614044af088b5bb92c581c_large.jpg', 'large', '2012-10-16 13:58:13.498829', '2012-10-16 13:58:13.498829');
INSERT INTO previews VALUES (447, 91, 205, 300, 'image/jpeg', '0f1e2ef7be614044af088b5bb92c581c_medium.jpg', 'medium', '2012-10-16 13:58:14.047758', '2012-10-16 13:58:14.047758');
INSERT INTO previews VALUES (448, 91, 85, 125, 'image/jpeg', '0f1e2ef7be614044af088b5bb92c581c_small_125.jpg', 'small_125', '2012-10-16 13:58:14.527239', '2012-10-16 13:58:14.527239');
INSERT INTO previews VALUES (170, 36, 768, 1024, 'image/jpeg', '90a43903d1704d21a54f6002815401b3_x_large.jpg', 'x_large', '2012-10-16 13:47:21.637788', '2012-10-16 13:47:21.637788');
INSERT INTO previews VALUES (171, 36, 465, 620, 'image/jpeg', '90a43903d1704d21a54f6002815401b3_large.jpg', 'large', '2012-10-16 13:47:21.983705', '2012-10-16 13:47:21.983705');
INSERT INTO previews VALUES (172, 36, 225, 300, 'image/jpeg', '90a43903d1704d21a54f6002815401b3_medium.jpg', 'medium', '2012-10-16 13:47:22.473733', '2012-10-16 13:47:22.473733');
INSERT INTO previews VALUES (173, 36, 94, 125, 'image/jpeg', '90a43903d1704d21a54f6002815401b3_small_125.jpg', 'small_125', '2012-10-16 13:47:22.861353', '2012-10-16 13:47:22.861353');
INSERT INTO previews VALUES (174, 36, 75, 100, 'image/jpeg', '90a43903d1704d21a54f6002815401b3_small.jpg', 'small', '2012-10-16 13:47:23.235651', '2012-10-16 13:47:23.235651');
INSERT INTO previews VALUES (175, 37, 768, 1024, 'image/jpeg', '33d7abf0674e44e385b1274fa584a661_x_large.jpg', 'x_large', '2012-10-16 13:47:24.358855', '2012-10-16 13:47:24.358855');
INSERT INTO previews VALUES (176, 37, 465, 620, 'image/jpeg', '33d7abf0674e44e385b1274fa584a661_large.jpg', 'large', '2012-10-16 13:47:24.769793', '2012-10-16 13:47:24.769793');
INSERT INTO previews VALUES (177, 37, 225, 300, 'image/jpeg', '33d7abf0674e44e385b1274fa584a661_medium.jpg', 'medium', '2012-10-16 13:47:25.233983', '2012-10-16 13:47:25.233983');
INSERT INTO previews VALUES (178, 37, 94, 125, 'image/jpeg', '33d7abf0674e44e385b1274fa584a661_small_125.jpg', 'small_125', '2012-10-16 13:47:25.567803', '2012-10-16 13:47:25.567803');
INSERT INTO previews VALUES (179, 37, 75, 100, 'image/jpeg', '33d7abf0674e44e385b1274fa584a661_small.jpg', 'small', '2012-10-16 13:47:25.873545', '2012-10-16 13:47:25.873545');
INSERT INTO previews VALUES (180, 38, 768, 952, 'image/jpeg', 'c96fde7621df4cf6a46f788ce654bc10_x_large.jpg', 'x_large', '2012-10-16 13:47:26.794276', '2012-10-16 13:47:26.794276');
INSERT INTO previews VALUES (181, 38, 500, 620, 'image/jpeg', 'c96fde7621df4cf6a46f788ce654bc10_large.jpg', 'large', '2012-10-16 13:47:27.086727', '2012-10-16 13:47:27.086727');
INSERT INTO previews VALUES (182, 38, 242, 300, 'image/jpeg', 'c96fde7621df4cf6a46f788ce654bc10_medium.jpg', 'medium', '2012-10-16 13:47:27.425499', '2012-10-16 13:47:27.425499');
INSERT INTO previews VALUES (183, 38, 101, 125, 'image/jpeg', 'c96fde7621df4cf6a46f788ce654bc10_small_125.jpg', 'small_125', '2012-10-16 13:47:27.621777', '2012-10-16 13:47:27.621777');
INSERT INTO previews VALUES (184, 38, 81, 100, 'image/jpeg', 'c96fde7621df4cf6a46f788ce654bc10_small.jpg', 'small', '2012-10-16 13:47:27.955151', '2012-10-16 13:47:27.955151');
INSERT INTO previews VALUES (449, 91, 68, 100, 'image/jpeg', '0f1e2ef7be614044af088b5bb92c581c_small.jpg', 'small', '2012-10-16 13:58:14.864866', '2012-10-16 13:58:14.864866');
INSERT INTO previews VALUES (450, 92, 768, 1024, 'image/jpeg', '1959e8c1ac2c4ec9ade2fa2086ff74c2_x_large.jpg', 'x_large', '2012-10-16 13:58:16.364395', '2012-10-16 13:58:16.364395');
INSERT INTO previews VALUES (451, 92, 465, 620, 'image/jpeg', '1959e8c1ac2c4ec9ade2fa2086ff74c2_large.jpg', 'large', '2012-10-16 13:58:16.807671', '2012-10-16 13:58:16.807671');
INSERT INTO previews VALUES (452, 92, 225, 300, 'image/jpeg', '1959e8c1ac2c4ec9ade2fa2086ff74c2_medium.jpg', 'medium', '2012-10-16 13:58:17.478846', '2012-10-16 13:58:17.478846');
INSERT INTO previews VALUES (453, 92, 94, 125, 'image/jpeg', '1959e8c1ac2c4ec9ade2fa2086ff74c2_small_125.jpg', 'small_125', '2012-10-16 13:58:17.924624', '2012-10-16 13:58:17.924624');
INSERT INTO previews VALUES (190, 40, 683, 1024, 'image/jpeg', 'd7477bb1ec664c4eb6109f9b430856ec_x_large.jpg', 'x_large', '2012-10-16 13:47:31.466583', '2012-10-16 13:47:31.466583');
INSERT INTO previews VALUES (191, 40, 414, 620, 'image/jpeg', 'd7477bb1ec664c4eb6109f9b430856ec_large.jpg', 'large', '2012-10-16 13:47:31.786218', '2012-10-16 13:47:31.786218');
INSERT INTO previews VALUES (192, 40, 200, 300, 'image/jpeg', 'd7477bb1ec664c4eb6109f9b430856ec_medium.jpg', 'medium', '2012-10-16 13:47:32.099219', '2012-10-16 13:47:32.099219');
INSERT INTO previews VALUES (193, 40, 83, 125, 'image/jpeg', 'd7477bb1ec664c4eb6109f9b430856ec_small_125.jpg', 'small_125', '2012-10-16 13:47:32.399042', '2012-10-16 13:47:32.399042');
INSERT INTO previews VALUES (194, 40, 67, 100, 'image/jpeg', 'd7477bb1ec664c4eb6109f9b430856ec_small.jpg', 'small', '2012-10-16 13:47:32.62907', '2012-10-16 13:47:32.62907');
INSERT INTO previews VALUES (195, 41, 717, 1024, 'image/jpeg', 'c3093da902a94905a55c94bc3c921285_x_large.jpg', 'x_large', '2012-10-16 13:47:33.893604', '2012-10-16 13:47:33.893604');
INSERT INTO previews VALUES (196, 41, 434, 620, 'image/jpeg', 'c3093da902a94905a55c94bc3c921285_large.jpg', 'large', '2012-10-16 13:47:34.264446', '2012-10-16 13:47:34.264446');
INSERT INTO previews VALUES (197, 41, 210, 300, 'image/jpeg', 'c3093da902a94905a55c94bc3c921285_medium.jpg', 'medium', '2012-10-16 13:47:34.602259', '2012-10-16 13:47:34.602259');
INSERT INTO previews VALUES (198, 41, 88, 125, 'image/jpeg', 'c3093da902a94905a55c94bc3c921285_small_125.jpg', 'small_125', '2012-10-16 13:47:34.879527', '2012-10-16 13:47:34.879527');
INSERT INTO previews VALUES (199, 41, 70, 100, 'image/jpeg', 'c3093da902a94905a55c94bc3c921285_small.jpg', 'small', '2012-10-16 13:47:35.058066', '2012-10-16 13:47:35.058066');
INSERT INTO previews VALUES (200, 42, 682, 1024, 'image/jpeg', 'c2d513ef39564e7f91a3be00fe862660_x_large.jpg', 'x_large', '2012-10-16 13:47:36.282989', '2012-10-16 13:47:36.282989');
INSERT INTO previews VALUES (201, 42, 413, 620, 'image/jpeg', 'c2d513ef39564e7f91a3be00fe862660_large.jpg', 'large', '2012-10-16 13:47:36.646844', '2012-10-16 13:47:36.646844');
INSERT INTO previews VALUES (202, 42, 200, 300, 'image/jpeg', 'c2d513ef39564e7f91a3be00fe862660_medium.jpg', 'medium', '2012-10-16 13:47:36.929872', '2012-10-16 13:47:36.929872');
INSERT INTO previews VALUES (203, 42, 83, 125, 'image/jpeg', 'c2d513ef39564e7f91a3be00fe862660_small_125.jpg', 'small_125', '2012-10-16 13:47:37.18796', '2012-10-16 13:47:37.18796');
INSERT INTO previews VALUES (204, 42, 67, 100, 'image/jpeg', 'c2d513ef39564e7f91a3be00fe862660_small.jpg', 'small', '2012-10-16 13:47:37.521215', '2012-10-16 13:47:37.521215');
INSERT INTO previews VALUES (205, 43, 768, 961, 'image/jpeg', '0e0cd049407e4491b75a0afd5bc7b9d9_x_large.jpg', 'x_large', '2012-10-16 13:47:38.344004', '2012-10-16 13:47:38.344004');
INSERT INTO previews VALUES (206, 43, 495, 620, 'image/jpeg', '0e0cd049407e4491b75a0afd5bc7b9d9_large.jpg', 'large', '2012-10-16 13:47:38.738122', '2012-10-16 13:47:38.738122');
INSERT INTO previews VALUES (207, 43, 240, 300, 'image/jpeg', '0e0cd049407e4491b75a0afd5bc7b9d9_medium.jpg', 'medium', '2012-10-16 13:47:39.024225', '2012-10-16 13:47:39.024225');
INSERT INTO previews VALUES (208, 43, 100, 125, 'image/jpeg', '0e0cd049407e4491b75a0afd5bc7b9d9_small_125.jpg', 'small_125', '2012-10-16 13:47:39.274212', '2012-10-16 13:47:39.274212');
INSERT INTO previews VALUES (209, 43, 80, 100, 'image/jpeg', '0e0cd049407e4491b75a0afd5bc7b9d9_small.jpg', 'small', '2012-10-16 13:47:39.694054', '2012-10-16 13:47:39.694054');
INSERT INTO previews VALUES (210, 44, 768, 1024, 'image/jpeg', '72d5719b1c1c4264932519dec70e7113_x_large.jpg', 'x_large', '2012-10-16 13:47:40.980134', '2012-10-16 13:47:40.980134');
INSERT INTO previews VALUES (211, 44, 465, 620, 'image/jpeg', '72d5719b1c1c4264932519dec70e7113_large.jpg', 'large', '2012-10-16 13:47:41.376009', '2012-10-16 13:47:41.376009');
INSERT INTO previews VALUES (212, 44, 225, 300, 'image/jpeg', '72d5719b1c1c4264932519dec70e7113_medium.jpg', 'medium', '2012-10-16 13:47:41.835267', '2012-10-16 13:47:41.835267');
INSERT INTO previews VALUES (213, 44, 94, 125, 'image/jpeg', '72d5719b1c1c4264932519dec70e7113_small_125.jpg', 'small_125', '2012-10-16 13:47:42.244811', '2012-10-16 13:47:42.244811');
INSERT INTO previews VALUES (214, 44, 75, 100, 'image/jpeg', '72d5719b1c1c4264932519dec70e7113_small.jpg', 'small', '2012-10-16 13:47:42.414957', '2012-10-16 13:47:42.414957');
INSERT INTO previews VALUES (215, 45, 706, 1024, 'image/jpeg', 'df2d6c7e54654961bea8b45f286eb2dd_x_large.jpg', 'x_large', '2012-10-16 13:47:43.188874', '2012-10-16 13:47:43.188874');
INSERT INTO previews VALUES (216, 45, 427, 620, 'image/jpeg', 'df2d6c7e54654961bea8b45f286eb2dd_large.jpg', 'large', '2012-10-16 13:47:43.597563', '2012-10-16 13:47:43.597563');
INSERT INTO previews VALUES (217, 45, 207, 300, 'image/jpeg', 'df2d6c7e54654961bea8b45f286eb2dd_medium.jpg', 'medium', '2012-10-16 13:47:43.820991', '2012-10-16 13:47:43.820991');
INSERT INTO previews VALUES (218, 45, 86, 125, 'image/jpeg', 'df2d6c7e54654961bea8b45f286eb2dd_small_125.jpg', 'small_125', '2012-10-16 13:47:44.026129', '2012-10-16 13:47:44.026129');
INSERT INTO previews VALUES (219, 45, 69, 100, 'image/jpeg', 'df2d6c7e54654961bea8b45f286eb2dd_small.jpg', 'small', '2012-10-16 13:47:44.283256', '2012-10-16 13:47:44.283256');
INSERT INTO previews VALUES (454, 92, 75, 100, 'image/jpeg', '1959e8c1ac2c4ec9ade2fa2086ff74c2_small.jpg', 'small', '2012-10-16 13:58:18.322548', '2012-10-16 13:58:18.322548');
INSERT INTO previews VALUES (455, 93, 668, 1024, 'image/jpeg', '2415e323a0634f3692cbdc42865f002d_x_large.jpg', 'x_large', '2012-10-16 13:58:19.412637', '2012-10-16 13:58:19.412637');
INSERT INTO previews VALUES (456, 93, 404, 620, 'image/jpeg', '2415e323a0634f3692cbdc42865f002d_large.jpg', 'large', '2012-10-16 13:58:19.785379', '2012-10-16 13:58:19.785379');
INSERT INTO previews VALUES (457, 93, 196, 300, 'image/jpeg', '2415e323a0634f3692cbdc42865f002d_medium.jpg', 'medium', '2012-10-16 13:58:20.27158', '2012-10-16 13:58:20.27158');
INSERT INTO previews VALUES (458, 93, 82, 125, 'image/jpeg', '2415e323a0634f3692cbdc42865f002d_small_125.jpg', 'small_125', '2012-10-16 13:58:20.738131', '2012-10-16 13:58:20.738131');
INSERT INTO previews VALUES (225, 47, 668, 1024, 'image/jpeg', '212c4cf6bcdf47a9a5a80cfde870b2de_x_large.jpg', 'x_large', '2012-10-16 13:47:47.667648', '2012-10-16 13:47:47.667648');
INSERT INTO previews VALUES (226, 47, 404, 620, 'image/jpeg', '212c4cf6bcdf47a9a5a80cfde870b2de_large.jpg', 'large', '2012-10-16 13:47:48.01805', '2012-10-16 13:47:48.01805');
INSERT INTO previews VALUES (227, 47, 196, 300, 'image/jpeg', '212c4cf6bcdf47a9a5a80cfde870b2de_medium.jpg', 'medium', '2012-10-16 13:47:48.254546', '2012-10-16 13:47:48.254546');
INSERT INTO previews VALUES (228, 47, 82, 125, 'image/jpeg', '212c4cf6bcdf47a9a5a80cfde870b2de_small_125.jpg', 'small_125', '2012-10-16 13:47:48.47904', '2012-10-16 13:47:48.47904');
INSERT INTO previews VALUES (229, 47, 65, 100, 'image/jpeg', '212c4cf6bcdf47a9a5a80cfde870b2de_small.jpg', 'small', '2012-10-16 13:47:48.698316', '2012-10-16 13:47:48.698316');
INSERT INTO previews VALUES (230, 48, 617, 1024, 'image/jpeg', 'a4b49df933564b3c93f34c186be5909e_x_large.jpg', 'x_large', '2012-10-16 13:47:49.943647', '2012-10-16 13:47:49.943647');
INSERT INTO previews VALUES (231, 48, 374, 620, 'image/jpeg', 'a4b49df933564b3c93f34c186be5909e_large.jpg', 'large', '2012-10-16 13:47:50.31243', '2012-10-16 13:47:50.31243');
INSERT INTO previews VALUES (232, 48, 181, 300, 'image/jpeg', 'a4b49df933564b3c93f34c186be5909e_medium.jpg', 'medium', '2012-10-16 13:47:50.726707', '2012-10-16 13:47:50.726707');
INSERT INTO previews VALUES (233, 48, 75, 125, 'image/jpeg', 'a4b49df933564b3c93f34c186be5909e_small_125.jpg', 'small_125', '2012-10-16 13:47:51.223007', '2012-10-16 13:47:51.223007');
INSERT INTO previews VALUES (234, 48, 60, 100, 'image/jpeg', 'a4b49df933564b3c93f34c186be5909e_small.jpg', 'small', '2012-10-16 13:47:51.485243', '2012-10-16 13:47:51.485243');
INSERT INTO previews VALUES (235, 49, 699, 1024, 'image/jpeg', '909b5d475a714bbbbbdd575cda814c28_x_large.jpg', 'x_large', '2012-10-16 13:47:52.322773', '2012-10-16 13:47:52.322773');
INSERT INTO previews VALUES (236, 49, 423, 620, 'image/jpeg', '909b5d475a714bbbbbdd575cda814c28_large.jpg', 'large', '2012-10-16 13:47:52.617108', '2012-10-16 13:47:52.617108');
INSERT INTO previews VALUES (237, 49, 205, 300, 'image/jpeg', '909b5d475a714bbbbbdd575cda814c28_medium.jpg', 'medium', '2012-10-16 13:47:52.915067', '2012-10-16 13:47:52.915067');
INSERT INTO previews VALUES (238, 49, 85, 125, 'image/jpeg', '909b5d475a714bbbbbdd575cda814c28_small_125.jpg', 'small_125', '2012-10-16 13:47:53.266001', '2012-10-16 13:47:53.266001');
INSERT INTO previews VALUES (239, 49, 68, 100, 'image/jpeg', '909b5d475a714bbbbbdd575cda814c28_small.jpg', 'small', '2012-10-16 13:47:53.580883', '2012-10-16 13:47:53.580883');
INSERT INTO previews VALUES (459, 93, 65, 100, 'image/jpeg', '2415e323a0634f3692cbdc42865f002d_small.jpg', 'small', '2012-10-16 13:58:21.349872', '2012-10-16 13:58:21.349872');
INSERT INTO previews VALUES (460, 94, 670, 1024, 'image/jpeg', '892b9d59952047649b4ba55776062c6e_x_large.jpg', 'x_large', '2012-10-16 13:58:22.626449', '2012-10-16 13:58:22.626449');
INSERT INTO previews VALUES (461, 94, 406, 620, 'image/jpeg', '892b9d59952047649b4ba55776062c6e_large.jpg', 'large', '2012-10-16 13:58:23.089119', '2012-10-16 13:58:23.089119');
INSERT INTO previews VALUES (462, 94, 196, 300, 'image/jpeg', '892b9d59952047649b4ba55776062c6e_medium.jpg', 'medium', '2012-10-16 13:58:23.575634', '2012-10-16 13:58:23.575634');
INSERT INTO previews VALUES (463, 94, 82, 125, 'image/jpeg', '892b9d59952047649b4ba55776062c6e_small_125.jpg', 'small_125', '2012-10-16 13:58:24.115694', '2012-10-16 13:58:24.115694');
INSERT INTO previews VALUES (245, 51, 669, 1024, 'image/jpeg', '0d5e46f7705e47b4abe2df24e08007d2_x_large.jpg', 'x_large', '2012-10-16 13:47:56.827347', '2012-10-16 13:47:56.827347');
INSERT INTO previews VALUES (246, 51, 405, 620, 'image/jpeg', '0d5e46f7705e47b4abe2df24e08007d2_large.jpg', 'large', '2012-10-16 13:47:57.098997', '2012-10-16 13:47:57.098997');
INSERT INTO previews VALUES (247, 51, 196, 300, 'image/jpeg', '0d5e46f7705e47b4abe2df24e08007d2_medium.jpg', 'medium', '2012-10-16 13:47:57.422184', '2012-10-16 13:47:57.422184');
INSERT INTO previews VALUES (248, 51, 82, 125, 'image/jpeg', '0d5e46f7705e47b4abe2df24e08007d2_small_125.jpg', 'small_125', '2012-10-16 13:47:57.799594', '2012-10-16 13:47:57.799594');
INSERT INTO previews VALUES (249, 51, 65, 100, 'image/jpeg', '0d5e46f7705e47b4abe2df24e08007d2_small.jpg', 'small', '2012-10-16 13:47:58.138656', '2012-10-16 13:47:58.138656');
INSERT INTO previews VALUES (250, 52, 668, 1024, 'image/jpeg', '2df542bd70b946d8aa6dc20e30a9d36f_x_large.jpg', 'x_large', '2012-10-16 13:47:59.101013', '2012-10-16 13:47:59.101013');
INSERT INTO previews VALUES (251, 52, 404, 620, 'image/jpeg', '2df542bd70b946d8aa6dc20e30a9d36f_large.jpg', 'large', '2012-10-16 13:47:59.398543', '2012-10-16 13:47:59.398543');
INSERT INTO previews VALUES (252, 52, 196, 300, 'image/jpeg', '2df542bd70b946d8aa6dc20e30a9d36f_medium.jpg', 'medium', '2012-10-16 13:47:59.825755', '2012-10-16 13:47:59.825755');
INSERT INTO previews VALUES (253, 52, 82, 125, 'image/jpeg', '2df542bd70b946d8aa6dc20e30a9d36f_small_125.jpg', 'small_125', '2012-10-16 13:48:00.470214', '2012-10-16 13:48:00.470214');
INSERT INTO previews VALUES (254, 52, 65, 100, 'image/jpeg', '2df542bd70b946d8aa6dc20e30a9d36f_small.jpg', 'small', '2012-10-16 13:48:00.905671', '2012-10-16 13:48:00.905671');
INSERT INTO previews VALUES (255, 53, 768, 1024, 'image/jpeg', '37be15bc92cd45b79107f0a1fe932f89_x_large.jpg', 'x_large', '2012-10-16 13:48:02.211219', '2012-10-16 13:48:02.211219');
INSERT INTO previews VALUES (256, 53, 465, 620, 'image/jpeg', '37be15bc92cd45b79107f0a1fe932f89_large.jpg', 'large', '2012-10-16 13:48:02.493861', '2012-10-16 13:48:02.493861');
INSERT INTO previews VALUES (257, 53, 225, 300, 'image/jpeg', '37be15bc92cd45b79107f0a1fe932f89_medium.jpg', 'medium', '2012-10-16 13:48:02.922421', '2012-10-16 13:48:02.922421');
INSERT INTO previews VALUES (258, 53, 94, 125, 'image/jpeg', '37be15bc92cd45b79107f0a1fe932f89_small_125.jpg', 'small_125', '2012-10-16 13:48:03.331062', '2012-10-16 13:48:03.331062');
INSERT INTO previews VALUES (259, 53, 75, 100, 'image/jpeg', '37be15bc92cd45b79107f0a1fe932f89_small.jpg', 'small', '2012-10-16 13:48:03.687875', '2012-10-16 13:48:03.687875');
INSERT INTO previews VALUES (260, 54, 670, 1024, 'image/jpeg', '70776c6bf8084592b0c464ca1082e385_x_large.jpg', 'x_large', '2012-10-16 13:48:04.7275', '2012-10-16 13:48:04.7275');
INSERT INTO previews VALUES (261, 54, 406, 620, 'image/jpeg', '70776c6bf8084592b0c464ca1082e385_large.jpg', 'large', '2012-10-16 13:48:05.269275', '2012-10-16 13:48:05.269275');
INSERT INTO previews VALUES (262, 54, 196, 300, 'image/jpeg', '70776c6bf8084592b0c464ca1082e385_medium.jpg', 'medium', '2012-10-16 13:48:05.930178', '2012-10-16 13:48:05.930178');
INSERT INTO previews VALUES (263, 54, 82, 125, 'image/jpeg', '70776c6bf8084592b0c464ca1082e385_small_125.jpg', 'small_125', '2012-10-16 13:48:06.446865', '2012-10-16 13:48:06.446865');
INSERT INTO previews VALUES (264, 54, 65, 100, 'image/jpeg', '70776c6bf8084592b0c464ca1082e385_small.jpg', 'small', '2012-10-16 13:48:06.830665', '2012-10-16 13:48:06.830665');
INSERT INTO previews VALUES (265, 55, 672, 1024, 'image/jpeg', '2b68888c0bf14c96a77153feb312e07d_x_large.jpg', 'x_large', '2012-10-16 13:48:08.057056', '2012-10-16 13:48:08.057056');
INSERT INTO previews VALUES (266, 55, 407, 620, 'image/jpeg', '2b68888c0bf14c96a77153feb312e07d_large.jpg', 'large', '2012-10-16 13:48:08.373787', '2012-10-16 13:48:08.373787');
INSERT INTO previews VALUES (267, 55, 197, 300, 'image/jpeg', '2b68888c0bf14c96a77153feb312e07d_medium.jpg', 'medium', '2012-10-16 13:48:08.755419', '2012-10-16 13:48:08.755419');
INSERT INTO previews VALUES (268, 55, 82, 125, 'image/jpeg', '2b68888c0bf14c96a77153feb312e07d_small_125.jpg', 'small_125', '2012-10-16 13:48:09.134296', '2012-10-16 13:48:09.134296');
INSERT INTO previews VALUES (269, 55, 66, 100, 'image/jpeg', '2b68888c0bf14c96a77153feb312e07d_small.jpg', 'small', '2012-10-16 13:48:09.361867', '2012-10-16 13:48:09.361867');
INSERT INTO previews VALUES (270, 56, 683, 1024, 'image/jpeg', '11df5179c244420daa7d2b3bbad7be71_x_large.jpg', 'x_large', '2012-10-16 13:48:10.768513', '2012-10-16 13:48:10.768513');
INSERT INTO previews VALUES (271, 56, 414, 620, 'image/jpeg', '11df5179c244420daa7d2b3bbad7be71_large.jpg', 'large', '2012-10-16 13:48:11.132148', '2012-10-16 13:48:11.132148');
INSERT INTO previews VALUES (272, 56, 200, 300, 'image/jpeg', '11df5179c244420daa7d2b3bbad7be71_medium.jpg', 'medium', '2012-10-16 13:48:11.571079', '2012-10-16 13:48:11.571079');
INSERT INTO previews VALUES (273, 56, 83, 125, 'image/jpeg', '11df5179c244420daa7d2b3bbad7be71_small_125.jpg', 'small_125', '2012-10-16 13:48:11.829832', '2012-10-16 13:48:11.829832');
INSERT INTO previews VALUES (274, 56, 67, 100, 'image/jpeg', '11df5179c244420daa7d2b3bbad7be71_small.jpg', 'small', '2012-10-16 13:48:12.265428', '2012-10-16 13:48:12.265428');
INSERT INTO previews VALUES (275, 57, 683, 1024, 'image/jpeg', '29ede99b7a9d48e588daac4ae519dae8_x_large.jpg', 'x_large', '2012-10-16 13:48:13.087567', '2012-10-16 13:48:13.087567');
INSERT INTO previews VALUES (276, 57, 414, 620, 'image/jpeg', '29ede99b7a9d48e588daac4ae519dae8_large.jpg', 'large', '2012-10-16 13:48:13.422117', '2012-10-16 13:48:13.422117');
INSERT INTO previews VALUES (277, 57, 200, 300, 'image/jpeg', '29ede99b7a9d48e588daac4ae519dae8_medium.jpg', 'medium', '2012-10-16 13:48:13.783853', '2012-10-16 13:48:13.783853');
INSERT INTO previews VALUES (278, 57, 83, 125, 'image/jpeg', '29ede99b7a9d48e588daac4ae519dae8_small_125.jpg', 'small_125', '2012-10-16 13:48:14.20662', '2012-10-16 13:48:14.20662');
INSERT INTO previews VALUES (279, 57, 67, 100, 'image/jpeg', '29ede99b7a9d48e588daac4ae519dae8_small.jpg', 'small', '2012-10-16 13:48:14.567319', '2012-10-16 13:48:14.567319');
INSERT INTO previews VALUES (464, 94, 65, 100, 'image/jpeg', '892b9d59952047649b4ba55776062c6e_small.jpg', 'small', '2012-10-16 13:58:24.504027', '2012-10-16 13:58:24.504027');
INSERT INTO previews VALUES (465, 95, 672, 1024, 'image/jpeg', '82aac15d6f8f40c09341ac67900a6912_x_large.jpg', 'x_large', '2012-10-16 13:58:25.829066', '2012-10-16 13:58:25.829066');
INSERT INTO previews VALUES (466, 95, 407, 620, 'image/jpeg', '82aac15d6f8f40c09341ac67900a6912_large.jpg', 'large', '2012-10-16 13:58:26.278376', '2012-10-16 13:58:26.278376');
INSERT INTO previews VALUES (467, 95, 197, 300, 'image/jpeg', '82aac15d6f8f40c09341ac67900a6912_medium.jpg', 'medium', '2012-10-16 13:58:26.710583', '2012-10-16 13:58:26.710583');
INSERT INTO previews VALUES (468, 95, 82, 125, 'image/jpeg', '82aac15d6f8f40c09341ac67900a6912_small_125.jpg', 'small_125', '2012-10-16 13:58:27.088477', '2012-10-16 13:58:27.088477');
INSERT INTO previews VALUES (285, 59, 670, 1024, 'image/jpeg', '0a4db977dd6a40449518eb21fadf0faa_x_large.jpg', 'x_large', '2012-10-16 13:56:35.628175', '2012-10-16 13:56:35.628175');
INSERT INTO previews VALUES (286, 59, 406, 620, 'image/jpeg', '0a4db977dd6a40449518eb21fadf0faa_large.jpg', 'large', '2012-10-16 13:56:36.162193', '2012-10-16 13:56:36.162193');
INSERT INTO previews VALUES (287, 59, 196, 300, 'image/jpeg', '0a4db977dd6a40449518eb21fadf0faa_medium.jpg', 'medium', '2012-10-16 13:56:36.503435', '2012-10-16 13:56:36.503435');
INSERT INTO previews VALUES (288, 59, 82, 125, 'image/jpeg', '0a4db977dd6a40449518eb21fadf0faa_small_125.jpg', 'small_125', '2012-10-16 13:56:36.780861', '2012-10-16 13:56:36.780861');
INSERT INTO previews VALUES (289, 59, 65, 100, 'image/jpeg', '0a4db977dd6a40449518eb21fadf0faa_small.jpg', 'small', '2012-10-16 13:56:37.332917', '2012-10-16 13:56:37.332917');
INSERT INTO previews VALUES (469, 95, 66, 100, 'image/jpeg', '82aac15d6f8f40c09341ac67900a6912_small.jpg', 'small', '2012-10-16 13:58:27.54714', '2012-10-16 13:58:27.54714');
INSERT INTO previews VALUES (470, 96, 683, 1024, 'image/jpeg', 'f97864380d3243f4bd608b32a540eaf9_x_large.jpg', 'x_large', '2012-10-16 13:58:29.04488', '2012-10-16 13:58:29.04488');
INSERT INTO previews VALUES (471, 96, 414, 620, 'image/jpeg', 'f97864380d3243f4bd608b32a540eaf9_large.jpg', 'large', '2012-10-16 13:58:29.433748', '2012-10-16 13:58:29.433748');
INSERT INTO previews VALUES (472, 96, 200, 300, 'image/jpeg', 'f97864380d3243f4bd608b32a540eaf9_medium.jpg', 'medium', '2012-10-16 13:58:29.943663', '2012-10-16 13:58:29.943663');
INSERT INTO previews VALUES (473, 96, 83, 125, 'image/jpeg', 'f97864380d3243f4bd608b32a540eaf9_small_125.jpg', 'small_125', '2012-10-16 13:58:30.407293', '2012-10-16 13:58:30.407293');
INSERT INTO previews VALUES (295, 61, 675, 1024, 'image/jpeg', 'b5c3c220239f4c6380ecac0e184563ed_x_large.jpg', 'x_large', '2012-10-16 13:56:42.515692', '2012-10-16 13:56:42.515692');
INSERT INTO previews VALUES (296, 61, 409, 620, 'image/jpeg', 'b5c3c220239f4c6380ecac0e184563ed_large.jpg', 'large', '2012-10-16 13:56:42.913083', '2012-10-16 13:56:42.913083');
INSERT INTO previews VALUES (297, 61, 198, 300, 'image/jpeg', 'b5c3c220239f4c6380ecac0e184563ed_medium.jpg', 'medium', '2012-10-16 13:56:43.255823', '2012-10-16 13:56:43.255823');
INSERT INTO previews VALUES (298, 61, 82, 125, 'image/jpeg', 'b5c3c220239f4c6380ecac0e184563ed_small_125.jpg', 'small_125', '2012-10-16 13:56:43.570555', '2012-10-16 13:56:43.570555');
INSERT INTO previews VALUES (299, 61, 66, 100, 'image/jpeg', 'b5c3c220239f4c6380ecac0e184563ed_small.jpg', 'small', '2012-10-16 13:56:44.089747', '2012-10-16 13:56:44.089747');
INSERT INTO previews VALUES (300, 62, 768, 545, 'image/jpeg', 'd5208d0eb97a48ebb8c43bac5924cf11_x_large.jpg', 'x_large', '2012-10-16 13:56:45.291324', '2012-10-16 13:56:45.291324');
INSERT INTO previews VALUES (301, 62, 500, 355, 'image/jpeg', 'd5208d0eb97a48ebb8c43bac5924cf11_large.jpg', 'large', '2012-10-16 13:56:45.736085', '2012-10-16 13:56:45.736085');
INSERT INTO previews VALUES (302, 62, 300, 213, 'image/jpeg', 'd5208d0eb97a48ebb8c43bac5924cf11_medium.jpg', 'medium', '2012-10-16 13:56:46.169461', '2012-10-16 13:56:46.169461');
INSERT INTO previews VALUES (303, 62, 125, 89, 'image/jpeg', 'd5208d0eb97a48ebb8c43bac5924cf11_small_125.jpg', 'small_125', '2012-10-16 13:56:46.505593', '2012-10-16 13:56:46.505593');
INSERT INTO previews VALUES (304, 62, 100, 71, 'image/jpeg', 'd5208d0eb97a48ebb8c43bac5924cf11_small.jpg', 'small', '2012-10-16 13:56:46.948139', '2012-10-16 13:56:46.948139');
INSERT INTO previews VALUES (305, 63, 768, 502, 'image/jpeg', '804b755ab83647dfa07908970ac6cdf2_x_large.jpg', 'x_large', '2012-10-16 13:56:48.02605', '2012-10-16 13:56:48.02605');
INSERT INTO previews VALUES (306, 63, 500, 327, 'image/jpeg', '804b755ab83647dfa07908970ac6cdf2_large.jpg', 'large', '2012-10-16 13:56:48.496774', '2012-10-16 13:56:48.496774');
INSERT INTO previews VALUES (307, 63, 300, 196, 'image/jpeg', '804b755ab83647dfa07908970ac6cdf2_medium.jpg', 'medium', '2012-10-16 13:56:49.036826', '2012-10-16 13:56:49.036826');
INSERT INTO previews VALUES (308, 63, 125, 82, 'image/jpeg', '804b755ab83647dfa07908970ac6cdf2_small_125.jpg', 'small_125', '2012-10-16 13:56:49.590452', '2012-10-16 13:56:49.590452');
INSERT INTO previews VALUES (309, 63, 100, 65, 'image/jpeg', '804b755ab83647dfa07908970ac6cdf2_small.jpg', 'small', '2012-10-16 13:56:49.994803', '2012-10-16 13:56:49.994803');
INSERT INTO previews VALUES (310, 64, 768, 463, 'image/jpeg', '2a586fcf60e74affa2770f9200722d5a_x_large.jpg', 'x_large', '2012-10-16 13:56:50.895065', '2012-10-16 13:56:50.895065');
INSERT INTO previews VALUES (311, 64, 500, 301, 'image/jpeg', '2a586fcf60e74affa2770f9200722d5a_large.jpg', 'large', '2012-10-16 13:56:51.508068', '2012-10-16 13:56:51.508068');
INSERT INTO previews VALUES (312, 64, 300, 181, 'image/jpeg', '2a586fcf60e74affa2770f9200722d5a_medium.jpg', 'medium', '2012-10-16 13:56:51.908209', '2012-10-16 13:56:51.908209');
INSERT INTO previews VALUES (313, 64, 125, 75, 'image/jpeg', '2a586fcf60e74affa2770f9200722d5a_small_125.jpg', 'small_125', '2012-10-16 13:56:52.327734', '2012-10-16 13:56:52.327734');
INSERT INTO previews VALUES (314, 64, 100, 60, 'image/jpeg', '2a586fcf60e74affa2770f9200722d5a_small.jpg', 'small', '2012-10-16 13:56:52.766465', '2012-10-16 13:56:52.766465');
INSERT INTO previews VALUES (315, 65, 675, 1024, 'image/jpeg', '9d52c9a6ff5b4eada7c489b3e2a6111b_x_large.jpg', 'x_large', '2012-10-16 13:56:53.410296', '2012-10-16 13:56:53.410296');
INSERT INTO previews VALUES (316, 65, 409, 620, 'image/jpeg', '9d52c9a6ff5b4eada7c489b3e2a6111b_large.jpg', 'large', '2012-10-16 13:56:53.853352', '2012-10-16 13:56:53.853352');
INSERT INTO previews VALUES (317, 65, 198, 300, 'image/jpeg', '9d52c9a6ff5b4eada7c489b3e2a6111b_medium.jpg', 'medium', '2012-10-16 13:56:54.245457', '2012-10-16 13:56:54.245457');
INSERT INTO previews VALUES (318, 65, 82, 125, 'image/jpeg', '9d52c9a6ff5b4eada7c489b3e2a6111b_small_125.jpg', 'small_125', '2012-10-16 13:56:54.79469', '2012-10-16 13:56:54.79469');
INSERT INTO previews VALUES (319, 65, 66, 100, 'image/jpeg', '9d52c9a6ff5b4eada7c489b3e2a6111b_small.jpg', 'small', '2012-10-16 13:56:55.235514', '2012-10-16 13:56:55.235514');
INSERT INTO previews VALUES (320, 66, 683, 1024, 'image/jpeg', '9312b221582c4c67b86745e3769bbc0b_x_large.jpg', 'x_large', '2012-10-16 13:56:56.635183', '2012-10-16 13:56:56.635183');
INSERT INTO previews VALUES (321, 66, 414, 620, 'image/jpeg', '9312b221582c4c67b86745e3769bbc0b_large.jpg', 'large', '2012-10-16 13:56:57.080309', '2012-10-16 13:56:57.080309');
INSERT INTO previews VALUES (322, 66, 200, 300, 'image/jpeg', '9312b221582c4c67b86745e3769bbc0b_medium.jpg', 'medium', '2012-10-16 13:56:57.681823', '2012-10-16 13:56:57.681823');
INSERT INTO previews VALUES (323, 66, 83, 125, 'image/jpeg', '9312b221582c4c67b86745e3769bbc0b_small_125.jpg', 'small_125', '2012-10-16 13:56:58.10051', '2012-10-16 13:56:58.10051');
INSERT INTO previews VALUES (324, 66, 67, 100, 'image/jpeg', '9312b221582c4c67b86745e3769bbc0b_small.jpg', 'small', '2012-10-16 13:56:58.717081', '2012-10-16 13:56:58.717081');
INSERT INTO previews VALUES (325, 67, 768, 621, 'image/jpeg', '90b268ef4efd40d4b2679019985ef1f2_x_large.jpg', 'x_large', '2012-10-16 13:56:59.91294', '2012-10-16 13:56:59.91294');
INSERT INTO previews VALUES (326, 67, 500, 404, 'image/jpeg', '90b268ef4efd40d4b2679019985ef1f2_large.jpg', 'large', '2012-10-16 13:57:00.399307', '2012-10-16 13:57:00.399307');
INSERT INTO previews VALUES (327, 67, 300, 243, 'image/jpeg', '90b268ef4efd40d4b2679019985ef1f2_medium.jpg', 'medium', '2012-10-16 13:57:00.713841', '2012-10-16 13:57:00.713841');
INSERT INTO previews VALUES (328, 67, 125, 101, 'image/jpeg', '90b268ef4efd40d4b2679019985ef1f2_small_125.jpg', 'small_125', '2012-10-16 13:57:01.190536', '2012-10-16 13:57:01.190536');
INSERT INTO previews VALUES (329, 67, 100, 81, 'image/jpeg', '90b268ef4efd40d4b2679019985ef1f2_small.jpg', 'small', '2012-10-16 13:57:01.564679', '2012-10-16 13:57:01.564679');
INSERT INTO previews VALUES (330, 68, 717, 1024, 'image/jpeg', '507e5b3acf4341858fc3ac116f1f9691_x_large.jpg', 'x_large', '2012-10-16 13:57:03.346516', '2012-10-16 13:57:03.346516');
INSERT INTO previews VALUES (331, 68, 434, 620, 'image/jpeg', '507e5b3acf4341858fc3ac116f1f9691_large.jpg', 'large', '2012-10-16 13:57:03.914648', '2012-10-16 13:57:03.914648');
INSERT INTO previews VALUES (332, 68, 210, 300, 'image/jpeg', '507e5b3acf4341858fc3ac116f1f9691_medium.jpg', 'medium', '2012-10-16 13:57:04.566115', '2012-10-16 13:57:04.566115');
INSERT INTO previews VALUES (333, 68, 88, 125, 'image/jpeg', '507e5b3acf4341858fc3ac116f1f9691_small_125.jpg', 'small_125', '2012-10-16 13:57:05.145974', '2012-10-16 13:57:05.145974');
INSERT INTO previews VALUES (334, 68, 70, 100, 'image/jpeg', '507e5b3acf4341858fc3ac116f1f9691_small.jpg', 'small', '2012-10-16 13:57:05.690675', '2012-10-16 13:57:05.690675');
INSERT INTO previews VALUES (474, 96, 67, 100, 'image/jpeg', 'f97864380d3243f4bd608b32a540eaf9_small.jpg', 'small', '2012-10-16 13:58:30.809489', '2012-10-16 13:58:30.809489');
INSERT INTO previews VALUES (475, 97, 683, 1024, 'image/jpeg', 'cc529d4936ec47fca6d4957000c24a32_x_large.jpg', 'x_large', '2012-10-16 13:58:31.623979', '2012-10-16 13:58:31.623979');
INSERT INTO previews VALUES (476, 97, 414, 620, 'image/jpeg', 'cc529d4936ec47fca6d4957000c24a32_large.jpg', 'large', '2012-10-16 13:58:32.151588', '2012-10-16 13:58:32.151588');
INSERT INTO previews VALUES (477, 97, 200, 300, 'image/jpeg', 'cc529d4936ec47fca6d4957000c24a32_medium.jpg', 'medium', '2012-10-16 13:58:32.617603', '2012-10-16 13:58:32.617603');
INSERT INTO previews VALUES (478, 97, 83, 125, 'image/jpeg', 'cc529d4936ec47fca6d4957000c24a32_small_125.jpg', 'small_125', '2012-10-16 13:58:33.155257', '2012-10-16 13:58:33.155257');
INSERT INTO previews VALUES (479, 97, 67, 100, 'image/jpeg', 'cc529d4936ec47fca6d4957000c24a32_small.jpg', 'small', '2012-10-16 13:58:33.534116', '2012-10-16 13:58:33.534116');
INSERT INTO previews VALUES (360, 74, 768, 952, 'image/jpeg', 'fc57d96b85ca4b9ebf96d460efcc9dba_x_large.jpg', 'x_large', '2012-10-16 13:57:21.908209', '2012-10-16 13:57:21.908209');
INSERT INTO previews VALUES (361, 74, 500, 620, 'image/jpeg', 'fc57d96b85ca4b9ebf96d460efcc9dba_large.jpg', 'large', '2012-10-16 13:57:22.435752', '2012-10-16 13:57:22.435752');
INSERT INTO previews VALUES (362, 74, 242, 300, 'image/jpeg', 'fc57d96b85ca4b9ebf96d460efcc9dba_medium.jpg', 'medium', '2012-10-16 13:57:22.835201', '2012-10-16 13:57:22.835201');
INSERT INTO previews VALUES (363, 74, 101, 125, 'image/jpeg', 'fc57d96b85ca4b9ebf96d460efcc9dba_small_125.jpg', 'small_125', '2012-10-16 13:57:23.259257', '2012-10-16 13:57:23.259257');
INSERT INTO previews VALUES (364, 74, 81, 100, 'image/jpeg', 'fc57d96b85ca4b9ebf96d460efcc9dba_small.jpg', 'small', '2012-10-16 13:57:23.642858', '2012-10-16 13:57:23.642858');
INSERT INTO previews VALUES (370, 76, 717, 1024, 'image/jpeg', '1c367cc8e2f849158cdd940017d14943_x_large.jpg', 'x_large', '2012-10-16 13:57:28.212167', '2012-10-16 13:57:28.212167');
INSERT INTO previews VALUES (371, 76, 434, 620, 'image/jpeg', '1c367cc8e2f849158cdd940017d14943_large.jpg', 'large', '2012-10-16 13:57:28.725985', '2012-10-16 13:57:28.725985');
INSERT INTO previews VALUES (372, 76, 210, 300, 'image/jpeg', '1c367cc8e2f849158cdd940017d14943_medium.jpg', 'medium', '2012-10-16 13:57:29.235732', '2012-10-16 13:57:29.235732');
INSERT INTO previews VALUES (373, 76, 88, 125, 'image/jpeg', '1c367cc8e2f849158cdd940017d14943_small_125.jpg', 'small_125', '2012-10-16 13:57:29.66769', '2012-10-16 13:57:29.66769');
INSERT INTO previews VALUES (374, 76, 70, 100, 'image/jpeg', '1c367cc8e2f849158cdd940017d14943_small.jpg', 'small', '2012-10-16 13:57:30.004635', '2012-10-16 13:57:30.004635');
INSERT INTO previews VALUES (375, 77, 682, 1024, 'image/jpeg', 'a04e6ca0c0824050abd7c52990d4ecec_x_large.jpg', 'x_large', '2012-10-16 13:57:31.302495', '2012-10-16 13:57:31.302495');
INSERT INTO previews VALUES (376, 77, 413, 620, 'image/jpeg', 'a04e6ca0c0824050abd7c52990d4ecec_large.jpg', 'large', '2012-10-16 13:57:31.731145', '2012-10-16 13:57:31.731145');
INSERT INTO previews VALUES (377, 77, 200, 300, 'image/jpeg', 'a04e6ca0c0824050abd7c52990d4ecec_medium.jpg', 'medium', '2012-10-16 13:57:32.273988', '2012-10-16 13:57:32.273988');
INSERT INTO previews VALUES (378, 77, 83, 125, 'image/jpeg', 'a04e6ca0c0824050abd7c52990d4ecec_small_125.jpg', 'small_125', '2012-10-16 13:57:32.702638', '2012-10-16 13:57:32.702638');
INSERT INTO previews VALUES (379, 77, 67, 100, 'image/jpeg', 'a04e6ca0c0824050abd7c52990d4ecec_small.jpg', 'small', '2012-10-16 13:57:33.265715', '2012-10-16 13:57:33.265715');
INSERT INTO previews VALUES (380, 78, 768, 961, 'image/jpeg', 'ad42a43b63574c48bfe9977a2fa54c41_x_large.jpg', 'x_large', '2012-10-16 13:57:34.293189', '2012-10-16 13:57:34.293189');
INSERT INTO previews VALUES (381, 78, 495, 620, 'image/jpeg', 'ad42a43b63574c48bfe9977a2fa54c41_large.jpg', 'large', '2012-10-16 13:57:34.702927', '2012-10-16 13:57:34.702927');
INSERT INTO previews VALUES (382, 78, 240, 300, 'image/jpeg', 'ad42a43b63574c48bfe9977a2fa54c41_medium.jpg', 'medium', '2012-10-16 13:57:35.265659', '2012-10-16 13:57:35.265659');
INSERT INTO previews VALUES (383, 78, 100, 125, 'image/jpeg', 'ad42a43b63574c48bfe9977a2fa54c41_small_125.jpg', 'small_125', '2012-10-16 13:57:35.73789', '2012-10-16 13:57:35.73789');
INSERT INTO previews VALUES (384, 78, 80, 100, 'image/jpeg', 'ad42a43b63574c48bfe9977a2fa54c41_small.jpg', 'small', '2012-10-16 13:57:36.160438', '2012-10-16 13:57:36.160438');
INSERT INTO previews VALUES (385, 79, 768, 1024, 'image/jpeg', '42b8ac3bd7b646d182017670dba9fad0_x_large.jpg', 'x_large', '2012-10-16 13:57:37.421425', '2012-10-16 13:57:37.421425');
INSERT INTO previews VALUES (386, 79, 465, 620, 'image/jpeg', '42b8ac3bd7b646d182017670dba9fad0_large.jpg', 'large', '2012-10-16 13:57:37.975966', '2012-10-16 13:57:37.975966');
INSERT INTO previews VALUES (387, 79, 225, 300, 'image/jpeg', '42b8ac3bd7b646d182017670dba9fad0_medium.jpg', 'medium', '2012-10-16 13:57:38.402798', '2012-10-16 13:57:38.402798');
INSERT INTO previews VALUES (388, 79, 94, 125, 'image/jpeg', '42b8ac3bd7b646d182017670dba9fad0_small_125.jpg', 'small_125', '2012-10-16 13:57:38.919496', '2012-10-16 13:57:38.919496');
INSERT INTO previews VALUES (389, 79, 75, 100, 'image/jpeg', '42b8ac3bd7b646d182017670dba9fad0_small.jpg', 'small', '2012-10-16 13:57:39.371957', '2012-10-16 13:57:39.371957');
INSERT INTO previews VALUES (395, 81, 668, 1024, 'image/jpeg', '8170d52fb27745b299da78b6298ff144_x_large.jpg', 'x_large', '2012-10-16 13:57:43.148715', '2012-10-16 13:57:43.148715');
INSERT INTO previews VALUES (396, 81, 404, 620, 'image/jpeg', '8170d52fb27745b299da78b6298ff144_large.jpg', 'large', '2012-10-16 13:57:43.543335', '2012-10-16 13:57:43.543335');
INSERT INTO previews VALUES (397, 81, 196, 300, 'image/jpeg', '8170d52fb27745b299da78b6298ff144_medium.jpg', 'medium', '2012-10-16 13:57:43.907443', '2012-10-16 13:57:43.907443');
INSERT INTO previews VALUES (398, 81, 82, 125, 'image/jpeg', '8170d52fb27745b299da78b6298ff144_small_125.jpg', 'small_125', '2012-10-16 13:57:44.379372', '2012-10-16 13:57:44.379372');
INSERT INTO previews VALUES (399, 81, 65, 100, 'image/jpeg', '8170d52fb27745b299da78b6298ff144_small.jpg', 'small', '2012-10-16 13:57:44.754339', '2012-10-16 13:57:44.754339');
INSERT INTO previews VALUES (400, 82, 617, 1024, 'image/jpeg', 'cefa87582fd04711b6b79443663df3be_x_large.jpg', 'x_large', '2012-10-16 13:57:46.171973', '2012-10-16 13:57:46.171973');
INSERT INTO previews VALUES (401, 82, 374, 620, 'image/jpeg', 'cefa87582fd04711b6b79443663df3be_large.jpg', 'large', '2012-10-16 13:57:46.62439', '2012-10-16 13:57:46.62439');
INSERT INTO previews VALUES (402, 82, 181, 300, 'image/jpeg', 'cefa87582fd04711b6b79443663df3be_medium.jpg', 'medium', '2012-10-16 13:57:47.255831', '2012-10-16 13:57:47.255831');
INSERT INTO previews VALUES (403, 82, 75, 125, 'image/jpeg', 'cefa87582fd04711b6b79443663df3be_small_125.jpg', 'small_125', '2012-10-16 13:57:47.734739', '2012-10-16 13:57:47.734739');
INSERT INTO previews VALUES (404, 82, 60, 100, 'image/jpeg', 'cefa87582fd04711b6b79443663df3be_small.jpg', 'small', '2012-10-16 13:57:48.226497', '2012-10-16 13:57:48.226497');
INSERT INTO previews VALUES (410, 84, 669, 1024, 'image/jpeg', 'dbfb300edaa04bcd960cebeec0c46bc3_x_large.jpg', 'x_large', '2012-10-16 13:57:52.332133', '2012-10-16 13:57:52.332133');
INSERT INTO previews VALUES (411, 84, 405, 620, 'image/jpeg', 'dbfb300edaa04bcd960cebeec0c46bc3_large.jpg', 'large', '2012-10-16 13:57:52.738763', '2012-10-16 13:57:52.738763');
INSERT INTO previews VALUES (412, 84, 196, 300, 'image/jpeg', 'dbfb300edaa04bcd960cebeec0c46bc3_medium.jpg', 'medium', '2012-10-16 13:57:53.234625', '2012-10-16 13:57:53.234625');
INSERT INTO previews VALUES (413, 84, 82, 125, 'image/jpeg', 'dbfb300edaa04bcd960cebeec0c46bc3_small_125.jpg', 'small_125', '2012-10-16 13:57:53.737658', '2012-10-16 13:57:53.737658');
INSERT INTO previews VALUES (505, 103, 668, 1024, 'image/jpeg', 'fec452eb8d194593b176aa36fd3eca7c_x_large.jpg', 'x_large', '2012-10-16 14:10:16.711757', '2012-10-16 14:10:16.711757');
INSERT INTO previews VALUES (506, 103, 404, 620, 'image/jpeg', 'fec452eb8d194593b176aa36fd3eca7c_large.jpg', 'large', '2012-10-16 14:10:17.164824', '2012-10-16 14:10:17.164824');
INSERT INTO previews VALUES (507, 103, 196, 300, 'image/jpeg', 'fec452eb8d194593b176aa36fd3eca7c_medium.jpg', 'medium', '2012-10-16 14:10:17.652696', '2012-10-16 14:10:17.652696');
INSERT INTO previews VALUES (508, 103, 82, 125, 'image/jpeg', 'fec452eb8d194593b176aa36fd3eca7c_small_125.jpg', 'small_125', '2012-10-16 14:10:17.860882', '2012-10-16 14:10:17.860882');
INSERT INTO previews VALUES (509, 103, 65, 100, 'image/jpeg', 'fec452eb8d194593b176aa36fd3eca7c_small.jpg', 'small', '2012-10-16 14:10:18.157341', '2012-10-16 14:10:18.157341');
INSERT INTO previews VALUES (515, 105, 683, 1024, 'image/jpeg', '619fe0823d304f97ac2c6ecace872d48_x_large.jpg', 'x_large', '2012-10-16 14:10:22.699054', '2012-10-16 14:10:22.699054');
INSERT INTO previews VALUES (516, 105, 414, 620, 'image/jpeg', '619fe0823d304f97ac2c6ecace872d48_large.jpg', 'large', '2012-10-16 14:10:23.09856', '2012-10-16 14:10:23.09856');
INSERT INTO previews VALUES (517, 105, 200, 300, 'image/jpeg', '619fe0823d304f97ac2c6ecace872d48_medium.jpg', 'medium', '2012-10-16 14:10:23.357557', '2012-10-16 14:10:23.357557');
INSERT INTO previews VALUES (518, 105, 83, 125, 'image/jpeg', '619fe0823d304f97ac2c6ecace872d48_small_125.jpg', 'small_125', '2012-10-16 14:10:23.769667', '2012-10-16 14:10:23.769667');
INSERT INTO previews VALUES (519, 105, 67, 100, 'image/jpeg', '619fe0823d304f97ac2c6ecace872d48_small.jpg', 'small', '2012-10-16 14:10:24.297095', '2012-10-16 14:10:24.297095');
INSERT INTO previews VALUES (530, 111, 768, 510, 'image/jpeg', '5e172a4a8405457abac60aee80f33948_maximum.jpg', 'maximum', '2013-03-12 10:32:12.925197', '2013-03-12 10:32:12.925197');
INSERT INTO previews VALUES (531, 111, 768, 510, 'image/jpeg', '5e172a4a8405457abac60aee80f33948_x_large.jpg', 'x_large', '2013-03-12 10:32:13.254597', '2013-03-12 10:32:13.254597');
INSERT INTO previews VALUES (532, 111, 500, 332, 'image/jpeg', '5e172a4a8405457abac60aee80f33948_large.jpg', 'large', '2013-03-12 10:32:13.758541', '2013-03-12 10:32:13.758541');
INSERT INTO previews VALUES (533, 111, 300, 199, 'image/jpeg', '5e172a4a8405457abac60aee80f33948_medium.jpg', 'medium', '2013-03-12 10:32:14.140916', '2013-03-12 10:32:14.140916');
INSERT INTO previews VALUES (534, 111, 125, 83, 'image/jpeg', '5e172a4a8405457abac60aee80f33948_small_125.jpg', 'small_125', '2013-03-12 10:32:14.533399', '2013-03-12 10:32:14.533399');
INSERT INTO previews VALUES (535, 111, 100, 66, 'image/jpeg', '5e172a4a8405457abac60aee80f33948_small.jpg', 'small', '2013-03-12 10:32:14.86451', '2013-03-12 10:32:14.86451');
INSERT INTO previews VALUES (536, 112, 348, 620, 'video/mp4', '66b1ef50186645438c047179f54ec6e6_encoded_ea33ebcd-81d2-4a16-b9c7-dcb9a65f1f03.mp4', 'large', '2013-05-21 07:03:38.008158', '2013-05-21 07:03:38.008158');
INSERT INTO previews VALUES (537, 112, 348, 620, 'video/webm', '66b1ef50186645438c047179f54ec6e6_encoded_ea33ebcd-81d2-4a16-b9c7-dcb9a65f1f03.webm', 'large', '2013-05-21 07:03:38.171082', '2013-05-21 07:03:38.171082');
INSERT INTO previews VALUES (538, 112, 348, 620, 'image/jpeg', '66b1ef50186645438c047179f54ec6e6_encoded_ea33ebcd-81d2-4a16-b9c7-dcb9a65f1f03_0000.jpg', 'large', '2013-05-21 07:03:38.233505', '2013-05-21 07:03:38.233505');
INSERT INTO previews VALUES (539, 112, 718, 1280, 'image/jpeg', '66b1ef50186645438c047179f54ec6e6_maximum.jpg', 'maximum', '2013-05-21 07:03:38.560503', '2013-05-21 07:03:38.560503');
INSERT INTO previews VALUES (540, 112, 348, 620, 'image/jpeg', '66b1ef50186645438c047179f54ec6e6_x_large.jpg', 'x_large', '2013-05-21 07:03:38.634611', '2013-05-21 07:03:38.634611');
INSERT INTO previews VALUES (541, 112, 348, 620, 'image/jpeg', '66b1ef50186645438c047179f54ec6e6_large.jpg', 'large', '2013-05-21 07:03:38.707955', '2013-05-21 07:03:38.707955');
INSERT INTO previews VALUES (542, 112, 168, 300, 'image/jpeg', '66b1ef50186645438c047179f54ec6e6_medium.jpg', 'medium', '2013-05-21 07:03:38.770957', '2013-05-21 07:03:38.770957');
INSERT INTO previews VALUES (543, 112, 70, 125, 'image/jpeg', '66b1ef50186645438c047179f54ec6e6_small_125.jpg', 'small_125', '2013-05-21 07:03:38.826693', '2013-05-21 07:03:38.826693');
INSERT INTO previews VALUES (544, 112, 56, 100, 'image/jpeg', '66b1ef50186645438c047179f54ec6e6_small.jpg', 'small', '2013-05-21 07:03:38.876986', '2013-05-21 07:03:38.876986');
INSERT INTO previews VALUES (545, 113, 1, 1, 'image/jpeg', '6985741d84e04b71b5345b2f6a077372_maximum.jpg', 'maximum', '2013-07-08 08:26:55.547299', '2013-07-08 08:26:55.547299');
INSERT INTO previews VALUES (546, 113, 595, 842, 'image/jpeg', '6985741d84e04b71b5345b2f6a077372_x_large.jpg', 'x_large', '2013-07-08 08:26:56.244121', '2013-07-08 08:26:56.244121');
INSERT INTO previews VALUES (547, 113, 438, 620, 'image/jpeg', '6985741d84e04b71b5345b2f6a077372_large.jpg', 'large', '2013-07-08 08:26:56.931817', '2013-07-08 08:26:56.931817');
INSERT INTO previews VALUES (548, 113, 212, 300, 'image/jpeg', '6985741d84e04b71b5345b2f6a077372_medium.jpg', 'medium', '2013-07-08 08:26:57.564949', '2013-07-08 08:26:57.564949');
INSERT INTO previews VALUES (549, 113, 88, 125, 'image/jpeg', '6985741d84e04b71b5345b2f6a077372_small_125.jpg', 'small_125', '2013-07-08 08:26:58.1842', '2013-07-08 08:26:58.1842');
INSERT INTO previews VALUES (550, 113, 71, 100, 'image/jpeg', '6985741d84e04b71b5345b2f6a077372_small.jpg', 'small', '2013-07-08 08:26:58.798091', '2013-07-08 08:26:58.798091');
INSERT INTO previews VALUES (551, 114, 600, 800, 'image/jpeg', '2a0cba39a2c242c189ced07dcea19dc6_maximum.jpg', 'maximum', '2013-07-08 08:41:53.019264', '2013-07-08 08:41:53.019264');
INSERT INTO previews VALUES (552, 114, 600, 800, 'image/jpeg', '2a0cba39a2c242c189ced07dcea19dc6_x_large.jpg', 'x_large', '2013-07-08 08:41:53.124525', '2013-07-08 08:41:53.124525');
INSERT INTO previews VALUES (553, 114, 465, 620, 'image/jpeg', '2a0cba39a2c242c189ced07dcea19dc6_large.jpg', 'large', '2013-07-08 08:41:53.235861', '2013-07-08 08:41:53.235861');
INSERT INTO previews VALUES (554, 114, 225, 300, 'image/jpeg', '2a0cba39a2c242c189ced07dcea19dc6_medium.jpg', 'medium', '2013-07-08 08:41:53.305152', '2013-07-08 08:41:53.305152');
INSERT INTO previews VALUES (555, 114, 94, 125, 'image/jpeg', '2a0cba39a2c242c189ced07dcea19dc6_small_125.jpg', 'small_125', '2013-07-08 08:41:53.359206', '2013-07-08 08:41:53.359206');
INSERT INTO previews VALUES (556, 114, 75, 100, 'image/jpeg', '2a0cba39a2c242c189ced07dcea19dc6_small.jpg', 'small', '2013-07-08 08:41:53.409562', '2013-07-08 08:41:53.409562');


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO schema_migrations VALUES ('1');
INSERT INTO schema_migrations VALUES ('2');
INSERT INTO schema_migrations VALUES ('3');
INSERT INTO schema_migrations VALUES ('4');
INSERT INTO schema_migrations VALUES ('5');
INSERT INTO schema_migrations VALUES ('6');
INSERT INTO schema_migrations VALUES ('7');
INSERT INTO schema_migrations VALUES ('8');
INSERT INTO schema_migrations VALUES ('9');
INSERT INTO schema_migrations VALUES ('10');
INSERT INTO schema_migrations VALUES ('11');
INSERT INTO schema_migrations VALUES ('12');
INSERT INTO schema_migrations VALUES ('13');
INSERT INTO schema_migrations VALUES ('14');
INSERT INTO schema_migrations VALUES ('15');
INSERT INTO schema_migrations VALUES ('16');
INSERT INTO schema_migrations VALUES ('17');
INSERT INTO schema_migrations VALUES ('18');
INSERT INTO schema_migrations VALUES ('19');
INSERT INTO schema_migrations VALUES ('20');
INSERT INTO schema_migrations VALUES ('21');
INSERT INTO schema_migrations VALUES ('22');
INSERT INTO schema_migrations VALUES ('23');
INSERT INTO schema_migrations VALUES ('24');
INSERT INTO schema_migrations VALUES ('25');
INSERT INTO schema_migrations VALUES ('26');
INSERT INTO schema_migrations VALUES ('27');
INSERT INTO schema_migrations VALUES ('20120924093527');
INSERT INTO schema_migrations VALUES ('20121005071336');
INSERT INTO schema_migrations VALUES ('20121010120938');
INSERT INTO schema_migrations VALUES ('20120820201434');
INSERT INTO schema_migrations VALUES ('20121015130831');
INSERT INTO schema_migrations VALUES ('20121116101855');
INSERT INTO schema_migrations VALUES ('20121203135807');
INSERT INTO schema_migrations VALUES ('20121204093504');
INSERT INTO schema_migrations VALUES ('20121217084234');
INSERT INTO schema_migrations VALUES ('20121219115031');
INSERT INTO schema_migrations VALUES ('20130205144924');
INSERT INTO schema_migrations VALUES ('20130314163226');
INSERT INTO schema_migrations VALUES ('20130319073038');
INSERT INTO schema_migrations VALUES ('20130322131740');
INSERT INTO schema_migrations VALUES ('20130326190454');
INSERT INTO schema_migrations VALUES ('20130411071654');
INSERT INTO schema_migrations VALUES ('20130415080622');
INSERT INTO schema_migrations VALUES ('20130415130815');
INSERT INTO schema_migrations VALUES ('20130416103629');
INSERT INTO schema_migrations VALUES ('20130417063225');
INSERT INTO schema_migrations VALUES ('20130417092015');
INSERT INTO schema_migrations VALUES ('20130419063314');
INSERT INTO schema_migrations VALUES ('20130617115706');
INSERT INTO schema_migrations VALUES ('20130618071639');
INSERT INTO schema_migrations VALUES ('20130716084432');


--
-- Data for Name: usage_terms; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO usage_terms VALUES (1, 'Nutzungsbedingungen', 'vom 29. September 2010', 'Bitte lesen, akzeptieren und halten Sie sich an die Nutzungsbedingungen.', '<h3>1. Gegenstand </h3>

<p>Die Nutzungsbedingungen des Medienarchivs der Züricher Hochschule der Künste (Betreiberin, nachfolgend
ZHdK bzw. Medienarchiv) regeln die Bedingungen der Nutzung für die Beteiligten (gemäss Ziff.4).</p>

<h3>2. Zweck</h3>

<p>Das Medienarchiv ist die zentrale Arbeitsplattform für digitale Medien an der ZHdK und unterstützt die erste
Stufe der Archivierung von künstlerischen und wissenschaftlichen Werken und deren Dokumentationen. </p>

<h3>3. Rechtsgrundlagen</h3>
<p>Die Rechtsgrundlagen für die Nutzung ergeben sich aus den entsprechenden immaterialgüterrechtlichen Bestimmungen [1] sowie jenen der Fachhochschulgesetzgebung [2].</p>

<h3>4.    Begriffe</h3>
<p>1) Als Anbieter gelten Personen, welche Medieninhalte in das Medienarchiv laden und deren Zugriffsberechtigungen verwalten. Dabei kommen als Personen sowohl natürliche wie juristische (Institutionen) in Frage.<br />
<p>2) Als Nutzer gelten Personen, welche die Dienstleistungen des Medienarchivs benützen und Medieneinträge der Anbieter verwenden. </p>
<p>3) Unter Medieninhalte werden alle Dateien und die dazugehörigen Metadaten verstanden, die im Medienarchiv digital gespeichert werden. </p>
<p>4) Als Medienarchiv wird die multimediale Internet-Plattform der ZHdK verstanden.</p>

<h3>5. Rechte </h3>
<p>
Bei den zur Verwendung stehenden Rechten geht es hauptsächlich um Immaterialgüterrechte (Rechte am Geistigen Eigentum), insbesondere Urheber-, Design-, Marken-, Patent- und Knowhow-Rechte.</p>

<h3>6. Nutzungsrechte</h3>
<p>Im Rahmen der gesetzlichen oder vertraglichen Bestimmungen sind folgende Nutzungsarten für Nutzer möglich:</p>
<p>- (beschränkte) Nutzung innerhalb der gesetzlichen oder vertraglichen Bedingungen</p>
<p>- (modifizierte) Nutzung gemäss Lizenzierung nach den Creative Commons-Lizenzen [3] oder gemäss individuellen Bedingungen (z.B. Studio Publikationen, ZHdK)</p>
<p>- (unbeschränkte) Nutzung bei Freigabe oder Entfall der Rechte (gemeinfreie Inhalte / public domain)</p>

<h3>7. Zugang</h3>
<p>1) Das Medienarchiv und dementsprechend deklarierte Medieninhalte sind prinzipiell frei zugänglich. </p>
<p>2) Durch ein Login erhalten die Angehörigen der ZHdK sowie bestimmte definierte Nutzer einen erweiterten Zugang zu den Inhalten und Funktionalitäten der Datenbank. </p>


<h3>8. Gewährleistungen </h3>
<p>1) Eine Gewähr für Richtigkeit, Vollständigkeit und Zulässigkeit der im Medienarchiv veröffentlichten Inhalte,
Informationen und Verweise wird von der ZHdK nicht übernommen. Die Verantwortung dafür liegt bei den
Anbietern.</p>
<p>2)  Die ZHdK haftet nur insoweit für die Inhalte und die Beachtung der vorliegenden Bestimmungen, soweit sie
von einem widerrechtlichen Inhalt Kenntnis hat und dafür gemäss dem einschlägigen Recht verantwortlich
gemacht werden kann.</p>
<p>3) Externe Internet-Plattformen geben den Inhalt und die Meinung der jeweiligen Anbieter wieder, für welche
keine Haftung übernommen werden kann. Für den Inhalt dieser verlinkten Seiten sind ausschliesslich deren
Betreiber verantwortlich.</p>
<p>4) Da das Medienarchiv keine Datenbank für private Ablagen ist, kann keine Garantie für die Erhaltung der
ausschliesslich privat einsehbaren Medieneinträge angeboten werden. Es ist Sache der Anbieter, eine eigene
Sicherungskopie dieser Medieneinträge zu erstellen.</p>
<p>5) Eine Haftung für Schäden, die durch unberechtigte Nutzung entstehen oder sonst gegen diese Bestimmungen verstossen, ist ausgeschlossen.</p>

<h3>9. Pflichten für die Anbieter</h3>
<p>1) Die Anbieter sind für die Einhaltung der rechtlichen, ethischen und moralischen Grundsätze verantwortlich.</p>
<p>2) Für die zur Verfügung gestellten Medieneinträge sind die Anbieter selbst verantwortlich. Dies betrifft nebst dien allgemeinen Grundsätzen (Abs.1) insbesondere die Beachtung von Rechten Dritter, wie den Hinweis auf Personen, welche Rechteinhaber sind und die genaue Angabe der Nutzungsbedingungen.</p>
<p>3) Die Anbieter sind ausserdem dazu verpflichtet, die Nutzungsrechte gemäss Art.6 zu definieren.</p>
<p>4) Die Nutzung des Medienarchivs darf nicht kommerziellen Zwecken dienen.</p>
<p>5) Eine rein private Ablage von Dateien und Informationen ist nicht erlaubt. </p>

<h3>10. Pflichten für die Nutzer</h3>
<p>1) Die Nutzer haben sich an die definierten Nutzungsrechte gemäss Art.6 zu halten. </p>
<p>2) Die Nutzung ist für den Eigengebrauch zulässig. Dies betrifft den privaten Gebrauch und die Verwendung für Lehre und Forschung. Eine weitergehende Nutzung (wie für kommerzielle Zwecke) bedarf der Zustimmung durch den Anbieter, soweit die Lizenz nicht bereits eine offene Verwendung zulässt.</p>

<h3>11. Nutzungen</h3>
<p>1) Das Medienarchiv ermöglicht es, für jeden Medieneintrag folgende Nutzungsrechte festzulegen:</p>
<ul>
  <li>a. Definition der Person bzw. der Nutzergruppe hinsichtlich der Sichtbarkeit.</li>
  <li>b. Definition der Person bzw. der Nutzergruppe hinsichtlich dem Editieren von Metadaten.</li>
  <li>c. Definition der Lizenzierung resp. der Bedingungen für die weitere Nutzung.</li>
</ul>
<p>2) Das Medienarchiv bezeichnet den Urheber bzw. Inhaber der Verwertungsrechte in einem dafür vorgesehenen Pflichtfeld in der Metadaten-Maske.</p>

<h3>12. Sanktionen bei unerlaubten Verwendungen</h3>
<p>Eine unerlaubte Verwendung einzelner Inhalte kann sowohl zivil- als auch strafrechtlich verfolgt werden. Die ZHdK kann eine entsprechende Anzeige machen.</p>

<h3>13. Weitere Bestimmungen</h3>
<p>Als anwendbares Recht gilt Schweizer Recht, insbesondere die Bestimmungen des allgemeinen Vertragsrechts und der immaterialgüterrechtlichen Sondergesetze.</p>

<h3>14. Inkrafttreten</h3>
<p>Diese Nutzungsbedingungen wurden von der Hochschulleitung am 29.9.2010 beschlossen und treten per sofort in Kraft.</p>
<p>Zürcher Hochschule der Künste</p>
<p>Im Namen der Hochschulleitung</p>
<p>Der Rektor</p>
<p>[1] Vgl. URG, DesG, MSchG, PatG, vgl. die Aufzählung in Art.5<br />
[2] Insbesondere § 16 und 22 FaHG<br />
[3] vgl. http://creativecommons.org<br /></p>', '2010-11-23 14:24:44');


--
-- Data for Name: userpermissions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO userpermissions VALUES (1, 5, 2, false, true, false, false);
INSERT INTO userpermissions VALUES (2, 4, 3, false, true, false, false);
INSERT INTO userpermissions VALUES (3, 16, 4, false, true, true, false);
INSERT INTO userpermissions VALUES (4, 10, 2, true, true, true, true);
INSERT INTO userpermissions VALUES (5, 18, 2, true, true, true, true);
INSERT INTO userpermissions VALUES (6, 19, 2, true, true, true, true);
INSERT INTO userpermissions VALUES (7, 20, 2, true, true, true, true);
INSERT INTO userpermissions VALUES (12, 105, 6, true, true, true, true);
INSERT INTO userpermissions VALUES (13, 106, 6, true, true, true, true);
INSERT INTO userpermissions VALUES (14, 107, 1, true, true, true, true);
INSERT INTO userpermissions VALUES (15, 107, 6, false, true, true, true);
INSERT INTO userpermissions VALUES (17, 108, 3, true, true, true, true);
INSERT INTO userpermissions VALUES (16, 108, 2, true, true, true, true);
INSERT INTO userpermissions VALUES (19, 113, 2, true, true, true, true);
INSERT INTO userpermissions VALUES (20, 114, 1, true, true, true, true);
INSERT INTO userpermissions VALUES (21, 115, 1, true, true, true, true);
INSERT INTO userpermissions VALUES (22, 94, 7, true, true, true, true);
INSERT INTO userpermissions VALUES (23, 94, 1, false, true, true, false);
INSERT INTO userpermissions VALUES (26, 114, 2, false, false, false, false);
INSERT INTO userpermissions VALUES (24, 114, 3, true, true, false, false);
INSERT INTO userpermissions VALUES (27, 115, 2, false, false, false, false);
INSERT INTO userpermissions VALUES (25, 115, 3, true, true, false, false);
INSERT INTO userpermissions VALUES (28, 95, 2, false, false, false, false);
INSERT INTO userpermissions VALUES (29, 95, 3, true, true, false, false);
INSERT INTO userpermissions VALUES (30, 95, 1, true, true, true, true);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO users VALUES (5, 5, NULL, 'antone@braunlangosh.net', 'beat', NULL, '2012-04-20 12:04:23', '2012-04-20 12:04:23', '2013-05-14 12:59:06.0959', '$2a$10$GFmqvMeGVozUhSuH6.HQcuyLBIdFjPDskgzssSkpBrKmezkCtkMta');
INSERT INTO users VALUES (6, 6, NULL, 'ahmed@vandervort.biz', 'liselotte', NULL, '2012-04-20 12:04:23', '2012-04-20 12:04:23', '2013-05-14 12:59:06.509585', '$2a$10$mwMZS0CYRvxeNIg.QZxdyOAxGAxR3i8q3W049XIx15/fYuPOCEetu');
INSERT INTO users VALUES (7, 10, NULL, 'karen@knacknuss.de', 'karen', '', '2012-10-16 13:27:59.25743', '2012-10-16 13:26:54.353205', '2013-05-14 12:59:06.923128', '$2a$10$EqUoM3Y.HsTX5kr38DAlZ.Ijf/vljYEKByAchAjJx4q5MunvFnniK');
INSERT INTO users VALUES (3, 3, NULL, 'una.quigley@kuphal.org', 'petra', NULL, '2013-07-02 13:00:31.69309', '2012-04-20 12:04:17', '2013-07-02 13:00:31.697383', '$2a$10$Cg5a1R66KiQuF2nqQHlG7uLdUxTAcMEJxQDHs9DH.qYOtEKG6iqrm');
INSERT INTO users VALUES (4, 4, NULL, 'devan@wisozk.net', 'norbert', NULL, '2012-04-20 12:04:20', '2012-04-20 12:04:20', '2013-07-08 12:50:29.096663', '$2a$10$XqxmL1wJRYTiHqacntKnsOCdUo9dhAzTdXObPCc5T3wYb3yf4VOPm');
INSERT INTO users VALUES (2, 2, NULL, 'imelda@carroll.info', 'normin', NULL, '2013-07-15 08:40:11.695244', '2012-04-20 12:04:17', '2013-07-15 08:40:11.704249', '$2a$10$eAV/9IRfLhxW7Le2Qh3Ey.Xs6w8Uf0qxuLkAaAZqLhwx.H2njIr8m');
INSERT INTO users VALUES (1, 1, NULL, 'frederick.dickinson@wehnerjewe.org', 'adam', NULL, '2013-07-15 08:41:58.415075', '2012-04-20 12:04:17', '2013-07-15 08:41:58.420543', '$2a$10$txH8LElk.qGG657Mtmhp1eOujLIUUqaHf5bpUzBi9emPWzVYiUXdy');


--
-- Data for Name: visualizations; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: zencoder_jobs; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO zencoder_jobs VALUES ('d034fa89-4615-410a-a12a-160daaf2ca98', 109, NULL, NULL, 'failed', '/home/rails/madek-personas/releases/20130306082832/app/models/zencoder_job.rb:75:in `send_request_to_zencoder''
/home/rails/madek-personas/releases/20130306082832/app/models/zencoder_job.rb:55:in `submit''
/home/rails/madek-personas/releases/20130306082832/app/controllers/import_controller.rb:112:in `block in complete''
/home/rails/madek-personas/releases/20130306082832/app/controllers/import_controller.rb:112:in `each''
/home/rails/madek-personas/releases/20130306082832/app/controllers/import_controller.rb:112:in `complete''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_controller/metal/implicit_render.rb:4:in `send_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/abstract_controller/base.rb:167:in `process_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_controller/metal/rendering.rb:10:in `process_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/abstract_controller/callbacks.rb:18:in `block in process_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/callbacks.rb:447:in `_run__2583865982912500672__process_action__1334313377754706577__callbacks''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/callbacks.rb:405:in `__run_callback''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/callbacks.rb:385:in `_run_process_action_callbacks''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/callbacks.rb:81:in `run_callbacks''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/abstract_controller/callbacks.rb:17:in `process_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_controller/metal/rescue.rb:29:in `process_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_controller/metal/instrumentation.rb:30:in `block in process_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/notifications.rb:123:in `block in instrument''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/notifications/instrumenter.rb:20:in `instrument''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/notifications.rb:123:in `instrument''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_controller/metal/instrumentation.rb:29:in `process_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_controller/metal/params_wrapper.rb:207:in `process_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activerecord-3.2.12/lib/active_record/railties/controller_runtime.rb:18:in `process_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/newrelic_rpm-3.5.7.59/lib/new_relic/agent/instrumentation/rails3/action_controller.rb:34:in `block in process_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/newrelic_rpm-3.5.7.59/lib/new_relic/agent/instrumentation/controller_instrumentation.rb:268:in `block in perform_action_with_newrelic_trace''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/newrelic_rpm-3.5.7.59/lib/new_relic/agent/method_tracer.rb:240:in `trace_execution_scoped''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/newrelic_rpm-3.5.7.59/lib/new_relic/agent/instrumentation/controller_instrumentation.rb:263:in `perform_action_with_newrelic_trace''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/newrelic_rpm-3.5.7.59/lib/new_relic/agent/instrumentation/rails3/action_controller.rb:33:in `process_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/abstract_controller/base.rb:121:in `process''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/abstract_controller/rendering.rb:45:in `process''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_controller/metal.rb:203:in `dispatch''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_controller/metal/rack_delegation.rb:14:in `dispatch''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_controller/metal.rb:246:in `block in action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/routing/route_set.rb:73:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/routing/route_set.rb:73:in `dispatch''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/routing/route_set.rb:36:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/journey-1.0.4/lib/journey/router.rb:68:in `block in call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/journey-1.0.4/lib/journey/router.rb:56:in `each''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/journey-1.0.4/lib/journey/router.rb:56:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/routing/route_set.rb:601:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/newrelic_rpm-3.5.7.59/lib/new_relic/rack/error_collector.rb:8:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/newrelic_rpm-3.5.7.59/lib/new_relic/rack/agent_hooks.rb:14:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/newrelic_rpm-3.5.7.59/lib/new_relic/rack/browser_monitoring.rb:12:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/sass-3.2.5/lib/sass/plugin/rack.rb:54:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-1.4.5/lib/rack/content_length.rb:14:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/warden-1.2.1/lib/warden/manager.rb:35:in `block in call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/warden-1.2.1/lib/warden/manager.rb:34:in `catch''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/warden-1.2.1/lib/warden/manager.rb:34:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/middleware/best_standards_support.rb:17:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-1.4.5/lib/rack/etag.rb:23:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-1.4.5/lib/rack/conditionalget.rb:35:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/middleware/head.rb:14:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/middleware/params_parser.rb:21:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/middleware/flash.rb:242:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-1.4.5/lib/rack/session/abstract/id.rb:210:in `context''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-1.4.5/lib/rack/session/abstract/id.rb:205:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/middleware/cookies.rb:341:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activerecord-3.2.12/lib/active_record/query_cache.rb:64:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activerecord-3.2.12/lib/active_record/connection_adapters/abstract/connection_pool.rb:479:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/middleware/callbacks.rb:28:in `block in call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/callbacks.rb:405:in `_run__3597103754883676298__call__172157096318743174__callbacks''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/callbacks.rb:405:in `__run_callback''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/callbacks.rb:385:in `_run_call_callbacks''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/callbacks.rb:81:in `run_callbacks''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/middleware/callbacks.rb:27:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-1.4.5/lib/rack/sendfile.rb:102:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/middleware/remote_ip.rb:31:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/middleware/debug_exceptions.rb:16:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/middleware/show_exceptions.rb:56:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/railties-3.2.12/lib/rails/rack/logger.rb:32:in `call_app''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/railties-3.2.12/lib/rails/rack/logger.rb:16:in `block in call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/tagged_logging.rb:22:in `tagged''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/railties-3.2.12/lib/rails/rack/logger.rb:16:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/middleware/request_id.rb:22:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-1.4.5/lib/rack/methodoverride.rb:21:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-1.4.5/lib/rack/runtime.rb:17:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/cache/strategy/local_cache.rb:72:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-1.4.5/lib/rack/lock.rb:15:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-cache-1.2/lib/rack/cache/context.rb:136:in `forward''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-cache-1.2/lib/rack/cache/context.rb:143:in `pass''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-cache-1.2/lib/rack/cache/context.rb:155:in `invalidate''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-cache-1.2/lib/rack/cache/context.rb:71:in `call!''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-cache-1.2/lib/rack/cache/context.rb:51:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/railties-3.2.12/lib/rails/engine.rb:479:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/railties-3.2.12/lib/rails/application.rb:223:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/railties-3.2.12/lib/rails/railtie/configurable.rb:30:in `method_missing''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/rack/request_handler.rb:96:in `process_request''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/abstract_request_handler.rb:516:in `accept_and_process_next_request''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/abstract_request_handler.rb:274:in `main_loop''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/rack/application_spawner.rb:206:in `start_request_handler''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/rack/application_spawner.rb:171:in `block in handle_spawn_application''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/utils.rb:470:in `safe_fork''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/rack/application_spawner.rb:166:in `handle_spawn_application''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/abstract_server.rb:357:in `server_main_loop''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/abstract_server.rb:206:in `start_synchronously''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/abstract_server.rb:180:in `start''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/rack/application_spawner.rb:129:in `start''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/spawn_manager.rb:253:in `block (2 levels) in spawn_rack_application''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/abstract_server_collection.rb:132:in `lookup_or_add''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/spawn_manager.rb:246:in `block in spawn_rack_application''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/abstract_server_collection.rb:82:in `block in synchronize''
<internal:prelude>:10:in `synchronize''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/abstract_server_collection.rb:79:in `synchronize''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/spawn_manager.rb:244:in `spawn_rack_application''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/spawn_manager.rb:137:in `spawn_application''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/spawn_manager.rb:275:in `handle_spawn_application''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/abstract_server.rb:357:in `server_main_loop''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/abstract_server.rb:206:in `start_synchronously''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/helper-scripts/passenger-spawn-server:99:in `<main>''', '{}', '{"input":"http://test:MAdeK@test.madek.zhdk.ch/media_files/109?access_hash=44d30f33-70a4-4aa1-adea-5af1f62910d8","test":true,"notifications":["http://zencoderfetcher/zencoder_jobs/d034fa89-4615-410a-a12a-160daaf2ca98/notification"],"outputs":[{"label":"webm","base_url":null,"quality":4,"speed":2,"width":620,"format":"webm","filename":"d034fa89-4615-410a-a12a-160daaf2ca98.webm","thumbnails":{"interval":60,"width":620,"base_url":null,"prefix":"d034fa89-4615-410a-a12a-160daaf2ca98","format":"jpg"}},{"label":"apple","base_url":null,"quality":4,"speed":2,"width":620,"format":"mp4","filename":"d034fa89-4615-410a-a12a-160daaf2ca98.mp4","video_codec":"h264"}]}', '{}', '2013-03-07 08:43:41.041252', '2013-03-07 08:43:41.108397');
INSERT INTO zencoder_jobs VALUES ('3e30d387-9dd3-4ecf-b152-f98760049112', 110, NULL, NULL, 'failed', '/home/rails/madek-personas/releases/20130306082832/app/models/zencoder_job.rb:75:in `send_request_to_zencoder''
/home/rails/madek-personas/releases/20130306082832/app/models/zencoder_job.rb:55:in `submit''
/home/rails/madek-personas/releases/20130306082832/app/controllers/import_controller.rb:112:in `block in complete''
/home/rails/madek-personas/releases/20130306082832/app/controllers/import_controller.rb:112:in `each''
/home/rails/madek-personas/releases/20130306082832/app/controllers/import_controller.rb:112:in `complete''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_controller/metal/implicit_render.rb:4:in `send_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/abstract_controller/base.rb:167:in `process_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_controller/metal/rendering.rb:10:in `process_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/abstract_controller/callbacks.rb:18:in `block in process_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/callbacks.rb:447:in `_run__2583865982912500672__process_action__1334313377754706577__callbacks''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/callbacks.rb:405:in `__run_callback''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/callbacks.rb:385:in `_run_process_action_callbacks''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/callbacks.rb:81:in `run_callbacks''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/abstract_controller/callbacks.rb:17:in `process_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_controller/metal/rescue.rb:29:in `process_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_controller/metal/instrumentation.rb:30:in `block in process_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/notifications.rb:123:in `block in instrument''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/notifications/instrumenter.rb:20:in `instrument''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/notifications.rb:123:in `instrument''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_controller/metal/instrumentation.rb:29:in `process_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_controller/metal/params_wrapper.rb:207:in `process_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activerecord-3.2.12/lib/active_record/railties/controller_runtime.rb:18:in `process_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/newrelic_rpm-3.5.7.59/lib/new_relic/agent/instrumentation/rails3/action_controller.rb:34:in `block in process_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/newrelic_rpm-3.5.7.59/lib/new_relic/agent/instrumentation/controller_instrumentation.rb:268:in `block in perform_action_with_newrelic_trace''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/newrelic_rpm-3.5.7.59/lib/new_relic/agent/method_tracer.rb:240:in `trace_execution_scoped''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/newrelic_rpm-3.5.7.59/lib/new_relic/agent/instrumentation/controller_instrumentation.rb:263:in `perform_action_with_newrelic_trace''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/newrelic_rpm-3.5.7.59/lib/new_relic/agent/instrumentation/rails3/action_controller.rb:33:in `process_action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/abstract_controller/base.rb:121:in `process''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/abstract_controller/rendering.rb:45:in `process''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_controller/metal.rb:203:in `dispatch''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_controller/metal/rack_delegation.rb:14:in `dispatch''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_controller/metal.rb:246:in `block in action''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/routing/route_set.rb:73:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/routing/route_set.rb:73:in `dispatch''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/routing/route_set.rb:36:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/journey-1.0.4/lib/journey/router.rb:68:in `block in call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/journey-1.0.4/lib/journey/router.rb:56:in `each''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/journey-1.0.4/lib/journey/router.rb:56:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/routing/route_set.rb:601:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/newrelic_rpm-3.5.7.59/lib/new_relic/rack/error_collector.rb:8:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/newrelic_rpm-3.5.7.59/lib/new_relic/rack/agent_hooks.rb:14:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/newrelic_rpm-3.5.7.59/lib/new_relic/rack/browser_monitoring.rb:12:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/sass-3.2.5/lib/sass/plugin/rack.rb:54:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-1.4.5/lib/rack/content_length.rb:14:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/warden-1.2.1/lib/warden/manager.rb:35:in `block in call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/warden-1.2.1/lib/warden/manager.rb:34:in `catch''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/warden-1.2.1/lib/warden/manager.rb:34:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/middleware/best_standards_support.rb:17:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-1.4.5/lib/rack/etag.rb:23:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-1.4.5/lib/rack/conditionalget.rb:35:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/middleware/head.rb:14:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/middleware/params_parser.rb:21:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/middleware/flash.rb:242:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-1.4.5/lib/rack/session/abstract/id.rb:210:in `context''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-1.4.5/lib/rack/session/abstract/id.rb:205:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/middleware/cookies.rb:341:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activerecord-3.2.12/lib/active_record/query_cache.rb:64:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activerecord-3.2.12/lib/active_record/connection_adapters/abstract/connection_pool.rb:479:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/middleware/callbacks.rb:28:in `block in call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/callbacks.rb:405:in `_run__3597103754883676298__call__172157096318743174__callbacks''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/callbacks.rb:405:in `__run_callback''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/callbacks.rb:385:in `_run_call_callbacks''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/callbacks.rb:81:in `run_callbacks''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/middleware/callbacks.rb:27:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-1.4.5/lib/rack/sendfile.rb:102:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/middleware/remote_ip.rb:31:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/middleware/debug_exceptions.rb:16:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/middleware/show_exceptions.rb:56:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/railties-3.2.12/lib/rails/rack/logger.rb:32:in `call_app''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/railties-3.2.12/lib/rails/rack/logger.rb:16:in `block in call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/tagged_logging.rb:22:in `tagged''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/railties-3.2.12/lib/rails/rack/logger.rb:16:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/actionpack-3.2.12/lib/action_dispatch/middleware/request_id.rb:22:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-1.4.5/lib/rack/methodoverride.rb:21:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-1.4.5/lib/rack/runtime.rb:17:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/activesupport-3.2.12/lib/active_support/cache/strategy/local_cache.rb:72:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-1.4.5/lib/rack/lock.rb:15:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-cache-1.2/lib/rack/cache/context.rb:136:in `forward''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-cache-1.2/lib/rack/cache/context.rb:143:in `pass''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-cache-1.2/lib/rack/cache/context.rb:155:in `invalidate''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-cache-1.2/lib/rack/cache/context.rb:71:in `call!''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/rack-cache-1.2/lib/rack/cache/context.rb:51:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/railties-3.2.12/lib/rails/engine.rb:479:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/railties-3.2.12/lib/rails/application.rb:223:in `call''
/home/rails/madek-personas/shared/bundle/ruby/1.9.1/gems/railties-3.2.12/lib/rails/railtie/configurable.rb:30:in `method_missing''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/rack/request_handler.rb:96:in `process_request''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/abstract_request_handler.rb:516:in `accept_and_process_next_request''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/abstract_request_handler.rb:274:in `main_loop''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/rack/application_spawner.rb:206:in `start_request_handler''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/rack/application_spawner.rb:171:in `block in handle_spawn_application''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/utils.rb:470:in `safe_fork''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/rack/application_spawner.rb:166:in `handle_spawn_application''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/abstract_server.rb:357:in `server_main_loop''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/abstract_server.rb:206:in `start_synchronously''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/abstract_server.rb:180:in `start''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/rack/application_spawner.rb:129:in `start''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/spawn_manager.rb:253:in `block (2 levels) in spawn_rack_application''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/abstract_server_collection.rb:132:in `lookup_or_add''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/spawn_manager.rb:246:in `block in spawn_rack_application''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/abstract_server_collection.rb:82:in `block in synchronize''
<internal:prelude>:10:in `synchronize''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/abstract_server_collection.rb:79:in `synchronize''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/spawn_manager.rb:244:in `spawn_rack_application''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/spawn_manager.rb:137:in `spawn_application''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/spawn_manager.rb:275:in `handle_spawn_application''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/abstract_server.rb:357:in `server_main_loop''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/lib/phusion_passenger/abstract_server.rb:206:in `start_synchronously''
/usr/local/rvm/gems/ruby-1.9.3-p327/gems/passenger-3.0.19/helper-scripts/passenger-spawn-server:99:in `<main>''', '{}', '{"input":"http://test:MAdeK@test.madek.zhdk.ch/media_files/110?access_hash=79aea089-81e3-4408-ba0b-42955a6190f9","test":true,"notifications":["http://zencoderfetcher/zencoder_jobs/3e30d387-9dd3-4ecf-b152-f98760049112/notification"],"outputs":[{"label":"Default","base_url":null,"quality":4,"speed":2,"width":620,"audio_codec":"vorbis","skip_video":true,"filename":"3e30d387-9dd3-4ecf-b152-f98760049112.ogg"}]}', '{}', '2013-03-07 08:46:17.970397', '2013-03-07 08:46:17.989621');
INSERT INTO zencoder_jobs VALUES ('ea33ebcd-81d2-4a16-b9c7-dcb9a65f1f03', 112, 46961278, NULL, 'finished', NULL, '{"input":{"total_bitrate_in_kbps":1452,"channels":"2","width":1280,"md5_checksum":null,"video_codec":"h264","file_size_in_bytes":922620,"duration_in_ms":5067,"audio_codec":"aac","state":"finished","format":"mpeg4","audio_sample_rate":44100,"id":46939267,"frame_rate":30.0,"audio_bitrate_in_kbps":50,"video_bitrate_in_kbps":1402,"height":720},"job":{"test":true,"pass_through":null,"updated_at":"2013-05-21T06:55:54Z","submitted_at":"2013-05-21T06:55:11Z","state":"finished","created_at":"2013-05-21T06:55:11Z","id":46961278},"outputs":[{"total_bitrate_in_kbps":933,"channels":"2","width":620,"md5_checksum":null,"video_codec":"h264","file_size_in_bytes":594449,"duration_in_ms":5000,"audio_codec":"aac","state":"finished","format":"mpeg4","audio_sample_rate":44100,"label":"apple","id":97799910,"url":"ftp://zencoder:z00nc4d3r@madek-server.zhdk.ch/encoded/ea33ebcd-81d2-4a16-b9c7-dcb9a65f1f03.mp4","frame_rate":30.0,"audio_bitrate_in_kbps":90,"video_bitrate_in_kbps":843,"height":348},{"total_bitrate_in_kbps":496,"channels":"2","width":620,"md5_checksum":null,"video_codec":"vp8","file_size_in_bytes":333126,"duration_in_ms":5000,"audio_codec":"vorbis","state":"finished","format":"webm","audio_sample_rate":44100,"label":"webm","id":97799909,"url":"ftp://zencoder:z00nc4d3r@madek-server.zhdk.ch/encoded/ea33ebcd-81d2-4a16-b9c7-dcb9a65f1f03.webm","frame_rate":30.0,"audio_bitrate_in_kbps":112,"video_bitrate_in_kbps":384,"thumbnails":[{"images":[{"dimensions":"620x348","file_size_bytes":21353,"format":"JPG","url":"ftp://zencoder:z00nc4d3r@madek-server.zhdk.ch/encoded/ea33ebcd-81d2-4a16-b9c7-dcb9a65f1f03_0000.jpg"}],"label":null}],"height":348}],"controller":"zencoder_jobs","action":"post_notification","id":"ea33ebcd-81d2-4a16-b9c7-dcb9a65f1f03","zencoder_job":{}}', '{"input":"http://s3.amazonaws.com/zencodertesting/test.mov","test":true,"notifications":["http://zencoderfetcher/zencoder_jobs/ea33ebcd-81d2-4a16-b9c7-dcb9a65f1f03/notification"],"outputs":[{"label":"webm","base_url":"ftp://zencoder:z00nc4d3r@madek-server.zhdk.ch/encoded","quality":4,"speed":2,"width":620,"format":"webm","filename":"ea33ebcd-81d2-4a16-b9c7-dcb9a65f1f03.webm","thumbnails":{"interval":60,"width":620,"base_url":"ftp://zencoder:z00nc4d3r@madek-server.zhdk.ch/encoded","prefix":"ea33ebcd-81d2-4a16-b9c7-dcb9a65f1f03","format":"jpg"}},{"label":"apple","base_url":"ftp://zencoder:z00nc4d3r@madek-server.zhdk.ch/encoded","quality":4,"speed":2,"width":620,"format":"mp4","filename":"ea33ebcd-81d2-4a16-b9c7-dcb9a65f1f03.mp4","video_codec":"h264"}]}', '{"test":true,"outputs":[{"label":"webm","url":"ftp://zencoder:z00nc4d3r@madek-server.zhdk.ch/encoded/ea33ebcd-81d2-4a16-b9c7-dcb9a65f1f03.webm","id":97799909},{"label":"apple","url":"ftp://zencoder:z00nc4d3r@madek-server.zhdk.ch/encoded/ea33ebcd-81d2-4a16-b9c7-dcb9a65f1f03.mp4","id":97799910}],"id":46961278}', '2013-05-21 06:55:09.290409', '2013-05-21 07:03:38.88464');


--
-- Name: app_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY app_settings
    ADD CONSTRAINT app_settings_pkey PRIMARY KEY (id);


--
-- Name: copyrights_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY copyrights
    ADD CONSTRAINT copyrights_pkey PRIMARY KEY (id);


--
-- Name: edit_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY edit_sessions
    ADD CONSTRAINT edit_sessions_pkey PRIMARY KEY (id);


--
-- Name: full_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY full_texts
    ADD CONSTRAINT full_texts_pkey PRIMARY KEY (id);


--
-- Name: grouppermissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY grouppermissions
    ADD CONSTRAINT grouppermissions_pkey PRIMARY KEY (id);


--
-- Name: groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: keywords_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY keywords
    ADD CONSTRAINT keywords_pkey PRIMARY KEY (id);


--
-- Name: media_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY media_files
    ADD CONSTRAINT media_files_pkey PRIMARY KEY (id);


--
-- Name: media_resource_arcs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY media_resource_arcs
    ADD CONSTRAINT media_resource_arcs_pkey PRIMARY KEY (id);


--
-- Name: media_resources_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY media_resources
    ADD CONSTRAINT media_resources_pkey PRIMARY KEY (id);


--
-- Name: meta_context_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY meta_context_groups
    ADD CONSTRAINT meta_context_groups_pkey PRIMARY KEY (id);


--
-- Name: meta_contexts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY meta_contexts
    ADD CONSTRAINT meta_contexts_pkey PRIMARY KEY (name);


--
-- Name: meta_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY meta_data
    ADD CONSTRAINT meta_data_pkey PRIMARY KEY (id);


--
-- Name: meta_key_definitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY meta_key_definitions
    ADD CONSTRAINT meta_key_definitions_pkey PRIMARY KEY (id);


--
-- Name: meta_keys_meta_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY meta_keys_meta_terms
    ADD CONSTRAINT meta_keys_meta_terms_pkey PRIMARY KEY (id);


--
-- Name: meta_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY meta_keys
    ADD CONSTRAINT meta_keys_pkey PRIMARY KEY (id);


--
-- Name: meta_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY meta_terms
    ADD CONSTRAINT meta_terms_pkey PRIMARY KEY (id);


--
-- Name: people_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: permission_presets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY permission_presets
    ADD CONSTRAINT permission_presets_pkey PRIMARY KEY (id);


--
-- Name: previews_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY previews
    ADD CONSTRAINT previews_pkey PRIMARY KEY (id);


--
-- Name: usage_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY usage_terms
    ADD CONSTRAINT usage_terms_pkey PRIMARY KEY (id);


--
-- Name: userpermissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY userpermissions
    ADD CONSTRAINT userpermissions_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: visualizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY visualizations
    ADD CONSTRAINT visualizations_pkey PRIMARY KEY (user_id, resource_identifier);


--
-- Name: zencoder_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY zencoder_jobs
    ADD CONSTRAINT zencoder_jobs_pkey PRIMARY KEY (id);


--
-- Name: idx_bools_unique; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_bools_unique ON permission_presets USING btree (view, edit, download, manage);


--
-- Name: idx_name_unique; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_name_unique ON permission_presets USING btree (name);


--
-- Name: index_copyrights_on_is_custom; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_copyrights_on_is_custom ON copyrights USING btree (is_custom);


--
-- Name: index_copyrights_on_is_default; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_copyrights_on_is_default ON copyrights USING btree (is_default);


--
-- Name: index_copyrights_on_label; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_copyrights_on_label ON copyrights USING btree (label);


--
-- Name: index_copyrights_on_lft_and_rgt; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_copyrights_on_lft_and_rgt ON copyrights USING btree (lft, rgt);


--
-- Name: index_copyrights_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_copyrights_on_parent_id ON copyrights USING btree (parent_id);


--
-- Name: index_edit_sessions_on_media_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_edit_sessions_on_media_resource_id ON edit_sessions USING btree (media_resource_id);


--
-- Name: index_edit_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_edit_sessions_on_user_id ON edit_sessions USING btree (user_id);


--
-- Name: index_favorites_on_user_id_and_media_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_favorites_on_user_id_and_media_resource_id ON favorites USING btree (user_id, media_resource_id);


--
-- Name: index_full_texts_on_media_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_full_texts_on_media_resource_id ON full_texts USING btree (media_resource_id);


--
-- Name: index_grouppermissions_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_grouppermissions_on_group_id ON grouppermissions USING btree (group_id);


--
-- Name: index_grouppermissions_on_group_id_and_media_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_grouppermissions_on_group_id_and_media_resource_id ON grouppermissions USING btree (group_id, media_resource_id);


--
-- Name: index_grouppermissions_on_media_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_grouppermissions_on_media_resource_id ON grouppermissions USING btree (media_resource_id);


--
-- Name: index_groups_on_ldap_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_on_ldap_id ON groups USING btree (ldap_id);


--
-- Name: index_groups_on_ldap_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_on_ldap_name ON groups USING btree (ldap_name);


--
-- Name: index_groups_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_on_type ON groups USING btree (type);


--
-- Name: index_groups_users_on_group_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_users_on_group_id_and_user_id ON groups_users USING btree (group_id, user_id);


--
-- Name: index_groups_users_on_user_id_and_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_groups_users_on_user_id_and_group_id ON groups_users USING btree (user_id, group_id);


--
-- Name: index_keywords_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_keywords_on_created_at ON keywords USING btree (created_at);


--
-- Name: index_keywords_on_meta_datum_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_keywords_on_meta_datum_id ON keywords USING btree (meta_datum_id);


--
-- Name: index_keywords_on_meta_term_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_keywords_on_meta_term_id_and_user_id ON keywords USING btree (meta_term_id, user_id);


--
-- Name: index_keywords_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_keywords_on_user_id ON keywords USING btree (user_id);


--
-- Name: index_media_files_on_extension; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_files_on_extension ON media_files USING btree (extension);


--
-- Name: index_media_files_on_media_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_files_on_media_type ON media_files USING btree (media_type);


--
-- Name: index_media_resource_arcs_on_child_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_resource_arcs_on_child_id ON media_resource_arcs USING btree (child_id);


--
-- Name: index_media_resource_arcs_on_cover; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_resource_arcs_on_cover ON media_resource_arcs USING btree (cover);


--
-- Name: index_media_resource_arcs_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_resource_arcs_on_parent_id ON media_resource_arcs USING btree (parent_id);


--
-- Name: index_media_resource_arcs_on_parent_id_and_child_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_media_resource_arcs_on_parent_id_and_child_id ON media_resource_arcs USING btree (parent_id, child_id);


--
-- Name: index_media_resources_on_media_entry_id_and_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_resources_on_media_entry_id_and_created_at ON media_resources USING btree (media_entry_id, created_at);


--
-- Name: index_media_resources_on_media_file_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_resources_on_media_file_id ON media_resources USING btree (media_file_id);


--
-- Name: index_media_resources_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_resources_on_type ON media_resources USING btree (type);


--
-- Name: index_media_resources_on_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_resources_on_updated_at ON media_resources USING btree (updated_at);


--
-- Name: index_media_resources_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_resources_on_user_id ON media_resources USING btree (user_id);


--
-- Name: index_media_sets_meta_contexts_on_meta_context_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_sets_meta_contexts_on_meta_context_name ON media_sets_meta_contexts USING btree (meta_context_name);


--
-- Name: index_meta_context_groups_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_context_groups_on_name ON meta_context_groups USING btree (name);


--
-- Name: index_meta_context_groups_on_position; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_context_groups_on_position ON meta_context_groups USING btree ("position");


--
-- Name: index_meta_contexts_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_contexts_on_name ON meta_contexts USING btree (name);


--
-- Name: index_meta_contexts_on_position; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_contexts_on_position ON meta_contexts USING btree ("position");


--
-- Name: index_meta_data_meta_departments; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_data_meta_departments ON meta_data_meta_departments USING btree (meta_datum_id, meta_department_id);


--
-- Name: index_meta_data_meta_terms_on_meta_datum_id_and_meta_term_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_data_meta_terms_on_meta_datum_id_and_meta_term_id ON meta_data_meta_terms USING btree (meta_datum_id, meta_term_id);


--
-- Name: index_meta_data_on_copyright_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_data_on_copyright_id ON meta_data USING btree (copyright_id);


--
-- Name: index_meta_data_on_meta_key_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_data_on_meta_key_id ON meta_data USING btree (meta_key_id);


--
-- Name: index_meta_data_people_on_meta_datum_id_and_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_data_people_on_meta_datum_id_and_person_id ON meta_data_people USING btree (meta_datum_id, person_id);


--
-- Name: index_meta_data_users_on_meta_datum_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_data_users_on_meta_datum_id_and_user_id ON meta_data_users USING btree (meta_datum_id, user_id);


--
-- Name: index_meta_key_definitions_on_meta_context_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_key_definitions_on_meta_context_name ON meta_key_definitions USING btree (meta_context_name);


--
-- Name: index_meta_key_definitions_on_meta_key_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_key_definitions_on_meta_key_id ON meta_key_definitions USING btree (meta_key_id);


--
-- Name: index_meta_keys_meta_terms_on_meta_key_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_keys_meta_terms_on_meta_key_id ON meta_keys_meta_terms USING btree (meta_key_id);


--
-- Name: index_meta_keys_meta_terms_on_position; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_keys_meta_terms_on_position ON meta_keys_meta_terms USING btree ("position");


--
-- Name: index_meta_keys_on_label; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_keys_on_label ON meta_keys USING btree (id);


--
-- Name: index_meta_terms_on_de_ch; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_terms_on_de_ch ON meta_terms USING btree (de_ch);


--
-- Name: index_meta_terms_on_en_gb; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_terms_on_en_gb ON meta_terms USING btree (en_gb);


--
-- Name: index_people_on_firstname; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_firstname ON people USING btree (first_name);


--
-- Name: index_people_on_is_group; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_is_group ON people USING btree (is_group);


--
-- Name: index_people_on_lastname; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_lastname ON people USING btree (last_name);


--
-- Name: index_previews_on_media_file_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_previews_on_media_file_id ON previews USING btree (media_file_id);


--
-- Name: index_userpermissions_on_media_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_userpermissions_on_media_resource_id ON userpermissions USING btree (media_resource_id);


--
-- Name: index_userpermissions_on_media_resource_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_userpermissions_on_media_resource_id_and_user_id ON userpermissions USING btree (media_resource_id, user_id);


--
-- Name: index_userpermissions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_userpermissions_on_user_id ON userpermissions USING btree (user_id);


--
-- Name: index_users_on_login; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_login ON users USING btree (login);


--
-- Name: index_users_on_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_person_id ON users USING btree (person_id);


--
-- Name: index_users_on_zhdkid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_zhdkid ON users USING btree (zhdkid);


--
-- Name: index_zencoder_jobs_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_zencoder_jobs_on_created_at ON zencoder_jobs USING btree (created_at);


--
-- Name: index_zencoder_jobs_on_media_file_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_zencoder_jobs_on_media_file_id ON zencoder_jobs USING btree (media_file_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: app_settings_catalog_set_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_settings
    ADD CONSTRAINT app_settings_catalog_set_id_fk FOREIGN KEY (catalog_set_id) REFERENCES media_resources(id);


--
-- Name: app_settings_featured_set_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_settings
    ADD CONSTRAINT app_settings_featured_set_id_fk FOREIGN KEY (featured_set_id) REFERENCES media_resources(id);


--
-- Name: app_settings_second_displayed_meta_context_name_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_settings
    ADD CONSTRAINT app_settings_second_displayed_meta_context_name_fk FOREIGN KEY (second_displayed_meta_context_name) REFERENCES meta_contexts(name);


--
-- Name: app_settings_splashscreen_slideshow_set_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_settings
    ADD CONSTRAINT app_settings_splashscreen_slideshow_set_id_fk FOREIGN KEY (splashscreen_slideshow_set_id) REFERENCES media_resources(id);


--
-- Name: app_settings_third_displayed_meta_context_name_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_settings
    ADD CONSTRAINT app_settings_third_displayed_meta_context_name_fk FOREIGN KEY (third_displayed_meta_context_name) REFERENCES meta_contexts(name);


--
-- Name: edit_sessions_media_resource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY edit_sessions
    ADD CONSTRAINT edit_sessions_media_resource_id_fk FOREIGN KEY (media_resource_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: edit_sessions_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY edit_sessions
    ADD CONSTRAINT edit_sessions_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: favorites_media_resource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites
    ADD CONSTRAINT favorites_media_resource_id_fk FOREIGN KEY (media_resource_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: favorites_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites
    ADD CONSTRAINT favorites_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: full_texts_media_resource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY full_texts
    ADD CONSTRAINT full_texts_media_resource_id_fk FOREIGN KEY (media_resource_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: grouppermissions_group_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY grouppermissions
    ADD CONSTRAINT grouppermissions_group_id_fk FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE;


--
-- Name: grouppermissions_media_resource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY grouppermissions
    ADD CONSTRAINT grouppermissions_media_resource_id_fk FOREIGN KEY (media_resource_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: groups_users_group_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups_users
    ADD CONSTRAINT groups_users_group_id_fk FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE;


--
-- Name: groups_users_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups_users
    ADD CONSTRAINT groups_users_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: keywords_meta_datum_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY keywords
    ADD CONSTRAINT keywords_meta_datum_id_fk FOREIGN KEY (meta_datum_id) REFERENCES meta_data(id) ON DELETE CASCADE;


--
-- Name: keywords_meta_term_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY keywords
    ADD CONSTRAINT keywords_meta_term_id_fk FOREIGN KEY (meta_term_id) REFERENCES meta_terms(id);


--
-- Name: keywords_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY keywords
    ADD CONSTRAINT keywords_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: media_resource_arcs_child_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_resource_arcs
    ADD CONSTRAINT media_resource_arcs_child_id_fk FOREIGN KEY (child_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: media_resource_arcs_parent_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_resource_arcs
    ADD CONSTRAINT media_resource_arcs_parent_id_fk FOREIGN KEY (parent_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: media_resources_media_entry_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_resources
    ADD CONSTRAINT media_resources_media_entry_id_fk FOREIGN KEY (media_entry_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: media_resources_media_file_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_resources
    ADD CONSTRAINT media_resources_media_file_id_fk FOREIGN KEY (media_file_id) REFERENCES media_files(id) ON DELETE CASCADE;


--
-- Name: media_resources_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_resources
    ADD CONSTRAINT media_resources_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: media_sets_meta_contexts_media_set_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_sets_meta_contexts
    ADD CONSTRAINT media_sets_meta_contexts_media_set_id_fk FOREIGN KEY (media_set_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: media_sets_meta_contexts_meta_context_name_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_sets_meta_contexts
    ADD CONSTRAINT media_sets_meta_contexts_meta_context_name_fk FOREIGN KEY (meta_context_name) REFERENCES meta_contexts(name);


--
-- Name: meta_contexts_description_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_contexts
    ADD CONSTRAINT meta_contexts_description_id_fk FOREIGN KEY (description_id) REFERENCES meta_terms(id);


--
-- Name: meta_contexts_label_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_contexts
    ADD CONSTRAINT meta_contexts_label_id_fk FOREIGN KEY (label_id) REFERENCES meta_terms(id);


--
-- Name: meta_contexts_meta_context_group_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_contexts
    ADD CONSTRAINT meta_contexts_meta_context_group_id_fk FOREIGN KEY (meta_context_group_id) REFERENCES meta_context_groups(id);


--
-- Name: meta_data_media_resource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data
    ADD CONSTRAINT meta_data_media_resource_id_fk FOREIGN KEY (media_resource_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: meta_data_meta_departments_meta_datum_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data_meta_departments
    ADD CONSTRAINT meta_data_meta_departments_meta_datum_id_fk FOREIGN KEY (meta_datum_id) REFERENCES meta_data(id) ON DELETE CASCADE;


--
-- Name: meta_data_meta_departments_meta_department_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data_meta_departments
    ADD CONSTRAINT meta_data_meta_departments_meta_department_id_fk FOREIGN KEY (meta_department_id) REFERENCES groups(id) ON DELETE CASCADE;


--
-- Name: meta_data_meta_key_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data
    ADD CONSTRAINT meta_data_meta_key_id_fk FOREIGN KEY (meta_key_id) REFERENCES meta_keys(id);


--
-- Name: meta_data_meta_terms_meta_datum_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data_meta_terms
    ADD CONSTRAINT meta_data_meta_terms_meta_datum_id_fk FOREIGN KEY (meta_datum_id) REFERENCES meta_data(id) ON DELETE CASCADE;


--
-- Name: meta_data_meta_terms_meta_term_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data_meta_terms
    ADD CONSTRAINT meta_data_meta_terms_meta_term_id_fk FOREIGN KEY (meta_term_id) REFERENCES meta_terms(id) ON DELETE CASCADE;


--
-- Name: meta_data_people_meta_datum_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data_people
    ADD CONSTRAINT meta_data_people_meta_datum_id_fk FOREIGN KEY (meta_datum_id) REFERENCES meta_data(id) ON DELETE CASCADE;


--
-- Name: meta_data_people_person_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data_people
    ADD CONSTRAINT meta_data_people_person_id_fk FOREIGN KEY (person_id) REFERENCES people(id);


--
-- Name: meta_data_users_meta_datum_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data_users
    ADD CONSTRAINT meta_data_users_meta_datum_id_fk FOREIGN KEY (meta_datum_id) REFERENCES meta_data(id) ON DELETE CASCADE;


--
-- Name: meta_data_users_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data_users
    ADD CONSTRAINT meta_data_users_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: meta_key_definitions_description_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_key_definitions
    ADD CONSTRAINT meta_key_definitions_description_id_fk FOREIGN KEY (description_id) REFERENCES meta_terms(id);


--
-- Name: meta_key_definitions_hint_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_key_definitions
    ADD CONSTRAINT meta_key_definitions_hint_id_fk FOREIGN KEY (hint_id) REFERENCES meta_terms(id);


--
-- Name: meta_key_definitions_label_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_key_definitions
    ADD CONSTRAINT meta_key_definitions_label_id_fk FOREIGN KEY (label_id) REFERENCES meta_terms(id);


--
-- Name: meta_key_definitions_meta_context_name_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_key_definitions
    ADD CONSTRAINT meta_key_definitions_meta_context_name_fk FOREIGN KEY (meta_context_name) REFERENCES meta_contexts(name);


--
-- Name: meta_key_definitions_meta_key_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_key_definitions
    ADD CONSTRAINT meta_key_definitions_meta_key_id_fk FOREIGN KEY (meta_key_id) REFERENCES meta_keys(id);


--
-- Name: meta_keys_meta_terms_meta_key_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_keys_meta_terms
    ADD CONSTRAINT meta_keys_meta_terms_meta_key_id_fk FOREIGN KEY (meta_key_id) REFERENCES meta_keys(id);


--
-- Name: meta_keys_meta_terms_meta_term_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_keys_meta_terms
    ADD CONSTRAINT meta_keys_meta_terms_meta_term_id_fk FOREIGN KEY (meta_term_id) REFERENCES meta_terms(id) ON DELETE CASCADE;


--
-- Name: previews_media_file_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY previews
    ADD CONSTRAINT previews_media_file_id_fk FOREIGN KEY (media_file_id) REFERENCES media_files(id) ON DELETE CASCADE;


--
-- Name: userpermissions_media_resource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY userpermissions
    ADD CONSTRAINT userpermissions_media_resource_id_fk FOREIGN KEY (media_resource_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: userpermissions_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY userpermissions
    ADD CONSTRAINT userpermissions_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: users_person_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_person_id_fk FOREIGN KEY (person_id) REFERENCES people(id);


--
-- Name: zencoder_jobs_media_file_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY zencoder_jobs
    ADD CONSTRAINT zencoder_jobs_media_file_id_fk FOREIGN KEY (media_file_id) REFERENCES media_files(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

