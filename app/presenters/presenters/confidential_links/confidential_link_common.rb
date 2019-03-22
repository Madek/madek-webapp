module Presenters
  module ConfidentialLinks
    class ConfidentialLinkCommon < Presenters::Shared::AppResourceWithUser

      delegate_to_app_resource :description, :expires_at, :revoked

      attr_accessor :just_created

      def label
        @app_resource.token
      end

      def is_expired
        return true if revoked
        return false unless expires_at
        expires_at.utc <= DateTime.now.utc
      end
    end
  end
end
