module Presenters
  module FilterSets
    module Modules
      module FilterSetCommon
        extend ActiveSupport::Concern
        include Presenters::Shared::MediaResources::Modules::MediaResourceCommon
        included do
          # TODO: attr_reader :relations
        end
        def initialize(resource, user)
          @resource = resource
          @user = user
        end
      end
    end
  end
end
