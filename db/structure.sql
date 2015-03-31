--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
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


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

--
-- Name: check_madek_core_meta_key_immutability(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_madek_core_meta_key_immutability() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
          BEGIN
            IF (TG_OP = 'DELETE') THEN
              IF (OLD.id ilike 'madek:core:%') THEN
                RAISE EXCEPTION 'The madek:core meta_key % may not be deleted', OLD.id;
              END IF;
            ELSIF  (TG_OP = 'UPDATE') THEN
              IF (OLD.id ilike 'madek:core:%') THEN
                RAISE EXCEPTION 'The madek:core meta_key % may not be modified', OLD.id;
              END IF;
            ELSIF  (TG_OP = 'INSERT') THEN
              IF (NEW.id ilike 'madek:core:%') THEN
                RAISE EXCEPTION 'The madek:core meta_key namespace may not be extended by %', NEW.id;
              END IF;
            END IF;
            RETURN NEW;
          END;
          $$;


--
-- Name: check_meta_data_meta_key_type_consistency(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_meta_data_meta_key_type_consistency() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
          BEGIN

            IF EXISTS (SELECT 1 FROM meta_keys 
              JOIN meta_data ON meta_data.meta_key_id = meta_keys.id
              WHERE meta_data.id = NEW.id
              AND meta_keys.meta_datum_object_type <> meta_data.type) THEN
                RAISE EXCEPTION 'The types of related meta_data and meta_keys must be identical';
            END IF;

            RETURN NEW;
          END;
          $$;


--
-- Name: check_meta_key_meta_data_type_consistency(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_meta_key_meta_data_type_consistency() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
          BEGIN

            IF EXISTS (SELECT 1 FROM meta_keys 
              JOIN meta_data ON meta_data.meta_key_id = meta_keys.id
              WHERE meta_keys.id = NEW.id
              AND meta_keys.meta_datum_object_type <> meta_data.type) THEN
                RAISE EXCEPTION 'The types of related meta_data and meta_keys must be identical';
            END IF;

            RETURN NEW;
          END;
          $$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: admins; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE admins (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: api_clients; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE api_clients (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    name character varying NOT NULL,
    description text,
    secret uuid DEFAULT uuid_generate_v4(),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    CONSTRAINT name_format CHECK (((name)::text ~ '^[a-z][a-z0-9\-\_]+$'::text))
);


--
-- Name: app_settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE app_settings (
    id integer NOT NULL,
    featured_set_id uuid,
    splashscreen_slideshow_set_id uuid,
    catalog_set_id uuid,
    title character varying,
    support_url character varying,
    welcome_title character varying,
    welcome_subtitle character varying,
    teaser_set_id uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    logo_url character varying DEFAULT '/assets/inserts/image-logo-zhdk.png'::character varying NOT NULL,
    brand character varying DEFAULT 'Zürcher Hochschule der Künste'::character varying NOT NULL,
    footer_links text,
    CONSTRAINT oneandonly CHECK ((id = 0))
);


--
-- Name: collection_api_client_permissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE collection_api_client_permissions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    edit_metadata_and_relations boolean DEFAULT false NOT NULL,
    collection_id uuid NOT NULL,
    api_client_id uuid NOT NULL,
    updator_id uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: collection_collection_arcs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE collection_collection_arcs (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    child_id uuid NOT NULL,
    parent_id uuid NOT NULL
);


--
-- Name: collection_filter_set_arcs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE collection_filter_set_arcs (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    filter_set_id uuid NOT NULL,
    collection_id uuid NOT NULL
);


--
-- Name: collection_group_permissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE collection_group_permissions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    edit_metadata_and_relations boolean DEFAULT false NOT NULL,
    collection_id uuid NOT NULL,
    group_id uuid NOT NULL,
    updator_id uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: collection_media_entry_arcs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE collection_media_entry_arcs (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    media_entry_id uuid NOT NULL,
    collection_id uuid NOT NULL,
    highlight boolean DEFAULT false,
    cover boolean
);


--
-- Name: collection_user_permissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE collection_user_permissions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    edit_metadata_and_relations boolean DEFAULT false NOT NULL,
    edit_permissions boolean DEFAULT false NOT NULL,
    collection_id uuid NOT NULL,
    user_id uuid NOT NULL,
    updator_id uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: collections; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE collections (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    responsible_user_id uuid NOT NULL,
    creator_id uuid NOT NULL
);


--
-- Name: custom_urls; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE custom_urls (
    id character varying NOT NULL,
    "primary?" boolean DEFAULT false NOT NULL,
    media_resource_id uuid NOT NULL,
    creator_id uuid NOT NULL,
    updator_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT custom_urls_id_format CHECK (((id)::text ~ '^[a-z][a-z0-9\-\_]+$'::text)),
    CONSTRAINT custom_urls_id_is_not_uuid CHECK ((NOT ((id)::text ~* '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'::text)))
);


--
-- Name: edit_sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE edit_sessions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    media_entry_id uuid,
    collection_id uuid,
    filter_set_id uuid,
    CONSTRAINT edit_sessions_is_related CHECK ((((((media_entry_id IS NULL) AND (collection_id IS NULL)) AND (filter_set_id IS NOT NULL)) OR (((media_entry_id IS NULL) AND (collection_id IS NOT NULL)) AND (filter_set_id IS NULL))) OR (((media_entry_id IS NOT NULL) AND (collection_id IS NULL)) AND (filter_set_id IS NULL))))
);


--
-- Name: favorite_collections; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorite_collections (
    user_id uuid NOT NULL,
    collection_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: favorite_filter_sets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorite_filter_sets (
    user_id uuid NOT NULL,
    filter_set_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: favorite_media_entries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorite_media_entries (
    user_id uuid NOT NULL,
    media_entry_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: filter_set_api_client_permissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE filter_set_api_client_permissions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    edit_metadata_and_filter boolean DEFAULT false NOT NULL,
    filter_set_id uuid NOT NULL,
    api_client_id uuid NOT NULL,
    updator_id uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: filter_set_group_permissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE filter_set_group_permissions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    filter_set_id uuid NOT NULL,
    group_id uuid NOT NULL,
    updator_id uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: filter_set_user_permissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE filter_set_user_permissions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    edit_metadata_and_filter boolean DEFAULT false NOT NULL,
    edit_permissions boolean DEFAULT false NOT NULL,
    filter_set_id uuid NOT NULL,
    user_id uuid NOT NULL,
    updator_id uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: filter_sets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE filter_sets (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    filter jsonb DEFAULT '{}'::jsonb NOT NULL,
    responsible_user_id uuid NOT NULL,
    creator_id uuid NOT NULL
);


--
-- Name: full_texts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE full_texts (
    media_resource_id uuid NOT NULL,
    text text
);


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE groups (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    previous_id integer,
    name character varying,
    institutional_group_id character varying,
    institutional_group_name character varying,
    type character varying DEFAULT 'Group'::character varying NOT NULL,
    searchable text DEFAULT ''::text NOT NULL
);


--
-- Name: groups_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE groups_users (
    group_id uuid NOT NULL,
    user_id uuid NOT NULL
);


--
-- Name: io_interfaces; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE io_interfaces (
    id character varying NOT NULL,
    description character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: io_mappings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE io_mappings (
    io_interface_id character varying NOT NULL,
    meta_key_id character varying NOT NULL,
    key_map character varying,
    key_map_type character varying,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    id uuid DEFAULT uuid_generate_v4() NOT NULL
);


--
-- Name: keyword_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE keyword_terms (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    term character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    creator_id uuid
);


--
-- Name: keywords; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE keywords (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_id uuid,
    meta_datum_id uuid NOT NULL,
    keyword_term_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: license_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE license_groups (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    description text,
    "position" double precision,
    parent_id uuid,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: licenses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE licenses (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    is_default boolean DEFAULT false,
    is_custom boolean DEFAULT false,
    label character varying,
    usage character varying,
    url character varying,
    "position" double precision
);


--
-- Name: licenses_license_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE licenses_license_groups (
    license_id uuid,
    license_group_id uuid,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: media_entries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_entries (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    get_full_size boolean DEFAULT false NOT NULL,
    responsible_user_id uuid NOT NULL,
    creator_id uuid NOT NULL,
    "published?" boolean DEFAULT false
);


--
-- Name: media_entry_api_client_permissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_entry_api_client_permissions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    get_full_size boolean DEFAULT false NOT NULL,
    media_entry_id uuid NOT NULL,
    api_client_id uuid NOT NULL,
    updator_id uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: media_entry_group_permissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_entry_group_permissions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    get_full_size boolean DEFAULT false NOT NULL,
    edit_metadata boolean DEFAULT false NOT NULL,
    media_entry_id uuid NOT NULL,
    group_id uuid NOT NULL,
    updator_id uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: media_entry_user_permissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_entry_user_permissions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    get_metadata_and_previews boolean DEFAULT false NOT NULL,
    get_full_size boolean DEFAULT false NOT NULL,
    edit_metadata boolean DEFAULT false NOT NULL,
    edit_permissions boolean DEFAULT false NOT NULL,
    media_entry_id uuid NOT NULL,
    user_id uuid NOT NULL,
    updator_id uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: media_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_files (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    height integer,
    size bigint,
    width integer,
    access_hash text,
    meta_data text,
    content_type character varying NOT NULL,
    filename character varying,
    guid character varying,
    extension character varying,
    media_type character varying,
    media_entry_id uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    uploader_id uuid NOT NULL
);


--
-- Name: media_resources; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_resources (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    previous_id integer,
    download boolean DEFAULT false NOT NULL,
    edit boolean DEFAULT false NOT NULL,
    manage boolean DEFAULT false NOT NULL,
    view boolean DEFAULT false NOT NULL,
    type character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT edit_on_publicpermissions_is_false CHECK ((edit = false)),
    CONSTRAINT manage_on_publicpermissions_is_false CHECK ((manage = false))
);


--
-- Name: meta_data; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_data (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    meta_key_id character varying NOT NULL,
    type character varying,
    string text,
    license_id uuid,
    media_entry_id uuid,
    collection_id uuid,
    filter_set_id uuid,
    CONSTRAINT meta_data_is_related CHECK ((((((media_entry_id IS NULL) AND (collection_id IS NULL)) AND (filter_set_id IS NOT NULL)) OR (((media_entry_id IS NULL) AND (collection_id IS NOT NULL)) AND (filter_set_id IS NULL))) OR (((media_entry_id IS NOT NULL) AND (collection_id IS NULL)) AND (filter_set_id IS NULL))))
);


--
-- Name: meta_data_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_data_groups (
    meta_datum_id uuid NOT NULL,
    group_id uuid NOT NULL
);


--
-- Name: meta_data_meta_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_data_meta_terms (
    meta_datum_id uuid NOT NULL,
    meta_term_id uuid NOT NULL
);


--
-- Name: meta_data_people; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_data_people (
    meta_datum_id uuid NOT NULL,
    person_id uuid NOT NULL
);


--
-- Name: meta_data_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_data_users (
    meta_datum_id uuid NOT NULL,
    user_id uuid NOT NULL
);


--
-- Name: meta_data_vocables; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_data_vocables (
    meta_datum_id uuid,
    vocable_id uuid
);


--
-- Name: meta_keys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_keys (
    id character varying NOT NULL,
    is_extensible_list boolean,
    meta_datum_object_type character varying DEFAULT 'MetaDatumString'::character varying NOT NULL,
    vocables_alphabetical_order boolean DEFAULT true,
    label text,
    description text,
    hint text,
    "required?" boolean DEFAULT false,
    length_max integer,
    length_min integer,
    "position" integer,
    input_type integer,
    "enabled_for_media_entries?" boolean DEFAULT false NOT NULL,
    "enabled_for_collections?" boolean DEFAULT false NOT NULL,
    "enabled_for_filters_sets?" boolean DEFAULT false NOT NULL,
    vocabulary_id character varying NOT NULL,
    "extensible?" boolean DEFAULT false
);


--
-- Name: people; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE people (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "bunch?" boolean DEFAULT false,
    date_of_birth date,
    date_of_death date,
    first_name character varying,
    last_name character varying,
    pseudonym character varying,
    searchable text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: previews; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE previews (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    media_file_id uuid NOT NULL,
    height integer,
    width integer,
    content_type character varying,
    filename character varying,
    thumbnail character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    media_type character varying NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: usage_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE usage_terms (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    title character varying,
    version character varying,
    intro text,
    body text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    previous_id integer,
    email character varying,
    login text,
    notes text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    password_digest character varying,
    person_id uuid NOT NULL,
    zhdkid integer,
    usage_terms_accepted_at timestamp without time zone,
    searchable text DEFAULT ''::text NOT NULL,
    trgm_searchable text DEFAULT ''::text NOT NULL,
    autocomplete text DEFAULT ''::text NOT NULL,
    contrast_mode boolean DEFAULT false NOT NULL,
    CONSTRAINT users_login_simple CHECK ((login ~* '^[a-z0-9\.\-\_]+$'::text))
);


--
-- Name: visualizations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE visualizations (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    resource_identifier character varying NOT NULL,
    control_settings text,
    layout text
);


--
-- Name: vocables; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vocables (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    meta_key_id character varying,
    term text
);


--
-- Name: vocabularies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vocabularies (
    id character varying NOT NULL,
    label text,
    description text,
    "public_view?" boolean DEFAULT true NOT NULL,
    "public_use?" boolean DEFAULT true NOT NULL,
    CONSTRAINT id_chars CHECK (((id)::text ~* '^[a-z0-9\-\_\:]+$'::text))
);


--
-- Name: vocabulary_api_client_permissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vocabulary_api_client_permissions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    api_client_id uuid NOT NULL,
    vocabulary_id character varying NOT NULL,
    use boolean DEFAULT false NOT NULL,
    view boolean DEFAULT true NOT NULL
);


--
-- Name: vocabulary_group_permissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vocabulary_group_permissions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    group_id uuid NOT NULL,
    vocabulary_id character varying NOT NULL,
    use boolean DEFAULT false NOT NULL,
    view boolean DEFAULT true NOT NULL
);


--
-- Name: vocabulary_user_permissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE vocabulary_user_permissions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    vocabulary_id character varying NOT NULL,
    use boolean DEFAULT false NOT NULL,
    view boolean DEFAULT true NOT NULL
);


--
-- Name: zencoder_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE zencoder_jobs (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    media_file_id uuid NOT NULL,
    zencoder_id integer,
    comment text,
    state character varying DEFAULT 'initialized'::character varying NOT NULL,
    error text,
    notification text,
    request text,
    response text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY admins
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: api_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY api_clients
    ADD CONSTRAINT api_clients_pkey PRIMARY KEY (id);


--
-- Name: app_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY app_settings
    ADD CONSTRAINT app_settings_pkey PRIMARY KEY (id);


--
-- Name: collection_api_client_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY collection_api_client_permissions
    ADD CONSTRAINT collection_api_client_permissions_pkey PRIMARY KEY (id);


--
-- Name: collection_collection_arcs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY collection_collection_arcs
    ADD CONSTRAINT collection_collection_arcs_pkey PRIMARY KEY (id);


--
-- Name: collection_filter_set_arcs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY collection_filter_set_arcs
    ADD CONSTRAINT collection_filter_set_arcs_pkey PRIMARY KEY (id);


--
-- Name: collection_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY collection_group_permissions
    ADD CONSTRAINT collection_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: collection_media_entry_arcs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY collection_media_entry_arcs
    ADD CONSTRAINT collection_media_entry_arcs_pkey PRIMARY KEY (id);


--
-- Name: collection_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY collection_user_permissions
    ADD CONSTRAINT collection_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: collections_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY collections
    ADD CONSTRAINT collections_pkey PRIMARY KEY (id);


--
-- Name: copyrights_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY licenses
    ADD CONSTRAINT copyrights_pkey PRIMARY KEY (id);


--
-- Name: custom_urls_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY custom_urls
    ADD CONSTRAINT custom_urls_pkey PRIMARY KEY (id);


--
-- Name: edit_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY edit_sessions
    ADD CONSTRAINT edit_sessions_pkey PRIMARY KEY (id);


--
-- Name: filter_set_api_client_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY filter_set_api_client_permissions
    ADD CONSTRAINT filter_set_api_client_permissions_pkey PRIMARY KEY (id);


--
-- Name: filter_set_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY filter_set_group_permissions
    ADD CONSTRAINT filter_set_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: filter_set_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY filter_set_user_permissions
    ADD CONSTRAINT filter_set_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: filter_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY filter_sets
    ADD CONSTRAINT filter_sets_pkey PRIMARY KEY (id);


--
-- Name: full_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY full_texts
    ADD CONSTRAINT full_texts_pkey PRIMARY KEY (media_resource_id);


--
-- Name: groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: io_interfaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY io_interfaces
    ADD CONSTRAINT io_interfaces_pkey PRIMARY KEY (id);


--
-- Name: io_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY io_mappings
    ADD CONSTRAINT io_mappings_pkey PRIMARY KEY (id);


--
-- Name: keyword_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY keyword_terms
    ADD CONSTRAINT keyword_terms_pkey PRIMARY KEY (id);


--
-- Name: keywords_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY keywords
    ADD CONSTRAINT keywords_pkey PRIMARY KEY (id);


--
-- Name: license_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY license_groups
    ADD CONSTRAINT license_groups_pkey PRIMARY KEY (id);


--
-- Name: media_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY media_entries
    ADD CONSTRAINT media_entries_pkey PRIMARY KEY (id);


--
-- Name: media_entry_api_client_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY media_entry_api_client_permissions
    ADD CONSTRAINT media_entry_api_client_permissions_pkey PRIMARY KEY (id);


--
-- Name: media_entry_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY media_entry_group_permissions
    ADD CONSTRAINT media_entry_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: media_entry_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY media_entry_user_permissions
    ADD CONSTRAINT media_entry_user_permissions_pkey PRIMARY KEY (id);


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
-- Name: meta_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY meta_data
    ADD CONSTRAINT meta_data_pkey PRIMARY KEY (id);


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
-- Name: usage_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY usage_terms
    ADD CONSTRAINT usage_terms_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: visualizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY visualizations
    ADD CONSTRAINT visualizations_pkey PRIMARY KEY (id);


--
-- Name: vocables_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vocables
    ADD CONSTRAINT vocables_pkey PRIMARY KEY (id);


--
-- Name: vocabularies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vocabularies
    ADD CONSTRAINT vocabularies_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_api_client_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vocabulary_api_client_permissions
    ADD CONSTRAINT vocabulary_api_client_permissions_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vocabulary_group_permissions
    ADD CONSTRAINT vocabulary_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY vocabulary_user_permissions
    ADD CONSTRAINT vocabulary_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: zencoder_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY zencoder_jobs
    ADD CONSTRAINT zencoder_jobs_pkey PRIMARY KEY (id);


--
-- Name: full_texts_text_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX full_texts_text_idx ON full_texts USING gin (text gin_trgm_ops);


--
-- Name: full_texts_to_tsvector_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX full_texts_to_tsvector_idx ON full_texts USING gin (to_tsvector('english'::regconfig, text));


--
-- Name: groups_searchable_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX groups_searchable_idx ON groups USING gin (searchable gin_trgm_ops);


--
-- Name: groups_to_tsvector_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX groups_to_tsvector_idx ON groups USING gin (to_tsvector('english'::regconfig, searchable));


--
-- Name: idx_colgrpp_edit_mdata_and_relations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_colgrpp_edit_mdata_and_relations ON collection_group_permissions USING btree (edit_metadata_and_relations);


--
-- Name: idx_colgrpp_get_mdata_and_previews; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_colgrpp_get_mdata_and_previews ON collection_group_permissions USING btree (get_metadata_and_previews);


--
-- Name: idx_colgrpp_on_collection_id_and_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_colgrpp_on_collection_id_and_group_id ON collection_group_permissions USING btree (collection_id, group_id);


--
-- Name: idx_colgrpp_on_filter_set_id_and_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_colgrpp_on_filter_set_id_and_group_id ON filter_set_group_permissions USING btree (filter_set_id, group_id);


--
-- Name: idx_collapiclp_edit_mdata_and_relations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_collapiclp_edit_mdata_and_relations ON collection_api_client_permissions USING btree (edit_metadata_and_relations);


--
-- Name: idx_collapiclp_get_mdata_and_previews; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_collapiclp_get_mdata_and_previews ON collection_api_client_permissions USING btree (get_metadata_and_previews);


--
-- Name: idx_collapiclp_on_collection_id_and_api_client_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_collapiclp_on_collection_id_and_api_client_id ON collection_api_client_permissions USING btree (collection_id, api_client_id);


--
-- Name: idx_collection_user_permission; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_collection_user_permission ON collection_user_permissions USING btree (collection_id, user_id);


--
-- Name: idx_colluserperm_edit_metadata_and_relations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_colluserperm_edit_metadata_and_relations ON collection_user_permissions USING btree (edit_metadata_and_relations);


--
-- Name: idx_colluserperm_edit_permissions; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_colluserperm_edit_permissions ON collection_user_permissions USING btree (edit_permissions);


--
-- Name: idx_colluserperm_get_metadata_and_previews; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_colluserperm_get_metadata_and_previews ON collection_user_permissions USING btree (get_metadata_and_previews);


--
-- Name: idx_fsetapiclp_edit_mdata_and_filter; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_fsetapiclp_edit_mdata_and_filter ON filter_set_api_client_permissions USING btree (edit_metadata_and_filter);


--
-- Name: idx_fsetapiclp_get_mdata_and_previews; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_fsetapiclp_get_mdata_and_previews ON filter_set_api_client_permissions USING btree (get_metadata_and_previews);


--
-- Name: idx_fsetapiclp_on_filter_set_id_and_api_client_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_fsetapiclp_on_filter_set_id_and_api_client_id ON filter_set_api_client_permissions USING btree (filter_set_id, api_client_id);


--
-- Name: idx_fsetusrp_on_filter_set_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_fsetusrp_on_filter_set_id_and_user_id ON filter_set_user_permissions USING btree (filter_set_id, user_id);


--
-- Name: idx_me_apicl_get_mdata_and_previews; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_me_apicl_get_mdata_and_previews ON media_entry_api_client_permissions USING btree (get_metadata_and_previews);


--
-- Name: idx_media_entry_user_permission; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_media_entry_user_permission ON media_entry_user_permissions USING btree (media_entry_id, user_id);


--
-- Name: idx_megrpp_get_full_size; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_megrpp_get_full_size ON media_entry_api_client_permissions USING btree (get_full_size);


--
-- Name: idx_megrpp_get_mdata_and_previews; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_megrpp_get_mdata_and_previews ON media_entry_group_permissions USING btree (get_metadata_and_previews);


--
-- Name: idx_megrpp_on_media_entry_id_and_api_client_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_megrpp_on_media_entry_id_and_api_client_id ON media_entry_api_client_permissions USING btree (media_entry_id, api_client_id);


--
-- Name: idx_megrpp_on_media_entry_id_and_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_megrpp_on_media_entry_id_and_group_id ON media_entry_group_permissions USING btree (media_entry_id, group_id);


--
-- Name: idx_vocabulary_api_client; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_vocabulary_api_client ON vocabulary_api_client_permissions USING btree (api_client_id, vocabulary_id);


--
-- Name: idx_vocabulary_group; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_vocabulary_group ON vocabulary_group_permissions USING btree (group_id, vocabulary_id);


--
-- Name: idx_vocabulary_user; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_vocabulary_user ON vocabulary_user_permissions USING btree (user_id, vocabulary_id);


--
-- Name: index_admins_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admins_on_user_id ON admins USING btree (user_id);


--
-- Name: index_api_clients_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_api_clients_on_name ON api_clients USING btree (name);


--
-- Name: index_collection_api_client_permissions_on_api_client_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_api_client_permissions_on_api_client_id ON collection_api_client_permissions USING btree (api_client_id);


--
-- Name: index_collection_api_client_permissions_on_collection_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_api_client_permissions_on_collection_id ON collection_api_client_permissions USING btree (collection_id);


--
-- Name: index_collection_api_client_permissions_on_updator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_api_client_permissions_on_updator_id ON collection_api_client_permissions USING btree (updator_id);


--
-- Name: index_collection_collection_arcs_on_child_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_collection_arcs_on_child_id ON collection_collection_arcs USING btree (child_id);


--
-- Name: index_collection_collection_arcs_on_child_id_and_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_collection_arcs_on_child_id_and_parent_id ON collection_collection_arcs USING btree (child_id, parent_id);


--
-- Name: index_collection_collection_arcs_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_collection_arcs_on_parent_id ON collection_collection_arcs USING btree (parent_id);


--
-- Name: index_collection_collection_arcs_on_parent_id_and_child_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_collection_collection_arcs_on_parent_id_and_child_id ON collection_collection_arcs USING btree (parent_id, child_id);


--
-- Name: index_collection_filter_set_arcs_on_collection_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_filter_set_arcs_on_collection_id ON collection_filter_set_arcs USING btree (collection_id);


--
-- Name: index_collection_filter_set_arcs_on_collection_id_and_filter_se; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_collection_filter_set_arcs_on_collection_id_and_filter_se ON collection_filter_set_arcs USING btree (collection_id, filter_set_id);


--
-- Name: index_collection_filter_set_arcs_on_filter_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_filter_set_arcs_on_filter_set_id ON collection_filter_set_arcs USING btree (filter_set_id);


--
-- Name: index_collection_filter_set_arcs_on_filter_set_id_and_collectio; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_filter_set_arcs_on_filter_set_id_and_collectio ON collection_filter_set_arcs USING btree (filter_set_id, collection_id);


--
-- Name: index_collection_group_permissions_on_collection_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_group_permissions_on_collection_id ON collection_group_permissions USING btree (collection_id);


--
-- Name: index_collection_group_permissions_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_group_permissions_on_group_id ON collection_group_permissions USING btree (group_id);


--
-- Name: index_collection_group_permissions_on_updator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_group_permissions_on_updator_id ON collection_group_permissions USING btree (updator_id);


--
-- Name: index_collection_media_entry_arcs_on_collection_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_media_entry_arcs_on_collection_id ON collection_media_entry_arcs USING btree (collection_id);


--
-- Name: index_collection_media_entry_arcs_on_collection_id_and_media_en; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_collection_media_entry_arcs_on_collection_id_and_media_en ON collection_media_entry_arcs USING btree (collection_id, media_entry_id);


--
-- Name: index_collection_media_entry_arcs_on_media_entry_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_media_entry_arcs_on_media_entry_id ON collection_media_entry_arcs USING btree (media_entry_id);


--
-- Name: index_collection_media_entry_arcs_on_media_entry_id_and_collect; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_media_entry_arcs_on_media_entry_id_and_collect ON collection_media_entry_arcs USING btree (media_entry_id, collection_id);


--
-- Name: index_collection_user_permissions_on_collection_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_user_permissions_on_collection_id ON collection_user_permissions USING btree (collection_id);


--
-- Name: index_collection_user_permissions_on_updator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_user_permissions_on_updator_id ON collection_user_permissions USING btree (updator_id);


--
-- Name: index_collection_user_permissions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collection_user_permissions_on_user_id ON collection_user_permissions USING btree (user_id);


--
-- Name: index_collections_on_creator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collections_on_creator_id ON collections USING btree (creator_id);


--
-- Name: index_collections_on_responsible_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_collections_on_responsible_user_id ON collections USING btree (responsible_user_id);


--
-- Name: index_custom_urls_on_creator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_custom_urls_on_creator_id ON custom_urls USING btree (creator_id);


--
-- Name: index_custom_urls_on_media_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_custom_urls_on_media_resource_id ON custom_urls USING btree (media_resource_id);


--
-- Name: index_custom_urls_on_updator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_custom_urls_on_updator_id ON custom_urls USING btree (updator_id);


--
-- Name: index_edit_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_edit_sessions_on_user_id ON edit_sessions USING btree (user_id);


--
-- Name: index_favorite_collections_on_collection_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorite_collections_on_collection_id ON favorite_collections USING btree (collection_id);


--
-- Name: index_favorite_collections_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorite_collections_on_user_id ON favorite_collections USING btree (user_id);


--
-- Name: index_favorite_collections_on_user_id_and_collection_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_favorite_collections_on_user_id_and_collection_id ON favorite_collections USING btree (user_id, collection_id);


--
-- Name: index_favorite_filter_sets_on_filter_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorite_filter_sets_on_filter_set_id ON favorite_filter_sets USING btree (filter_set_id);


--
-- Name: index_favorite_filter_sets_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorite_filter_sets_on_user_id ON favorite_filter_sets USING btree (user_id);


--
-- Name: index_favorite_filter_sets_on_user_id_and_filter_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_favorite_filter_sets_on_user_id_and_filter_set_id ON favorite_filter_sets USING btree (user_id, filter_set_id);


--
-- Name: index_favorite_media_entries_on_media_entry_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorite_media_entries_on_media_entry_id ON favorite_media_entries USING btree (media_entry_id);


--
-- Name: index_favorite_media_entries_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorite_media_entries_on_user_id ON favorite_media_entries USING btree (user_id);


--
-- Name: index_favorite_media_entries_on_user_id_and_media_entry_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_favorite_media_entries_on_user_id_and_media_entry_id ON favorite_media_entries USING btree (user_id, media_entry_id);


--
-- Name: index_filter_set_api_client_permissions_on_api_client_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_filter_set_api_client_permissions_on_api_client_id ON filter_set_api_client_permissions USING btree (api_client_id);


--
-- Name: index_filter_set_api_client_permissions_on_filter_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_filter_set_api_client_permissions_on_filter_set_id ON filter_set_api_client_permissions USING btree (filter_set_id);


--
-- Name: index_filter_set_api_client_permissions_on_updator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_filter_set_api_client_permissions_on_updator_id ON filter_set_api_client_permissions USING btree (updator_id);


--
-- Name: index_filter_set_group_permissions_on_filter_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_filter_set_group_permissions_on_filter_set_id ON filter_set_group_permissions USING btree (filter_set_id);


--
-- Name: index_filter_set_group_permissions_on_get_metadata_and_previews; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_filter_set_group_permissions_on_get_metadata_and_previews ON filter_set_group_permissions USING btree (get_metadata_and_previews);


--
-- Name: index_filter_set_group_permissions_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_filter_set_group_permissions_on_group_id ON filter_set_group_permissions USING btree (group_id);


--
-- Name: index_filter_set_group_permissions_on_updator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_filter_set_group_permissions_on_updator_id ON filter_set_group_permissions USING btree (updator_id);


--
-- Name: index_filter_set_user_permissions_on_edit_metadata_and_filter; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_filter_set_user_permissions_on_edit_metadata_and_filter ON filter_set_user_permissions USING btree (edit_metadata_and_filter);


--
-- Name: index_filter_set_user_permissions_on_edit_permissions; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_filter_set_user_permissions_on_edit_permissions ON filter_set_user_permissions USING btree (edit_permissions);


--
-- Name: index_filter_set_user_permissions_on_filter_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_filter_set_user_permissions_on_filter_set_id ON filter_set_user_permissions USING btree (filter_set_id);


--
-- Name: index_filter_set_user_permissions_on_get_metadata_and_previews; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_filter_set_user_permissions_on_get_metadata_and_previews ON filter_set_user_permissions USING btree (get_metadata_and_previews);


--
-- Name: index_filter_set_user_permissions_on_updator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_filter_set_user_permissions_on_updator_id ON filter_set_user_permissions USING btree (updator_id);


--
-- Name: index_filter_set_user_permissions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_filter_set_user_permissions_on_user_id ON filter_set_user_permissions USING btree (user_id);


--
-- Name: index_filter_sets_on_creator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_filter_sets_on_creator_id ON filter_sets USING btree (creator_id);


--
-- Name: index_filter_sets_on_responsible_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_filter_sets_on_responsible_user_id ON filter_sets USING btree (responsible_user_id);


--
-- Name: index_groups_on_institutional_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_on_institutional_group_id ON groups USING btree (institutional_group_id);


--
-- Name: index_groups_on_institutional_group_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_on_institutional_group_name ON groups USING btree (institutional_group_name);


--
-- Name: index_groups_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_on_name ON groups USING btree (name);


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
-- Name: index_keywords_on_keyword_term_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_keywords_on_keyword_term_id ON keywords USING btree (keyword_term_id);


--
-- Name: index_keywords_on_meta_datum_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_keywords_on_meta_datum_id ON keywords USING btree (meta_datum_id);


--
-- Name: index_keywords_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_keywords_on_user_id ON keywords USING btree (user_id);


--
-- Name: index_licenses_on_label; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_licenses_on_label ON licenses USING btree (label);


--
-- Name: index_media_entries_on_creator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_entries_on_creator_id ON media_entries USING btree (creator_id);


--
-- Name: index_media_entries_on_responsible_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_entries_on_responsible_user_id ON media_entries USING btree (responsible_user_id);


--
-- Name: index_media_entry_api_client_permissions_on_api_client_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_entry_api_client_permissions_on_api_client_id ON media_entry_api_client_permissions USING btree (api_client_id);


--
-- Name: index_media_entry_api_client_permissions_on_get_full_size; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_entry_api_client_permissions_on_get_full_size ON media_entry_api_client_permissions USING btree (get_full_size);


--
-- Name: index_media_entry_api_client_permissions_on_media_entry_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_entry_api_client_permissions_on_media_entry_id ON media_entry_api_client_permissions USING btree (media_entry_id);


--
-- Name: index_media_entry_api_client_permissions_on_updator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_entry_api_client_permissions_on_updator_id ON media_entry_api_client_permissions USING btree (updator_id);


--
-- Name: index_media_entry_group_permissions_on_edit_metadata; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_entry_group_permissions_on_edit_metadata ON media_entry_group_permissions USING btree (edit_metadata);


--
-- Name: index_media_entry_group_permissions_on_get_full_size; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_entry_group_permissions_on_get_full_size ON media_entry_group_permissions USING btree (get_full_size);


--
-- Name: index_media_entry_group_permissions_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_entry_group_permissions_on_group_id ON media_entry_group_permissions USING btree (group_id);


--
-- Name: index_media_entry_group_permissions_on_media_entry_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_entry_group_permissions_on_media_entry_id ON media_entry_group_permissions USING btree (media_entry_id);


--
-- Name: index_media_entry_group_permissions_on_updator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_entry_group_permissions_on_updator_id ON media_entry_group_permissions USING btree (updator_id);


--
-- Name: index_media_entry_user_permissions_on_edit_metadata; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_entry_user_permissions_on_edit_metadata ON media_entry_user_permissions USING btree (edit_metadata);


--
-- Name: index_media_entry_user_permissions_on_edit_permissions; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_entry_user_permissions_on_edit_permissions ON media_entry_user_permissions USING btree (edit_permissions);


--
-- Name: index_media_entry_user_permissions_on_get_full_size; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_entry_user_permissions_on_get_full_size ON media_entry_user_permissions USING btree (get_full_size);


--
-- Name: index_media_entry_user_permissions_on_get_metadata_and_previews; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_entry_user_permissions_on_get_metadata_and_previews ON media_entry_user_permissions USING btree (get_metadata_and_previews);


--
-- Name: index_media_entry_user_permissions_on_media_entry_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_entry_user_permissions_on_media_entry_id ON media_entry_user_permissions USING btree (media_entry_id);


--
-- Name: index_media_entry_user_permissions_on_updator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_entry_user_permissions_on_updator_id ON media_entry_user_permissions USING btree (updator_id);


--
-- Name: index_media_entry_user_permissions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_entry_user_permissions_on_user_id ON media_entry_user_permissions USING btree (user_id);


--
-- Name: index_media_files_on_extension; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_files_on_extension ON media_files USING btree (extension);


--
-- Name: index_media_files_on_media_entry_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_files_on_media_entry_id ON media_files USING btree (media_entry_id);


--
-- Name: index_media_files_on_media_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_files_on_media_type ON media_files USING btree (media_type);


--
-- Name: index_media_resources_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_resources_on_created_at ON media_resources USING btree (created_at);


--
-- Name: index_media_resources_on_previous_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_resources_on_previous_id ON media_resources USING btree (previous_id);


--
-- Name: index_media_resources_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_resources_on_type ON media_resources USING btree (type);


--
-- Name: index_media_resources_on_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_resources_on_updated_at ON media_resources USING btree (updated_at);


--
-- Name: index_meta_data_institutional_groups; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_data_institutional_groups ON meta_data_groups USING btree (meta_datum_id, group_id);


--
-- Name: index_meta_data_meta_terms_on_meta_datum_id_and_meta_term_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_data_meta_terms_on_meta_datum_id_and_meta_term_id ON meta_data_meta_terms USING btree (meta_datum_id, meta_term_id);


--
-- Name: index_meta_data_on_collection_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_data_on_collection_id ON meta_data USING btree (collection_id);


--
-- Name: index_meta_data_on_filter_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_data_on_filter_set_id ON meta_data USING btree (filter_set_id);


--
-- Name: index_meta_data_on_media_entry_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_data_on_media_entry_id ON meta_data USING btree (media_entry_id);


--
-- Name: index_meta_data_on_meta_key_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_data_on_meta_key_id ON meta_data USING btree (meta_key_id);


--
-- Name: index_meta_data_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_data_on_type ON meta_data USING btree (type);


--
-- Name: index_meta_data_people_on_meta_datum_id_and_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_data_people_on_meta_datum_id_and_person_id ON meta_data_people USING btree (meta_datum_id, person_id);


--
-- Name: index_meta_data_users_on_meta_datum_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_data_users_on_meta_datum_id_and_user_id ON meta_data_users USING btree (meta_datum_id, user_id);


--
-- Name: index_meta_data_vocables_on_meta_datum_id_and_vocable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_data_vocables_on_meta_datum_id_and_vocable_id ON meta_data_vocables USING btree (meta_datum_id, vocable_id);


--
-- Name: index_meta_data_vocables_on_vocable_id_and_meta_datum_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_data_vocables_on_vocable_id_and_meta_datum_id ON meta_data_vocables USING btree (vocable_id, meta_datum_id);


--
-- Name: index_people_on_bunch?; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX "index_people_on_bunch?" ON people USING btree ("bunch?");


--
-- Name: index_people_on_first_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_first_name ON people USING btree (first_name);


--
-- Name: index_people_on_last_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_last_name ON people USING btree (last_name);


--
-- Name: index_previews_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_previews_on_created_at ON previews USING btree (created_at);


--
-- Name: index_previews_on_media_file_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_previews_on_media_file_id ON previews USING btree (media_file_id);


--
-- Name: index_previews_on_media_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_previews_on_media_type ON previews USING btree (media_type);


--
-- Name: index_users_on_autocomplete; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_autocomplete ON users USING btree (autocomplete);


--
-- Name: index_users_on_login; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_login ON users USING btree (login);


--
-- Name: index_users_on_zhdkid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_zhdkid ON users USING btree (zhdkid);


--
-- Name: index_vocables_on_meta_key_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_vocables_on_meta_key_id ON vocables USING btree (meta_key_id);


--
-- Name: index_zencoder_jobs_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_zencoder_jobs_on_created_at ON zencoder_jobs USING btree (created_at);


--
-- Name: index_zencoder_jobs_on_media_file_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_zencoder_jobs_on_media_file_id ON zencoder_jobs USING btree (media_file_id);


--
-- Name: keyword_terms_term_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX keyword_terms_term_idx ON keyword_terms USING gin (term gin_trgm_ops);


--
-- Name: keyword_terms_to_tsvector_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX keyword_terms_to_tsvector_idx ON keyword_terms USING gin (to_tsvector('english'::regconfig, (term)::text));


--
-- Name: people_searchable_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX people_searchable_idx ON people USING gin (searchable gin_trgm_ops);


--
-- Name: people_to_tsvector_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX people_to_tsvector_idx ON people USING gin (to_tsvector('english'::regconfig, searchable));


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: users_to_tsvector_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX users_to_tsvector_idx ON users USING gin (to_tsvector('english'::regconfig, searchable));


--
-- Name: users_trgm_searchable_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX users_trgm_searchable_idx ON users USING gin (trgm_searchable gin_trgm_ops);


--
-- Name: trigger_madek_core_meta_key_immutability; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_madek_core_meta_key_immutability AFTER INSERT OR DELETE OR UPDATE ON meta_keys DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE check_madek_core_meta_key_immutability();


--
-- Name: trigger_meta_data_meta_key_type_consistency; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_meta_data_meta_key_type_consistency AFTER INSERT OR UPDATE ON meta_data DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE check_meta_data_meta_key_type_consistency();


--
-- Name: trigger_meta_key_meta_data_type_consistency; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_meta_key_meta_data_type_consistency AFTER INSERT OR UPDATE ON meta_keys DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE check_meta_key_meta_data_type_consistency();


--
-- Name: fk_rails_021108619d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_collection_arcs
    ADD CONSTRAINT fk_rails_021108619d FOREIGN KEY (parent_id) REFERENCES collections(id) ON DELETE CASCADE;


--
-- Name: fk_rails_083aa47d74; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_entry_api_client_permissions
    ADD CONSTRAINT fk_rails_083aa47d74 FOREIGN KEY (updator_id) REFERENCES users(id);


--
-- Name: fk_rails_09d340ddf4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vocables
    ADD CONSTRAINT fk_rails_09d340ddf4 FOREIGN KEY (meta_key_id) REFERENCES meta_keys(id) ON DELETE CASCADE;


--
-- Name: fk_rails_1a7b964354; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY edit_sessions
    ADD CONSTRAINT fk_rails_1a7b964354 FOREIGN KEY (collection_id) REFERENCES collections(id);


--
-- Name: fk_rails_1c12af797a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vocabulary_group_permissions
    ADD CONSTRAINT fk_rails_1c12af797a FOREIGN KEY (vocabulary_id) REFERENCES vocabularies(id) ON DELETE CASCADE;


--
-- Name: fk_rails_1c3d9422fe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data_vocables
    ADD CONSTRAINT fk_rails_1c3d9422fe FOREIGN KEY (meta_datum_id) REFERENCES meta_data(id) ON DELETE CASCADE;


--
-- Name: fk_rails_2243e0b445; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY custom_urls
    ADD CONSTRAINT fk_rails_2243e0b445 FOREIGN KEY (media_resource_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: fk_rails_2e91ac581d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY custom_urls
    ADD CONSTRAINT fk_rails_2e91ac581d FOREIGN KEY (creator_id) REFERENCES users(id);


--
-- Name: fk_rails_2f39d2f50b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data_users
    ADD CONSTRAINT fk_rails_2f39d2f50b FOREIGN KEY (meta_datum_id) REFERENCES meta_data(id) ON DELETE CASCADE;


--
-- Name: fk_rails_2fd2dfae2a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_entry_group_permissions
    ADD CONSTRAINT fk_rails_2fd2dfae2a FOREIGN KEY (media_entry_id) REFERENCES media_entries(id) ON DELETE CASCADE;


--
-- Name: fk_rails_34917dcbdc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_api_client_permissions
    ADD CONSTRAINT fk_rails_34917dcbdc FOREIGN KEY (collection_id) REFERENCES collections(id) ON DELETE CASCADE;


--
-- Name: fk_rails_3871e81126; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_media_entry_arcs
    ADD CONSTRAINT fk_rails_3871e81126 FOREIGN KEY (media_entry_id) REFERENCES media_entries(id) ON DELETE CASCADE;


--
-- Name: fk_rails_3a2226a59b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filter_sets
    ADD CONSTRAINT fk_rails_3a2226a59b FOREIGN KEY (responsible_user_id) REFERENCES users(id);


--
-- Name: fk_rails_3ea68635ea; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filter_set_user_permissions
    ADD CONSTRAINT fk_rails_3ea68635ea FOREIGN KEY (updator_id) REFERENCES users(id);


--
-- Name: fk_rails_433bbdf822; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_group_permissions
    ADD CONSTRAINT fk_rails_433bbdf822 FOREIGN KEY (collection_id) REFERENCES collections(id) ON DELETE CASCADE;


--
-- Name: fk_rails_4645b13096; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data
    ADD CONSTRAINT fk_rails_4645b13096 FOREIGN KEY (filter_set_id) REFERENCES filter_sets(id);


--
-- Name: fk_rails_46467a43dc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY zencoder_jobs
    ADD CONSTRAINT fk_rails_46467a43dc FOREIGN KEY (media_file_id) REFERENCES media_files(id);


--
-- Name: fk_rails_46992e4997; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_collection_arcs
    ADD CONSTRAINT fk_rails_46992e4997 FOREIGN KEY (child_id) REFERENCES collections(id) ON DELETE CASCADE;


--
-- Name: fk_rails_49ee113f49; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorite_filter_sets
    ADD CONSTRAINT fk_rails_49ee113f49 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_rails_4ad83bee2d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_group_permissions
    ADD CONSTRAINT fk_rails_4ad83bee2d FOREIGN KEY (updator_id) REFERENCES users(id);


--
-- Name: fk_rails_4e63edbd27; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups_users
    ADD CONSTRAINT fk_rails_4e63edbd27 FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE;


--
-- Name: fk_rails_4fd8dafc83; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vocabulary_api_client_permissions
    ADD CONSTRAINT fk_rails_4fd8dafc83 FOREIGN KEY (api_client_id) REFERENCES api_clients(id) ON DELETE CASCADE;


--
-- Name: fk_rails_524339166d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_entry_api_client_permissions
    ADD CONSTRAINT fk_rails_524339166d FOREIGN KEY (media_entry_id) REFERENCES media_entries(id) ON DELETE CASCADE;


--
-- Name: fk_rails_531b44ea0a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_user_permissions
    ADD CONSTRAINT fk_rails_531b44ea0a FOREIGN KEY (collection_id) REFERENCES collections(id) ON DELETE CASCADE;


--
-- Name: fk_rails_58d285f632; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_files
    ADD CONSTRAINT fk_rails_58d285f632 FOREIGN KEY (uploader_id) REFERENCES users(id);


--
-- Name: fk_rails_595a6061d7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorite_media_entries
    ADD CONSTRAINT fk_rails_595a6061d7 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_rails_5ad0794348; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vocabulary_api_client_permissions
    ADD CONSTRAINT fk_rails_5ad0794348 FOREIGN KEY (vocabulary_id) REFERENCES vocabularies(id) ON DELETE CASCADE;


--
-- Name: fk_rails_5b1ae50915; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_filter_set_arcs
    ADD CONSTRAINT fk_rails_5b1ae50915 FOREIGN KEY (filter_set_id) REFERENCES filter_sets(id) ON DELETE CASCADE;


--
-- Name: fk_rails_64d68dff28; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filter_set_api_client_permissions
    ADD CONSTRAINT fk_rails_64d68dff28 FOREIGN KEY (api_client_id) REFERENCES api_clients(id) ON DELETE CASCADE;


--
-- Name: fk_rails_685b83c003; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorite_collections
    ADD CONSTRAINT fk_rails_685b83c003 FOREIGN KEY (collection_id) REFERENCES collections(id) ON DELETE CASCADE;


--
-- Name: fk_rails_6946aceec2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data_users
    ADD CONSTRAINT fk_rails_6946aceec2 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_rails_6a03c000b5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data_people
    ADD CONSTRAINT fk_rails_6a03c000b5 FOREIGN KEY (meta_datum_id) REFERENCES meta_data(id) ON DELETE CASCADE;


--
-- Name: fk_rails_6ad9b754cf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vocabulary_user_permissions
    ADD CONSTRAINT fk_rails_6ad9b754cf FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_rails_7096ea001b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data_vocables
    ADD CONSTRAINT fk_rails_7096ea001b FOREIGN KEY (vocable_id) REFERENCES vocables(id) ON DELETE CASCADE;


--
-- Name: fk_rails_71939571b2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filter_set_group_permissions
    ADD CONSTRAINT fk_rails_71939571b2 FOREIGN KEY (updator_id) REFERENCES users(id);


--
-- Name: fk_rails_7318531d65; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_entry_user_permissions
    ADD CONSTRAINT fk_rails_7318531d65 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_rails_74807b1b58; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY custom_urls
    ADD CONSTRAINT fk_rails_74807b1b58 FOREIGN KEY (updator_id) REFERENCES users(id);


--
-- Name: fk_rails_7c05d4af6f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filter_set_api_client_permissions
    ADD CONSTRAINT fk_rails_7c05d4af6f FOREIGN KEY (updator_id) REFERENCES users(id);


--
-- Name: fk_rails_7e222bf0d7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data_groups
    ADD CONSTRAINT fk_rails_7e222bf0d7 FOREIGN KEY (meta_datum_id) REFERENCES meta_data(id) ON DELETE CASCADE;


--
-- Name: fk_rails_7fe28f5997; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorite_collections
    ADD CONSTRAINT fk_rails_7fe28f5997 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_rails_8125d6f8b2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_user_permissions
    ADD CONSTRAINT fk_rails_8125d6f8b2 FOREIGN KEY (updator_id) REFERENCES users(id);


--
-- Name: fk_rails_8546c71994; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups_users
    ADD CONSTRAINT fk_rails_8546c71994 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_rails_8550647b84; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vocabulary_group_permissions
    ADD CONSTRAINT fk_rails_8550647b84 FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE;


--
-- Name: fk_rails_8612581b4b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data
    ADD CONSTRAINT fk_rails_8612581b4b FOREIGN KEY (collection_id) REFERENCES collections(id);


--
-- Name: fk_rails_8b2fc8e9de; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_filter_set_arcs
    ADD CONSTRAINT fk_rails_8b2fc8e9de FOREIGN KEY (collection_id) REFERENCES collections(id) ON DELETE CASCADE;


--
-- Name: fk_rails_8c14de08ae; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_api_client_permissions
    ADD CONSTRAINT fk_rails_8c14de08ae FOREIGN KEY (updator_id) REFERENCES users(id);


--
-- Name: fk_rails_8f6c176911; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY full_texts
    ADD CONSTRAINT fk_rails_8f6c176911 FOREIGN KEY (media_resource_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: fk_rails_8f830fb7e7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_user_permissions
    ADD CONSTRAINT fk_rails_8f830fb7e7 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_rails_8f99b491cc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY licenses_license_groups
    ADD CONSTRAINT fk_rails_8f99b491cc FOREIGN KEY (license_id) REFERENCES licenses(id);


--
-- Name: fk_rails_9108dab9f9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_settings
    ADD CONSTRAINT fk_rails_9108dab9f9 FOREIGN KEY (catalog_set_id) REFERENCES media_resources(id);


--
-- Name: fk_rails_930a52954c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_entries
    ADD CONSTRAINT fk_rails_930a52954c FOREIGN KEY (creator_id) REFERENCES users(id);


--
-- Name: fk_rails_9913a1efdb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY edit_sessions
    ADD CONSTRAINT fk_rails_9913a1efdb FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_rails_99d0e1d0c1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_entries
    ADD CONSTRAINT fk_rails_99d0e1d0c1 FOREIGN KEY (responsible_user_id) REFERENCES users(id);


--
-- Name: fk_rails_9c891d2878; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_entry_group_permissions
    ADD CONSTRAINT fk_rails_9c891d2878 FOREIGN KEY (updator_id) REFERENCES users(id);


--
-- Name: fk_rails_9cf683b9d3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filter_set_group_permissions
    ADD CONSTRAINT fk_rails_9cf683b9d3 FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE;


--
-- Name: fk_rails_9cf968d59e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filter_set_api_client_permissions
    ADD CONSTRAINT fk_rails_9cf968d59e FOREIGN KEY (filter_set_id) REFERENCES filter_sets(id) ON DELETE CASCADE;


--
-- Name: fk_rails_9f34e90b35; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_settings
    ADD CONSTRAINT fk_rails_9f34e90b35 FOREIGN KEY (splashscreen_slideshow_set_id) REFERENCES media_resources(id);


--
-- Name: fk_rails_a322627641; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_keys
    ADD CONSTRAINT fk_rails_a322627641 FOREIGN KEY (vocabulary_id) REFERENCES vocabularies(id) ON DELETE CASCADE;


--
-- Name: fk_rails_a3de285f9a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY visualizations
    ADD CONSTRAINT fk_rails_a3de285f9a FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_a6a8d89e10; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY previews
    ADD CONSTRAINT fk_rails_a6a8d89e10 FOREIGN KEY (media_file_id) REFERENCES media_files(id) ON DELETE CASCADE;


--
-- Name: fk_rails_aa0acbbdd1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_entry_api_client_permissions
    ADD CONSTRAINT fk_rails_aa0acbbdd1 FOREIGN KEY (api_client_id) REFERENCES api_clients(id) ON DELETE CASCADE;


--
-- Name: fk_rails_ab2fec83b3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collections
    ADD CONSTRAINT fk_rails_ab2fec83b3 FOREIGN KEY (creator_id) REFERENCES users(id);


--
-- Name: fk_rails_abdcca9411; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data_people
    ADD CONSTRAINT fk_rails_abdcca9411 FOREIGN KEY (person_id) REFERENCES people(id);


--
-- Name: fk_rails_ad6ea85fe1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_media_entry_arcs
    ADD CONSTRAINT fk_rails_ad6ea85fe1 FOREIGN KEY (collection_id) REFERENCES collections(id) ON DELETE CASCADE;


--
-- Name: fk_rails_ad94405e98; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data_groups
    ADD CONSTRAINT fk_rails_ad94405e98 FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE;


--
-- Name: fk_rails_b11487c786; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_files
    ADD CONSTRAINT fk_rails_b11487c786 FOREIGN KEY (media_entry_id) REFERENCES media_entries(id);


--
-- Name: fk_rails_b33ac1a17a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_entry_user_permissions
    ADD CONSTRAINT fk_rails_b33ac1a17a FOREIGN KEY (updator_id) REFERENCES users(id);


--
-- Name: fk_rails_b88fcbe505; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_group_permissions
    ADD CONSTRAINT fk_rails_b88fcbe505 FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE;


--
-- Name: fk_rails_c2f0aa5d1d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY keywords
    ADD CONSTRAINT fk_rails_c2f0aa5d1d FOREIGN KEY (keyword_term_id) REFERENCES keyword_terms(id);


--
-- Name: fk_rails_c316f79bb2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY licenses_license_groups
    ADD CONSTRAINT fk_rails_c316f79bb2 FOREIGN KEY (license_group_id) REFERENCES license_groups(id);


--
-- Name: fk_rails_c40753f126; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_settings
    ADD CONSTRAINT fk_rails_c40753f126 FOREIGN KEY (featured_set_id) REFERENCES media_resources(id);


--
-- Name: fk_rails_c4f75db4e4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY admins
    ADD CONSTRAINT fk_rails_c4f75db4e4 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: fk_rails_c5e91a50bb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_entry_group_permissions
    ADD CONSTRAINT fk_rails_c5e91a50bb FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE;


--
-- Name: fk_rails_c851051238; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filter_set_user_permissions
    ADD CONSTRAINT fk_rails_c851051238 FOREIGN KEY (filter_set_id) REFERENCES filter_sets(id) ON DELETE CASCADE;


--
-- Name: fk_rails_cfa3a95f8a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY keywords
    ADD CONSTRAINT fk_rails_cfa3a95f8a FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_d1a462521d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_api_client_permissions
    ADD CONSTRAINT fk_rails_d1a462521d FOREIGN KEY (api_client_id) REFERENCES api_clients(id) ON DELETE CASCADE;


--
-- Name: fk_rails_d5fff4f64b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vocabulary_user_permissions
    ADD CONSTRAINT fk_rails_d5fff4f64b FOREIGN KEY (vocabulary_id) REFERENCES vocabularies(id) ON DELETE CASCADE;


--
-- Name: fk_rails_d61bb0f3a0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filter_sets
    ADD CONSTRAINT fk_rails_d61bb0f3a0 FOREIGN KEY (creator_id) REFERENCES users(id);


--
-- Name: fk_rails_d8ad23759a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY edit_sessions
    ADD CONSTRAINT fk_rails_d8ad23759a FOREIGN KEY (filter_set_id) REFERENCES filter_sets(id);


--
-- Name: fk_rails_dbf6e7c067; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY io_mappings
    ADD CONSTRAINT fk_rails_dbf6e7c067 FOREIGN KEY (meta_key_id) REFERENCES meta_keys(id) ON DELETE CASCADE;


--
-- Name: fk_rails_dcd8dcb691; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY edit_sessions
    ADD CONSTRAINT fk_rails_dcd8dcb691 FOREIGN KEY (media_entry_id) REFERENCES media_entries(id);


--
-- Name: fk_rails_e8716e273a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data
    ADD CONSTRAINT fk_rails_e8716e273a FOREIGN KEY (media_entry_id) REFERENCES media_entries(id);


--
-- Name: fk_rails_ec0e750894; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_entry_user_permissions
    ADD CONSTRAINT fk_rails_ec0e750894 FOREIGN KEY (media_entry_id) REFERENCES media_entries(id) ON DELETE CASCADE;


--
-- Name: fk_rails_ee76aad01f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data
    ADD CONSTRAINT fk_rails_ee76aad01f FOREIGN KEY (meta_key_id) REFERENCES meta_keys(id) ON DELETE CASCADE;


--
-- Name: fk_rails_ef9a87f15d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data_meta_terms
    ADD CONSTRAINT fk_rails_ef9a87f15d FOREIGN KEY (meta_datum_id) REFERENCES meta_data(id) ON DELETE CASCADE;


--
-- Name: fk_rails_f0283cbd2e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data
    ADD CONSTRAINT fk_rails_f0283cbd2e FOREIGN KEY (license_id) REFERENCES licenses(id);


--
-- Name: fk_rails_f4bde348c0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY io_mappings
    ADD CONSTRAINT fk_rails_f4bde348c0 FOREIGN KEY (io_interface_id) REFERENCES io_interfaces(id) ON DELETE CASCADE;


--
-- Name: fk_rails_f9e38c9615; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorite_filter_sets
    ADD CONSTRAINT fk_rails_f9e38c9615 FOREIGN KEY (filter_set_id) REFERENCES filter_sets(id) ON DELETE CASCADE;


--
-- Name: fk_rails_fa67535741; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_rails_fa67535741 FOREIGN KEY (person_id) REFERENCES people(id);


--
-- Name: fk_rails_fa9caa5c0a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorite_media_entries
    ADD CONSTRAINT fk_rails_fa9caa5c0a FOREIGN KEY (media_entry_id) REFERENCES media_entries(id) ON DELETE CASCADE;


--
-- Name: fk_rails_fbfc88b929; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY keywords
    ADD CONSTRAINT fk_rails_fbfc88b929 FOREIGN KEY (meta_datum_id) REFERENCES meta_data(id) ON DELETE CASCADE;


--
-- Name: fk_rails_fc47629db9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filter_set_group_permissions
    ADD CONSTRAINT fk_rails_fc47629db9 FOREIGN KEY (filter_set_id) REFERENCES filter_sets(id) ON DELETE CASCADE;


--
-- Name: fk_rails_fce65666e9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collections
    ADD CONSTRAINT fk_rails_fce65666e9 FOREIGN KEY (responsible_user_id) REFERENCES users(id);


--
-- Name: fk_rails_fe38b294ce; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filter_set_user_permissions
    ADD CONSTRAINT fk_rails_fe38b294ce FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY license_groups
    ADD CONSTRAINT parent_id_fkey FOREIGN KEY (parent_id) REFERENCES license_groups(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('0');

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('100');

INSERT INTO schema_migrations (version) VALUES ('101');

INSERT INTO schema_migrations (version) VALUES ('102');

INSERT INTO schema_migrations (version) VALUES ('103');

INSERT INTO schema_migrations (version) VALUES ('104');

INSERT INTO schema_migrations (version) VALUES ('105');

INSERT INTO schema_migrations (version) VALUES ('107');

INSERT INTO schema_migrations (version) VALUES ('108');

INSERT INTO schema_migrations (version) VALUES ('109');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('110');

INSERT INTO schema_migrations (version) VALUES ('111');

INSERT INTO schema_migrations (version) VALUES ('112');

INSERT INTO schema_migrations (version) VALUES ('113');

INSERT INTO schema_migrations (version) VALUES ('114');

INSERT INTO schema_migrations (version) VALUES ('115');

INSERT INTO schema_migrations (version) VALUES ('117');

INSERT INTO schema_migrations (version) VALUES ('118');

INSERT INTO schema_migrations (version) VALUES ('119');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('120');

INSERT INTO schema_migrations (version) VALUES ('121');

INSERT INTO schema_migrations (version) VALUES ('122');

INSERT INTO schema_migrations (version) VALUES ('123');

INSERT INTO schema_migrations (version) VALUES ('124');

INSERT INTO schema_migrations (version) VALUES ('125');

INSERT INTO schema_migrations (version) VALUES ('126');

INSERT INTO schema_migrations (version) VALUES ('127');

INSERT INTO schema_migrations (version) VALUES ('128');

INSERT INTO schema_migrations (version) VALUES ('129');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('130');

INSERT INTO schema_migrations (version) VALUES ('131');

INSERT INTO schema_migrations (version) VALUES ('132');

INSERT INTO schema_migrations (version) VALUES ('133');

INSERT INTO schema_migrations (version) VALUES ('134');

INSERT INTO schema_migrations (version) VALUES ('135');

INSERT INTO schema_migrations (version) VALUES ('136');

INSERT INTO schema_migrations (version) VALUES ('137');

INSERT INTO schema_migrations (version) VALUES ('138');

INSERT INTO schema_migrations (version) VALUES ('139');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('140');

INSERT INTO schema_migrations (version) VALUES ('141');

INSERT INTO schema_migrations (version) VALUES ('142');

INSERT INTO schema_migrations (version) VALUES ('143');

INSERT INTO schema_migrations (version) VALUES ('144');

INSERT INTO schema_migrations (version) VALUES ('145');

INSERT INTO schema_migrations (version) VALUES ('146');

INSERT INTO schema_migrations (version) VALUES ('147');

INSERT INTO schema_migrations (version) VALUES ('148');

INSERT INTO schema_migrations (version) VALUES ('149');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('150');

INSERT INTO schema_migrations (version) VALUES ('151');

INSERT INTO schema_migrations (version) VALUES ('153');

INSERT INTO schema_migrations (version) VALUES ('154');

INSERT INTO schema_migrations (version) VALUES ('16');

INSERT INTO schema_migrations (version) VALUES ('165');

INSERT INTO schema_migrations (version) VALUES ('166');

INSERT INTO schema_migrations (version) VALUES ('167');

INSERT INTO schema_migrations (version) VALUES ('168');

INSERT INTO schema_migrations (version) VALUES ('169');

INSERT INTO schema_migrations (version) VALUES ('17');

INSERT INTO schema_migrations (version) VALUES ('170');

INSERT INTO schema_migrations (version) VALUES ('171');

INSERT INTO schema_migrations (version) VALUES ('18');

INSERT INTO schema_migrations (version) VALUES ('19');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('20');

INSERT INTO schema_migrations (version) VALUES ('21');

INSERT INTO schema_migrations (version) VALUES ('22');

INSERT INTO schema_migrations (version) VALUES ('23');

INSERT INTO schema_migrations (version) VALUES ('24');

INSERT INTO schema_migrations (version) VALUES ('25');

INSERT INTO schema_migrations (version) VALUES ('26');

INSERT INTO schema_migrations (version) VALUES ('27');

INSERT INTO schema_migrations (version) VALUES ('28');

INSERT INTO schema_migrations (version) VALUES ('29');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('30');

INSERT INTO schema_migrations (version) VALUES ('31');

INSERT INTO schema_migrations (version) VALUES ('32');

INSERT INTO schema_migrations (version) VALUES ('33');

INSERT INTO schema_migrations (version) VALUES ('34');

INSERT INTO schema_migrations (version) VALUES ('35');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('9');

