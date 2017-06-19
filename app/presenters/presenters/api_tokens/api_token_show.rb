module Presenters
  module ApiTokens
    class ApiTokenShow < Presenters::ApiTokens::ApiTokenCommon

      def initialize(token, user, callback_url)
        super(token, user)
        @callback_url = callback_url
      end

      # NOTE: only available on new instances, e.g. in response to creation action
      def secret
        @app_resource.token
      end

      def actions
        {
          index: {
            url: prepend_url_context(my_create_api_token_path)
          },
          callback: (if @callback_url.present? then { url: @callback_url } end)
        }.compact
      end
    end
  end
end
