module Presenters
  module ApiTokens
    class ApiTokenNew < Presenters::ApiTokens::ApiTokenCommon

      def initialize(token, user, given_props)
        super(token, user)
        @given_props = given_props
      end

      attr_accessor :given_props

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
