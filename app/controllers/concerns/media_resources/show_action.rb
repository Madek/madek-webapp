module Concerns
  module MediaResources
    module ShowAction
      extend ActiveSupport::Concern
      include Concerns::ControllerHelpers
      include Concerns::ResourceListParams

      def show
        respond_with(@get = (
          presenter_by_class.new(
            get_authorized_resource,
            current_user,
            list_conf: resource_list_params)))
      end

      private

      def presenter_by_class
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
