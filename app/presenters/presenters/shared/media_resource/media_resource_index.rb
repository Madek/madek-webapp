module Presenters
  module Shared
    module MediaResource
      class MediaResourceIndex < Presenters::Shared::AppResource
        include Presenters::Shared::MediaResource::Modules::PrivacyStatus

        def initialize(app_resource, user, list_conf: nil)
          super(app_resource)
          @user = user
          @list_conf = list_conf
        end

        def favored
          @app_resource.favored?(@user)
        end

        def favorite_policy
          policy(@user).favor?
        end

      end
    end
  end
end
