module Modules
  module Resources
    module ResourceTransferResponsibility
      extend ActiveSupport::Concern

      include Resources::SharedResourceTransferResponsibility

      private

      def resource_update_transfer_responsibility(user, type, resource_id)
        resource = type.find(resource_id)
        auth_authorize(resource)

        new_user_uuid = params.require(:transfer_responsibility).require(:user)
        new_user = User.find(new_user_uuid)

        ActiveRecord::Base.transaction do
          update_permissions_resource(user, new_user, resource)
        end

        transfer_responsibility_respond
      end
    end
  end
end
