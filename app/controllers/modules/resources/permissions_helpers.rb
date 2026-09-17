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

        # Derives creator_id/updator_id for a rebuilt permission from its
        # previous incarnation (matched by receiver), without fabricating
        # provenance:
        #   * brand-new receiver        -> creator = current_user, no updator
        #   * existing, values changed  -> keep creator, updator = current_user
        #   * existing, values unchanged-> keep both creator and updator as-is
        def add_creator_and_updator(p, previous)
          if previous.nil?
            p.merge(creator_id: current_user.id)
          elsif permission_changed?(p, previous)
            p.merge(creator_id: previous.creator_id,
                    updator_id: current_user.id)
          else
            p.merge(creator_id: previous.creator_id,
                    updator_id: previous.updator_id)
          end
        end

        # Compares the submitted permission flags against the previous record.
        # A flag that is absent from the params defaults to false (matching the
        # database default used on create).
        def permission_changed?(p, previous)
          boolean_columns =
            previous.class.columns.select { |c| c.type == :boolean }.map(&:name)
          boolean_columns.any? do |col|
            new_value =
              if p.key?(col)
                ActiveModel::Type::Boolean.new.cast(p[col])
              else
                false
              end
            new_value != previous[col]
          end
        end

        # Rebuilds a permission collection from the submitted params while
        # preserving the original creator (and, for unchanged rows, the original
        # updator) of each individual permission, matched by its receiver
        # (e.g. user_id/delegation_id/group_id/...).
        def rebuild_permissions!(collection, permission_params, &receiver_key)
          existing_by_receiver = collection.each_with_object({}) do |perm, memo|
            memo[receiver_key.call(perm)] = perm
          end
          collection.destroy_all
          permission_params.each do |p|
            previous = existing_by_receiver[receiver_key.call(p)]
            collection.create! add_creator_and_updator(p, previous)
          end
        end

        def update_user_permissions!(resource)
          rebuild_permissions!(resource.user_permissions, user_permissions_params) do |x|
            x[:user_id] || x[:delegation_id]
          end
        end

        def update_group_permissions!(resource)
          rebuild_permissions!(resource.group_permissions, group_permissions_params) do |x|
            x[:group_id]
          end
        end

        def update_api_client_permissions!(resource)
          rebuild_permissions!(resource.api_client_permissions, api_client_permissions_params) do |x|
            x[:api_client_id]
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
