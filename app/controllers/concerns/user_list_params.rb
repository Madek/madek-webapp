# Some of the `ResourceListParams` are persisted to the User's session.
module Concerns
  module UserListParams
    extend ActiveSupport::Concern

    included do

      private

      def persist_list_config_to_session(config)
        session[:list_config] = (session[:list_config] || {})
          .merge(config.slice(*Madek::Constants::Webapp::USER_LIST_CONFIG_KEYS))
      end

    end
  end
end
