module Concerns
  module MediaResources
    module PermissionsActions
      extend ActiveSupport::Concern

      def permissions_show
        authorize_and_respond_with_respective_presenter
      end

      def permissions_edit
        authorize_and_respond_with_respective_presenter
      end

      def permissions_update
        resource = model_klass.unscoped.find(params[:id])
        authorize resource

        ActiveRecord::Base.transaction do
          update_user_permissions! resource
          update_group_permissions! resource
          update_api_client_permissions! resource
          update_public_permissions! resource
        end

        path_helper_name = \
          "edit_permissions_#{model_klass.model_name.singular}_path"

        redirect_to send(path_helper_name, resource)
      end

      included do

        private

        def filter_relevant_permissions(type, perm_array)
          perm_array
            .select do |p|
              p.key?("#{type}_id") \
                and not p.fetch("#{type}_id").blank? \
                and p.size > 1
            end
        end

        def raise_if_not_an_array(perm_array)
          perm_array.tap do |v|
            unless v.is_a? Array
              raise Errors::InvalidParameterValue,
                    'Permissions must be an array!'
            end
          end
        end

        def check_and_filter(type, perm_array)
          filter_relevant_permissions(type,
                                      raise_if_not_an_array(perm_array))
        end

        def associated_entity_permissions_helper(type, *perms)
          check_and_filter \
            type,
            send("#{model_klass.model_name.singular}_params")
              .permit(Hash["#{type}_permissions", ["#{type}_id", *perms]])
              .fetch("#{type}_permissions", [])
        end

        def update_user_permissions!(resource)
          resource.user_permissions.destroy_all
          user_permissions_params
            .each { |p| resource.user_permissions.create! p }
        end

        def update_group_permissions!(resource)
          resource.group_permissions.destroy_all
          group_permissions_params
            .each { |p| resource.group_permissions.create! p }
        end

        def update_api_client_permissions!(resource)
          resource.api_client_permissions.destroy_all
          api_client_permissions_params
            .each { |p| resource.api_client_permissions.create! p }
        end

        def update_public_permissions!(resource)
          resource.update_attributes!(self.class::PUBLIC_PERMISSIONS_RESET)
          resource.update_attributes!(public_permissions_params)
        end
      end
    end
  end
end
