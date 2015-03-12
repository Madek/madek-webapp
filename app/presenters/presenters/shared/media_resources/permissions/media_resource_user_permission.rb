module Presenters
  module Shared
    module MediaResources
      module Permissions
        class MediaResourceUserPermission < MediaResourceCommonPermission
          def initialize(app_resource)
            @app_resource = app_resource
          end

          def person_name
            @app_resource.user.person.to_s
          end

          delegate :edit_permissions, to: :@app_resource
        end
      end
    end
  end
end
