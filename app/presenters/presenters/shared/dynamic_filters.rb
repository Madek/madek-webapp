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

      def initialize(user, scope, tree, existing_filters, sparse_filter)
        @user = user
        @scope = scope
        @tree = tree || {}
        @resource_type = scope.model or fail 'TypeError! (Expected AR Scope)'
        @existing_filters = existing_filters
        @sparse_filter = sparse_filter
      end

      def list
        [
          (media_files(@scope, @tree) if @resource_type == MediaEntry),
          permissions(@scope),
          meta_data(@scope, @tree)
        ].flatten.compact
      end

      private

      def media_files(scope, tree)
        if @resource_type == MediaEntry
          media_files_filters(scope, get_key(tree, :media_files))
        end
      end

      def permissions(scope)
        return nil if scope.count == 0

        children = [
          permissions_visibility(scope),
          permissions_responsible_user(scope),
          permissions_entrusted_to_user(scope),
          permissions_entrusted_to_group(scope)
        ].compact

        unless children.empty?
          {
            label: 'Berechtigung',
            uuid: 'permissions',
            position: 2,
            children: children
          }
        end
      end

      def permissions_visibility(scope)
        filters = [
          (
            { label: 'Öffentlich', uuid: 'public' } if (
              scope.filter_by_visibility_public.count > 0
            )
          ),
          (
            { label: 'Geteilt', uuid: 'shared' } if (
              scope.filter_by_visibility_shared.count > 0
            )
          ),
          (
            { label: 'Privat', uuid: 'private' } if (
              scope.filter_by_visibility_private.count > 0
            )
          )
        ].compact

        unless filters.empty?
          {
            label: 'Sichtbarkeit',
            uuid: 'visibility',
            children: filters
          }
        end
      end

      def permissions_responsible_user(scope)
        unless @sparse_filter == 'responsible_user'
          return {
            label: 'Verantwortliche Person',
            uuid: 'responsible_user',
            children: []
          }
        end

        responsible_user_ids = scope.reorder(:responsible_user_id).select(
          @resource_type.select('responsible_user_id').arel.projections).uniq
        users_scope = User.where("users.id IN (#{responsible_user_ids.to_sql})")

        users = users_scope
          .map { |u| Presenters::Users::UserIndex.new(u) }

        {
          label: 'Verantwortliche Person',
          uuid: 'responsible_user',
          children: users
        }
      end

      def permissions_entrusted_to_user(scope)
        unless @sparse_filter == 'entrusted_to_user'
          return {
            label: 'Sichtbar für Person',
            uuid: 'entrusted_to_user',
            children: []
          }
        end

        users = entrusted_users_for_scope(scope)
          .map { |u| Presenters::Users::UserIndex.new(u) }

        {
          label: 'Sichtbar für Person',
          uuid: 'entrusted_to_user',
          children: users
        }
      end

      def permissions_entrusted_to_group(scope)
        unless @sparse_filter == 'entrusted_to_group'
          return {
            label: 'Sichtbar für Gruppe',
            uuid: 'entrusted_to_group',
            children: []
          }
        end

        groups = entrusted_groups_for_scope(scope)
          .map { |u| Presenters::Groups::GroupIndex.new(u) }

        {
          label: 'Sichtbar für Gruppe',
          uuid: 'entrusted_to_group',
          children: groups
        }
      end

      def entrusted_users_for_scope(scope)
        user_ids_sql = permissions_scope_user(scope)
        User.where(
          "users.id IN (#{user_ids_sql})")
      end

      def entrusted_groups_for_scope(scope)
        group_ids_sql = permissions_scope_group(scope)
        Group.where(
          "groups.id IN (#{group_ids_sql})")
      end

      def permissions_scope_user(scope)
        singular = @resource_type.name.underscore
        <<-SQL

          with resource_ids as (
            select scope.id from (#{scope.to_sql}) as scope
          )

          select distinct
            users.id
          from
            users
          where exists(

            select * from #{singular}_user_permissions, resource_ids
            where
              #{singular}_user_permissions.user_id = users.id
              and #{singular}_user_permissions.get_metadata_and_previews = true
              and #{singular}_user_permissions.#{singular}_id = resource_ids.id
          )
          or exists(

            select *
            from groups_users, #{singular}_group_permissions, resource_ids
            where groups_users.user_id = users.id
            and groups_users.group_id = #{singular}_group_permissions.group_id
            and #{singular}_group_permissions.get_metadata_and_previews = true
            and #{singular}_group_permissions.#{singular}_id = resource_ids.id
          )
        SQL
      end

      def permissions_scope_group(scope)
        singular = @resource_type.name.underscore
        <<-SQL

          with resource_ids as (
            select scope.id from (#{scope.to_sql}) as scope
          )

          select distinct
        		#{singular}_group_permissions.group_id
        	from
            #{singular}_group_permissions,
            resource_ids
          where
            #{singular}_group_permissions.#{singular}_id = resource_ids.id
            and #{singular}_group_permissions.get_metadata_and_previews = true
        SQL
      end

      def project_resource_id(scope)
        scope.reorder(:id).select(
          @resource_type.select('id').arel.projections
        ).uniq
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
            { label: 'Medientyp',
              uuid: 'media_type',
              children: media_types,
              multi: false }
        end
        unless extensions.empty?
          children <<
            { label: 'Dokumenttyp',
              uuid: 'extension',
              children: extensions,
              multi: false }
        end

        { label: 'Datei',
          filter_type: 'media_files',
          uuid: 'file',
          position: 1,
          children: children }
      end

      def get_key(children, key)
        children.try(:fetch, key, false)
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
