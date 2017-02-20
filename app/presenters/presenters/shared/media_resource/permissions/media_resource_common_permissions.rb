module Presenters
  module Shared
    module MediaResource
      module Permissions
        module MediaResourceCommonPermissions
          extend ActiveSupport::Concern

          included do
            delegate :get_metadata_and_previews, to: :@app_resource
          end
        end
      end
    end
  end
end
