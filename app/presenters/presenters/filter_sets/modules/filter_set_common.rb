module Presenters
  module FilterSets
    module Modules
      module FilterSetCommon
        extend ActiveSupport::Concern
        include Presenters::Shared::MediaResource::Modules::MediaResourceCommon

        def saved_filter
          return unless (definition = @app_resource.try(:definition))
          definition.deep_symbolize_keys
        end
      end

    end
  end
end
