module Presenters
  module Shared
    module MediaResource
      class MediaResourceIndex < Presenters::Shared::AppResource
        include Presenters::Shared::MediaResource::Modules::PrivacyStatus

        def initialize(app_resource, user)
          super(app_resource)
          @user = user
        end
      end
    end
  end
end
