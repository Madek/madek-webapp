module Presenters
  module FilterSets
    module Modules
      module FilterSetCommon
        extend ActiveSupport::Concern
        include Presenters::Shared::MediaResource::Modules::MediaResourceCommon

        def initialize(app_resource, user, list_conf: nil, load_meta_data: false)
          fail 'TypeError!' unless app_resource.is_a?(FilterSet)
          super(app_resource, user)
          @list_conf = list_conf
          @load_meta_data = load_meta_data
        end

        def saved_filter
          return unless (definition = @app_resource.try(:definition))
          definition.deep_symbolize_keys
        end
      end
    end
  end
end
