module Modules
  module Resources
    module ResourceTransferResponsibility
      extend ActiveSupport::Concern

      include Resources::SharedResourceTransferResponsibility

      private

      def resource_update_transfer_responsibility(type, resource_id)
        resource = type.find(resource_id)
        auth_authorize(resource)

        new_user_uuid = params.require(:transfer_responsibility).require(:user)
        new_user = User.find(new_user_uuid)

        ActiveRecord::Base.transaction do
          update_permissions_resource(new_user, resource)
        end

        transfer_responsibility_respond(resource.class)
      end

      def transfer_responsibility_respond(type)
        underscore = type.name.underscore
        respond_to do |format|
          format.json do
            flash[:success] = I18n.t(
              "transfer_responsibility_success_#{underscore}")
            render(json: { result: 'success' })
          end
        end
      end
    end
  end
end
