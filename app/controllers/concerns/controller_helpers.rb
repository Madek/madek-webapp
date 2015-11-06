module Concerns
  module ControllerHelpers
    extend ActiveSupport::Concern

    included do

      private

      def get_authorized_resource(resource = nil)
        resource ||= model_klass.find(params[:id])
        authorize resource
        resource
      end

    end
  end
end
