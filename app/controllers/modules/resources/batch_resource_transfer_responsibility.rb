module Modules
  module Resources
    module BatchResourceTransferResponsibility
      extend ActiveSupport::Concern

      include Resources::SharedResourceTransferResponsibility

      private

      def batch_resource_update_transfer_responsibility(user, type)
        auth_authorize type, :logged_in?
        resources = type.unscoped.where(id: resources_ids_param)
        authorize_resources_for_batch_transfer_responsibility!(resources)

        new_user_uuid = params.require(:transfer_responsibility).require(:user)
        new_user = User.find(new_user_uuid)

        ActiveRecord::Base.transaction do
          resources.each do |resource|
            update_permissions_resource(user, new_user, resource)
          end
        end

        transfer_responsibility_respond
      end

      def authorize_resources_for_batch_transfer_responsibility!(resources)
        authorized_resources = auth_policy_scope(
          current_user,
          resources,
          MediaResourcePolicy::ResponsibilityTransferableScope)
        if resources.count != authorized_resources.count
          raise(
            Errors::ForbiddenError,
            'Not allowed to transfer responsibility for all resources!')
        end
      end

      def resources_ids_param
        params.require(:id)
      end
    end
  end
end
