# rubocop:disable Metrics/ClassLength
module Presenters
  module Shared
    # Provides configuration for Filters in UI
    # TODO: usage counts for everything
    # NOTE: since order is important, every filter has a 'position' 0—99,
    #       Vocabularies are always last so their positions start at 100.
    # NOTE: Context sections are implemented as Presenters,
    # but everything else can't reuse anything. Just build plain hashes.
    class DynamicFilters < Presenter
      include Presenters::Shared::Modules::VocabularyConfig

      def initialize(user, scope, tree, existing_filters)
        @user = user
        @scope = scope
        @tree = tree || {}
        @resource_type = scope.model or fail 'TypeError! (Expected AR Scope)'
        @existing_filters = existing_filters
      end

      def section_group_media_files
        media_files(@scope, @tree)
      end

      def section_group_meta_data
        meta_data(@scope, @tree)
      end

      def section_group_permissions
        permissions(@scope)
      end

      private

      def media_files(scope, tree)
        return nil if @resource_type != MediaEntry

        media_files_filters(scope, get_key(tree, :media_files))
      end

      def permissions(scope)
        return nil if scope.count == 0

        children = [permissions_visibility(scope)]
        if @user
          children.concat(
            [
              permissions_responsible_user(scope),
              permissions_responsible_delegation(scope),
              permissions_entrusted_to_user(scope),
              permissions_entrusted_to_group(scope),
              permissions_entrusted_to_api_client(scope)
            ]
          )
        end
        children = children.compact

        unless children.empty?
          [
            {
              label: I18n.t(:dynamic_filters_authorization),
              uuid: 'permissions',
              filter_type: 'permissions',
              position: 2,
              children: children
            }
          ]
        end
      end

      def permissions_visibility(scope)
        filters = [
          permissions_visibility_private(scope),
          permissions_visibility_user_or_group(scope),
          permissions_visibility_public(scope)
        ].compact

        unless filters.empty?
          {
            label: I18n.t(:dynamic_filters_visibility),
            uuid: 'visibility',
            children: filters
          }
        end
      end

      def permissions_visibility_private(scope)
        private_count = scope.filter_by_visibility_private.count
        {
          label: I18n.t(:dynamic_filters_visibility_private),
          uuid: 'private',
          count: private_count
        } if private_count > 0
      end

      def permissions_visibility_user_or_group(scope)
        user_or_group_count = scope.filter_by_visibility_user_or_group.count
        {
          label: I18n.t(:dynamic_filters_visibility_user_or_group),
          uuid: 'user_or_group',
          count: user_or_group_count
        } if user_or_group_count > 0
      end

      def permissions_visibility_public(scope)
        public_count = scope.filter_by_visibility_public.count
        {
          label: I18n.t(:permission_subject_title_public),
          uuid: 'public',
          count: public_count
        } if public_count > 0
      end

      def permissions_responsible_user(scope)
        users = responsible_users_for_scope(scope)
          .map { |u| Presenters::Users::UserIndex.new(u) }

        return if users.count == 0

        {
          label: I18n.t(:permissions_responsible_user_title),
          uuid: 'responsible_user',
          children: users
        }
      end

      def permissions_responsible_delegation(scope)
        delegations = responsible_delegations_for_scope(scope)
          .map { |d| Presenters::Delegations::DelegationIndex.new(d) }

        return if delegations.count == 0

        {
          label: I18n.t(:permissions_responsible_delegation_title),
          uuid: 'responsible_delegation',
          children: delegations
        }
      end

      def permissions_entrusted_to_user(scope)
        users = entrusted_users_for_scope(scope)
          .map { |u| Presenters::Users::UserIndex.new(u) }

        return if users.count == 0

        {
          label: I18n.t(:permission_entrusted_to_user),
          uuid: 'entrusted_to_user',
          children: users
        }
      end

      def permissions_entrusted_to_group(scope)
        groups = entrusted_groups_for_scope(scope)
          .map { |u| Presenters::Groups::GroupIndex.new(u) }

        return if groups.count == 0

        {
          label: I18n.t(:permission_entrusted_to_group),
          uuid: 'entrusted_to_group',
          children: groups
        }
      end

      def permissions_entrusted_to_api_client(scope)
        api_clients = entrusted_api_clients_for_scope(scope)
          .map { |ac| Presenters::ApiClients::ApiClientIndex.new(ac) }

        return if api_clients.count == 0

        {
          label: I18n.t(:permission_entrusted_to_api_client),
          uuid: 'entrusted_to_api_client',
          children: api_clients
        }
      end

      def responsible_users_for_scope(scope)
        User.where("users.id IN (#{responsible_user_ids(scope)})")
      end

      def responsible_delegations_for_scope(scope)
        Delegation.where("delegations.id IN (#{responsible_delegation_ids(scope)})")
      end

      def entrusted_users_for_scope(scope)
        User.where("users.id IN (#{entrusted_user_ids(scope)})")
      end

      def entrusted_groups_for_scope(scope)
        Group.where("groups.id IN (#{entrusted_group_ids(scope)})")
      end

      def entrusted_api_clients_for_scope(scope)
        ApiClient.where("api_clients.id IN (#{entrusted_api_client_ids(scope)})")
      end

      def responsible_user_ids(scope)
        <<-SQL

          with
            resources as (
              #{scope.to_sql}
            )

          select distinct
            resources.responsible_user_id
          from
            resources

        SQL
      end

      def responsible_delegation_ids(scope)
        <<-SQL

          with
            resources as (
              #{scope.to_sql}
            )

          select distinct
            resources.responsible_delegation_id
          from
            resources

        SQL
      end

      def entrusted_user_ids(scope)
        singular = @resource_type.name.underscore
        <<-SQL
          with
            resource_ids as (
              select scope.id from (#{scope.to_sql}) as scope
            ),
            group_ids as (
              select distinct
                group_id as id
              from
                #{singular}_group_permissions, resource_ids
              where
                #{singular}_group_permissions.get_metadata_and_previews = true
                and #{singular}_group_permissions.#{singular}_id = resource_ids.id

            )

          select distinct
            groups_users.user_id
          from
            groups_users, group_ids
          where
            groups_users.group_id = group_ids.id

          union

          select distinct
            #{singular}_user_permissions.user_id
          from
            resource_ids, #{singular}_user_permissions
          where
            #{singular}_user_permissions.get_metadata_and_previews = true
            and #{singular}_user_permissions.#{singular}_id = resource_ids.id
        SQL
      end

      def entrusted_group_ids(scope)
        singular = @resource_type.name.underscore
        <<-SQL
          with resource_ids as (
            select scope.id from (#{scope.to_sql}) as scope
          )

          select distinct
            #{singular}_group_permissions.group_id
          from
            resource_ids, #{singular}_group_permissions
          where
            #{singular}_group_permissions.get_metadata_and_previews = true
            and #{singular}_group_permissions.#{singular}_id = resource_ids.id
        SQL
      end

      def entrusted_api_client_ids(scope)
        singular = @resource_type.name.underscore
        <<-SQL
          with resource_ids as (
            select scope.id from (#{scope.to_sql}) as scope
          )

          select distinct
            #{singular}_api_client_permissions.api_client_id
          from
            resource_ids, #{singular}_api_client_permissions
          where
            #{singular}_api_client_permissions.get_metadata_and_previews = true
            and #{singular}_api_client_permissions.#{singular}_id = resource_ids.id
        SQL
      end

      def meta_data(scope, _tree)
        # TODO: ui_context_list = contexts_for_dynamic_filters (when in Admin UI)
        ui_context_list = _contexts_for_dynamic_filters # from VocabularyConfig
        return unless ui_context_list.present?
        ui_context_list_ids = ui_context_list.map(&:id)
        values = FilterBarQuery.get_metadata_unsafe(
          @resource_type, scope, ui_context_list, @user)
        values
          .group_by { |v| v['context_id'] }
          .sort_by { |bundle| ui_context_list_ids.index(bundle[0]) }
          .map.with_index do |bundle, index|
            context_id, values = bundle
            # Sort them last in list (assumes there are less than 100 app-filters):
            position = 100 + index
            Presenters::Contexts::ContextAsFilter.new(
              Context.find(context_id), values, position)
          end
      end

      def media_files_filters(scope, _children)
        media_types = FilterBarQuery.get_media_types_unsafe(scope)
        extensions = FilterBarQuery.get_extensions_unsafe(scope)

        if media_types.empty? and extensions.empty?
          return nil
        end

        children = []
        unless media_types.empty?
          children <<
            { label: I18n.t(:resource_meta_data_resource_type),
              uuid: 'media_type',
              children: media_types,
              multi: false }
        end
        unless extensions.empty?
          children <<
            { label: I18n.t(:resource_meta_data_document_type),
              uuid: 'extension',
              children: extensions,
              multi: false }
        end

        [
          {
            label: I18n.t(:media_entry_file_information_title),
            filter_type: 'media_files',
            uuid: 'file',
            position: 1,
            children: children
          }
        ]
      end

      def get_key(children, key)
        children.try(:fetch, key, false)
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
