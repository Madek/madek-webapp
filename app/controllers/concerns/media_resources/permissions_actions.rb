module Concerns
  module MediaResources
    module PermissionsActions
      extend ActiveSupport::Concern
      include Modules::Resources::PermissionsHelpers
      include Concerns::MediaResources::LogIntoEditSessions

      def permissions_update
        resource = get_authorized_resource

        ActiveRecord::Base.transaction do
          update_user_permissions! resource
          update_group_permissions! resource
          update_api_client_permissions! resource
          update_public_permissions! resource

          log_into_edit_sessions! resource
        end

        # TODO: responder(?)
        if request.accept == 'application/json'
          render json: { message: 'Success!' }
        else
          path_helper = "edit_permissions_#{model_klass.model_name.singular}_path"
          redirect_to send(path_helper, resource)
        end
      end

    end
  end
end
