module Presenters
  module Groups
    class GroupEdit < GroupCommon

      def members
        @app_resource.users.map do |user|
          Presenters::Users::UserIndex.new(user)
        end
      end

      def current_user_id
        @user.id
      end

      def cancel_url
        my_groups_path
      end

      def success_url
        my_groups_path
      end
    end
  end
end
