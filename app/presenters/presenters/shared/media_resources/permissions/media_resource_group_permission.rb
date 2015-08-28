module Presenters
  module Shared
    module MediaResources
      module Permissions
        class MediaResourceGroupPermission < MediaResourceCommonPermission
          def group_name
            @app_resource.group.name
          end

          delegate :group_id, to: :@app_resource
        end
      end
    end
  end
end
