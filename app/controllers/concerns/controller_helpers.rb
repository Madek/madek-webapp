module Concerns
  module ControllerHelpers
    extend ActiveSupport::Concern

    included do

      private

      def get_authorized_resource(resource = resource_by_action)
        authorize resource
        resource
      end

      def resource_by_action(action = action_name)
        (action == 'index') ? model_klass.all : model_klass.find(params[:id])
      end

      def model_klass
        controller_name.classify.constantize
      end

    end
  end
end
