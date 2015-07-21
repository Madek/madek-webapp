module Presenters
  module Groups
    class GroupEdit < GroupCommon
      def initialize(app_resource, user)
        @user = user
        super(app_resource)
      end
    end
  end
end
