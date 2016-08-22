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
    end
  end
end
