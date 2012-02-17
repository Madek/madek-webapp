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


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

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
-- Name: edit_sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE edit_sessions (
    id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    media_resource_id integer
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
-- Name: favorites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites (
    user_id integer,
    media_resource_id integer
);


--
-- Name: full_texts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE full_texts (
    id integer NOT NULL,
    text text,
    media_resource_id integer
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
-- Name: groups_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE groups_users (
    group_id integer,
    user_id integer
);


--
-- Name: keywords; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE keywords (
    id integer NOT NULL,
    meta_term_id integer,
    user_id integer,
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
-- Name: media_entries_media_sets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_entries_media_sets (
    media_set_id integer,
    media_entry_id integer
);


--
-- Name: media_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_files (
    id integer NOT NULL,
    guid character varying(255),
    meta_data text,
    content_type character varying(255),
    filename character varying(255),
    size integer,
    height integer,
    width integer,
    job_id character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    access_hash text
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
-- Name: media_resources; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_resources (
    id integer NOT NULL,
    type character varying(255),
    user_id integer,
    media_file_id integer,
    media_entry_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    download boolean DEFAULT false NOT NULL,
    view boolean DEFAULT false NOT NULL,
    edit boolean DEFAULT false NOT NULL,
    manage boolean DEFAULT false NOT NULL
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
-- Name: media_set_arcs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_set_arcs (
    id integer NOT NULL,
    parent_id integer NOT NULL,
    child_id integer NOT NULL,
    CONSTRAINT media_set_arcs_check CHECK ((parent_id <> child_id))
);


--
-- Name: media_set_arcs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE media_set_arcs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: media_set_arcs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE media_set_arcs_id_seq OWNED BY media_set_arcs.id;


--
-- Name: media_sets_meta_contexts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_sets_meta_contexts (
    media_set_id integer,
    meta_context_id integer
);


--
-- Name: meta_contexts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_contexts (
    id integer NOT NULL,
    is_user_interface boolean DEFAULT false,
    name character varying(255),
    label_id integer NOT NULL,
    description_id integer
);


--
-- Name: meta_contexts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE meta_contexts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meta_contexts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE meta_contexts_id_seq OWNED BY meta_contexts.id;


--
-- Name: meta_data; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_data (
    id integer NOT NULL,
    meta_key_id integer,
    value text,
    media_resource_id integer
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
-- Name: meta_key_definitions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_key_definitions (
    id integer NOT NULL,
    meta_context_id integer,
    meta_key_id integer,
    "position" integer NOT NULL,
    key_map character varying(255),
    key_map_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    label_id integer,
    description_id integer,
    hint_id integer,
    settings text
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
-- Name: meta_keys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_keys (
    id integer NOT NULL,
    label character varying(255),
    object_type character varying(255),
    is_dynamic boolean,
    is_extensible_list boolean
);


--
-- Name: meta_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE meta_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: meta_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE meta_keys_id_seq OWNED BY meta_keys.id;


--
-- Name: meta_keys_meta_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_keys_meta_terms (
    meta_key_id integer,
    meta_term_id integer,
    id integer NOT NULL,
    "position" integer DEFAULT 0 NOT NULL
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
-- Name: meta_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_terms (
    id integer NOT NULL,
    "en_GB" character varying(255),
    "de_CH" character varying(255)
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
-- Name: people; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE people (
    id integer NOT NULL,
    firstname character varying(255),
    lastname character varying(255),
    pseudonym character varying(255),
    birthdate date,
    deathdate date,
    nationality character varying(255),
    wiki_links text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    is_group boolean DEFAULT false
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
-- Name: previews; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE previews (
    id integer NOT NULL,
    media_file_id integer,
    filename character varying(255),
    content_type character varying(255),
    height integer,
    width integer,
    thumbnail character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    var character varying(255) NOT NULL,
    value text,
    target_id integer,
    target_type character varying(30),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


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
-- Name: use_terms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE use_terms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: use_terms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE use_terms_id_seq OWNED BY usage_terms.id;


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
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    person_id integer NOT NULL,
    login character varying(40),
    email character varying(100),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    usage_terms_accepted_at timestamp without time zone,
    password character varying(255)
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
-- Name: wiki_page_versions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE wiki_page_versions (
    id integer NOT NULL,
    page_id integer NOT NULL,
    updator_id integer,
    number integer,
    comment character varying(255),
    path character varying(255),
    title character varying(255),
    content text,
    updated_at timestamp without time zone
);


--
-- Name: wiki_page_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE wiki_page_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wiki_page_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE wiki_page_versions_id_seq OWNED BY wiki_page_versions.id;


--
-- Name: wiki_pages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE wiki_pages (
    id integer NOT NULL,
    creator_id integer,
    updator_id integer,
    path character varying(255),
    title character varying(255),
    content text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: wiki_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE wiki_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wiki_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE wiki_pages_id_seq OWNED BY wiki_pages.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE copyrights ALTER COLUMN id SET DEFAULT nextval('copyrights_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE edit_sessions ALTER COLUMN id SET DEFAULT nextval('edit_sessions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE full_texts ALTER COLUMN id SET DEFAULT nextval('full_texts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE grouppermissions ALTER COLUMN id SET DEFAULT nextval('grouppermissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE keywords ALTER COLUMN id SET DEFAULT nextval('keywords_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE media_files ALTER COLUMN id SET DEFAULT nextval('media_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE media_resources ALTER COLUMN id SET DEFAULT nextval('media_resources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE media_set_arcs ALTER COLUMN id SET DEFAULT nextval('media_set_arcs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE meta_contexts ALTER COLUMN id SET DEFAULT nextval('meta_contexts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE meta_data ALTER COLUMN id SET DEFAULT nextval('meta_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE meta_key_definitions ALTER COLUMN id SET DEFAULT nextval('meta_key_definitions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE meta_keys ALTER COLUMN id SET DEFAULT nextval('meta_keys_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE meta_keys_meta_terms ALTER COLUMN id SET DEFAULT nextval('meta_keys_meta_terms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE meta_terms ALTER COLUMN id SET DEFAULT nextval('meta_terms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE people ALTER COLUMN id SET DEFAULT nextval('people_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE previews ALTER COLUMN id SET DEFAULT nextval('previews_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE usage_terms ALTER COLUMN id SET DEFAULT nextval('use_terms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE userpermissions ALTER COLUMN id SET DEFAULT nextval('userpermissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE wiki_page_versions ALTER COLUMN id SET DEFAULT nextval('wiki_page_versions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE wiki_pages ALTER COLUMN id SET DEFAULT nextval('wiki_pages_id_seq'::regclass);


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
-- Name: media_resources_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY media_resources
    ADD CONSTRAINT media_resources_pkey PRIMARY KEY (id);


--
-- Name: media_set_arcs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY media_set_arcs
    ADD CONSTRAINT media_set_arcs_pkey PRIMARY KEY (id);


--
-- Name: meta_contexts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY meta_contexts
    ADD CONSTRAINT meta_contexts_pkey PRIMARY KEY (id);


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
-- Name: people_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: previews_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY previews
    ADD CONSTRAINT previews_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY meta_terms
    ADD CONSTRAINT terms_pkey PRIMARY KEY (id);


--
-- Name: use_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY usage_terms
    ADD CONSTRAINT use_terms_pkey PRIMARY KEY (id);


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
-- Name: wiki_page_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wiki_page_versions
    ADD CONSTRAINT wiki_page_versions_pkey PRIMARY KEY (id);


--
-- Name: wiki_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wiki_pages
    ADD CONSTRAINT wiki_pages_pkey PRIMARY KEY (id);


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

CREATE UNIQUE INDEX index_groups_users_on_group_id_and_user_id ON groups_users USING btree (group_id, user_id);


--
-- Name: index_groups_users_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_users_on_user_id ON groups_users USING btree (user_id);


--
-- Name: index_keywords_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_keywords_on_created_at ON keywords USING btree (created_at);


--
-- Name: index_keywords_on_term_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_keywords_on_term_id_and_user_id ON keywords USING btree (meta_term_id, user_id);


--
-- Name: index_keywords_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_keywords_on_user_id ON keywords USING btree (user_id);


--
-- Name: index_media_entries_media_sets_on_media_entry_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_entries_media_sets_on_media_entry_id ON media_entries_media_sets USING btree (media_entry_id);


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
-- Name: index_media_set_arcs_on_child_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_set_arcs_on_child_id ON media_set_arcs USING btree (child_id);


--
-- Name: index_media_set_arcs_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_set_arcs_on_parent_id ON media_set_arcs USING btree (parent_id);


--
-- Name: index_media_set_arcs_on_parent_id_and_child_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_media_set_arcs_on_parent_id_and_child_id ON media_set_arcs USING btree (parent_id, child_id);


--
-- Name: index_meta_contexts_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_contexts_on_name ON meta_contexts USING btree (name);


--
-- Name: index_meta_data_on_media_resource_id_and_meta_key_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_data_on_media_resource_id_and_meta_key_id ON meta_data USING btree (media_resource_id, meta_key_id);


--
-- Name: index_meta_data_on_meta_key_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_data_on_meta_key_id ON meta_data USING btree (meta_key_id);


--
-- Name: index_meta_key_definitions_on_meta_context_id_and_position; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_key_definitions_on_meta_context_id_and_position ON meta_key_definitions USING btree (meta_context_id, "position");


--
-- Name: index_meta_key_definitions_on_meta_key_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_key_definitions_on_meta_key_id ON meta_key_definitions USING btree (meta_key_id);


--
-- Name: index_meta_keys_meta_terms_on_position; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_keys_meta_terms_on_position ON meta_keys_meta_terms USING btree ("position");


--
-- Name: index_meta_keys_on_label; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_keys_on_label ON meta_keys USING btree (label);


--
-- Name: index_meta_keys_on_object_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_keys_on_object_type ON meta_keys USING btree (object_type);


--
-- Name: index_meta_keys_terms_on_meta_key_id_and_term_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_keys_terms_on_meta_key_id_and_term_id ON meta_keys_meta_terms USING btree (meta_key_id, meta_term_id);


--
-- Name: index_on_media_set_id_and_media_entry_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_on_media_set_id_and_media_entry_id ON media_entries_media_sets USING btree (media_set_id, media_entry_id);


--
-- Name: index_on_projects_and_contexts; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_on_projects_and_contexts ON media_sets_meta_contexts USING btree (media_set_id, meta_context_id);


--
-- Name: index_people_on_firstname; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_firstname ON people USING btree (firstname);


--
-- Name: index_people_on_is_group; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_is_group ON people USING btree (is_group);


--
-- Name: index_people_on_lastname; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_lastname ON people USING btree (lastname);


--
-- Name: index_previews_on_media_file_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_previews_on_media_file_id ON previews USING btree (media_file_id);


--
-- Name: index_settings_on_target_type_and_target_id_and_var; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_settings_on_target_type_and_target_id_and_var ON settings USING btree (target_type, target_id, var);


--
-- Name: index_terms_on_en_GB_and_de_CH; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "index_terms_on_en_GB_and_de_CH" ON meta_terms USING btree ("en_GB", "de_CH");


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

CREATE INDEX index_users_on_person_id ON users USING btree (person_id);


--
-- Name: index_wiki_page_versions_on_page_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_wiki_page_versions_on_page_id ON wiki_page_versions USING btree (page_id);


--
-- Name: index_wiki_page_versions_on_updator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_wiki_page_versions_on_updator_id ON wiki_page_versions USING btree (updator_id);


--
-- Name: index_wiki_pages_on_creator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_wiki_pages_on_creator_id ON wiki_pages USING btree (creator_id);


--
-- Name: index_wiki_pages_on_path; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_wiki_pages_on_path ON wiki_pages USING btree (path);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: edit_sessions_media_resource_id_media_resources_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY edit_sessions
    ADD CONSTRAINT edit_sessions_media_resource_id_media_resources_fkey FOREIGN KEY (media_resource_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: favorites_media_resource_id_media_resources_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites
    ADD CONSTRAINT favorites_media_resource_id_media_resources_fkey FOREIGN KEY (media_resource_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: full_texts_media_resource_id_media_resources_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY full_texts
    ADD CONSTRAINT full_texts_media_resource_id_media_resources_fkey FOREIGN KEY (media_resource_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: grouppermissions_group_id_groups_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY grouppermissions
    ADD CONSTRAINT grouppermissions_group_id_groups_fkey FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE;


--
-- Name: grouppermissions_media_resource_id_media_resources_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY grouppermissions
    ADD CONSTRAINT grouppermissions_media_resource_id_media_resources_fkey FOREIGN KEY (media_resource_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: groups_users_group_id_groups_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups_users
    ADD CONSTRAINT groups_users_group_id_groups_fkey FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE;


--
-- Name: groups_users_user_id_users_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups_users
    ADD CONSTRAINT groups_users_user_id_users_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: media_entries_media_sets_media_entry_id_media_resources_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_entries_media_sets
    ADD CONSTRAINT media_entries_media_sets_media_entry_id_media_resources_fkey FOREIGN KEY (media_entry_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: media_entries_media_sets_media_set_id_media_resources_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_entries_media_sets
    ADD CONSTRAINT media_entries_media_sets_media_set_id_media_resources_fkey FOREIGN KEY (media_set_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: media_set_arcs_child_id_media_resources_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_set_arcs
    ADD CONSTRAINT media_set_arcs_child_id_media_resources_fkey FOREIGN KEY (child_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: media_set_arcs_parent_id_media_resources_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_set_arcs
    ADD CONSTRAINT media_set_arcs_parent_id_media_resources_fkey FOREIGN KEY (parent_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: media_sets_meta_contexts_media_set_id_media_resources_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_sets_meta_contexts
    ADD CONSTRAINT media_sets_meta_contexts_media_set_id_media_resources_fkey FOREIGN KEY (media_set_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: meta_contexts_description_id_meta_terms_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_contexts
    ADD CONSTRAINT meta_contexts_description_id_meta_terms_fkey FOREIGN KEY (description_id) REFERENCES meta_terms(id);


--
-- Name: meta_contexts_label_id_meta_terms_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_contexts
    ADD CONSTRAINT meta_contexts_label_id_meta_terms_fkey FOREIGN KEY (label_id) REFERENCES meta_terms(id);


--
-- Name: meta_data_media_resource_id_media_resources_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data
    ADD CONSTRAINT meta_data_media_resource_id_media_resources_fkey FOREIGN KEY (media_resource_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: meta_key_definitions_description_id_meta_terms_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_key_definitions
    ADD CONSTRAINT meta_key_definitions_description_id_meta_terms_fkey FOREIGN KEY (description_id) REFERENCES meta_terms(id);


--
-- Name: meta_key_definitions_hint_id_meta_terms_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_key_definitions
    ADD CONSTRAINT meta_key_definitions_hint_id_meta_terms_fkey FOREIGN KEY (hint_id) REFERENCES meta_terms(id);


--
-- Name: meta_key_definitions_label_id_meta_terms_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_key_definitions
    ADD CONSTRAINT meta_key_definitions_label_id_meta_terms_fkey FOREIGN KEY (label_id) REFERENCES meta_terms(id);


--
-- Name: person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT person_id_fkey FOREIGN KEY (person_id) REFERENCES people(id);


--
-- Name: userpermissions_media_resource_id_media_resources_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY userpermissions
    ADD CONSTRAINT userpermissions_media_resource_id_media_resources_fkey FOREIGN KEY (media_resource_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: userpermissions_user_id_users_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY userpermissions
    ADD CONSTRAINT userpermissions_user_id_users_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20090304091402');

INSERT INTO schema_migrations (version) VALUES ('20090304091431');

INSERT INTO schema_migrations (version) VALUES ('20090310150441');

INSERT INTO schema_migrations (version) VALUES ('20090504143011');

INSERT INTO schema_migrations (version) VALUES ('20090505114718');

INSERT INTO schema_migrations (version) VALUES ('20090505120000');

INSERT INTO schema_migrations (version) VALUES ('20090529140042');

INSERT INTO schema_migrations (version) VALUES ('20090826101541');

INSERT INTO schema_migrations (version) VALUES ('20090827124700');

INSERT INTO schema_migrations (version) VALUES ('20090928135809');

INSERT INTO schema_migrations (version) VALUES ('20090930130031');

INSERT INTO schema_migrations (version) VALUES ('20091111170552');

INSERT INTO schema_migrations (version) VALUES ('20091125165700');

INSERT INTO schema_migrations (version) VALUES ('20091209083948');

INSERT INTO schema_migrations (version) VALUES ('20100118200011');

INSERT INTO schema_migrations (version) VALUES ('20100203222610');

INSERT INTO schema_migrations (version) VALUES ('20100223090310');

INSERT INTO schema_migrations (version) VALUES ('20100319183758');

INSERT INTO schema_migrations (version) VALUES ('20100528111406');

INSERT INTO schema_migrations (version) VALUES ('20100610103525');

INSERT INTO schema_migrations (version) VALUES ('20100614160217');

INSERT INTO schema_migrations (version) VALUES ('20100619104047');

INSERT INTO schema_migrations (version) VALUES ('20100623123943');

INSERT INTO schema_migrations (version) VALUES ('20100727160912');

INSERT INTO schema_migrations (version) VALUES ('20100806222042');

INSERT INTO schema_migrations (version) VALUES ('20100811134357');

INSERT INTO schema_migrations (version) VALUES ('20100827095717');

INSERT INTO schema_migrations (version) VALUES ('20101002144342');

INSERT INTO schema_migrations (version) VALUES ('20101025095028');

INSERT INTO schema_migrations (version) VALUES ('20101028135817');

INSERT INTO schema_migrations (version) VALUES ('20101111142814');

INSERT INTO schema_migrations (version) VALUES ('20101118151432');

INSERT INTO schema_migrations (version) VALUES ('20101130155457');

INSERT INTO schema_migrations (version) VALUES ('20101213183358');

INSERT INTO schema_migrations (version) VALUES ('20101216161948');

INSERT INTO schema_migrations (version) VALUES ('20101223133610');

INSERT INTO schema_migrations (version) VALUES ('20110124150835');

INSERT INTO schema_migrations (version) VALUES ('20110128143744');

INSERT INTO schema_migrations (version) VALUES ('20110301125220');

INSERT INTO schema_migrations (version) VALUES ('20110328122446');

INSERT INTO schema_migrations (version) VALUES ('20110330150317');

INSERT INTO schema_migrations (version) VALUES ('20110415133056');

INSERT INTO schema_migrations (version) VALUES ('20110505180606');

INSERT INTO schema_migrations (version) VALUES ('20111114110014');

INSERT INTO schema_migrations (version) VALUES ('20111114110109');

INSERT INTO schema_migrations (version) VALUES ('20111208131742');

INSERT INTO schema_migrations (version) VALUES ('20111212073809');

INSERT INTO schema_migrations (version) VALUES ('20111221132442');

INSERT INTO schema_migrations (version) VALUES ('20111221142909');

INSERT INTO schema_migrations (version) VALUES ('20120111104043');

INSERT INTO schema_migrations (version) VALUES ('20120111133855');

INSERT INTO schema_migrations (version) VALUES ('20120113221603');

INSERT INTO schema_migrations (version) VALUES ('20120119000000');

INSERT INTO schema_migrations (version) VALUES ('20120119000001');

INSERT INTO schema_migrations (version) VALUES ('20120119000002');

INSERT INTO schema_migrations (version) VALUES ('20120119000004');

INSERT INTO schema_migrations (version) VALUES ('20120207000000');

INSERT INTO schema_migrations (version) VALUES ('20120207000001');

INSERT INTO schema_migrations (version) VALUES ('20120208170529');

INSERT INTO schema_migrations (version) VALUES ('20120210163904');