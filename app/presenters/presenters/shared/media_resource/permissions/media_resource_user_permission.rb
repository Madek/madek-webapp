module Presenters
  module Shared
    module MediaResource
      module Permissions
        class MediaResourceUserPermission < MediaResourceCommonPermission
          def initialize(app_resource)
            @app_resource = app_resource
          end

          def subject
            Presenters::Users::UserIndex.new(@app_resource.user)
          end

          delegate :edit_permissions, to: :@app_resource
        end
      end
    end
  end
end
