module Presenters
  module Shared
    module MediaResources
      module Permissions
        class MediaResourceApiClientPermission < MediaResourceCommonPermission
          def api_client_id
            @app_resource.api_client.id
          end

          def api_client_login
            @app_resource.api_client.login
          end
        end
      end
    end
  end
end
