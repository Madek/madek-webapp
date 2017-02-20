module Presenters
  module Shared
    module MediaResource
      module Permissions
        class MediaResourceUserPermission < \
          Presenters::Shared::Resource::ResourceUserPermission

          delegate :edit_permissions, to: :@app_resource

        end
      end
    end
  end
end
