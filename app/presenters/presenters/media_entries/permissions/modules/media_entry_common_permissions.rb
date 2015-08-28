module Presenters
  module MediaEntries
    module Permissions
      module Modules
        module MediaEntryCommonPermissions
          extend ActiveSupport::Concern

          included do
            delegate :get_full_size, to: :@app_resource
            delegate :edit_metadata, to: :@app_resource
          end
        end
      end
    end
  end
end
