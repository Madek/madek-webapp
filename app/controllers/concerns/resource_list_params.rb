# Handles parameters `MediaResources` Presenters
# NOTE: shared logic! keep in sync with
#       `app/assets/javascripts/shared/resource_list_params.coffee`
module Concerns
  module ResourceListParams
    extend ActiveSupport::Concern

    included do

      include Concerns::UserListParams

      private

      BOTH_ALLOWED_FILTER_PARAMS =
        [:search].freeze
      COLLECTIONS_ALLOWED_FILTER_PARAMS =
        [:search, :meta_data, :permissions].freeze
      ENTRIES_ALLOWED_FILTER_PARAMS =
        [:search, :meta_data, :media_files, :permissions].freeze

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
        if (not params[:type]) || params[:type] == 'entries'
          entries_list_params
        elsif params[:type] == 'collections'
          collections_list_params
        else
          both_list_params
        end
      end

      def resource_list_params(parameters = params,
                               allowed_filter_params = nil)
        # TODO: only permit supported layout modes…
        base = :list
        allowed = [:layout, :filter, :show_filter, :accordion,
                   :page, :per_page, :order]
        coerced_types = { bools: [:show_filter],
                          jsons: [:filter, :accordion] }

        # NOTE: can be `nil` if base is a string (like `?list=some_string`)
        list_params = parameters.permit(base => allowed).fetch(base, {}) || {}

        list_params = process_list_params(
          list_params, coerced_types, allowed_filter_params)

        # side effect: persist list config to session
        persist_list_config_to_session(list_params)

        list_params
      end

      def process_list_params(list_params, coerced_types, allowed_filter_params)
        list_params
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
              pathname: url_for(only_path: true),
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
            raise ActionController::UnpermittedParameters, not_allowed_given
          end
        end
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
end
