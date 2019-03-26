module Presenters
  module ApiTokens
    class ApiTokenCommon < Presenters::Shared::AppResourceWithUser
      delegate_to_app_resource :description, :user_id, :revoked, :expires_at

      def label # first 5 letters of secret (to make it easier to manage)
        @app_resource.token_part
      end

      def scopes
        [:read, :write].map do |key|
          key if @app_resource.send("scope_#{key}")
        end.compact
      end

      def is_expired
        return true if revoked
        return false unless expires_at
        expires_at.utc <= DateTime.now.utc
      end

    end
  end
end
