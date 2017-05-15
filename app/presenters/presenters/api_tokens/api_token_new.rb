module Presenters
  module ApiTokens
    class ApiTokenNew < Presenters::ApiTokens::ApiTokenCommon

      def actions
        {
          create: {
            url: prepend_url_context(my_create_api_token_path(uuid)),
            method: 'POST'
          }
        }
      end
    end
  end
end
