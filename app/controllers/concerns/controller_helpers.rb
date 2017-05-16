module Concerns
  module ControllerHelpers
    extend ActiveSupport::Concern
    include Concerns::ResourceListParams

    def id_param
      params.require(:id)
    end

    def filtered_index_path(filter)
      media_entries_path(
        list: { show_filter: true, filter: JSON.generate(filter) })
    end

    def redirect_to_filtered_index(filter)
      redirect_to(filtered_index_path(filter))
    end

    def get_authorized_resource(resource = nil)
      resource ||= model_klass.unscoped.find(id_param)
      auth_authorize resource, "#{action_name}?".to_sym
      resource
    end

    def model_klass
      controller_name.classify.constantize
    end

    def represent(resource = get_authorized_resource,
                  presenter = nil)
      @get = presenterify(resource, presenter)
      respond_with @get
    end

    def presenterify(resource, presenter = nil, **args)
      presenter ||= presenter_by_class(action_name)
      presenter.new(
        resource, current_user, list_conf: resource_list_by_type_param, **args)
    end

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
