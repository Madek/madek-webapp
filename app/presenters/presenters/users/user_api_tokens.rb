module Presenters
  module Users
    class UserApiTokens < Presenter

      def initialize(user)
        @user = user
      end

      def api_tokens
        ApiToken.where(user: @user).map do |t|
          Presenters::ApiTokens::ApiTokenIndex.new(t, @user)
        end
      end

      def actions
        {
          new: {
            url: prepend_url_context(my_new_api_token_path)
          }
        }
      end

    end
  end
end
