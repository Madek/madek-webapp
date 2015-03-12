module Presenters
  module Collections
    module Modules
      module CollectionCommon
        extend ActiveSupport::Concern
        include Presenters::Shared::MediaResources::Modules::MediaResourceCommon
        included do
          attr_reader :relations
        end
        def initialize(app_resource, user)
          @app_resource = app_resource
          @user = user
        end
      end
    end
  end
end
