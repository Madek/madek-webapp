module Presenters
  module Shared
    module MediaResources
      class MediaResourcePermissionsShow < Presenters::Shared::AppResource
        include Presenters::Shared::MediaResources::Modules::Responsible

        GENERIC_PERMISSION_TYPES = [:data_and_preview,
                                    :edit_data,
                                    :fullsize,
                                    :edit_permissions]

        SHARED_TYPES_MAP = { get_metadata_and_previews: :data_and_preview,
                             edit_permissions: :edit_permissions }

        def initialize(app_resource, user)
          super(app_resource)
          @user = user
        end

        def generic_permission_types
          self.class::GENERIC_PERMISSION_TYPES
        end

        def current_user_permission_types
          @app_resource
            .permission_types_for_user(@user)
            .map { |type| self.class::TYPES_MAP[type] }
        end

        def self.setup(app_resource_class, types_map)
          define_permissions_api(app_resource_class)

          validate_types_map \
            types_map,
            "Permissions::Modules::#{app_resource_class}::PERMISSION_TYPES"
              .constantize
        end

        ################## PRIVATE CLASS METHODS #########################

        def self.define_permissions_api(app_resource_class)
          partial_const_path = \
            'Presenters::'\
            "#{app_resource_class.model_name.plural.camelize}::"\
            'Permissions::'\
            "#{app_resource_class.model_name.singular.camelize}"\

          permissions_helper('user_permission', partial_const_path)
          permissions_helper('group_permission', partial_const_path)
          permissions_helper('api_client_permission', partial_const_path)

          define_method :public_permission do
            p_class = "#{partial_const_path}PublicPermission".constantize
            p_class.new(@app_resource)
          end
        end

        def self.permissions_helper(perm_type, partial_const_path)
          define_method(perm_type.pluralize) do
            p_class = "#{partial_const_path}#{perm_type.camelize}".constantize
            @app_resource
              .send(perm_type.pluralize)
              .map { |p| p_class.new(p) }
          end
        end

        def self.generic_types_valid?(types)
          types.all? { |type| GENERIC_PERMISSION_TYPES.include?(type) }
        end

        def self.validate_types_map(types_map, specific_types)
          raise 'Invalid permission type' \
            unless specific_types_valid?(types_map.keys, specific_types) \
              or generic_types_valid?(types_map.values)
        end

        def self.specific_types_valid?(types, specific_types)
          types.all? { |type| specific_types.include?(type) }
        end

        private_class_method :define_permissions_api,
                             :permissions_helper,
                             :generic_types_valid?,
                             :specific_types_valid?,
                             :validate_types_map
      end
    end
  end
end
