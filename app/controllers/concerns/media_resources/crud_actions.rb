module Concerns
  module MediaResources
    module CrudActions
      extend ActiveSupport::Concern
      include Concerns::ControllerHelpers
      include Concerns::ResourceListParams

      def represent(resource = get_authorized_resource, action = action_name)
        respond_with(@get = (
          presenter_by_class(action).new(
            resource,
            current_user,
            list_conf: resource_list_params)))
      end

      alias_method :index, :represent
      alias_method :show, :represent

      private

      def presenter_by_class(action)
        base_klass = model_klass.name.pluralize
        klass = if (action == 'index')
                  base_klass
                else
                  base_klass.singularize + action.camelize
                end
        "::Presenters::#{base_klass}::#{klass}".constantize
      end

    end
  end
end
