module Presenters
  module FilterSets
    module Modules
      module FilterSetCommon
        extend ActiveSupport::Concern
        include Presenters::Shared::MediaResources::Modules::MediaResourceCommon
        included do
          # TODO: attr_reader :relations
        end
        def initialize(app_resource, user)
          @app_resource = app_resource
          @user = user
        end
      end
    end
  end
end
