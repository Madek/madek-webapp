module Presenters
  module Groups
    class GroupShow < Presenter

      def initialize(
        app_resource,
        user,
        resources_type,
        list_conf,
        sub_filters)

        @app_resource = app_resource
        @user = user
        @resources_type = resources_type
        @list_conf = list_conf
        @sub_filters = sub_filters
      end

      def group
        Presenters::Groups::GroupCommon.new(
          @app_resource, @user, list_conf: @list_conf)
      end

      def resources
        type = @resources_type ? @resources_type : 'entries'

        clazz = resource_class_by_type_string(type)

        user_scope = group_scope(@app_resource, clazz)

        resources = Presenters::Shared::MediaResource::MediaResources.new(
          user_scope,
          @user,
          can_filter: true,
          list_conf: @list_conf,
          content_type: content_type,
          sub_filters: @sub_filters
        )

        check_for_try_collection(resources, clazz)
        resources
      end

      def members
        return if @app_resource.type != 'Group'
        @app_resource.users.map do |user|
          Presenters::Users::UserIndex.new(user)
        end
      end

      def vocabulary_permissions
        return if @app_resource.type != 'Group'

        vocabularies = Vocabulary.joins(:group_permissions).where(
          vocabulary_group_permissions: { group_id: @app_resource.id })

        vocabularies.map do |vocabulary|
          permissions = vocabulary.group_permissions.where(
            group_id: @app_resource.id).first
          next unless permissions
          Presenters::Groups::Permissions::VocabularyGroupPermissions.new(
            permissions, @user)
        end.compact
      end

      private

      def media_files_filter?
        return true if @list_conf[:filter].try(:[], :media_files)
      end

      def content_type
        case @resources_type
        when 'entries' then MediaEntry
        when 'collections' then Collection
        end
      end

      def check_for_try_collection(resources, clazz)
        if !media_files_filter? && resources.empty? && clazz == MediaEntry
          try_scope = group_scope(@app_resource, Collection)
          try_resources = Presenters::Shared::MediaResource::MediaResources.new(
            try_scope,
            @user,
            can_filter: true,
            list_conf: @list_conf,
            content_type: content_type
          )
          if try_resources.any?
            resources.try_collections = true
          end
        end
      end

      def group_scope(group, clazz)
        clazz.entrusted_to_group(group)
      end

      def resource_class_by_type_string(resource_type)
        case resource_type
        when 'entries'
          MediaEntry
        when 'collections'
          Collection
        else
          raise Errors::InvalidParameterValue, "Type is #{type}"
        end
      end
    end
  end
end
