module Presenters
  module Shared
    module MediaResource
      class MediaResourceShow < Presenters::Shared::AppResource
        include Presenters::Shared::MediaResource::Modules::PrivacyStatus

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
