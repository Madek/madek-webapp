# Some of the `ResourceListParams` are persisted to the User's session.
module Concerns
  module UserListParams
    extend ActiveSupport::Concern

    included do

      private

      def persist_list_config_to_session(config)
        if current_user
          current_user.settings = (current_user.settings || {}).merge(
            config.slice(*Madek::Constants::Webapp::USER_LIST_CONFIG_KEYS))
          current_user.save
        end
      end
    end
  end
end
