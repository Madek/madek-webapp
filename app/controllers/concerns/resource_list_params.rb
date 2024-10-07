# Handles parameters `MediaResources` Presenters
# NOTE: shared logic! keep in sync with
#       `app/assets/javascripts/shared/resource_list_params.coffee`
module ResourceListParams
  extend ActiveSupport::Concern

  included do

    include UserListParams

    private

    BOTH_ALLOWED_FILTER_PARAMS =
      [:search].freeze
    COLLECTIONS_ALLOWED_FILTER_PARAMS =
      [:search, :meta_data, :permissions].freeze
    ENTRIES_ALLOWED_FILTER_PARAMS =
      [:search, :meta_data, :media_files, :permissions].freeze
    ALLOWED_PERMISSION_FILTER_KEYS = [:visibility].freeze

    def both_list_params
      resource_list_params(params, BOTH_ALLOWED_FILTER_PARAMS)
    end

    def entries_list_params
      resource_list_params(params, ENTRIES_ALLOWED_FILTER_PARAMS)
    end

    def collections_list_params
      # if params[:list] and params[:list][:filter]
      #   filter = JSON.parse(params[:list][:filter]).deep_symbolize_keys
      #   params[:list][:filter] = filter.except!(:media_files).to_json
      # end
      #
      resource_list_params(params, COLLECTIONS_ALLOWED_FILTER_PARAMS)
    end

    def resource_list_by_type_param
      type = params[:type]
      if (not type) || type == 'entries'
        entries_list_params
      elsif type == 'collections'
        collections_list_params
      elsif type == 'all'
        both_list_params
      else
        throw 'Unexpected type: ' + type.to_s
      end
    end

    def resource_list_params(parameters = params,
                              allowed_filter_params = nil)
      base = :list
      allowed = [:layout, :filter, :show_filter, :accordion,
                  :page, :per_page, :order, :sparse_filter, :lang]
      coerced_types = { bools: [:show_filter],
                        jsons: [:filter, :accordion] }

      # NOTE: can be `nil` if base is a string (like `?list=some_string`)
      list_params = parameters.permit(base => allowed).fetch(base, {})
      list_params.permit! if list_params.empty?
      list_params = process_list_params(
        list_params, coerced_types, allowed_filter_params)
      list_params = restrict_permission_filter_keys(list_params)

      # side effect: persist list config to session
      persist_list_config_to_session(list_params)

      list_params
    end

    def process_list_params(list_params, coerced_types, allowed_filter_params)
      list_params
        .to_h
        .deep_symbolize_keys
        .map { |key, val| _coerce_types(coerced_types, key, val) }
        .tap do |p|
          check_allowed_filter_params! p, allowed_filter_params
        end
        .to_h
        .merge(
          # config from session
          user: (current_user ? current_user.settings : {})
        )
        .merge(
          for_url: { # context of current request (for building new links):
            pathname: request.path,
            query: request.query_parameters.deep_symbolize_keys })
    end

    def check_allowed_filter_params!(parameters, allowed_filter_params)
      filter_params = parameters.assoc(:filter).try(:second).try(:keys)
      # allowed filter params are defined as a constant in
      # the respective controller
      if filter_params
        # if no allowed_filter_params were given, then check in the respective
        # controller for the constant ALLOWED_FILTER_PARAMS
        allowed_filter_params ||= self.class::ALLOWED_FILTER_PARAMS
        not_allowed_given = filter_params - allowed_filter_params
        unless not_allowed_given.empty?
          Rails.logger.warn("TEMP FOR DEBUGGING: #{request.url}")
          raise ActionController::UnpermittedParameters, not_allowed_given
        end
      end
    end

    def restrict_permission_filter_keys(list_params)
      unless current_user
        unless (permissions = list_params.fetch(:filter, {}).fetch(:permissions, [])).empty?
          allowed_permissions_params = permissions.select do |p|
            ALLOWED_PERMISSION_FILTER_KEYS.include?(p[:key].to_sym)
          end
          list_params[:filter][:permissions] = allowed_permissions_params
        end
      end
      list_params
    end

    # NOTE: there is no "private in private", so helper methods are underscored

    def _coerce_types(types, key, val)
      case
      when types[:bools].include?(key) then [key, val == 'true']
      when types[:jsons].include?(key) then [key, _parse_json_param(key, val)]
      else
        [key, val]
      end
    end

    def _parse_json_param(key, val)
      begin
        JSON.parse(val).deep_symbolize_keys
      rescue => e
        raise Errors::InvalidParameterValue, "'#{key}' must be valid JSON!\n#{e}"
      end
    end

  end
end
