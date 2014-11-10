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
-- Name: check_collections_sibbling(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_collections_sibbling() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            DECLARE
              resources_sibblings_count int;
            BEGIN
                IF (TG_OP = 'DELETE') THEN
                
                  IF (SELECT count(*) FROM resources WHERE id = OLD.id ) <> 0 THEN
                    RAISE EXCEPTION 'The resource with % should have been deleted with its sibling row in collections ', OLD.id ;
                  END IF; 

                ELSE

                  IF (SELECT count(*) FROM collections
                    JOIN resources ON resources.id = collections.id
                    WHERE resources.id = NEW.id
                    ) <> 1 THEN
                    RAISE EXCEPTION 'Every row in collections with id % must have exactly one and only one resource sibbling.', NEW.id ;
                  END IF; 

                  resources_sibblings_count := (SELECT count(collections.id) + count(media_entries.id) + count(filter_sets.id)
                       FROM resources
                       LEFT OUTER JOIN media_entries ON resources.id = media_entries.id
                       LEFT OUTER JOIN collections ON resources.id = collections.id
                       LEFT OUTER JOIN filter_sets ON resources.id = filter_sets.id
                       WHERE resources.id = NEW.id
                       GROUP BY resources.id, collections.id, media_entries.id, filter_sets.id ); 

                  IF  resources_sibblings_count <> 1 THEN
                    RAISE EXCEPTION 'Every row in resources with id % must have exactly one sibbling but this has %.', NEW.id, resources_sibblings_count;
                  END IF; 

                END IF;
                  
                RETURN NEW;

            END;
            $$;


--
-- Name: check_filter_sets_sibbling(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_filter_sets_sibbling() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            DECLARE
              resources_sibblings_count int;
            BEGIN
                IF (TG_OP = 'DELETE') THEN
                
                  IF (SELECT count(*) FROM resources WHERE id = OLD.id ) <> 0 THEN
                    RAISE EXCEPTION 'The resource with % should have been deleted with its sibling row in filter_sets ', OLD.id ;
                  END IF; 

                ELSE

                  IF (SELECT count(*) FROM filter_sets
                    JOIN resources ON resources.id = filter_sets.id
                    WHERE resources.id = NEW.id
                    ) <> 1 THEN
                    RAISE EXCEPTION 'Every row in filter_sets with id % must have exactly one and only one resource sibbling.', NEW.id ;
                  END IF; 

                  resources_sibblings_count := (SELECT count(collections.id) + count(media_entries.id) + count(filter_sets.id)
                       FROM resources
                       LEFT OUTER JOIN media_entries ON resources.id = media_entries.id
                       LEFT OUTER JOIN collections ON resources.id = collections.id
                       LEFT OUTER JOIN filter_sets ON resources.id = filter_sets.id
                       WHERE resources.id = NEW.id
                       GROUP BY resources.id, collections.id, media_entries.id, filter_sets.id ); 

                  IF  resources_sibblings_count <> 1 THEN
                    RAISE EXCEPTION 'Every row in resources with id % must have exactly one sibbling but this has %.', NEW.id, resources_sibblings_count;
                  END IF; 

                END IF;
                  
                RETURN NEW;

            END;
            $$;


--
-- Name: check_media_entries_sibbling(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_media_entries_sibbling() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            DECLARE
              resources_sibblings_count int;
            BEGIN
                IF (TG_OP = 'DELETE') THEN
                
                  IF (SELECT count(*) FROM resources WHERE id = OLD.id ) <> 0 THEN
                    RAISE EXCEPTION 'The resource with % should have been deleted with its sibling row in media_entries ', OLD.id ;
                  END IF; 

                ELSE

                  IF (SELECT count(*) FROM media_entries
                    JOIN resources ON resources.id = media_entries.id
                    WHERE resources.id = NEW.id
                    ) <> 1 THEN
                    RAISE EXCEPTION 'Every row in media_entries with id % must have exactly one and only one resource sibbling.', NEW.id ;
                  END IF; 

                  resources_sibblings_count := (SELECT count(collections.id) + count(media_entries.id) + count(filter_sets.id)
                       FROM resources
                       LEFT OUTER JOIN media_entries ON resources.id = media_entries.id
                       LEFT OUTER JOIN collections ON resources.id = collections.id
                       LEFT OUTER JOIN filter_sets ON resources.id = filter_sets.id
                       WHERE resources.id = NEW.id
                       GROUP BY resources.id, collections.id, media_entries.id, filter_sets.id ); 

                  IF  resources_sibblings_count <> 1 THEN
                    RAISE EXCEPTION 'Every row in resources with id % must have exactly one sibbling but this has %.', NEW.id, resources_sibblings_count;
                  END IF; 

                END IF;
                  
                RETURN NEW;

            END;
            $$;


--
-- Name: check_resources_sibbling(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_resources_sibbling() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
          DECLARE
            resources_sibblings_count int;
          BEGIN
              IF (TG_OP = 'DELETE') THEN

                 IF (SELECT count(*) FROM media_entries WHERE id = OLD.id ) <> 0 THEN 
                 RAISE EXCEPTION 'The sibling in media_entries of the resource with % should have been deleted too', OLD.id ;
             END IF; 
 IF (SELECT count(*) FROM collections WHERE id = OLD.id ) <> 0 THEN 
                 RAISE EXCEPTION 'The sibling in collections of the resource with % should have been deleted too', OLD.id ;
             END IF; 
 IF (SELECT count(*) FROM filter_sets WHERE id = OLD.id ) <> 0 THEN 
                 RAISE EXCEPTION 'The sibling in filter_sets of the resource with % should have been deleted too', OLD.id ;
             END IF;  
                 
              ELSE

                resources_sibblings_count := (SELECT count(collections.id) + count(media_entries.id) + count(filter_sets.id)
                     FROM resources
                     LEFT OUTER JOIN media_entries ON resources.id = media_entries.id
                     LEFT OUTER JOIN collections ON resources.id = collections.id
                     LEFT OUTER JOIN filter_sets ON resources.id = filter_sets.id
                     WHERE resources.id = NEW.id
                     GROUP BY resources.id, collections.id, media_entries.id, filter_sets.id ); 

                IF  resources_sibblings_count <> 1 THEN
                  RAISE EXCEPTION 'Every row in resources with id % must have exactly one sibbling but this has %.', NEW.id, resources_sibblings_count;
                END IF; 

              END IF;

              RETURN NEW;

          END;
          $$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE admin_users (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: app_settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE app_settings (
    id integer NOT NULL,
    featured_set_id uuid,
    splashscreen_slideshow_set_id uuid,
    catalog_set_id uuid,
    title character varying(255),
    support_url character varying(255),
    welcome_title character varying(255),
    welcome_subtitle character varying(255),
    teaser_set_id uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    logo_url character varying(255) DEFAULT '/assets/inserts/image-logo-zhdk.png'::character varying NOT NULL,
    brand character varying(255) DEFAULT 'Zürcher Hochschule der Künste'::character varying NOT NULL,
    footer_links text,
    second_displayed_context_id character varying(255),
    third_displayed_context_id character varying(255),
    CONSTRAINT oneandonly CHECK ((id = 0))
);


--
-- Name: applicationpermissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE applicationpermissions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    resource_id uuid NOT NULL,
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
    secret uuid DEFAULT uuid_generate_v4(),
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
-- Name: collections; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE collections (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: context_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE context_groups (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255),
    "position" integer NOT NULL
);


--
-- Name: contexts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contexts (
    id character varying(255) NOT NULL,
    label character varying(255) DEFAULT ''::character varying NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    context_group_id uuid,
    "position" integer
);


--
-- Name: copyrights; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE copyrights (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    is_default boolean DEFAULT false,
    is_custom boolean DEFAULT false,
    label character varying(255),
    parent_id uuid,
    usage character varying(255),
    url character varying(255),
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
    resource_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites (
    user_id uuid NOT NULL,
    resource_id uuid NOT NULL
);


--
-- Name: filter_sets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE filter_sets (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    filter json DEFAULT '{}'::json NOT NULL
);


--
-- Name: full_texts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE full_texts (
    media_resource_id uuid NOT NULL,
    text text
);


--
-- Name: grouppermissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE grouppermissions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    resource_id uuid NOT NULL,
    group_id uuid NOT NULL,
    download boolean DEFAULT false NOT NULL,
    edit boolean DEFAULT false NOT NULL,
    manage boolean DEFAULT false NOT NULL,
    view boolean DEFAULT false NOT NULL,
    CONSTRAINT manage_on_grouppermissions_is_false CHECK ((manage = false))
);


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE groups (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    previous_id integer,
    name character varying(255),
    institutional_group_id character varying(255),
    institutional_group_name character varying(255),
    type character varying(255) DEFAULT 'Group'::character varying NOT NULL,
    searchable text DEFAULT ''::text NOT NULL,
    users_count integer DEFAULT 0
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
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: io_mappings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE io_mappings (
    io_interface_id character varying(255) NOT NULL,
    meta_key_id character varying(255) NOT NULL,
    key_map character varying(255),
    key_map_type character varying(255),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: keyword_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE keyword_terms (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    term character varying(255) DEFAULT ''::character varying NOT NULL,
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
    meta_datum_id uuid,
    keyword_term_id uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: media_entries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_entries (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    type character varying(255) DEFAULT 'MediaEntry'::character varying
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
    content_type character varying(255) NOT NULL,
    filename character varying(255),
    guid character varying(255),
    extension character varying(255),
    media_type character varying(255),
    media_entry_id uuid,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: media_sets_contexts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_sets_contexts (
    media_set_id uuid NOT NULL,
    context_id character varying(255) NOT NULL
);


--
-- Name: meta_data; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_data (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    media_resource_id uuid NOT NULL,
    meta_key_id character varying(255) NOT NULL,
    type character varying(255),
    string text,
    copyright_id uuid
);


--
-- Name: meta_data_institutional_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_data_institutional_groups (
    meta_datum_id uuid NOT NULL,
    institutional_group_id uuid NOT NULL
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
-- Name: meta_key_definitions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_key_definitions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    hint text DEFAULT ''::text NOT NULL,
    label text DEFAULT ''::text NOT NULL,
    context_id character varying(255) NOT NULL,
    meta_key_id character varying(255) NOT NULL,
    is_required boolean DEFAULT false,
    length_max integer,
    length_min integer,
    "position" integer NOT NULL,
    input_type integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: meta_keys; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_keys (
    id character varying(255) NOT NULL,
    is_extensible_list boolean,
    meta_datum_object_type character varying(255) DEFAULT 'MetaDatumString'::character varying NOT NULL,
    meta_terms_alphabetical_order boolean DEFAULT true
);


--
-- Name: meta_keys_meta_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE meta_keys_meta_terms (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    meta_key_id character varying(255) NOT NULL,
    meta_term_id uuid NOT NULL,
    "position" integer DEFAULT 0 NOT NULL
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
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    is_group boolean DEFAULT false,
    date_of_birth date,
    date_of_death date,
    first_name character varying(255),
    last_name character varying(255),
    pseudonym character varying(255),
    searchable text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: permission_presets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE permission_presets (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255),
    "position" double precision,
    download boolean DEFAULT false NOT NULL,
    edit boolean DEFAULT false NOT NULL,
    manage boolean DEFAULT false NOT NULL,
    view boolean DEFAULT false NOT NULL
);


--
-- Name: previews; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE previews (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    media_file_id uuid NOT NULL,
    height integer,
    width integer,
    content_type character varying(255),
    filename character varying(255),
    thumbnail character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    media_type character varying(255) NOT NULL
);


--
-- Name: resources; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE resources (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    previous_id integer,
    download boolean DEFAULT false NOT NULL,
    edit boolean DEFAULT false NOT NULL,
    manage boolean DEFAULT false NOT NULL,
    view boolean DEFAULT false NOT NULL,
    responsible_user_id uuid NOT NULL,
    type character varying(255),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    creator_id uuid NOT NULL,
    updator_id uuid NOT NULL,
    CONSTRAINT edit_on_publicpermissions_is_false CHECK ((edit = false)),
    CONSTRAINT manage_on_publicpermissions_is_false CHECK ((manage = false)),
    CONSTRAINT valid_media_resource_type CHECK (((type)::text = ANY ((ARRAY['MediaEntryResource'::character varying, 'MediaEntryIncompleteResource'::character varying, 'CollectionResource'::character varying, 'FilterSetResource'::character varying])::text[])))
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
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    title character varying(255),
    version character varying(255),
    intro text,
    body text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: user_resources_counts; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW user_resources_counts AS
 SELECT count(*) AS resouces_count,
    resources.responsible_user_id AS user_id
   FROM resources
  GROUP BY resources.responsible_user_id;


--
-- Name: userpermissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE userpermissions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    download boolean DEFAULT false NOT NULL,
    edit boolean DEFAULT false NOT NULL,
    manage boolean DEFAULT false NOT NULL,
    view boolean DEFAULT false NOT NULL,
    resource_id uuid NOT NULL,
    user_id uuid NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    previous_id integer,
    email character varying(255),
    login text,
    notes text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    password_digest character varying(255),
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
    resource_identifier character varying(255) NOT NULL,
    control_settings text,
    layout text
);


--
-- Name: zencoder_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE zencoder_jobs (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    media_file_id uuid NOT NULL,
    zencoder_id integer,
    comment text,
    state character varying(255) DEFAULT 'initialized'::character varying NOT NULL,
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
-- Name: collection_media_entry_arcs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY collection_media_entry_arcs
    ADD CONSTRAINT collection_media_entry_arcs_pkey PRIMARY KEY (id);


--
-- Name: collections_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY collections
    ADD CONSTRAINT collections_pkey PRIMARY KEY (id);


--
-- Name: context_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY context_groups
    ADD CONSTRAINT context_groups_pkey PRIMARY KEY (id);


--
-- Name: contexts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contexts
    ADD CONSTRAINT contexts_pkey PRIMARY KEY (id);


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
-- Name: media_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY media_entries
    ADD CONSTRAINT media_entries_pkey PRIMARY KEY (id);


--
-- Name: media_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY media_files
    ADD CONSTRAINT media_files_pkey PRIMARY KEY (id);


--
-- Name: media_resources_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resources
    ADD CONSTRAINT media_resources_pkey PRIMARY KEY (id);


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
    ADD CONSTRAINT visualizations_pkey PRIMARY KEY (id);


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
-- Name: index_applicationpermissions_on_application_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_applicationpermissions_on_application_id ON applicationpermissions USING btree (application_id);


--
-- Name: index_applicationpermissions_on_mr_id_and_app_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_applicationpermissions_on_mr_id_and_app_id ON applicationpermissions USING btree (resource_id, application_id);


--
-- Name: index_applicationpermissions_on_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_applicationpermissions_on_resource_id ON applicationpermissions USING btree (resource_id);


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
-- Name: index_contexts_on_position; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contexts_on_position ON contexts USING btree ("position");


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
-- Name: index_edit_sessions_on_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_edit_sessions_on_resource_id ON edit_sessions USING btree (resource_id);


--
-- Name: index_edit_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_edit_sessions_on_user_id ON edit_sessions USING btree (user_id);


--
-- Name: index_favorites_on_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_on_resource_id ON favorites USING btree (resource_id);


--
-- Name: index_favorites_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favorites_on_user_id ON favorites USING btree (user_id);


--
-- Name: index_favorites_on_user_id_and_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_favorites_on_user_id_and_resource_id ON favorites USING btree (user_id, resource_id);


--
-- Name: index_grouppermissions_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_grouppermissions_on_group_id ON grouppermissions USING btree (group_id);


--
-- Name: index_grouppermissions_on_group_id_and_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_grouppermissions_on_group_id_and_resource_id ON grouppermissions USING btree (group_id, resource_id);


--
-- Name: index_grouppermissions_on_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_grouppermissions_on_resource_id ON grouppermissions USING btree (resource_id);


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
-- Name: index_media_sets_contexts; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_media_sets_contexts ON media_sets_contexts USING btree (media_set_id, context_id);


--
-- Name: index_meta_data_institutional_groups; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_data_institutional_groups ON meta_data_institutional_groups USING btree (meta_datum_id, institutional_group_id);


--
-- Name: index_meta_data_meta_terms_on_meta_datum_id_and_meta_term_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_meta_data_meta_terms_on_meta_datum_id_and_meta_term_id ON meta_data_meta_terms USING btree (meta_datum_id, meta_term_id);


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
-- Name: index_resources_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_resources_on_created_at ON resources USING btree (created_at);


--
-- Name: index_resources_on_previous_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_resources_on_previous_id ON resources USING btree (previous_id);


--
-- Name: index_resources_on_responsible_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_resources_on_responsible_user_id ON resources USING btree (responsible_user_id);


--
-- Name: index_resources_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_resources_on_type ON resources USING btree (type);


--
-- Name: index_resources_on_updated_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_resources_on_updated_at ON resources USING btree (updated_at);


--
-- Name: index_userpermissions_on_resource_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_userpermissions_on_resource_id ON userpermissions USING btree (resource_id);


--
-- Name: index_userpermissions_on_resource_id_and_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_userpermissions_on_resource_id_and_user_id ON userpermissions USING btree (resource_id, user_id);


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

CREATE INDEX index_users_on_login ON users USING btree (login);


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
-- Name: check_collections_sibbling; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER check_collections_sibbling AFTER INSERT OR DELETE OR UPDATE ON collections DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE check_collections_sibbling();


--
-- Name: check_filter_sets_sibbling; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER check_filter_sets_sibbling AFTER INSERT OR DELETE OR UPDATE ON filter_sets DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE check_filter_sets_sibbling();


--
-- Name: check_media_entries_sibbling; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER check_media_entries_sibbling AFTER INSERT OR DELETE OR UPDATE ON media_entries DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE check_media_entries_sibbling();


--
-- Name: check_resources_sibbling; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER check_resources_sibbling AFTER INSERT OR DELETE OR UPDATE ON resources DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE check_resources_sibbling();


--
-- Name: admin_users_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_users
    ADD CONSTRAINT admin_users_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: app_settings_catalog_set_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_settings
    ADD CONSTRAINT app_settings_catalog_set_id_fk FOREIGN KEY (catalog_set_id) REFERENCES resources(id);


--
-- Name: app_settings_featured_set_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_settings
    ADD CONSTRAINT app_settings_featured_set_id_fk FOREIGN KEY (featured_set_id) REFERENCES resources(id);


--
-- Name: app_settings_second_displayed_context_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_settings
    ADD CONSTRAINT app_settings_second_displayed_context_id_fk FOREIGN KEY (second_displayed_context_id) REFERENCES contexts(id);


--
-- Name: app_settings_splashscreen_slideshow_set_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_settings
    ADD CONSTRAINT app_settings_splashscreen_slideshow_set_id_fk FOREIGN KEY (splashscreen_slideshow_set_id) REFERENCES resources(id);


--
-- Name: app_settings_third_displayed_context_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY app_settings
    ADD CONSTRAINT app_settings_third_displayed_context_id_fk FOREIGN KEY (third_displayed_context_id) REFERENCES contexts(id);


--
-- Name: applicationpermissions_application_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY applicationpermissions
    ADD CONSTRAINT applicationpermissions_application_id_fk FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE CASCADE;


--
-- Name: applicationpermissions_media_resource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY applicationpermissions
    ADD CONSTRAINT applicationpermissions_media_resource_id_fk FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE CASCADE;


--
-- Name: applications_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY applications
    ADD CONSTRAINT applications_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: collection_collection_arcs_child_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_collection_arcs
    ADD CONSTRAINT collection_collection_arcs_child_id_fk FOREIGN KEY (child_id) REFERENCES collections(id) ON DELETE CASCADE;


--
-- Name: collection_collection_arcs_parent_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_collection_arcs
    ADD CONSTRAINT collection_collection_arcs_parent_id_fk FOREIGN KEY (parent_id) REFERENCES collections(id) ON DELETE CASCADE;


--
-- Name: collection_filter_set_arcs_collection_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_filter_set_arcs
    ADD CONSTRAINT collection_filter_set_arcs_collection_id_fk FOREIGN KEY (collection_id) REFERENCES collections(id) ON DELETE CASCADE;


--
-- Name: collection_filter_set_arcs_filter_set_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_filter_set_arcs
    ADD CONSTRAINT collection_filter_set_arcs_filter_set_id_fk FOREIGN KEY (filter_set_id) REFERENCES filter_sets(id) ON DELETE CASCADE;


--
-- Name: collection_media_entry_arcs_collection_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_media_entry_arcs
    ADD CONSTRAINT collection_media_entry_arcs_collection_id_fk FOREIGN KEY (collection_id) REFERENCES collections(id) ON DELETE CASCADE;


--
-- Name: collection_media_entry_arcs_media_entry_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collection_media_entry_arcs
    ADD CONSTRAINT collection_media_entry_arcs_media_entry_id_fk FOREIGN KEY (media_entry_id) REFERENCES media_entries(id) ON DELETE CASCADE;


--
-- Name: collections_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY collections
    ADD CONSTRAINT collections_id_fk FOREIGN KEY (id) REFERENCES resources(id);


--
-- Name: contexts_context_group_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contexts
    ADD CONSTRAINT contexts_context_group_id_fk FOREIGN KEY (context_group_id) REFERENCES context_groups(id);


--
-- Name: custom_urls_creator_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY custom_urls
    ADD CONSTRAINT custom_urls_creator_id_fk FOREIGN KEY (creator_id) REFERENCES users(id);


--
-- Name: custom_urls_media_resource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY custom_urls
    ADD CONSTRAINT custom_urls_media_resource_id_fk FOREIGN KEY (media_resource_id) REFERENCES resources(id) ON DELETE CASCADE;


--
-- Name: custom_urls_updator_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY custom_urls
    ADD CONSTRAINT custom_urls_updator_id_fk FOREIGN KEY (updator_id) REFERENCES users(id);


--
-- Name: edit_sessions_media_resource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY edit_sessions
    ADD CONSTRAINT edit_sessions_media_resource_id_fk FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE CASCADE;


--
-- Name: edit_sessions_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY edit_sessions
    ADD CONSTRAINT edit_sessions_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: favorites_media_resource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites
    ADD CONSTRAINT favorites_media_resource_id_fk FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE CASCADE;


--
-- Name: favorites_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites
    ADD CONSTRAINT favorites_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: filter_sets_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filter_sets
    ADD CONSTRAINT filter_sets_id_fk FOREIGN KEY (id) REFERENCES resources(id);


--
-- Name: full_texts_media_resource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY full_texts
    ADD CONSTRAINT full_texts_media_resource_id_fk FOREIGN KEY (media_resource_id) REFERENCES resources(id) ON DELETE CASCADE;


--
-- Name: grouppermissions_group_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY grouppermissions
    ADD CONSTRAINT grouppermissions_group_id_fk FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE;


--
-- Name: grouppermissions_media_resource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY grouppermissions
    ADD CONSTRAINT grouppermissions_media_resource_id_fk FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE CASCADE;


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
-- Name: media_entries_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_entries
    ADD CONSTRAINT media_entries_id_fk FOREIGN KEY (id) REFERENCES resources(id);


--
-- Name: media_files_media_entry_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_files
    ADD CONSTRAINT media_files_media_entry_id_fk FOREIGN KEY (media_entry_id) REFERENCES media_entries(id);


--
-- Name: media_resources_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY resources
    ADD CONSTRAINT media_resources_user_id_fk FOREIGN KEY (responsible_user_id) REFERENCES users(id);


--
-- Name: media_sets_contexts_context_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_sets_contexts
    ADD CONSTRAINT media_sets_contexts_context_id_fk FOREIGN KEY (context_id) REFERENCES contexts(id) ON DELETE CASCADE;


--
-- Name: media_sets_contexts_media_set_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_sets_contexts
    ADD CONSTRAINT media_sets_contexts_media_set_id_fk FOREIGN KEY (media_set_id) REFERENCES resources(id) ON DELETE CASCADE;


--
-- Name: meta_data_copyright_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data
    ADD CONSTRAINT meta_data_copyright_id_fk FOREIGN KEY (copyright_id) REFERENCES copyrights(id);


--
-- Name: meta_data_institutional_groups_institutional_group_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data_institutional_groups
    ADD CONSTRAINT meta_data_institutional_groups_institutional_group_id_fk FOREIGN KEY (institutional_group_id) REFERENCES groups(id) ON DELETE CASCADE;


--
-- Name: meta_data_institutional_groups_meta_datum_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data_institutional_groups
    ADD CONSTRAINT meta_data_institutional_groups_meta_datum_id_fk FOREIGN KEY (meta_datum_id) REFERENCES meta_data(id) ON DELETE CASCADE;


--
-- Name: meta_data_media_resource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_data
    ADD CONSTRAINT meta_data_media_resource_id_fk FOREIGN KEY (media_resource_id) REFERENCES resources(id) ON DELETE CASCADE;


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
-- Name: meta_key_definitions_context_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY meta_key_definitions
    ADD CONSTRAINT meta_key_definitions_context_id_fk FOREIGN KEY (context_id) REFERENCES contexts(id);


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
-- Name: parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY copyrights
    ADD CONSTRAINT parent_id_fkey FOREIGN KEY (parent_id) REFERENCES copyrights(id);


--
-- Name: previews_media_file_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY previews
    ADD CONSTRAINT previews_media_file_id_fk FOREIGN KEY (media_file_id) REFERENCES media_files(id) ON DELETE CASCADE;


--
-- Name: resources_creator_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY resources
    ADD CONSTRAINT resources_creator_id_fk FOREIGN KEY (creator_id) REFERENCES users(id);


--
-- Name: resources_updator_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY resources
    ADD CONSTRAINT resources_updator_id_fk FOREIGN KEY (updator_id) REFERENCES users(id);


--
-- Name: userpermissions_media_resource_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY userpermissions
    ADD CONSTRAINT userpermissions_media_resource_id_fk FOREIGN KEY (resource_id) REFERENCES resources(id) ON DELETE CASCADE;


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
    ADD CONSTRAINT visualizations_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: zencoder_jobs_media_file_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY zencoder_jobs
    ADD CONSTRAINT zencoder_jobs_media_file_id_fk FOREIGN KEY (media_file_id) REFERENCES media_files(id);


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

