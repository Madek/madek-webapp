module Presenters
  module Shared
    module MediaResources
      class MediaResourceShow < Presenters::Shared::AppResource
        def initialize(app_resource, user)
          super(app_resource)
          @user = user
        end

        def description
          @app_resource.description
        end

        def keywords
          @app_resource.keywords.map(&:to_s)
        end
      end
    end
  end
end
