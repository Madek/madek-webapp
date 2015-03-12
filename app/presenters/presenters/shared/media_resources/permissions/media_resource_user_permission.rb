module Presenters
  module Shared
    module MediaResources
      module Permissions
        class MediaResourceUserPermission < MediaResourceCommonPermission
          def initialize(app_resource)
            @app_resource = app_resource
          end

          def person_name
            ::Presenters::People::PersonIndex.new(@app_resource.user.person)
          end

          delegate :edit_permissions, to: :@app_resource
        end
      end
    end
  end
end
