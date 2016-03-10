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

      end
    end
  end
end
