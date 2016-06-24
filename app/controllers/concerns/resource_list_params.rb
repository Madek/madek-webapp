# Handles parameters `MediaResources` Presenters
# NOTE: shared logic! keep in sync with
#       `app/assets/javascripts/shared/resource_list_params.coffee`
module Concerns
  module ResourceListParams
    extend ActiveSupport::Concern

    included do

      private

      def resource_list_params(parameters = params)
        # TODO: only permit supported layout modes…
        base = :list
        allowed = [:layout,
                   :filter,
                   :show_filter,
                   :accordion,
                   :page,
                   :per_page]
        coerced_types = { bools: [:show_filter],
                          jsons: [:filter, :accordion] }

        parameters
          .permit(base => allowed)
          .fetch(base, {})
          .deep_symbolize_keys
          .map { |key, val| _coerce_types(coerced_types, key, val) }
          .tap { |parameters| check_allowed_filter_params! parameters }
          .to_h
          .merge( # context of current request (for building new links):
            for_url: {
              path: url_for(only_path: true),
              query: request.query_parameters.deep_symbolize_keys })
      end

      def check_allowed_filter_params!(parameters)
        filter_params = parameters.assoc(:filter).try(:second).try(:keys)
        # allowed filter params are defined as a constant in
        # the respective controller
        if filter_params
          not_allowed = filter_params - self.class::ALLOWED_FILTER_PARAMS
          unless not_allowed.empty?
            raise ActionController::UnpermittedParameters, not_allowed
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
