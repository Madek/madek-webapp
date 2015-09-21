module Concerns
  module MediaResources
    module PermissionsActions
      extend ActiveSupport::Concern

      def permissions_update
        resource = model_klass.unscoped.find(params[:id])
        authorize resource

        ActiveRecord::Base.transaction do
          update_user_permissions! resource
          update_group_permissions! resource
          update_api_client_permissions! resource
          update_public_permissions! resource
        end

        # TODO: responder(?)
        if request.accept == 'application/json'
          render json: { message: 'Success!' }
        else
          path_helper = "edit_permissions_#{model_klass.model_name.singular}_path"
          redirect_to send(path_helper, resource)
        end
      end

      included do

        private

        def transform_permissions(type, perm_array)
          perm_array
            .map do |p|
              if p.key?('subject')
                uuid = p.delete('subject')['uuid']
                p.merge Hash["#{type}_id", uuid]
              end
            end
            .compact
        end

        def filter_permissions(type, perm_array)
          perm_array
            .select do |p|
              p.key?("#{type}_id") \
                and not p.fetch("#{type}_id").blank? \
                and p.size > 1
            end
        end

        def raise_if_not_an_array!(perm_array)
          perm_array.tap do |v|
            unless v.is_a? Array
              raise Errors::InvalidParameterValue,
                    'Permissions must be an array!'
            end
          end
        end

        def check_and_filter_and_transform(type, perm_array)
          raise_if_not_an_array!(perm_array)
          filter_permissions(type,
                             transform_permissions(type, perm_array))
        end

        def associated_entity_permissions_helper(type, *perms)
          check_and_filter_and_transform \
            type,
            send("#{model_klass.model_name.singular}_params")
              .permit(Hash["#{type}_permissions", [{ subject: [:uuid] }, *perms]])
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
