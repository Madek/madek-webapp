module Concerns
  module ControllerHelpers
    extend ActiveSupport::Concern

    included do

      private

      def model_klass
        controller_name.classify.constantize
      end

      def authorize_and_respond_with_respective_presenter
        @get = get_authorized_presenter
        respond_with @get
      end

      def get_authorized_presenter(resource = nil)
        determine_presenter.new(get_authorized_resource(resource), current_user)
      end

      def get_authorized_resource(resource = nil)
        resource ||= model_klass.find(params[:id])
        authorize resource
        resource
      end

      def determine_presenter
        presenter_klass_name = action_name.camelize
        "::Presenters::#{model_klass.name.pluralize}" \
        "::#{model_klass}#{presenter_klass_name}" \
          .constantize
      end
    end
  end
end
