module Presenters
  module Collections
    module Modules
      module CollectionCommon
        extend ActiveSupport::Concern
        include Presenters::Shared::MediaResource::Modules::MediaResourceCommon

        def initialize(app_resource, user)
          fail 'TypeError!' unless app_resource.is_a?(Collection)
          @app_resource = app_resource
          @user = user
        end

        included do
          attr_reader :relations
        end

      end
    end
  end
end
