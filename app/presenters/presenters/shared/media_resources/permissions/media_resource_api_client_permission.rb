module Presenters
  module Shared
    module MediaResources
      module Permissions
        class MediaResourceApiClientPermission < MediaResourceCommonPermission
          def id
            @app_resource.api_client.id
          end
        end
      end
    end
  end
end
