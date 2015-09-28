module Presenters
  module ApiClients
    class ApiClientIndex < Presenters::Shared::AppResource
      delegate_to_app_resource :login, :description
    end
  end
end
