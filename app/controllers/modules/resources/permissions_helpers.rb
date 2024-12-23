module Modules
  module Resources
    module PermissionsHelpers
      extend ActiveSupport::Concern

      included do

        private

        def transform_permissions(type, perm_array)
          perm_array
            .map do |p|
              next unless p.key?('subject')

              resource_type = p.dig('subject', 'resource_type')&.downcase
              uuid = p.delete('subject')['uuid']
              fk_prefix = resource_type.presence || type

              p.merge Hash["#{fk_prefix}_id", uuid]
            end
            .compact
        end

        def filter_permissions(perm_array)
          perm_array
            .select do |p|
              hashed_params = p.to_h
              receiver_id = hashed_params.keys.detect do |k|
                k.to_s != model_klass.to_s.foreign_key && k.ends_with?('_id')
              end

              valid_uuid?(p[receiver_id]) && hashed_params.size > 1
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
          filter_permissions(transform_permissions(type, perm_array))
        end

        def associated_entity_permissions_helper(type, *perms)
          check_and_filter_and_transform \
            type,
            send("#{model_klass.model_name.singular}_params")
              .permit(Hash["#{type}_permissions", [{ subject: [:uuid, :resource_type] }, *perms]])
              .fetch("#{type}_permissions", [])
        end

        def update_user_permissions!(resource)
          resource.user_permissions.destroy_all
          user_permissions_params.each do |p| 
            resource.user_permissions.create! p.merge(creator_id: current_user.id)
          end
        end

        def update_group_permissions!(resource)
          resource.group_permissions.destroy_all
          group_permissions_params.each do |p|
            resource.group_permissions.create! p.merge(creator_id: current_user.id)
          end
        end

        def update_api_client_permissions!(resource)
          resource.api_client_permissions.destroy_all
          api_client_permissions_params.each do |p|
            resource.api_client_permissions.create! p.merge(creator_id: current_user.id)
          end
        end

        def update_public_permissions!(resource)
          resource.update!(self.class::PUBLIC_PERMISSIONS_RESET)
          resource.update!(public_permissions_params)
        end
      end
    end
  end
end
