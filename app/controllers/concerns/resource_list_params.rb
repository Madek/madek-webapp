module Concerns
  # handles parameters for UI Decorators of `MediaResources` Presenters
  module ResourceListParams
    extend ActiveSupport::Concern

    included do

      private

      def resource_list_params
        params
          .permit(list: [:layout, :filter, :page, :per_page])
          .fetch(:list, {})
          .merge( # context of current request (for building new links):
            for_url: {
              path: url_for(only_path: true),
              query: request.query_parameters })
      end
    end
  end
end
