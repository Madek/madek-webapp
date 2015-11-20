module Concerns
  module ControllerHelpers
    extend ActiveSupport::Concern

    included do

      private

      def get_authorized_resource(resource = resource_by_action)
        authorize resource, "#{action_name}?".to_sym
        resource
      end

      def resource_by_action(action = action_name)
        # TODO: implement this distinction with "pundit scopes"
        if (action == 'index')
          model_klass.viewable_by_user_or_public(current_user)
        else
          model_klass.find_by(id: params[:id])
        end
      end

      def model_klass
        controller_name.classify.constantize
      end

    end
  end
end
