module Presenters
  module ApiTokens
    class ApiTokenIndex < Presenters::ApiTokens::ApiTokenCommon

      def actions
        {
          update: !is_expired && policy_for(@user).update_api_token? && {
            url: prepend_url_context(my_update_api_token_path(uuid)),
            method: 'PATCH'
          }
        }
      end

    end
  end
end
