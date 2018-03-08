module Presenters
  module Shared
    module MediaResource
      class MediaResourceConfidentialLinkCommon < \
        Presenters::Shared::AppResourceWithUser

        delegate_to_app_resource :description, :expires_at, :revoked

        attr_accessor :just_created

        def label
          @app_resource.token
        end
      end
    end
  end
end
