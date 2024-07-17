module Modules
  module Resources
    module SharedResourceTransferResponsibility
      extend ActiveSupport::Concern

      private

      def update_permissions_resource(new_entity, resource)
        remove_existing_permissions_for_new_user(resource, new_entity)

        send(
          "update_permissions_#{resource.class.name.underscore}",
          resource)

        case new_entity.class.name
        when 'User'
          resource.responsible_user = new_entity
          resource.responsible_delegation = nil
        when 'Delegation'
          resource.responsible_delegation = new_entity
          resource.responsible_user = nil
        end
        resource.save!
      end

      def remove_existing_permissions_for_new_user(resource, new_entity)
        if new_entity.instance_of?(User)
          resource.user_permissions.where(user: new_entity).destroy_all
        elsif new_entity.instance_of?(Delegation)
          resource.user_permissions.where(delegation: new_entity).destroy_all
        end
      end

      def update_permissions_media_entry(resource)
        view = read_permission(:view)
        download = read_permission(:download)
        edit = read_permission(:edit)
        manage = read_permission(:manage)

        return if !view && !download && !edit && !manage

        do_update_permissions_media_entry(
          resource, view, download, edit, manage)
      end

      def do_update_permissions_media_entry(
          resource, view, download, edit, manage)
        existing_permissions = resource.user_permissions.where(
          user: resource.responsible_user, delegation: resource.responsible_delegation).first
        if existing_permissions
          existing_permissions.get_metadata_and_previews = view
          existing_permissions.get_full_size = download
          existing_permissions.edit_metadata = edit
          existing_permissions.edit_permissions = manage
          existing_permissions.save!
        else
          config = {
            user: resource.responsible_user,
            delegation: resource.responsible_delegation,
            get_metadata_and_previews: view,
            get_full_size: download,
            edit_metadata: edit,
            edit_permissions: manage
          }
          resource.user_permissions.create!(config)
        end
      end

      def update_permissions_collection(resource)
        view = read_permission(:view)
        edit = read_permission(:edit)
        manage = read_permission(:manage)

        return if !view && !edit && !manage

        do_update_permissions_collection(resource, view, edit, manage)
      end

      def do_update_permissions_collection(resource, view, edit, manage)
        existing_permissions = resource.user_permissions.where(
          user: resource.responsible_user, delegation: resource.responsible_delegation).first
        if existing_permissions
          existing_permissions.get_metadata_and_previews = view
          existing_permissions.edit_metadata_and_relations = edit
          existing_permissions.edit_permissions = manage
          existing_permissions.save!
        else
          config = {
            user: resource.responsible_user,
            delegation: resource.responsible_delegation,
            get_metadata_and_previews: view,
            edit_metadata_and_relations: edit,
            edit_permissions: manage
          }
          resource.user_permissions.create!(config)
        end
      end

      def read_permission(permission)
        permissions = params.require(:transfer_responsibility)[:permissions]
        return false unless permissions

        if permissions[permission]
          true
        else
          false
        end
      end
    end
  end
end
