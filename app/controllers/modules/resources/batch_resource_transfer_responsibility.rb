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

        batch_transfer_responsibility_respond(type, resources.count)
      end

      def batch_transfer_responsibility_respond(type, count)
        underscore = type.name.underscore
        t1 = I18n.t("transfer_responsibility_batch_success_#{underscore}_1")
        t1a = I18n.t("transfer_responsibility_batch_success_#{underscore}_1a")
        t1b = I18n.t("transfer_responsibility_batch_success_#{underscore}_1b")
        t2 = I18n.t("transfer_responsibility_batch_success_#{underscore}_2")

        respond_to do |format|
          format.json do
            flash[:success] = t1 + count.to_s + (count == 1 ? t1a : t1b) + t2
            render(json: { result: 'success' })
          end
        end
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
