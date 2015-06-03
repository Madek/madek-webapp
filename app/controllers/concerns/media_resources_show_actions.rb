module Concerns
  module MediaResourcesShowActions
    extend ActiveSupport::Concern

    def show
      authorize_and_respond_with_respective_presenter
    end

    def permissions_show
      authorize_and_respond_with_respective_presenter
    end

    included do

      private

      def authorize_and_respond_with_respective_presenter
        resource = model_klass.find(params[:id])
        authorize resource
        @get = determine_presenter.new(resource, current_user)
        respond_with @get
      end

      def determine_presenter
        presenter_klass_name = action_name.camelize
        "::Presenters::#{model_klass.name.pluralize}" \
        "::#{model_klass}#{presenter_klass_name}" \
          .constantize
      end

      def model_klass
        controller_name.classify.constantize
      end
    end
  end
end
