module Presenters
  module FilterSets
    module Modules
      module FilterSetCommon
        extend ActiveSupport::Concern
        include Presenters::Shared::MediaResource::Modules::MediaResourceCommon

        def initialize(app_resource, user)
          fail 'TypeError!' unless app_resource.is_a?(FilterSet)
          super(app_resource, user)
        end

        included do
          # TODO: attr_reader :relations
        end
      end
    end
  end
end
