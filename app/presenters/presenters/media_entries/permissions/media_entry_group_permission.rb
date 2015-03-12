module Presenters
  module MediaEntries
    module Permissions
      class MediaEntryGroupPermission < \
        Presenters::Shared::MediaResources::Permissions::\
          MediaResourceGroupPermission

        delegate :get_full_size, to: :@app_resource
      end
    end
  end
end
