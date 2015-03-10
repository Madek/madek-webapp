module Presenters
  module Shared
    module MediaResources
      module Permissions
        class MediaResourceCommonPermission < Presenter
          def initialize(resource)
            @resource = resource
          end

          delegate :get_metadata_and_previews, to: :@resource
        end
      end
    end
  end
end
