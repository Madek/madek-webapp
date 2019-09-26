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
      handle_confidential_links(resource)
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

    def handle_confidential_links(resource)
      return unless resource.respond_to?(:accessed_by_confidential_link)
      if token = get_valid_access_token(resource)
        return resource.accessed_by_confidential_link = token
      end
      if preview_request_by_parent_confidential_link?(resource)
        resource.accessed_by_confidential_link = true
      end
    end

    private

    def get_valid_access_token(resource)
      return unless resource
      return unless access_token = get_access_token_from_params(params)
      return unless access = ConfidentialLink.find_by_token(access_token)
      return access_token if access.resource_id == resource.id
    end

    def preview_request_by_parent_confidential_link?(resource)
      return false unless resource.is_a?(Preview)
      return false unless controller_name == 'previews' && action_name == 'show'
      return unless access_token = get_access_token_from_params(referrer_params)
      ConfidentialLink.find_by_token(access_token)
        .try(:resource_id) == resource.media_file.media_entry_id
    rescue ActionController::RoutingError
      false
    end

    def get_access_token_from_params(params)
      (action_name == 'show_by_confidential_link' && params.fetch('token', nil)) ||
        (action_name == 'show' && params.fetch('access', nil)) ||
        (controller_name == 'previews' && params.fetch('token', nil)) ||
        params.fetch('accessToken', nil)
    end

    def referrer_params
      ref_route = _with_failsafe do
        Rails.application.routes.recognize_path(request.referrer)
      end
      ref_params = _with_failsafe do
        Rack::Utils.parse_query(URI.parse(request.referrer).query)
      end
      {}.merge(ref_route.to_h).merge(ref_params.to_h).deep_stringify_keys
    end

    def absolute_full_url(url)
      URI.parse(settings.madek_external_base_url).merge(url).to_s
    end

    def _with_failsafe
       yield
    rescue StandardError
      nil
    end

    def disable_http_caching
      response.headers['Cache-Control'] = 'no-cache, no-store'
      response.headers['Pragma'] = 'no-cache'
      response.headers['Expires'] = 1.year.ago.to_s
    end

  end
end
