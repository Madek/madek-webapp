module Presenters
  module Groups
    class GroupEdit < GroupCommon
      def initialize(app_resource, user)
        @user = user
        super(app_resource)
      end

      def members
        @app_resource.users.map do |user|
          Presenters::Users::UserIndex.new(user)
        end
      end
    end
  end
end
