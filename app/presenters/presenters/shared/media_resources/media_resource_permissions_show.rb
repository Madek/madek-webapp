module Presenters
  module Shared
    module MediaResources
      class MediaResourcePermissionsShow < Presenters::Shared::AppResource
        include Presenters::Shared::MediaResources::Modules::Responsible

        def initialize(resource, user)
          super(resource)
          @user = user
        end

        def current_user_permission_types
          @resource.permission_types_for_user(@user)
        end

        def self.define_permissions_api(resource_class)
          partial_const_path = \
            'Presenters::'\
            "#{resource_class.model_name.plural.camelize}::"\
            'Permissions::'\
            "#{resource_class.model_name.singular.camelize}"\

          permissions_helper('user_permission', partial_const_path)
          permissions_helper('group_permission', partial_const_path)
          permissions_helper('api_client_permission', partial_const_path)

          define_method :public_permission do
            p_class = "#{partial_const_path}PublicPermission".constantize
            p_class.new(@resource)
          end
        end

        def self.permissions_helper(perm_type, partial_const_path)
          define_method(perm_type.pluralize) do
            p_class = "#{partial_const_path}#{perm_type.camelize}".constantize
            @resource
              .send(perm_type.pluralize)
              .map { |p| p_class.new(p) }
          end
        end

        private_class_method :permissions_helper
      end
    end
  end
end
