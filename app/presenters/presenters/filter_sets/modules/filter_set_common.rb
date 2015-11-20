module Presenters
  module FilterSets
    module Modules
      module FilterSetCommon
        extend ActiveSupport::Concern
        include Presenters::Shared::MediaResource::Modules::MediaResourceCommon

        def initialize(app_resource, user, list_conf: nil)
          fail 'TypeError!' unless app_resource.is_a?(FilterSet)
          super(app_resource, user)
          @list_conf = list_conf
        end

        included do
          # TODO: attr_reader :relations
        end

        def saved_filter
          @app_resource.definition.deep_symbolize_keys
        end
      end
    end
  end
end
