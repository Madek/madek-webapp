module Presenters
  module Users
    class UserIndex < Presenters::Shared::AppResource
      delegate_to_app_resource :login, :email

      def name
        @app_resource.person.to_s
      end

    end
  end
end
