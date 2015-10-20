module Presenters
  module Shared
    module MediaResource
      module Permissions
        class MediaResourceCommonPermission < Presenters::Shared::AppResource
          delegate :get_metadata_and_previews, to: :@app_resource
        end
      end
    end
  end
end
