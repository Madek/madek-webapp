module Presenters
  module Collections
    class CollectionNew < Presenters::Users::UserDashboard

      attr_accessor :error

      def initialize(user, user_scopes, list_conf)
        super(user, user_scopes, list_conf)
      end

      def submit_url
        collections_path
      end

      def cancel_url
        my_dashboard_path
      end

    end
  end
end
