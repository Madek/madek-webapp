module Presenters
  module Groups
    class GroupShow < Presenter

      def initialize(
        app_resource,
        user,
        resources_type,
        list_conf)

        @app_resource = app_resource
        @user = user
        @resources_type = resources_type
        @list_conf = list_conf
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
          user_scope, @user, can_filter: true, list_conf: @list_conf
        )

        check_for_try_collection(resources, clazz)
        resources
      end

      private

      def check_for_try_collection(resources, clazz)
        if resources.empty? && clazz == MediaEntry
          try_scope = group_scope(@app_resource, Collection)
          try_resources = Presenters::Shared::MediaResource::MediaResources.new(
            try_scope, @user, can_filter: true, list_conf: @list_conf
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
