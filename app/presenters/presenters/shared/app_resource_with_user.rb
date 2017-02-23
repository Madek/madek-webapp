module Presenters
  module Shared
    class AppResourceWithUser < AppResource
      def initialize(app_resource, user)
        super(app_resource)
        @user = user
        raise TypeError, 'Not a User!' unless (user.nil? or user.is_a?(User))
      end
    end
  end
end
