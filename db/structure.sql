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

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE admin_users (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL
);


--
-- Name: app_settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE app_settings (
    id integer NOT NULL,
    title character varying(255),
    support_url character varying(255),
    welcome_title character varying(255),
    welcome_subtitle character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    logo_url character varying(255) DEFAULT '/assets/inserts/image-logo-zhdk.png'::character varying NOT NULL,
    brand character varying(255) DEFAULT 'Zürcher Hochschule der Künste'::character varying NOT NULL,
    footer_links text,
    second_displayed_context_id character varying(255),
    third_displayed_context_id character varying(255),
    catalog_set_id uuid,
    featured_set_id uuid,
    teaser_set_id uuid,
    CONSTRAINT oneandonly CHECK ((id = 0))
);


--
-- Name: applicationpermissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE applicationpermissions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    media_resource_id uuid NOT NULL,
    application_id character varying(255) NOT NULL,
    download boolean DEFAULT false NOT NULL,
    edit boolean DEFAULT false NOT NULL,
    manage boolean DEFAULT false NOT NULL,
    view boolean DEFAULT false NOT NULL,
    CONSTRAINT edit_on_applicationpermissions_is_false CHECK ((edit = false)),
    CONSTRAINT manage_on_applicationpermissions_is_false CHECK ((manage = false))
);


--
-- Name: applications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE applications (
    user_id uuid NOT NULL,
    id character varying(255) NOT NULL,
    description text,
    secret uuid DEFAULT uuid_generate_v4()
);


--
-- Name: context_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE context_groups (
    name character varying(255),
    "position" integer NOT NULL,
    id uuid DEFAULT uuid_generate_v4() NOT NULL
);


--
-- Name: contexts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contexts (
    "position" integer,
    id character varying(255) NOT NULL,
    context_group_id uuid,
    label text DEFAULT ''::text NOT NULL,
    description text DEFAULT ''::text NOT NULL
);


--
-- Name: copyrights; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE copyrights (
    is_default boolean DEFAULT false,
    is_custom boolean DEFAULT false,
    label character varying(255),
    usage character varying(255),
    url character varying(255),
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    parent_id uuid,
    "position" double precision
);


--
-- Name: custom_urls; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE custom_urls (
    id character varying(255) NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    media_resource_id uuid NOT NULL,
    creator_id uuid NOT NULL,
    updator_id uuid NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT custom_urls_id_format CHECK (((id)::text ~ '^[a-z][a-z0-9\-\_]+$'::text)),
    CONSTRAINT custom_urls_id_is_not_uuid CHECK ((NOT ((id)::text ~* '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'::text)))
);


--
-- Name: edit_sessions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE edit_sessions (
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    media_resource_id uuid NOT NULL,
    user_id uuid NOT NULL,
    id uuid DEFAULT uuid_generate_v4() NOT NULL
);


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites (
    media_resource_id uuid NOT NULL,
    user_id uuid NOT NULL
);


--
-- Name: full_texts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE full_texts (
    text text,
    media_resource_id uuid NOT NULL
);


