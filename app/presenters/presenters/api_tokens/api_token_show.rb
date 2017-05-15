module Presenters
  module ApiTokens
    class ApiTokenShow < Presenters::ApiTokens::ApiTokenCommon

      # NOTE: only available on new instances, e.g. in response to creation action
      def secret
        @app_resource.token
      end

      def actions
        {
          index: {
            url: prepend_url_context(my_create_api_token_path)
          }
        }
      end
    end
  end
end
