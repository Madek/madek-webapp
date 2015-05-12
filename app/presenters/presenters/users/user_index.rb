module Presenters
  module Users
    class UserIndex < Presenters::Shared::AppResource
      delegate_to_app_resource :login, :email
    end
  end
end