--
-- Name: grouppermissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE grouppermissions (
    download boolean DEFAULT false NOT NULL,
    edit boolean DEFAULT false NOT NULL,
    manage boolean DEFAULT false NOT NULL,
    view boolean DEFAULT false NOT NULL,
    media_resource_id uuid NOT NULL,
    group_id uuid NOT NULL,
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    CONSTRAINT manage_on_grouppermissions_is_false CHECK ((manage = false))
);


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE groups (
    name character varying(255),
    institutional_group_id character varying(255),
    institutional_group_name character varying(255),
    type character varying(255) DEFAULT 'Group'::character varying NOT NULL,
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    previous_id integer,
    searchable text DEFAULT ''::text NOT NULL,
    users_count integer DEFAULT 0 NOT NULL
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
    id character varying(255) NOT NULL,
    description character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: io_mappings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE io_mappings (
    io_interface_id character varying(255) NOT NULL,
    meta_key_id character varying(255) NOT NULL,
    key_map character varying(255),
    key_map_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: keyword_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE keyword_terms (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    term character varying(255) DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_id uuid
);


--
-- Name: keywords; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE keywords (
    created_at timestamp without time zone,
    user_id uuid,
    meta_datum_id uuid NOT NULL,
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    keyword_term_id uuid NOT NULL
);


--
-- Name: media_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_files (
    height integer,
    size bigint,
    width integer,
    content_type character varying(255) NOT NULL,
    filename character varying(255),
    guid character varying(255),
    access_hash text,
    meta_data text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    extension character varying(255),
    media_type character varying(255) NOT NULL,
    media_entry_id uuid,
    id uuid DEFAULT uuid_generate_v4() NOT NULL
);


--
-- Name: media_resource_arcs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_resource_arcs (
    highlight boolean DEFAULT false,
    cover boolean,
    child_id uuid NOT NULL,
    parent_id uuid NOT NULL,
    id uuid DEFAULT uuid_generate_v4() NOT NULL
);


--
-- Name: media_resources; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_resources (
    previous_id integer,
    download boolean DEFAULT false NOT NULL,
    edit boolean DEFAULT false NOT NULL,
    manage boolean DEFAULT false NOT NULL,
    view boolean DEFAULT false NOT NULL,
    settings text,
    type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    CONSTRAINT edit_on_publicpermissions_is_false CHECK ((edit = false)),
    CONSTRAINT manage_on_publicpermissions_is_false CHECK ((manage = false))
);


--
-- Name: media_sets_contexts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_sets_contexts (
    context_id character varying(255),
    media_set_id uuid NOT NULL
);


--
-- Name: meta_data; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_data (
    type character varying(255),
    string text,
    meta_key_id character varying(255),
    media_resource_id uuid NOT NULL,
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    copyright_id uuid
);


--
-- Name: meta_data_institutional_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_data_institutional_groups (
    institutional_group_id uuid NOT NULL,
    meta_datum_id uuid NOT NULL
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
    person_id uuid NOT NULL,
    meta_datum_id uuid NOT NULL
);


--
-- Name: meta_data_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_data_users (
    user_id uuid NOT NULL,
    meta_datum_id uuid NOT NULL
);


--
-- Name: meta_key_definitions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_key_definitions (
    is_required boolean DEFAULT false,
    length_max integer,
    length_min integer,
    "position" integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    meta_key_id character varying(255),
    context_id character varying(255),
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    label text DEFAULT ''::text NOT NULL,
    hint text DEFAULT ''::text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    input_type integer
);


--
-- Name: meta_keys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_keys (
    is_extensible_list boolean,
    id character varying(255) NOT NULL,
    meta_datum_object_type character varying(255) DEFAULT 'MetaDatumString'::character varying NOT NULL,
    meta_terms_alphabetical_order boolean DEFAULT true
);


--
-- Name: meta_keys_meta_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_keys_meta_terms (
    "position" integer DEFAULT 0 NOT NULL,
    meta_key_id character varying(255),
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    meta_term_id uuid
);


--
-- Name: meta_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_terms (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    term text DEFAULT ''::text NOT NULL
);


--
-- Name: people; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE people (
    is_group boolean DEFAULT false,
    date_of_birth date,
    date_of_death date,
    first_name character varying(255),
    last_name character varying(255),
    pseudonym character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    searchable text DEFAULT ''::text NOT NULL
);


--
-- Name: permission_presets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE permission_presets (
    name character varying(255),
    download boolean DEFAULT false NOT NULL,
    edit boolean DEFAULT false NOT NULL,
    manage boolean DEFAULT false NOT NULL,
    view boolean DEFAULT false NOT NULL,
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "position" double precision
);


--
-- Name: previews; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE previews (
    height integer,
    width integer,
    content_type character varying(255) NOT NULL,
    filename character varying(255),
    thumbnail character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    media_file_id uuid NOT NULL,
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    media_type character varying(255) NOT NULL
);


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
    title character varying(255),
    version character varying(255),
    intro text,
    body text,
    updated_at timestamp without time zone,
    id uuid DEFAULT uuid_generate_v4() NOT NULL
);


--
-- Name: user_resources_counts; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW user_resources_counts AS
 SELECT count(*) AS resouces_count,
    media_resources.user_id
   FROM media_resources
  GROUP BY media_resources.user_id;


--
-- Name: userpermissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE userpermissions (
    download boolean DEFAULT false NOT NULL,
    edit boolean DEFAULT false NOT NULL,
    manage boolean DEFAULT false NOT NULL,
    view boolean DEFAULT false NOT NULL,
    media_resource_id uuid NOT NULL,
    user_id uuid NOT NULL,
    id uuid DEFAULT uuid_generate_v4() NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    zhdkid integer,
    email character varying(255) NOT NULL,
    login text NOT NULL,
    notes text,
    usage_terms_accepted_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    password_digest character varying(255),
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    previous_id integer,
    person_id uuid NOT NULL,
    searchable text DEFAULT ''::text NOT NULL,
    trgm_searchable text DEFAULT ''::text NOT NULL,
    autocomplete character varying(255) DEFAULT ''::character varying NOT NULL,
    contrast_mode boolean DEFAULT false NOT NULL,
    CONSTRAINT users_login_simple CHECK ((login ~* '^[a-z0-9\.\-\_]+$'::text))
);


--
-- Name: visualizations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE visualizations (
    resource_identifier character varying(255) NOT NULL,
    control_settings text,
    layout text,
    user_id uuid NOT NULL,
    id uuid DEFAULT uuid_generate_v4() NOT NULL
);


--
-- Name: zencoder_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE zencoder_jobs (
    id uuid NOT NULL,
    zencoder_id integer,
    comment text,
    state character varying(255) DEFAULT 'initialized'::character varying NOT NULL,
    error text,
    notification text,
    request text,
    response text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    media_file_id uuid NOT NULL
);


--
-- Name: admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: app_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY app_settings
    ADD CONSTRAINT app_settings_pkey PRIMARY KEY (id);


--
-- Name: applicationpermissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY applicationpermissions
    ADD CONSTRAINT applicationpermissions_pkey PRIMARY KEY (id);


--
-- Name: applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY applications
    ADD CONSTRAINT applications_pkey PRIMARY KEY (id);


--
-- Name: copyrights_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY copyrights
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
-- Name: full_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY full_texts
    ADD CONSTRAINT full_texts_pkey PRIMARY KEY (media_resource_id);


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
-- Name: io_interfaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY io_interfaces
    ADD CONSTRAINT io_interfaces_pkey PRIMARY KEY (id);


--
-- Name: io_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY io_mappings
    ADD CONSTRAINT io_mappings_pkey PRIMARY KEY (io_interface_id, meta_key_id);


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

ALTER TABLE ONLY context_groups
    ADD CONSTRAINT meta_context_groups_pkey PRIMARY KEY (id);


--
-- Name: meta_contexts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contexts
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
-- Name: meta_terms_pkey1; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY meta_terms
    ADD CONSTRAINT meta_terms_pkey1 PRIMARY KEY (id);


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
    ADD CONSTRAINT visualizations_pkey PRIMARY KEY (id);


--
-- Name: zencoder_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY zencoder_jobs
    ADD CONSTRAINT zencoder_jobs_pkey PRIMARY KEY (id);


--
-- Name: groups_searchable_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX groups_searchable_idx ON groups USING gin (searchable gin_trgm_ops);


--
-- Name: groups_to_tsvector_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX groups_to_tsvector_idx ON groups USING gin (to_tsvector('english'::regconfig, searchable));


--
-- Name: idx_bools_unique; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_bools_unique ON permission_presets USING btree (view, edit, download, manage);


--
-- Name: idx_name_unique; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX idx_name_unique ON permission_presets USING btree (name);


--
-- Name: index_admin_users_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_admin_users_on_user_id ON admin_users USING btree (user_id);


--
-- Name: index_app_settings_on_catalog_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_app_settings_on_catalog_set_id ON app_settings USING btree (catalog_set_id);


--
-- Name: index_app_settings_on_featured_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_app_settings_on_featured_set_id ON app_settings USING btree (featured_set_id);


--
-- Name: index_app_settings_on_teaser_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_app_settings_on_teaser_set_id ON app_settings USING btree (teaser_set_id);


--
-- Name: index_applicationpermissions_on_application_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_applicationpermissions_on_application_id ON applicationpermissions USING btree (application_id);


--
-- Name: index_applicationpermissions_on_media_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_applicationpermissions_on_media_resource_id ON applicationpermissions USING btree (media_resource_id);


--
-- Name: index_applicationpermissions_on_mr_id_and_app_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_applicationpermissions_on_mr_id_and_app_id ON applicationpermissions USING btree (media_resource_id, application_id);


--
-- Name: index_context_groups_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_context_groups_on_name ON context_groups USING btree (name);


--
-- Name: index_context_groups_on_position; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_context_groups_on_position ON context_groups USING btree ("position");


--
-- Name: index_contexts_on_context_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contexts_on_context_group_id ON contexts USING btree (context_group_id);


--
-- Name: index_contexts_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_contexts_on_id ON contexts USING btree (id);


--
-- Name: index_contexts_on_position; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contexts_on_position ON contexts USING btree ("position");


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
-- Name: index_edit_sessions_on_media_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_edit_sessions_on_media_resource_id ON edit_sessions USING btree (media_resource_id);


--
-- Name: index_edit_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_edit_sessions_on_user_id ON edit_sessions USING btree (user_id);


--
-- Name: index_favorites_on_media_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_on_media_resource_id ON favorites USING btree (media_resource_id);


--
-- Name: index_favorites_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_on_user_id ON favorites USING btree (user_id);


--
-- Name: index_full_texts_on_media_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_full_texts_on_media_resource_id ON full_texts USING btree (media_resource_id);


--
-- Name: index_grouppermissions_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_grouppermissions_on_group_id ON grouppermissions USING btree (group_id);


--
-- Name: index_grouppermissions_on_media_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_grouppermissions_on_media_resource_id ON grouppermissions USING btree (media_resource_id);


--
-- Name: index_groups_on_institutional_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_on_institutional_group_id ON groups USING btree (institutional_group_id);


--
-- Name: index_groups_on_institutional_group_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_on_institutional_group_name ON groups USING btree (institutional_group_name);


--
-- Name: index_groups_on_previous_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_on_previous_id ON groups USING btree (previous_id);


--
-- Name: index_groups_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_on_type ON groups USING btree (type);


--
-- Name: index_groups_users_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_users_on_group_id ON groups_users USING btree (group_id);


--
-- Name: index_groups_users_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_users_on_user_id ON groups_users USING btree (user_id);


--
-- Name: index_keyword_terms_on_term; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_keyword_terms_on_term ON keyword_terms USING btree (term);


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
-- Name: index_media_resources_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_resources_on_user_id ON media_resources USING btree (user_id);


--
-- Name: index_media_sets_contexts_on_context_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_sets_contexts_on_context_id ON media_sets_contexts USING btree (context_id);


--
-- Name: index_media_sets_contexts_on_media_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_sets_contexts_on_media_set_id ON media_sets_contexts USING btree (media_set_id);


--
-- Name: index_meta_data_institutional_groups_on_institutional_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_data_institutional_groups_on_institutional_group_id ON meta_data_institutional_groups USING btree (institutional_group_id);


--
-- Name: index_meta_data_institutional_groups_on_meta_datum_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_data_institutional_groups_on_meta_datum_id ON meta_data_institutional_groups USING btree (meta_datum_id);


--
-- Name: index_meta_data_meta_dep_on_meta_datum_id_and_meta_dep_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_data_meta_dep_on_meta_datum_id_and_meta_dep_id ON meta_data_institutional_groups USING btree (meta_datum_id, institutional_group_id);


--
-- Name: index_meta_data_meta_terms_on_meta_datum_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_data_meta_terms_on_meta_datum_id ON meta_data_meta_terms USING btree (meta_datum_id);


--
-- Name: index_meta_data_meta_terms_on_meta_term_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_data_meta_terms_on_meta_term_id ON meta_data_meta_terms USING btree (meta_term_id);


--
-- Name: index_meta_data_on_copyright_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_data_on_copyright_id ON meta_data USING btree (copyright_id);


--
-- Name: index_meta_data_on_media_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_data_on_media_resource_id ON meta_data USING btree (media_resource_id);


--
-- Name: index_meta_data_on_media_resource_id_and_meta_key_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_data_on_media_resource_id_and_meta_key_id ON meta_data USING btree (media_resource_id, meta_key_id);


--
-- Name: index_meta_data_on_meta_key_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_data_on_meta_key_id ON meta_data USING btree (meta_key_id);


--
-- Name: index_meta_data_people_on_meta_datum_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_data_people_on_meta_datum_id ON meta_data_people USING btree (meta_datum_id);


--
-- Name: index_meta_data_people_on_meta_datum_id_and_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_data_people_on_meta_datum_id_and_person_id ON meta_data_people USING btree (meta_datum_id, person_id);


--
-- Name: index_meta_data_people_on_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_data_people_on_person_id ON meta_data_people USING btree (person_id);


--
-- Name: index_meta_data_users_on_meta_datum_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_data_users_on_meta_datum_id ON meta_data_users USING btree (meta_datum_id);


--
-- Name: index_meta_data_users_on_meta_datum_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_data_users_on_meta_datum_id_and_user_id ON meta_data_users USING btree (meta_datum_id, user_id);


--
-- Name: index_meta_data_users_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_data_users_on_user_id ON meta_data_users USING btree (user_id);


--
-- Name: index_meta_key_definitions_on_context_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_key_definitions_on_context_id ON meta_key_definitions USING btree (context_id);


--
-- Name: index_meta_key_definitions_on_meta_key_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_key_definitions_on_meta_key_id ON meta_key_definitions USING btree (meta_key_id);


--
-- Name: index_meta_keys_meta_terms_on_meta_key_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_keys_meta_terms_on_meta_key_id ON meta_keys_meta_terms USING btree (meta_key_id);


--
-- Name: index_meta_keys_meta_terms_on_meta_key_id_and_meta_term_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_keys_meta_terms_on_meta_key_id_and_meta_term_id ON meta_keys_meta_terms USING btree (meta_key_id, meta_term_id);


--
-- Name: index_meta_keys_meta_terms_on_position; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_meta_keys_meta_terms_on_position ON meta_keys_meta_terms USING btree ("position");


--
-- Name: index_meta_keys_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_keys_on_id ON meta_keys USING btree (id);


--
-- Name: index_meta_terms_on_term; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_terms_on_term ON meta_terms USING btree (term);


--
-- Name: index_people_on_first_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_first_name ON people USING btree (first_name);


--
-- Name: index_people_on_is_group; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_people_on_is_group ON people USING btree (is_group);


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
-- Name: index_userpermissions_on_media_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_userpermissions_on_media_resource_id ON userpermissions USING btree (media_resource_id);


--
-- Name: index_userpermissions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_userpermissions_on_user_id ON userpermissions USING btree (user_id);


--
-- Name: index_users_on_autocomplete; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_autocomplete ON users USING btree (autocomplete);


--
-- Name: index_users_on_login; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_login ON users USING btree (login);


--
-- Name: index_users_on_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_person_id ON users USING btree (person_id);


--
-- Name: index_users_on_previous_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_previous_id ON users USING btree (previous_id);


--
-- Name: index_users_on_zhdkid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_zhdkid ON users USING btree (zhdkid);


--
-- Name: index_visualizations_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_visualizations_on_user_id ON visualizations USING btree (user_id);


--
-- Name: index_visualizations_on_user_id_and_resource_identifier; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_visualizations_on_user_id_and_resource_identifier ON visualizations USING btree (user_id, resource_identifier);


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
-- Name: meta_terms_term_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX meta_terms_term_idx ON meta_terms USING gin (term gin_trgm_ops);


--
-- Name: meta_terms_to_tsvector_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX meta_terms_to_tsvector_idx ON meta_terms USING gin (to_tsvector('english'::regconfig, term));


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
-- Name: admin_users_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_users
    ADD CONSTRAINT admin_users_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: app_settings_catalog_set_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_settings
    ADD CONSTRAINT app_settings_catalog_set_id_fk FOREIGN KEY (catalog_set_id) REFERENCES media_resources(id) ON DELETE SET NULL;


--
-- Name: app_settings_featured_set_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_settings
    ADD CONSTRAINT app_settings_featured_set_id_fk FOREIGN KEY (featured_set_id) REFERENCES media_resources(id) ON DELETE SET NULL;


--
-- Name: app_settings_second_displayed_meta_context_name_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_settings
    ADD CONSTRAINT app_settings_second_displayed_meta_context_name_fk FOREIGN KEY (second_displayed_context_id) REFERENCES contexts(id);


--
-- Name: app_settings_splashscreen_slideshow_set_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_settings
    ADD CONSTRAINT app_settings_splashscreen_slideshow_set_id_fk FOREIGN KEY (teaser_set_id) REFERENCES media_resources(id) ON DELETE SET NULL;


--
-- Name: app_settings_third_displayed_meta_context_name_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_settings
    ADD CONSTRAINT app_settings_third_displayed_meta_context_name_fk FOREIGN KEY (third_displayed_context_id) REFERENCES contexts(id);


--
-- Name: applicationpermissions_application_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY applicationpermissions
    ADD CONSTRAINT applicationpermissions_application_id_fk FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE CASCADE;


--
-- Name: applicationpermissions_media_resource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY applicationpermissions
    ADD CONSTRAINT applicationpermissions_media_resource_id_fk FOREIGN KEY (media_resource_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: applications_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY applications
    ADD CONSTRAINT applications_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: copyrights_parent_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY copyrights
    ADD CONSTRAINT copyrights_parent_id_fk FOREIGN KEY (parent_id) REFERENCES copyrights(id);


--
-- Name: custom_urls_creator_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY custom_urls
    ADD CONSTRAINT custom_urls_creator_id_fk FOREIGN KEY (creator_id) REFERENCES users(id);


--
-- Name: custom_urls_media_resource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY custom_urls
    ADD CONSTRAINT custom_urls_media_resource_id_fk FOREIGN KEY (media_resource_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: custom_urls_updator_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY custom_urls
    ADD CONSTRAINT custom_urls_updator_id_fk FOREIGN KEY (updator_id) REFERENCES users(id);


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
-- Name: io_mappings_io_interface_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY io_mappings
    ADD CONSTRAINT io_mappings_io_interface_id_fk FOREIGN KEY (io_interface_id) REFERENCES io_interfaces(id) ON DELETE CASCADE;


--
-- Name: io_mappings_meta_key_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY io_mappings
    ADD CONSTRAINT io_mappings_meta_key_id_fk FOREIGN KEY (meta_key_id) REFERENCES meta_keys(id) ON DELETE CASCADE;


--
-- Name: keywords_keyword_term_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY keywords
    ADD CONSTRAINT keywords_keyword_term_id_fk FOREIGN KEY (keyword_term_id) REFERENCES keyword_terms(id);


--
-- Name: keywords_meta_datum_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY keywords
    ADD CONSTRAINT keywords_meta_datum_id_fk FOREIGN KEY (meta_datum_id) REFERENCES meta_data(id) ON DELETE CASCADE;


--
-- Name: keywords_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY keywords
    ADD CONSTRAINT keywords_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: media_files_media_entry_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_files
    ADD CONSTRAINT media_files_media_entry_id_fk FOREIGN KEY (media_entry_id) REFERENCES media_resources(id);


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
-- Name: media_resources_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_resources
    ADD CONSTRAINT media_resources_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: media_sets_meta_contexts_media_set_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_sets_contexts
    ADD CONSTRAINT media_sets_meta_contexts_media_set_id_fk FOREIGN KEY (media_set_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: media_sets_meta_contexts_meta_context_name_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_sets_contexts
    ADD CONSTRAINT media_sets_meta_contexts_meta_context_name_fk FOREIGN KEY (context_id) REFERENCES contexts(id);


--
-- Name: meta_contexts_meta_context_group_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contexts
    ADD CONSTRAINT meta_contexts_meta_context_group_id_fk FOREIGN KEY (context_group_id) REFERENCES context_groups(id) ON DELETE SET NULL;


--
-- Name: meta_data_copyright_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data
    ADD CONSTRAINT meta_data_copyright_id_fk FOREIGN KEY (copyright_id) REFERENCES copyrights(id);


--
-- Name: meta_data_media_resource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data
    ADD CONSTRAINT meta_data_media_resource_id_fk FOREIGN KEY (media_resource_id) REFERENCES media_resources(id) ON DELETE CASCADE;


--
-- Name: meta_data_meta_departments_meta_datum_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data_institutional_groups
    ADD CONSTRAINT meta_data_meta_departments_meta_datum_id_fk FOREIGN KEY (meta_datum_id) REFERENCES meta_data(id) ON DELETE CASCADE;


--
-- Name: meta_data_meta_departments_meta_department_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data_institutional_groups
    ADD CONSTRAINT meta_data_meta_departments_meta_department_id_fk FOREIGN KEY (institutional_group_id) REFERENCES groups(id) ON DELETE CASCADE;


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
-- Name: meta_key_definitions_meta_context_name_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_key_definitions
    ADD CONSTRAINT meta_key_definitions_meta_context_name_fk FOREIGN KEY (context_id) REFERENCES contexts(id);


--
-- Name: meta_key_definitions_meta_key_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_key_definitions
    ADD CONSTRAINT meta_key_definitions_meta_key_id_fk FOREIGN KEY (meta_key_id) REFERENCES meta_keys(id);


--
-- Name: meta_keys_meta_terms_meta_key_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_keys_meta_terms
    ADD CONSTRAINT meta_keys_meta_terms_meta_key_id_fk FOREIGN KEY (meta_key_id) REFERENCES meta_keys(id) ON DELETE CASCADE;


--
-- Name: meta_keys_meta_terms_meta_term_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_keys_meta_terms
    ADD CONSTRAINT meta_keys_meta_terms_meta_term_id_fk FOREIGN KEY (meta_term_id) REFERENCES meta_terms(id) ON DELETE CASCADE;


--
-- Name: previews_media_file_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY previews
    ADD CONSTRAINT previews_media_file_id_fk FOREIGN KEY (media_file_id) REFERENCES media_files(id);


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
-- Name: visualizations_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY visualizations
    ADD CONSTRAINT visualizations_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: zencoder_jobs_media_file_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY zencoder_jobs
    ADD CONSTRAINT zencoder_jobs_media_file_id_fk FOREIGN KEY (media_file_id) REFERENCES media_files(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('16');

INSERT INTO schema_migrations (version) VALUES ('17');

INSERT INTO schema_migrations (version) VALUES ('18');

INSERT INTO schema_migrations (version) VALUES ('19');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('20');

INSERT INTO schema_migrations (version) VALUES ('20120820201434');

INSERT INTO schema_migrations (version) VALUES ('20120924093527');

INSERT INTO schema_migrations (version) VALUES ('20121005071336');

INSERT INTO schema_migrations (version) VALUES ('20121010120938');

INSERT INTO schema_migrations (version) VALUES ('20121015130831');

INSERT INTO schema_migrations (version) VALUES ('20121116101855');

INSERT INTO schema_migrations (version) VALUES ('20121203135807');

INSERT INTO schema_migrations (version) VALUES ('20121204093504');

INSERT INTO schema_migrations (version) VALUES ('20121217084234');

INSERT INTO schema_migrations (version) VALUES ('20121219115031');

INSERT INTO schema_migrations (version) VALUES ('20130205144924');

INSERT INTO schema_migrations (version) VALUES ('20130314163226');

INSERT INTO schema_migrations (version) VALUES ('20130319073038');

INSERT INTO schema_migrations (version) VALUES ('20130322131740');

INSERT INTO schema_migrations (version) VALUES ('20130326190454');

INSERT INTO schema_migrations (version) VALUES ('20130411071654');

INSERT INTO schema_migrations (version) VALUES ('20130415080622');

INSERT INTO schema_migrations (version) VALUES ('20130415130815');

INSERT INTO schema_migrations (version) VALUES ('20130416103629');

INSERT INTO schema_migrations (version) VALUES ('20130417063225');

INSERT INTO schema_migrations (version) VALUES ('20130417092015');

INSERT INTO schema_migrations (version) VALUES ('20130419063314');

INSERT INTO schema_migrations (version) VALUES ('20130617115706');

INSERT INTO schema_migrations (version) VALUES ('20130618071639');

INSERT INTO schema_migrations (version) VALUES ('20130716084432');

INSERT INTO schema_migrations (version) VALUES ('20130716091049');

INSERT INTO schema_migrations (version) VALUES ('20130920133708');

INSERT INTO schema_migrations (version) VALUES ('20130923085830');

INSERT INTO schema_migrations (version) VALUES ('20131009083332');

INSERT INTO schema_migrations (version) VALUES ('20131105100927');

INSERT INTO schema_migrations (version) VALUES ('20131213124951');

INSERT INTO schema_migrations (version) VALUES ('20131219093649');

INSERT INTO schema_migrations (version) VALUES ('20131220080516');

INSERT INTO schema_migrations (version) VALUES ('20131220084119');

INSERT INTO schema_migrations (version) VALUES ('20131220092952');

INSERT INTO schema_migrations (version) VALUES ('20140106090500');

INSERT INTO schema_migrations (version) VALUES ('20140128104450');

INSERT INTO schema_migrations (version) VALUES ('20140129091723');

INSERT INTO schema_migrations (version) VALUES ('20140129115655');

INSERT INTO schema_migrations (version) VALUES ('20140205063856');

INSERT INTO schema_migrations (version) VALUES ('20140218080030');

INSERT INTO schema_migrations (version) VALUES ('20140218092526');

INSERT INTO schema_migrations (version) VALUES ('20140218190628');

INSERT INTO schema_migrations (version) VALUES ('20140220133023');

INSERT INTO schema_migrations (version) VALUES ('20140224081939');

INSERT INTO schema_migrations (version) VALUES ('20140304114839');

INSERT INTO schema_migrations (version) VALUES ('20140310141910');

INSERT INTO schema_migrations (version) VALUES ('20140314113548');

INSERT INTO schema_migrations (version) VALUES ('20140314125723');

INSERT INTO schema_migrations (version) VALUES ('20140408112530');

INSERT INTO schema_migrations (version) VALUES ('20140429074104');

INSERT INTO schema_migrations (version) VALUES ('20140430082935');

INSERT INTO schema_migrations (version) VALUES ('20140430112951');

INSERT INTO schema_migrations (version) VALUES ('20140516092321');

INSERT INTO schema_migrations (version) VALUES ('20140519083555');

INSERT INTO schema_migrations (version) VALUES ('20140521065627');

INSERT INTO schema_migrations (version) VALUES ('20140606172708');

INSERT INTO schema_migrations (version) VALUES ('20140609181841');

INSERT INTO schema_migrations (version) VALUES ('20140611121741');

INSERT INTO schema_migrations (version) VALUES ('20140613084713');

INSERT INTO schema_migrations (version) VALUES ('20140613150056');

INSERT INTO schema_migrations (version) VALUES ('20140613150648');

INSERT INTO schema_migrations (version) VALUES ('20140613154055');

INSERT INTO schema_migrations (version) VALUES ('20140623075458');

INSERT INTO schema_migrations (version) VALUES ('20140709085016');

INSERT INTO schema_migrations (version) VALUES ('20140714140008');

INSERT INTO schema_migrations (version) VALUES ('20140716154252');

INSERT INTO schema_migrations (version) VALUES ('20140718095641');

INSERT INTO schema_migrations (version) VALUES ('20140721075032');

INSERT INTO schema_migrations (version) VALUES ('20140721075956');

INSERT INTO schema_migrations (version) VALUES ('20140722104558');

INSERT INTO schema_migrations (version) VALUES ('20140808090502');

INSERT INTO schema_migrations (version) VALUES ('20140822054042');

INSERT INTO schema_migrations (version) VALUES ('20140915103141');

INSERT INTO schema_migrations (version) VALUES ('20140917074821');

INSERT INTO schema_migrations (version) VALUES ('20140923093912');

INSERT INTO schema_migrations (version) VALUES ('20140926064805');

INSERT INTO schema_migrations (version) VALUES ('20140926101701');

INSERT INTO schema_migrations (version) VALUES ('20141006074635');

INSERT INTO schema_migrations (version) VALUES ('20141006094714');

INSERT INTO schema_migrations (version) VALUES ('20141006113152');

INSERT INTO schema_migrations (version) VALUES ('20141014083457');

INSERT INTO schema_migrations (version) VALUES ('20141014090348');

INSERT INTO schema_migrations (version) VALUES ('20150127134935');

INSERT INTO schema_migrations (version) VALUES ('20150217141205');

INSERT INTO schema_migrations (version) VALUES ('21');

INSERT INTO schema_migrations (version) VALUES ('22');

INSERT INTO schema_migrations (version) VALUES ('23');

INSERT INTO schema_migrations (version) VALUES ('24');

INSERT INTO schema_migrations (version) VALUES ('25');

INSERT INTO schema_migrations (version) VALUES ('26');

INSERT INTO schema_migrations (version) VALUES ('27');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('9');

