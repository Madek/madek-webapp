module Presenters
  module Shared
    module MediaResources
      module Permissions
        class MediaResourceCommonPermission < Presenters::Shared::AppResource
          delegate :get_metadata_and_previews, to: :@resource
        end
      end
    end
  end
end
