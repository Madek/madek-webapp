module Modules
  module Resources
    module SharedResourceTransferResponsibility
      extend ActiveSupport::Concern

      private

      def update_permissions_resource(user, new_user, resource)
        send(
          "update_permissions_#{resource.class.name.underscore}",
          user,
          resource)
        resource.responsible_user = new_user
        resource.save!
      end

      def update_permissions_media_entry(user, resource)
        existing_permissions = resource.user_permissions.where(user: user).first
        if existing_permissions
          existing_permissions.get_metadata_and_previews = read_permission(:view)
          existing_permissions.get_full_size = read_permission(:download)
          existing_permissions.edit_metadata = read_permission(:edit)
          existing_permissions.edit_permissions = read_permission(:manage)
          existing_permissions.save!
        else
          config = {
            user: resource.responsible_user,
            get_metadata_and_previews: read_permission(:view),
            get_full_size: read_permission(:download),
            edit_metadata: read_permission(:edit),
            edit_permissions: read_permission(:manage)
          }
          resource.user_permissions.create!(config)
        end
      end

      def update_permissions_collection(user, resource)
        existing_permissions = resource.user_permissions.where(user: user).first
        if existing_permissions
          existing_permissions.get_metadata_and_previews = read_permission(:view)
          existing_permissions.edit_metadata_and_relations = read_permission(:edit)
          existing_permissions.edit_permissions = read_permission(:manage)
          existing_permissions.save!
        else
          config = {
            user: resource.responsible_user,
            get_metadata_and_previews: read_permission(:view),
            edit_metadata_and_relations: read_permission(:edit),
            edit_permissions: read_permission(:manage)
          }
          resource.user_permissions.create!(config)
        end
      end

      def read_permission(permission)
        permissions = params.require(:transfer_responsibility)
          .require(:permissions)
        if permissions[permission]
          true
        else
          false
        end
      end

      def transfer_responsibility_respond
        respond_to do |format|
          format.json do
            render(json: { result: 'success' })
          end
        end
      end
    end
  end
end
