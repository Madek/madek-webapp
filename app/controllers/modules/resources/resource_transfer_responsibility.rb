module Modules
  module Resources
    module ResourceTransferResponsibility
      extend ActiveSupport::Concern

      include Resources::SharedResourceTransferResponsibility

      private

      def resource_update_transfer_responsibility(type, resource_id)
        resource = type.find(resource_id)
        auth_authorize(resource)

        new_entity_uuid = params.require(:transfer_responsibility).require(:entity)
        new_entity_type = params.require(:transfer_responsibility).require(:type)

        if allowed_entity_type?(new_entity_type)
          old_entity = resource.responsible_user || resource.responsible_delegation
          new_entity = new_entity_type.constantize.find(new_entity_uuid)

          ActiveRecord::Base.transaction do
            update_permissions_resource(new_entity, resource)
            extra_data = {
              resource: {
                link_def: {
                  href: if type == MediaEntry
                          media_entry_path(resource)
                        else type == Collection
                          collection_path(resource)
                        end
                }
              }
            }
            Notification.transfer_responsibility(resource, old_entity, new_entity, extra_data)
          end

          transfer_responsibility_respond(resource.class)
        else
          raise 'Unsupported entity type! ' + new_entity_type.inspect
        end
      end

      def transfer_responsibility_respond(type)
        underscore = type.name.underscore
        viewable = read_permission(:view)
        respond_to do |format|
          format.json do
            flash[:success] = I18n.t(
              "transfer_responsibility_success_#{underscore}")
            render(json: { result: 'success', viewable: viewable })
          end
        end
      end

      def allowed_entity_type?(type)
        %w(Delegation User).include?(type)
      end
    end
  end
end
