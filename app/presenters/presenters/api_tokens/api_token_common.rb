module Presenters
  module ApiTokens
    class ApiTokenCommon < Presenters::Shared::AppResourceWithUser
      delegate_to_app_resource :description, :user_id, :revoked

      def label # first 5 letters of secret (to make it easier to manage)
        @app_resource.token_part
      end

      def scopes
        [:read, :write].map do |key|
          key if @app_resource.send("scope_#{key}")
        end.compact
      end

      def expires_at
        @app_resource.expires_at unless @app_resource.revoked
      end

    end
  end
end
