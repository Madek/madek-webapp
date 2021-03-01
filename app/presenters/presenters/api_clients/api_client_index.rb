module Presenters
  module ApiClients
    class ApiClientIndex < Presenters::Shared::AppResource
      delegate_to_app_resource :login, :description

      def label
        @app_resource.login
      end
    end
  end
end
