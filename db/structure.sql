--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.4
-- Dumped by pg_dump version 9.6.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

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
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


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
-- Name: reservation_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE reservation_status AS ENUM (
    'unsubmitted',
    'submitted',
    'rejected',
    'approved',
    'signed',
    'closed'
);


--
-- Name: check_closed_reservations_contract_state(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_closed_reservations_contract_state() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF (
          NEW.status = 'closed' AND
          NOT EXISTS(
            SELECT 1
            FROM reservations
            WHERE contract_id = NEW.contract_id AND status != 'closed')
          ) AND
          (SELECT state FROM contracts WHERE contracts.id = NEW.contract_id) != 'closed'
        THEN
          RAISE EXCEPTION 'If all reservations are closed then the contract must be closed as well';
        END IF;

        RETURN NEW;
      END;
      $$;


--
-- Name: check_contract_has_at_least_one_reservation(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_contract_has_at_least_one_reservation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1
          FROM reservations
          WHERE contract_id = NEW.id)
        THEN
          RAISE EXCEPTION 'contract must have at least one reservation';
        END IF;

        RETURN NEW;
      END;
      $$;


--
-- Name: check_general_building_id_for_general_room(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_general_building_id_for_general_room() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF (
          OLD.general IS TRUE
          AND OLD.building_id != NEW.building_id
          )
          THEN RAISE EXCEPTION
            'Building ID cannot be changed for a general room';
        END IF;
        RETURN NEW;
      END;
      $$;


--
-- Name: check_item_line_state_consistency(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_item_line_state_consistency() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF (
          (NEW.type = 'ItemLine' AND NEW.status = 'submitted' AND EXISTS (
            SELECT 1
            FROM orders
            WHERE id = NEW.order_id AND state <> 'submitted')) OR
          (NEW.type = 'ItemLine' AND NEW.status = 'rejected' AND EXISTS (
            SELECT 1
            FROM orders
            WHERE id = NEW.order_id AND state <> 'rejected')) OR
          (NEW.type = 'ItemLine' AND NEW.status IN ('approved', 'signed', 'closed') AND EXISTS (
            SELECT 1
            FROM orders
            WHERE id = NEW.order_id AND state <> 'approved'))
        )
        THEN
          RAISE EXCEPTION 'state between item line and order is inconsistent';
        END IF;

        RETURN NEW;
      END;
      $$;


--
-- Name: check_option_line_state_consistency(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_option_line_state_consistency() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF (
          NEW.type = 'OptionLine' AND EXISTS (
            SELECT 1
            FROM orders
            WHERE id = NEW.order_id)
        )
        THEN
          RAISE EXCEPTION 'option line cannot belong to an order';
        END IF;

        RETURN NEW;
      END;
      $$;


--
-- Name: check_reservation_contract_inventory_pool_id_consistency(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_reservation_contract_inventory_pool_id_consistency() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF (
          NEW.inventory_pool_id != (
            SELECT inventory_pool_id
            FROM contracts
            WHERE id = NEW.contract_id)
        )
        THEN
          RAISE EXCEPTION 'inventory_pool_id between reservation and contract is inconsistent';
        END IF;

        RETURN NEW;
      END;
      $$;


--
-- Name: check_reservation_contract_user_id_consistency(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_reservation_contract_user_id_consistency() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF (
          NEW.user_id != (
            SELECT user_id
            FROM contracts
            WHERE id = NEW.contract_id)
        )
        THEN
          RAISE EXCEPTION 'user_id between reservation and contract is inconsistent';
        END IF;

        RETURN NEW;
      END;
      $$;


--
-- Name: check_reservation_order_inventory_pool_id_consistency(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_reservation_order_inventory_pool_id_consistency() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF (
          NEW.inventory_pool_id != (
            SELECT inventory_pool_id
            FROM orders
            WHERE id = NEW.order_id)
        )
        THEN
          RAISE EXCEPTION 'inventory_pool_id between reservation and order is inconsistent';
        END IF;

        RETURN NEW;
      END;
      $$;


--
-- Name: check_reservation_order_user_id_consistency(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_reservation_order_user_id_consistency() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF (
          NEW.user_id != (
            SELECT user_id
            FROM orders
            WHERE id = NEW.order_id)
        )
        THEN
          RAISE EXCEPTION 'user_id between reservation and order is inconsistent';
        END IF;

        RETURN NEW;
      END;
      $$;


--
-- Name: check_reservations_contracts_state_consistency(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_reservations_contracts_state_consistency() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF (
          NEW.state = 'closed' AND (
            SELECT count(*)
            FROM reservations
            WHERE contract_id = NEW.id AND status != 'closed') > 0
        )
        THEN
          RAISE EXCEPTION 'all reservations of a closed contract must be closed as well';
        END IF;

        RETURN NEW;
      END;
      $$;


--
-- Name: delete_empty_order(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION delete_empty_order() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      DECLARE
        result text;
      BEGIN
        IF (
          NOT EXISTS (
            SELECT 1
            FROM reservations
            WHERE reservations.order_id = OLD.order_id
        ))
        THEN
          DELETE FROM orders WHERE orders.id = OLD.order_id;
        END IF;

        RETURN OLD;
      END;
      $$;


--
-- Name: delete_procurement_users_filters_after_procurement_accesses(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION delete_procurement_users_filters_after_procurement_accesses() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF
    (EXISTS
      (SELECT 1
       FROM procurement_users_filters
       WHERE procurement_users_filters.user_id = OLD.user_id)
     AND NOT EXISTS
      (SELECT 1
       FROM procurement_accesses
       WHERE procurement_accesses.user_id = OLD.user_id))
  THEN
    DELETE FROM procurement_users_filters
    WHERE procurement_users_filters.user_id = OLD.user_id;
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: delete_procurement_users_filters_after_users(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION delete_procurement_users_filters_after_users() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF
    (EXISTS
      (SELECT 1
       FROM procurement_users_filters
       WHERE procurement_users_filters.user_id = OLD.id))
  THEN
    DELETE FROM procurement_users_filters
    WHERE procurement_users_filters.user_id = OLD.id;
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: ensure_general_building_cannot_be_deleted(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ensure_general_building_cannot_be_deleted() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF (OLD.id = 'abae04c5-d767-425e-acc2-7ce04df645d1')
          THEN RAISE EXCEPTION
            'Building with ID = abae04c5-d767-425e-acc2-7ce04df645d1 cannot be deleted.';
        END IF;
        RETURN NEW;
      END;
      $$;


--
-- Name: ensure_general_room_cannot_be_deleted(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ensure_general_room_cannot_be_deleted() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF (
          OLD.general IS TRUE
          AND EXISTS (SELECT 1 FROM buildings WHERE id = OLD.building_id)
          )
          THEN RAISE EXCEPTION
            'There must be a general room for every building.';
        END IF;
        RETURN NEW;
      END;
      $$;


--
-- Name: hex_to_int(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hex_to_int(hexval character varying) RETURNS bigint
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
      DECLARE
        result bigint;
      BEGIN
        EXECUTE 'SELECT x''' || hexval || '''::bigint' INTO result;
        RETURN result;
      END;
      $$;


--
-- Name: restrict_operations_on_fields_function(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION restrict_operations_on_fields_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  RAISE EXCEPTION 'The fields table does not allow INSERT or DELETE or TRUNCATE!';
  RETURN NULL;
END;
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: access_rights; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE access_rights (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    inventory_pool_id uuid,
    suspended_until date,
    suspended_reason text,
    deleted_at date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    role character varying NOT NULL,
    CONSTRAINT check_allowed_roles CHECK (((role)::text = ANY ((ARRAY['customer'::character varying, 'group_manager'::character varying, 'lending_manager'::character varying, 'inventory_manager'::character varying, 'admin'::character varying])::text[])))
);


--
-- Name: accessories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE accessories (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    model_id uuid,
    name character varying NOT NULL,
    quantity integer
);


--
-- Name: accessories_inventory_pools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE accessories_inventory_pools (
    accessory_id uuid,
    inventory_pool_id uuid
);


--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE addresses (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    street character varying,
    zip_code character varying,
    city character varying,
    country_code character varying,
    latitude double precision,
    longitude double precision
);


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE attachments (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    model_id uuid,
    content_type character varying,
    filename character varying,
    size integer,
    item_id uuid,
    content text,
    metadata json
);


--
-- Name: audits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE audits (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    auditable_id uuid,
    auditable_type character varying,
    associated_id uuid,
    associated_type character varying,
    user_id uuid,
    user_type character varying,
    username character varying,
    action character varying,
    audited_changes text,
    version integer DEFAULT 0,
    comment character varying,
    remote_address character varying,
    request_uuid character varying,
    created_at timestamp without time zone
);


--
-- Name: authentication_systems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE authentication_systems (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying,
    class_name character varying,
    is_default boolean DEFAULT false,
    is_active boolean DEFAULT false
);


--
-- Name: buildings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE buildings (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    code character varying
);


--
-- Name: contracts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE contracts (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    compact_id text NOT NULL,
    note text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state text NOT NULL,
    user_id uuid NOT NULL,
    inventory_pool_id uuid NOT NULL,
    purpose text NOT NULL,
    CONSTRAINT check_valid_state CHECK ((state = ANY (ARRAY['open'::text, 'closed'::text])))
);


--
-- Name: database_authentications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE database_authentications (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    login character varying NOT NULL,
    crypted_password character varying(40),
    salt character varying(40),
    user_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: delegations_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE delegations_users (
    delegation_id uuid,
    user_id uuid
);


--
-- Name: entitlement_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE entitlement_groups (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    inventory_pool_id uuid NOT NULL,
    is_verification_required boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: entitlement_groups_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE entitlement_groups_users (
    user_id uuid,
    entitlement_group_id uuid
);


--
-- Name: entitlements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE entitlements (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    model_id uuid NOT NULL,
    inventory_pool_id uuid NOT NULL,
    entitlement_group_id uuid NOT NULL,
    quantity integer NOT NULL,
    "position" integer DEFAULT 0 NOT NULL
);


--
-- Name: fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE fields (
    id character varying(50) NOT NULL,
    active boolean DEFAULT true,
    "position" integer,
    data jsonb DEFAULT '{}'::jsonb
);


--
-- Name: hidden_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE hidden_fields (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    field_id character varying,
    user_id uuid
);


--
-- Name: holidays; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE holidays (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    inventory_pool_id uuid,
    start_date date,
    end_date date,
    name character varying
);


--
-- Name: images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE images (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    target_id uuid,
    target_type character varying,
    content_type character varying,
    filename character varying,
    size integer,
    parent_id uuid,
    content text,
    thumbnail boolean DEFAULT false,
    metadata json
);


--
-- Name: inventory_pools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE inventory_pools (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    description text,
    contact_details character varying,
    contract_description character varying,
    contract_url character varying,
    logo_url character varying,
    default_contract_note text,
    shortname character varying NOT NULL,
    email character varying NOT NULL,
    color text,
    print_contracts boolean DEFAULT true,
    opening_hours text,
    address_id uuid,
    automatic_suspension boolean DEFAULT false NOT NULL,
    automatic_suspension_reason text,
    automatic_access boolean,
    required_purpose boolean DEFAULT true,
    is_active boolean DEFAULT true NOT NULL
);


--
-- Name: inventory_pools_model_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE inventory_pools_model_groups (
    inventory_pool_id uuid,
    model_group_id uuid
);


--
-- Name: items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE items (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    inventory_code character varying NOT NULL,
    serial_number character varying,
    model_id uuid NOT NULL,
    supplier_id uuid,
    owner_id uuid NOT NULL,
    inventory_pool_id uuid NOT NULL,
    parent_id uuid,
    invoice_number character varying,
    invoice_date date,
    last_check date,
    retired date,
    retired_reason character varying,
    price numeric(8,2),
    is_broken boolean DEFAULT false,
    is_incomplete boolean DEFAULT false,
    is_borrowable boolean DEFAULT false,
    status_note text,
    needs_permission boolean DEFAULT false,
    is_inventory_relevant boolean DEFAULT false,
    responsible character varying,
    insurance_number character varying,
    note text,
    name text,
    user_name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    shelf text,
    room_id uuid NOT NULL,
    properties jsonb DEFAULT '{}'::jsonb,
    item_version character varying
);


--
-- Name: languages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE languages (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying,
    locale_name character varying,
    "default" boolean,
    active boolean
);


--
-- Name: mail_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE mail_templates (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    inventory_pool_id uuid,
    language_id uuid,
    name character varying,
    format character varying,
    body text
);


--
-- Name: model_group_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE model_group_links (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    parent_id uuid,
    child_id uuid,
    label character varying
);


--
-- Name: model_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE model_groups (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    type character varying,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: model_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE model_links (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    model_group_id uuid NOT NULL,
    model_id uuid NOT NULL,
    quantity integer DEFAULT 1 NOT NULL
);


--
-- Name: models; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE models (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    type character varying DEFAULT 'Model'::character varying NOT NULL,
    manufacturer character varying,
    product character varying NOT NULL,
    version character varying,
    description text,
    internal_description text,
    info_url character varying,
    rental_price numeric(8,2),
    maintenance_period integer DEFAULT 0,
    is_package boolean DEFAULT false,
    technical_detail text,
    hand_over_note text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: models_compatibles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE models_compatibles (
    model_id uuid,
    compatible_id uuid
);


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE notifications (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_id uuid,
    title character varying DEFAULT ''::character varying,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: numerators; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE numerators (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    item integer
);


--
-- Name: old_empty_contracts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE old_empty_contracts (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    compact_id text NOT NULL,
    note text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE options (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    inventory_pool_id uuid NOT NULL,
    inventory_code character varying DEFAULT (uuid_generate_v4())::text NOT NULL,
    manufacturer character varying,
    product character varying NOT NULL,
    version character varying,
    price numeric(8,2)
);


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE orders (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    inventory_pool_id uuid NOT NULL,
    purpose text,
    state text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    reject_reason character varying,
    CONSTRAINT check_state_and_reject_reason_consistency CHECK ((((state = ANY (ARRAY['submitted'::text, 'approved'::text, 'rejected'::text])) AND (reject_reason IS NULL)) OR ((state = 'rejected'::text) AND (reject_reason IS NOT NULL)))),
    CONSTRAINT check_valid_state CHECK ((state = ANY (ARRAY['submitted'::text, 'approved'::text, 'rejected'::text])))
);


--
-- Name: procurement_accesses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE procurement_accesses (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_id uuid,
    organization_id uuid,
    is_admin boolean
);


--
-- Name: procurement_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE procurement_attachments (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    request_id uuid,
    filename character varying,
    content_type character varying,
    size integer,
    content text,
    metadata json
);


--
-- Name: procurement_budget_limits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE procurement_budget_limits (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    budget_period_id uuid NOT NULL,
    main_category_id uuid NOT NULL,
    amount_cents integer DEFAULT 0 NOT NULL,
    amount_currency character varying DEFAULT 'CHF'::character varying NOT NULL
);


--
-- Name: procurement_budget_periods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE procurement_budget_periods (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    inspection_start_date date NOT NULL,
    end_date date NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: procurement_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE procurement_categories (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying,
    main_category_id uuid,
    general_ledger_account character varying,
    cost_center character varying
);


--
-- Name: procurement_category_inspectors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE procurement_category_inspectors (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    category_id uuid NOT NULL
);


--
-- Name: procurement_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE procurement_images (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    main_category_id uuid NOT NULL,
    content_type character varying NOT NULL,
    content character varying NOT NULL,
    filename character varying NOT NULL,
    size integer,
    parent_id uuid,
    metadata json
);


--
-- Name: procurement_main_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE procurement_main_categories (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying
);


--
-- Name: procurement_organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE procurement_organizations (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying,
    shortname character varying,
    parent_id uuid
);


--
-- Name: procurement_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE procurement_requests (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    budget_period_id uuid,
    category_id uuid NOT NULL,
    user_id uuid,
    organization_id uuid,
    model_id uuid,
    supplier_id uuid,
    template_id uuid,
    article_name character varying NOT NULL,
    article_number character varying,
    requested_quantity integer NOT NULL,
    approved_quantity integer,
    order_quantity integer,
    price_cents integer DEFAULT 0 NOT NULL,
    price_currency character varying DEFAULT 'CHF'::character varying NOT NULL,
    priority character varying DEFAULT 'normal'::character varying NOT NULL,
    replacement boolean DEFAULT true,
    supplier_name character varying,
    receiver character varying,
    location_name character varying,
    motivation character varying,
    inspection_comment character varying,
    created_at timestamp without time zone NOT NULL,
    inspector_priority character varying DEFAULT 'medium'::character varying NOT NULL,
    room_id uuid NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    accounting_type character varying DEFAULT 'aquisition'::character varying NOT NULL,
    internal_order_number character varying,
    CONSTRAINT check_allowed_priorities CHECK (((priority)::text = ANY ((ARRAY['normal'::character varying, 'high'::character varying])::text[]))),
    CONSTRAINT check_inspector_priority CHECK (((inspector_priority)::text = ANY ((ARRAY['low'::character varying, 'medium'::character varying, 'high'::character varying, 'mandatory'::character varying])::text[]))),
    CONSTRAINT check_internal_order_number_if_type_investment CHECK ((NOT (((accounting_type)::text = 'investment'::text) AND (internal_order_number IS NULL)))),
    CONSTRAINT check_valid_accounting_type CHECK (((accounting_type)::text = ANY ((ARRAY['aquisition'::character varying, 'investment'::character varying])::text[])))
);


--
-- Name: procurement_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE procurement_settings (
    id integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    contact_url character varying,
    inspection_comments jsonb DEFAULT '[]'::jsonb,
    CONSTRAINT oneandonly CHECK ((id = 0))
);


--
-- Name: procurement_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE procurement_templates (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    model_id uuid,
    supplier_id uuid,
    article_name character varying NOT NULL,
    article_number character varying,
    price_cents integer DEFAULT 0 NOT NULL,
    price_currency character varying DEFAULT 'CHF'::character varying NOT NULL,
    supplier_name character varying,
    category_id uuid NOT NULL
);


--
-- Name: procurement_users_filters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE procurement_users_filters (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    user_id uuid,
    filter json
);


--
-- Name: properties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE properties (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    model_id uuid,
    key character varying NOT NULL,
    value character varying NOT NULL
);


--
-- Name: reservations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE reservations (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    contract_id uuid,
    inventory_pool_id uuid NOT NULL,
    user_id uuid NOT NULL,
    delegated_user_id uuid,
    handed_over_by_user_id uuid,
    type character varying DEFAULT 'ItemLine'::character varying NOT NULL,
    status reservation_status NOT NULL,
    item_id uuid,
    model_id uuid,
    quantity integer DEFAULT 1,
    start_date date,
    end_date date,
    returned_date date,
    option_id uuid,
    returned_to_user_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    order_id uuid,
    CONSTRAINT check_order_id_for_different_statuses_of_item_line CHECK (((((type)::text = 'ItemLine'::text) AND (((status = 'unsubmitted'::reservation_status) AND (order_id IS NULL)) OR ((status = ANY (ARRAY['submitted'::reservation_status, 'rejected'::reservation_status])) AND (order_id IS NOT NULL)) OR (status = ANY (ARRAY['approved'::reservation_status, 'signed'::reservation_status, 'closed'::reservation_status])))) OR (((type)::text = 'OptionLine'::text) AND (status = ANY (ARRAY['approved'::reservation_status, 'signed'::reservation_status, 'closed'::reservation_status]))))),
    CONSTRAINT check_valid_status_and_contract_id CHECK ((((status = ANY (ARRAY['unsubmitted'::reservation_status, 'submitted'::reservation_status, 'approved'::reservation_status, 'rejected'::reservation_status])) AND (contract_id IS NULL)) OR ((status = ANY (ARRAY['signed'::reservation_status, 'closed'::reservation_status])) AND (contract_id IS NOT NULL))))
);


--
-- Name: rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rooms (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    description text,
    building_id uuid NOT NULL,
    general boolean DEFAULT false NOT NULL,
    CONSTRAINT check_non_empty_name CHECK (((name)::text !~ '^\s*$'::text))
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE settings (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    smtp_address character varying,
    smtp_port integer,
    smtp_domain character varying,
    local_currency_string character varying NOT NULL,
    contract_terms text,
    contract_lending_party_string text,
    email_signature character varying NOT NULL,
    default_email character varying NOT NULL,
    deliver_order_notifications boolean,
    user_image_url character varying,
    ldap_config character varying,
    logo_url character varying,
    mail_delivery_method character varying,
    smtp_username character varying,
    smtp_password character varying,
    smtp_enable_starttls_auto boolean DEFAULT false NOT NULL,
    smtp_openssl_verify_mode character varying DEFAULT 'none'::character varying NOT NULL,
    time_zone character varying DEFAULT 'Bern'::character varying NOT NULL,
    disable_manage_section boolean DEFAULT false NOT NULL,
    disable_manage_section_message text,
    disable_borrow_section boolean DEFAULT false NOT NULL,
    disable_borrow_section_message text,
    text text,
    timeout_minutes integer DEFAULT 30 NOT NULL,
    external_base_url character varying,
    custom_head_tag text,
    sessions_max_lifetime_secs integer DEFAULT 432000,
    sessions_force_uniqueness boolean DEFAULT true NOT NULL,
    sessions_force_secure boolean DEFAULT false NOT NULL
);


--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE suppliers (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_sessions (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    token_hash text NOT NULL,
    user_id uuid,
    delegation_id uuid,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    login character varying,
    firstname character varying NOT NULL,
    lastname character varying,
    phone character varying,
    authentication_system_id uuid,
    unique_id character varying,
    email character varying,
    badge_id character varying,
    address character varying,
    city character varying,
    zip character varying,
    country character varying,
    language_id uuid,
    extended_info text,
    settings character varying(1024),
    delegator_user_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: workdays; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE workdays (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    inventory_pool_id uuid,
    monday boolean DEFAULT true,
    tuesday boolean DEFAULT true,
    wednesday boolean DEFAULT true,
    thursday boolean DEFAULT true,
    friday boolean DEFAULT true,
    saturday boolean DEFAULT false,
    sunday boolean DEFAULT false,
    reservation_advance_days integer DEFAULT 0,
    max_visits text
);


--
-- Name: access_rights access_rights_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY access_rights
    ADD CONSTRAINT access_rights_pkey PRIMARY KEY (id);


--
-- Name: accessories accessories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accessories
    ADD CONSTRAINT accessories_pkey PRIMARY KEY (id);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: audits audits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY audits
    ADD CONSTRAINT audits_pkey PRIMARY KEY (id);


--
-- Name: authentication_systems authentication_systems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authentication_systems
    ADD CONSTRAINT authentication_systems_pkey PRIMARY KEY (id);


--
-- Name: buildings buildings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY buildings
    ADD CONSTRAINT buildings_pkey PRIMARY KEY (id);


--
-- Name: contracts contracts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contracts
    ADD CONSTRAINT contracts_pkey PRIMARY KEY (id);


--
-- Name: database_authentications database_authentications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY database_authentications
    ADD CONSTRAINT database_authentications_pkey PRIMARY KEY (id);


--
-- Name: fields fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fields
    ADD CONSTRAINT fields_pkey PRIMARY KEY (id);


--
-- Name: entitlement_groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entitlement_groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: hidden_fields hidden_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hidden_fields
    ADD CONSTRAINT hidden_fields_pkey PRIMARY KEY (id);


--
-- Name: holidays holidays_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY holidays
    ADD CONSTRAINT holidays_pkey PRIMARY KEY (id);


--
-- Name: images images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id);


--
-- Name: inventory_pools inventory_pools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_pools
    ADD CONSTRAINT inventory_pools_pkey PRIMARY KEY (id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);


--
-- Name: mail_templates mail_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY mail_templates
    ADD CONSTRAINT mail_templates_pkey PRIMARY KEY (id);


--
-- Name: model_group_links model_group_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY model_group_links
    ADD CONSTRAINT model_group_links_pkey PRIMARY KEY (id);


--
-- Name: model_groups model_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY model_groups
    ADD CONSTRAINT model_groups_pkey PRIMARY KEY (id);


--
-- Name: model_links model_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY model_links
    ADD CONSTRAINT model_links_pkey PRIMARY KEY (id);


--
-- Name: models models_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY models
    ADD CONSTRAINT models_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: numerators numerators_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY numerators
    ADD CONSTRAINT numerators_pkey PRIMARY KEY (id);


--
-- Name: old_empty_contracts old_empty_contracts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY old_empty_contracts
    ADD CONSTRAINT old_empty_contracts_pkey PRIMARY KEY (id);


--
-- Name: options options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY options
    ADD CONSTRAINT options_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: entitlements partitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entitlements
    ADD CONSTRAINT partitions_pkey PRIMARY KEY (id);


--
-- Name: procurement_accesses procurement_accesses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_accesses
    ADD CONSTRAINT procurement_accesses_pkey PRIMARY KEY (id);


--
-- Name: procurement_attachments procurement_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_attachments
    ADD CONSTRAINT procurement_attachments_pkey PRIMARY KEY (id);


--
-- Name: procurement_budget_limits procurement_budget_limits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_budget_limits
    ADD CONSTRAINT procurement_budget_limits_pkey PRIMARY KEY (id);


--
-- Name: procurement_budget_periods procurement_budget_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_budget_periods
    ADD CONSTRAINT procurement_budget_periods_pkey PRIMARY KEY (id);


--
-- Name: procurement_categories procurement_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_categories
    ADD CONSTRAINT procurement_categories_pkey PRIMARY KEY (id);


--
-- Name: procurement_category_inspectors procurement_category_inspectors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_category_inspectors
    ADD CONSTRAINT procurement_category_inspectors_pkey PRIMARY KEY (id);


--
-- Name: procurement_images procurement_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_images
    ADD CONSTRAINT procurement_images_pkey PRIMARY KEY (id);


--
-- Name: procurement_main_categories procurement_main_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_main_categories
    ADD CONSTRAINT procurement_main_categories_pkey PRIMARY KEY (id);


--
-- Name: procurement_organizations procurement_organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_organizations
    ADD CONSTRAINT procurement_organizations_pkey PRIMARY KEY (id);


--
-- Name: procurement_requests procurement_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_requests
    ADD CONSTRAINT procurement_requests_pkey PRIMARY KEY (id);


--
-- Name: procurement_settings procurement_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_settings
    ADD CONSTRAINT procurement_settings_pkey PRIMARY KEY (id);


--
-- Name: procurement_templates procurement_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_templates
    ADD CONSTRAINT procurement_templates_pkey PRIMARY KEY (id);


--
-- Name: procurement_users_filters procurement_users_filters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_users_filters
    ADD CONSTRAINT procurement_users_filters_pkey PRIMARY KEY (id);


--
-- Name: properties properties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY properties
    ADD CONSTRAINT properties_pkey PRIMARY KEY (id);


--
-- Name: reservations reservations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reservations
    ADD CONSTRAINT reservations_pkey PRIMARY KEY (id);


--
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);


--
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: workdays workdays_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY workdays
    ADD CONSTRAINT workdays_pkey PRIMARY KEY (id);


--
-- Name: associated_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX associated_index ON audits USING btree (associated_id, associated_type);


--
-- Name: auditable_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auditable_index ON audits USING btree (auditable_id, auditable_type);


--
-- Name: case_insensitive_inventory_code_for_items; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX case_insensitive_inventory_code_for_items ON items USING btree (lower((inventory_code)::text));


--
-- Name: case_insensitive_inventory_code_for_options; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX case_insensitive_inventory_code_for_options ON options USING btree (lower((inventory_code)::text));


--
-- Name: idx_model_pool_egroup; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_model_pool_egroup ON entitlements USING btree (model_id, inventory_pool_id, entitlement_group_id);


--
-- Name: idx_procurement_group_inspectors_uc; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_procurement_group_inspectors_uc ON procurement_category_inspectors USING btree (user_id, category_id);


--
-- Name: idx_user_egroup; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_user_egroup ON entitlement_groups_users USING btree (user_id, entitlement_group_id);


--
-- Name: index_access_rights_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_rights_on_deleted_at ON access_rights USING btree (deleted_at);


--
-- Name: index_access_rights_on_inventory_pool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_rights_on_inventory_pool_id ON access_rights USING btree (inventory_pool_id);


--
-- Name: index_access_rights_on_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_rights_on_role ON access_rights USING btree (role);


--
-- Name: index_access_rights_on_suspended_until; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_access_rights_on_suspended_until ON access_rights USING btree (suspended_until);


--
-- Name: index_accessories_inventory_pools; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_accessories_inventory_pools ON accessories_inventory_pools USING btree (accessory_id, inventory_pool_id);


--
-- Name: index_accessories_inventory_pools_on_inventory_pool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accessories_inventory_pools_on_inventory_pool_id ON accessories_inventory_pools USING btree (inventory_pool_id);


--
-- Name: index_accessories_on_model_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accessories_on_model_id ON accessories USING btree (model_id);


--
-- Name: index_addresses_szcc; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_addresses_szcc ON addresses USING btree (street, zip_code, city, country_code);


--
-- Name: index_attachments_on_model_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attachments_on_model_id ON attachments USING btree (model_id);


--
-- Name: index_audits_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audits_on_created_at ON audits USING btree (created_at);


--
-- Name: index_audits_on_request_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audits_on_request_uuid ON audits USING btree (request_uuid);


--
-- Name: index_contracts_on_compact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_contracts_on_compact_id ON contracts USING btree (compact_id);


--
-- Name: index_contracts_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_created_at ON contracts USING btree (created_at);


--
-- Name: index_contracts_on_inventory_pool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_inventory_pool_id ON contracts USING btree (inventory_pool_id);


--
-- Name: index_contracts_on_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_state ON contracts USING btree (state);


--
-- Name: index_contracts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contracts_on_user_id ON contracts USING btree (user_id);


--
-- Name: index_delegations_users_on_delegation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delegations_users_on_delegation_id ON delegations_users USING btree (delegation_id);


--
-- Name: index_delegations_users_on_user_id_and_delegation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_delegations_users_on_user_id_and_delegation_id ON delegations_users USING btree (user_id, delegation_id);


--
-- Name: index_entitlement_groups_on_inventory_pool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entitlement_groups_on_inventory_pool_id ON entitlement_groups USING btree (inventory_pool_id);


--
-- Name: index_entitlement_groups_on_is_verification_required; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entitlement_groups_on_is_verification_required ON entitlement_groups USING btree (is_verification_required);


--
-- Name: index_entitlement_groups_users_on_entitlement_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entitlement_groups_users_on_entitlement_group_id ON entitlement_groups_users USING btree (entitlement_group_id);


--
-- Name: index_entitlements_on_entitlement_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entitlements_on_entitlement_group_id ON entitlements USING btree (entitlement_group_id);


--
-- Name: index_entitlements_on_inventory_pool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entitlements_on_inventory_pool_id ON entitlements USING btree (inventory_pool_id);


--
-- Name: index_entitlements_on_model_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entitlements_on_model_id ON entitlements USING btree (model_id);


--
-- Name: index_fields_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fields_on_active ON fields USING btree (active);


--
-- Name: index_holidays_on_inventory_pool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_holidays_on_inventory_pool_id ON holidays USING btree (inventory_pool_id);


--
-- Name: index_holidays_on_start_date_and_end_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_holidays_on_start_date_and_end_date ON holidays USING btree (start_date, end_date);


--
-- Name: index_images_on_target_id_and_target_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_images_on_target_id_and_target_type ON images USING btree (target_id, target_type);


--
-- Name: index_inventory_pools_model_groups_on_inventory_pool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inventory_pools_model_groups_on_inventory_pool_id ON inventory_pools_model_groups USING btree (inventory_pool_id);


--
-- Name: index_inventory_pools_model_groups_on_model_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inventory_pools_model_groups_on_model_group_id ON inventory_pools_model_groups USING btree (model_group_id);


--
-- Name: index_inventory_pools_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_inventory_pools_on_name ON inventory_pools USING btree (name);


--
-- Name: index_items_on_inventory_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_items_on_inventory_code ON items USING btree (inventory_code);


--
-- Name: index_items_on_inventory_pool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_inventory_pool_id ON items USING btree (inventory_pool_id);


--
-- Name: index_items_on_is_borrowable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_is_borrowable ON items USING btree (is_borrowable);


--
-- Name: index_items_on_is_broken; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_is_broken ON items USING btree (is_broken);


--
-- Name: index_items_on_is_incomplete; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_is_incomplete ON items USING btree (is_incomplete);


--
-- Name: index_items_on_model_id_and_retired_and_inventory_pool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_model_id_and_retired_and_inventory_pool_id ON items USING btree (model_id, retired, inventory_pool_id);


--
-- Name: index_items_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_owner_id ON items USING btree (owner_id);


--
-- Name: index_items_on_parent_id_and_retired; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_parent_id_and_retired ON items USING btree (parent_id, retired);


--
-- Name: index_items_on_retired; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_retired ON items USING btree (retired);


--
-- Name: index_languages_on_active_and_default; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_languages_on_active_and_default ON languages USING btree (active, "default");


--
-- Name: index_languages_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_languages_on_name ON languages USING btree (name);


--
-- Name: index_model_group_links_on_child_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_model_group_links_on_child_id ON model_group_links USING btree (child_id);


--
-- Name: index_model_group_links_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_model_group_links_on_parent_id ON model_group_links USING btree (parent_id);


--
-- Name: index_model_groups_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_model_groups_on_type ON model_groups USING btree (type);


--
-- Name: index_model_links_on_model_group_id_and_model_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_model_links_on_model_group_id_and_model_id ON model_links USING btree (model_group_id, model_id);


--
-- Name: index_model_links_on_model_id_and_model_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_model_links_on_model_id_and_model_group_id ON model_links USING btree (model_id, model_group_id);


--
-- Name: index_models_compatibles_on_compatible_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_models_compatibles_on_compatible_id ON models_compatibles USING btree (compatible_id);


--
-- Name: index_models_compatibles_on_model_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_models_compatibles_on_model_id ON models_compatibles USING btree (model_id);


--
-- Name: index_models_on_is_package; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_models_on_is_package ON models USING btree (is_package);


--
-- Name: index_models_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_models_on_type ON models USING btree (type);


--
-- Name: index_notifications_on_created_at_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_created_at_and_user_id ON notifications USING btree (created_at, user_id);


--
-- Name: index_notifications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notifications_on_user_id ON notifications USING btree (user_id);


--
-- Name: index_old_empty_contracts_on_compact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_old_empty_contracts_on_compact_id ON old_empty_contracts USING btree (compact_id);


--
-- Name: index_on_budget_period_id_and_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_on_budget_period_id_and_category_id ON procurement_budget_limits USING btree (budget_period_id, main_category_id);


--
-- Name: index_on_user_id_and_inventory_pool_id_and_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_on_user_id_and_inventory_pool_id_and_deleted_at ON access_rights USING btree (user_id, inventory_pool_id, deleted_at);


--
-- Name: index_options_on_inventory_pool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_options_on_inventory_pool_id ON options USING btree (inventory_pool_id);


--
-- Name: index_orders_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_created_at ON orders USING btree (created_at);


--
-- Name: index_orders_on_inventory_pool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_inventory_pool_id ON orders USING btree (inventory_pool_id);


--
-- Name: index_orders_on_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_state ON orders USING btree (state);


--
-- Name: index_orders_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_user_id ON orders USING btree (user_id);


--
-- Name: index_procurement_accesses_on_is_admin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_procurement_accesses_on_is_admin ON procurement_accesses USING btree (is_admin);


--
-- Name: index_procurement_budget_periods_on_end_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_procurement_budget_periods_on_end_date ON procurement_budget_periods USING btree (end_date);


--
-- Name: index_procurement_categories_on_main_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_procurement_categories_on_main_category_id ON procurement_categories USING btree (main_category_id);


--
-- Name: index_procurement_categories_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_procurement_categories_on_name ON procurement_categories USING btree (name);


--
-- Name: index_procurement_main_categories_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_procurement_main_categories_on_name ON procurement_main_categories USING btree (name);


--
-- Name: index_procurement_users_filters_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_procurement_users_filters_on_user_id ON procurement_users_filters USING btree (user_id);


--
-- Name: index_properties_on_model_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_properties_on_model_id ON properties USING btree (model_id);


--
-- Name: index_reservations_on_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reservations_on_contract_id ON reservations USING btree (contract_id);


--
-- Name: index_reservations_on_end_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reservations_on_end_date ON reservations USING btree (end_date);


--
-- Name: index_reservations_on_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reservations_on_item_id ON reservations USING btree (item_id);


--
-- Name: index_reservations_on_model_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reservations_on_model_id ON reservations USING btree (model_id);


--
-- Name: index_reservations_on_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reservations_on_option_id ON reservations USING btree (option_id);


--
-- Name: index_reservations_on_returned_date_and_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reservations_on_returned_date_and_contract_id ON reservations USING btree (returned_date, contract_id);


--
-- Name: index_reservations_on_start_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reservations_on_start_date ON reservations USING btree (start_date);


--
-- Name: index_reservations_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reservations_on_status ON reservations USING btree (status);


--
-- Name: index_reservations_on_type_and_contract_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reservations_on_type_and_contract_id ON reservations USING btree (type, contract_id);


--
-- Name: index_suppliers_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_suppliers_on_name ON suppliers USING btree (name);


--
-- Name: index_user_sessions_on_token_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_sessions_on_token_hash ON user_sessions USING btree (token_hash);


--
-- Name: index_user_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_sessions_on_user_id ON user_sessions USING btree (user_id);


--
-- Name: index_users_on_authentication_system_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_authentication_system_id ON users USING btree (authentication_system_id);


--
-- Name: index_workdays_on_inventory_pool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workdays_on_inventory_pool_id ON workdays USING btree (inventory_pool_id);


--
-- Name: rooms_unique_building_id_general_true; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX rooms_unique_building_id_general_true ON rooms USING btree (building_id, general) WHERE (general IS TRUE);


--
-- Name: rooms_unique_name_and_building_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX rooms_unique_name_and_building_id ON rooms USING btree ((((lower((name)::text) || ' '::text) || building_id)));


--
-- Name: user_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX user_index ON audits USING btree (user_id, user_type);


--
-- Name: reservations trigger_check_closed_reservations_contract_state; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_check_closed_reservations_contract_state AFTER INSERT OR UPDATE ON reservations DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE check_closed_reservations_contract_state();


--
-- Name: contracts trigger_check_contract_has_at_least_one_reservation; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_check_contract_has_at_least_one_reservation AFTER INSERT OR UPDATE ON contracts DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE check_contract_has_at_least_one_reservation();


--
-- Name: rooms trigger_check_general_building_id_for_general_room; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_check_general_building_id_for_general_room AFTER UPDATE ON rooms NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE check_general_building_id_for_general_room();


--
-- Name: reservations trigger_check_item_line_state_consistency; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_check_item_line_state_consistency AFTER INSERT OR UPDATE ON reservations DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE check_item_line_state_consistency();


--
-- Name: reservations trigger_check_option_line_state_consistency; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_check_option_line_state_consistency AFTER INSERT OR UPDATE ON reservations DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE check_option_line_state_consistency();


--
-- Name: reservations trigger_check_reservation_contract_inventory_pool_id_consistenc; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_check_reservation_contract_inventory_pool_id_consistenc AFTER INSERT OR UPDATE ON reservations DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE check_reservation_contract_inventory_pool_id_consistency();


--
-- Name: reservations trigger_check_reservation_contract_user_id_consistency; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_check_reservation_contract_user_id_consistency AFTER INSERT OR UPDATE ON reservations DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE check_reservation_contract_user_id_consistency();


--
-- Name: reservations trigger_check_reservation_order_inventory_pool_id_consistency; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_check_reservation_order_inventory_pool_id_consistency AFTER INSERT OR UPDATE ON reservations DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE check_reservation_order_inventory_pool_id_consistency();


--
-- Name: reservations trigger_check_reservation_order_user_id_consistency; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_check_reservation_order_user_id_consistency AFTER INSERT OR UPDATE ON reservations DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE check_reservation_order_user_id_consistency();


--
-- Name: contracts trigger_check_reservations_contracts_state_consistency; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_check_reservations_contracts_state_consistency AFTER INSERT OR UPDATE ON contracts DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE check_reservations_contracts_state_consistency();


--
-- Name: reservations trigger_delete_empty_order; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_delete_empty_order AFTER DELETE ON reservations DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE delete_empty_order();


--
-- Name: procurement_accesses trigger_delete_procurement_users_filters_after_procurement_acce; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_delete_procurement_users_filters_after_procurement_acce AFTER DELETE ON procurement_accesses DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE delete_procurement_users_filters_after_procurement_accesses();


--
-- Name: users trigger_delete_procurement_users_filters_after_users; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_delete_procurement_users_filters_after_users AFTER DELETE ON users DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE delete_procurement_users_filters_after_users();


--
-- Name: buildings trigger_ensure_general_building_cannot_be_deleted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_ensure_general_building_cannot_be_deleted AFTER DELETE ON buildings NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE ensure_general_building_cannot_be_deleted();


--
-- Name: rooms trigger_ensure_general_room_cannot_be_deleted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE CONSTRAINT TRIGGER trigger_ensure_general_room_cannot_be_deleted AFTER DELETE ON rooms NOT DEFERRABLE INITIALLY IMMEDIATE FOR EACH ROW EXECUTE PROCEDURE ensure_general_room_cannot_be_deleted();


--
-- Name: fields trigger_restrict_operations_on_fields_function; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_restrict_operations_on_fields_function BEFORE INSERT OR DELETE ON fields FOR EACH STATEMENT EXECUTE PROCEDURE restrict_operations_on_fields_function();


--
-- Name: hidden_fields fk_rails_00a4ef0c4f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hidden_fields
    ADD CONSTRAINT fk_rails_00a4ef0c4f FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: items fk_rails_042cf7b23c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY items
    ADD CONSTRAINT fk_rails_042cf7b23c FOREIGN KEY (inventory_pool_id) REFERENCES inventory_pools(id);


--
-- Name: procurement_organizations fk_rails_0731e8b712; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_organizations
    ADD CONSTRAINT fk_rails_0731e8b712 FOREIGN KEY (parent_id) REFERENCES procurement_organizations(id);


--
-- Name: items fk_rails_0ed18b3bf9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY items
    ADD CONSTRAINT fk_rails_0ed18b3bf9 FOREIGN KEY (model_id) REFERENCES models(id);


--
-- Name: model_links fk_rails_11add1a9a3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY model_links
    ADD CONSTRAINT fk_rails_11add1a9a3 FOREIGN KEY (model_group_id) REFERENCES model_groups(id) ON DELETE CASCADE;


--
-- Name: reservations fk_rails_151794e412; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reservations
    ADD CONSTRAINT fk_rails_151794e412 FOREIGN KEY (inventory_pool_id) REFERENCES inventory_pools(id);


--
-- Name: contracts fk_rails_1bf8633565; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contracts
    ADD CONSTRAINT fk_rails_1bf8633565 FOREIGN KEY (inventory_pool_id) REFERENCES inventory_pools(id);


--
-- Name: procurement_budget_limits fk_rails_1c5f9021ad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_budget_limits
    ADD CONSTRAINT fk_rails_1c5f9021ad FOREIGN KEY (main_category_id) REFERENCES procurement_main_categories(id);


--
-- Name: procurement_requests fk_rails_214a7de1ff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_requests
    ADD CONSTRAINT fk_rails_214a7de1ff FOREIGN KEY (model_id) REFERENCES models(id);


--
-- Name: users fk_rails_330f34f125; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_rails_330f34f125 FOREIGN KEY (authentication_system_id) REFERENCES authentication_systems(id);


--
-- Name: procurement_attachments fk_rails_396a61ca60; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_attachments
    ADD CONSTRAINT fk_rails_396a61ca60 FOREIGN KEY (request_id) REFERENCES procurement_requests(id);


--
-- Name: reservations fk_rails_3cc4562273; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reservations
    ADD CONSTRAINT fk_rails_3cc4562273 FOREIGN KEY (handed_over_by_user_id) REFERENCES users(id);


--
-- Name: hidden_fields fk_rails_3dac013d86; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hidden_fields
    ADD CONSTRAINT fk_rails_3dac013d86 FOREIGN KEY (field_id) REFERENCES fields(id) ON DELETE CASCADE;


--
-- Name: mail_templates fk_rails_3e8b923972; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY mail_templates
    ADD CONSTRAINT fk_rails_3e8b923972 FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE;


--
-- Name: entitlements fk_rails_44495fc6cf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entitlements
    ADD CONSTRAINT fk_rails_44495fc6cf FOREIGN KEY (entitlement_group_id) REFERENCES entitlement_groups(id);


--
-- Name: users fk_rails_45f4f12508; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_rails_45f4f12508 FOREIGN KEY (language_id) REFERENCES languages(id);


--
-- Name: entitlement_groups fk_rails_45f96f9df2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entitlement_groups
    ADD CONSTRAINT fk_rails_45f96f9df2 FOREIGN KEY (inventory_pool_id) REFERENCES inventory_pools(id);


--
-- Name: procurement_templates fk_rails_46cc05bf71; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_templates
    ADD CONSTRAINT fk_rails_46cc05bf71 FOREIGN KEY (supplier_id) REFERENCES suppliers(id);


--
-- Name: procurement_images fk_rails_47fed491ad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_images
    ADD CONSTRAINT fk_rails_47fed491ad FOREIGN KEY (parent_id) REFERENCES procurement_images(id);


--
-- Name: reservations fk_rails_48a92fce51; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reservations
    ADD CONSTRAINT fk_rails_48a92fce51 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: model_group_links fk_rails_48e1ccdd03; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY model_group_links
    ADD CONSTRAINT fk_rails_48e1ccdd03 FOREIGN KEY (child_id) REFERENCES model_groups(id) ON DELETE CASCADE;


--
-- Name: procurement_requests fk_rails_4c51bafad3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_requests
    ADD CONSTRAINT fk_rails_4c51bafad3 FOREIGN KEY (organization_id) REFERENCES procurement_organizations(id);


--
-- Name: reservations fk_rails_4d0c0195f0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reservations
    ADD CONSTRAINT fk_rails_4d0c0195f0 FOREIGN KEY (item_id) REFERENCES items(id);


--
-- Name: entitlement_groups_users fk_rails_4e63edbd27; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entitlement_groups_users
    ADD CONSTRAINT fk_rails_4e63edbd27 FOREIGN KEY (entitlement_group_id) REFERENCES entitlement_groups(id);


--
-- Name: procurement_requests fk_rails_51707743b7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_requests
    ADD CONSTRAINT fk_rails_51707743b7 FOREIGN KEY (supplier_id) REFERENCES suppliers(id);


--
-- Name: items fk_rails_538506beaf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY items
    ADD CONSTRAINT fk_rails_538506beaf FOREIGN KEY (supplier_id) REFERENCES suppliers(id);


--
-- Name: accessories fk_rails_54c6f19548; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accessories
    ADD CONSTRAINT fk_rails_54c6f19548 FOREIGN KEY (model_id) REFERENCES models(id) ON DELETE CASCADE;


--
-- Name: models_compatibles fk_rails_5c311e46b1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY models_compatibles
    ADD CONSTRAINT fk_rails_5c311e46b1 FOREIGN KEY (model_id) REFERENCES models(id);


--
-- Name: reservations fk_rails_5cc2043d96; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reservations
    ADD CONSTRAINT fk_rails_5cc2043d96 FOREIGN KEY (returned_to_user_id) REFERENCES users(id);


--
-- Name: mail_templates fk_rails_5d00b5b086; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY mail_templates
    ADD CONSTRAINT fk_rails_5d00b5b086 FOREIGN KEY (inventory_pool_id) REFERENCES inventory_pools(id) ON DELETE CASCADE;


--
-- Name: procurement_images fk_rails_62917a6a8f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_images
    ADD CONSTRAINT fk_rails_62917a6a8f FOREIGN KEY (main_category_id) REFERENCES procurement_main_categories(id);


--
-- Name: entitlements fk_rails_69c88ff594; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entitlements
    ADD CONSTRAINT fk_rails_69c88ff594 FOREIGN KEY (model_id) REFERENCES models(id) ON DELETE CASCADE;


--
-- Name: inventory_pools fk_rails_6a55965722; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_pools
    ADD CONSTRAINT fk_rails_6a55965722 FOREIGN KEY (address_id) REFERENCES addresses(id);


--
-- Name: inventory_pools_model_groups fk_rails_6a7781d99f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_pools_model_groups
    ADD CONSTRAINT fk_rails_6a7781d99f FOREIGN KEY (inventory_pool_id) REFERENCES inventory_pools(id);


--
-- Name: reservations fk_rails_6f10314351; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reservations
    ADD CONSTRAINT fk_rails_6f10314351 FOREIGN KEY (delegated_user_id) REFERENCES users(id);


--
-- Name: attachments fk_rails_753607b7c1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT fk_rails_753607b7c1 FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE;


--
-- Name: entitlement_groups_users fk_rails_8546c71994; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entitlement_groups_users
    ADD CONSTRAINT fk_rails_8546c71994 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: database_authentications fk_rails_85650bffa9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY database_authentications
    ADD CONSTRAINT fk_rails_85650bffa9 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: items fk_rails_8757b4d49c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY items
    ADD CONSTRAINT fk_rails_8757b4d49c FOREIGN KEY (owner_id) REFERENCES inventory_pools(id);


--
-- Name: user_sessions fk_rails_8987cee3fd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_sessions
    ADD CONSTRAINT fk_rails_8987cee3fd FOREIGN KEY (delegation_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: reservations fk_rails_8dc1da71d1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reservations
    ADD CONSTRAINT fk_rails_8dc1da71d1 FOREIGN KEY (contract_id) REFERENCES contracts(id) ON DELETE CASCADE;


--
-- Name: items fk_rails_9353db44a2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY items
    ADD CONSTRAINT fk_rails_9353db44a2 FOREIGN KEY (room_id) REFERENCES rooms(id);


--
-- Name: reservations fk_rails_943a884838; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reservations
    ADD CONSTRAINT fk_rails_943a884838 FOREIGN KEY (model_id) REFERENCES models(id);


--
-- Name: accessories_inventory_pools fk_rails_9511c9a747; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accessories_inventory_pools
    ADD CONSTRAINT fk_rails_9511c9a747 FOREIGN KEY (accessory_id) REFERENCES accessories(id);


--
-- Name: model_links fk_rails_9b7295b085; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY model_links
    ADD CONSTRAINT fk_rails_9b7295b085 FOREIGN KEY (model_id) REFERENCES models(id) ON DELETE CASCADE;


--
-- Name: user_sessions fk_rails_9fa262d742; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_sessions
    ADD CONSTRAINT fk_rails_9fa262d742 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: workdays fk_rails_a18bc267df; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY workdays
    ADD CONSTRAINT fk_rails_a18bc267df FOREIGN KEY (inventory_pool_id) REFERENCES inventory_pools(id) ON DELETE CASCADE;


--
-- Name: rooms fk_rails_a3957b23a8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rooms
    ADD CONSTRAINT fk_rails_a3957b23a8 FOREIGN KEY (building_id) REFERENCES buildings(id) ON DELETE CASCADE;


--
-- Name: properties fk_rails_a52b96ad3d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY properties
    ADD CONSTRAINT fk_rails_a52b96ad3d FOREIGN KEY (model_id) REFERENCES models(id) ON DELETE CASCADE;


--
-- Name: reservations fk_rails_a863d81c8a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reservations
    ADD CONSTRAINT fk_rails_a863d81c8a FOREIGN KEY (option_id) REFERENCES options(id);


--
-- Name: notifications fk_rails_b080fb4855; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT fk_rails_b080fb4855 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: entitlements fk_rails_b10a540212; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entitlements
    ADD CONSTRAINT fk_rails_b10a540212 FOREIGN KEY (inventory_pool_id) REFERENCES inventory_pools(id);


--
-- Name: access_rights fk_rails_b36d97eb0c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY access_rights
    ADD CONSTRAINT fk_rails_b36d97eb0c FOREIGN KEY (inventory_pool_id) REFERENCES inventory_pools(id) ON DELETE CASCADE;


--
-- Name: delegations_users fk_rails_b5f7f9c898; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegations_users
    ADD CONSTRAINT fk_rails_b5f7f9c898 FOREIGN KEY (delegation_id) REFERENCES users(id);


--
-- Name: procurement_requests fk_rails_b6213e1ee9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_requests
    ADD CONSTRAINT fk_rails_b6213e1ee9 FOREIGN KEY (budget_period_id) REFERENCES procurement_budget_periods(id);


--
-- Name: procurement_requests fk_rails_b740f37e3d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_requests
    ADD CONSTRAINT fk_rails_b740f37e3d FOREIGN KEY (category_id) REFERENCES procurement_categories(id);


--
-- Name: procurement_budget_limits fk_rails_beb637d785; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_budget_limits
    ADD CONSTRAINT fk_rails_beb637d785 FOREIGN KEY (budget_period_id) REFERENCES procurement_budget_periods(id);


--
-- Name: procurement_requests fk_rails_bf7bec026c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_requests
    ADD CONSTRAINT fk_rails_bf7bec026c FOREIGN KEY (template_id) REFERENCES procurement_templates(id);


--
-- Name: access_rights fk_rails_c10a7fd1fd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY access_rights
    ADD CONSTRAINT fk_rails_c10a7fd1fd FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: procurement_accesses fk_rails_c116e35025; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_accesses
    ADD CONSTRAINT fk_rails_c116e35025 FOREIGN KEY (organization_id) REFERENCES procurement_organizations(id);


--
-- Name: holidays fk_rails_c189a29194; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY holidays
    ADD CONSTRAINT fk_rails_c189a29194 FOREIGN KEY (inventory_pool_id) REFERENCES inventory_pools(id) ON DELETE CASCADE;


--
-- Name: inventory_pools_model_groups fk_rails_cb04742a0b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_pools_model_groups
    ADD CONSTRAINT fk_rails_cb04742a0b FOREIGN KEY (model_group_id) REFERENCES model_groups(id);


--
-- Name: model_group_links fk_rails_d4425f3184; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY model_group_links
    ADD CONSTRAINT fk_rails_d4425f3184 FOREIGN KEY (parent_id) REFERENCES model_groups(id) ON DELETE CASCADE;


--
-- Name: delegations_users fk_rails_df1fb72b34; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegations_users
    ADD CONSTRAINT fk_rails_df1fb72b34 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: models_compatibles fk_rails_e63411efbd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY models_compatibles
    ADD CONSTRAINT fk_rails_e63411efbd FOREIGN KEY (compatible_id) REFERENCES models(id);


--
-- Name: procurement_templates fk_rails_e6aab61827; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_templates
    ADD CONSTRAINT fk_rails_e6aab61827 FOREIGN KEY (model_id) REFERENCES models(id);


--
-- Name: accessories_inventory_pools fk_rails_e9daa88f6c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY accessories_inventory_pools
    ADD CONSTRAINT fk_rails_e9daa88f6c FOREIGN KEY (inventory_pool_id) REFERENCES inventory_pools(id);


--
-- Name: procurement_category_inspectors fk_rails_ed1149b98d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_category_inspectors
    ADD CONSTRAINT fk_rails_ed1149b98d FOREIGN KEY (category_id) REFERENCES procurement_categories(id);


--
-- Name: items fk_rails_ed5bf219ac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY items
    ADD CONSTRAINT fk_rails_ed5bf219ac FOREIGN KEY (parent_id) REFERENCES items(id) ON DELETE SET NULL;


--
-- Name: contracts fk_rails_f191b5ed7a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contracts
    ADD CONSTRAINT fk_rails_f191b5ed7a FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: procurement_requests fk_rails_f365098d3c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_requests
    ADD CONSTRAINT fk_rails_f365098d3c FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: procurement_requests fk_rails_f60a954ec5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_requests
    ADD CONSTRAINT fk_rails_f60a954ec5 FOREIGN KEY (room_id) REFERENCES rooms(id);


--
-- Name: attachments fk_rails_f6d36cd48e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY attachments
    ADD CONSTRAINT fk_rails_f6d36cd48e FOREIGN KEY (model_id) REFERENCES models(id) ON DELETE CASCADE;


--
-- Name: procurement_category_inspectors fk_rails_f80c94fb1e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_category_inspectors
    ADD CONSTRAINT fk_rails_f80c94fb1e FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: options fk_rails_fd8397be78; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY options
    ADD CONSTRAINT fk_rails_fd8397be78 FOREIGN KEY (inventory_pool_id) REFERENCES inventory_pools(id);


--
-- Name: procurement_templates fk_rails_fe27b0b24a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY procurement_templates
    ADD CONSTRAINT fk_rails_fe27b0b24a FOREIGN KEY (category_id) REFERENCES procurement_categories(id);


--
-- Name: images fkey_images_images_parent_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY images
    ADD CONSTRAINT fkey_images_images_parent_id FOREIGN KEY (parent_id) REFERENCES images(id);


--
-- Name: users fkey_users_delegators; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fkey_users_delegators FOREIGN KEY (delegator_user_id) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('0'),
('1'),
('10'),
('100'),
('101'),
('102'),
('103'),
('104'),
('105'),
('106'),
('107'),
('108'),
('109'),
('11'),
('110'),
('111'),
('112'),
('113'),
('114'),
('115'),
('116'),
('117'),
('118'),
('119'),
('12'),
('120'),
('121'),
('122'),
('13'),
('2'),
('200'),
('201'),
('202'),
('203'),
('204'),
('205'),
('206'),
('207'),
('208'),
('209'),
('210'),
('211'),
('212'),
('213'),
('4'),
('5'),
('6'),
('7'),
('8'),
('9');


