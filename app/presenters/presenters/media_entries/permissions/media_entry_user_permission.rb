module Presenters
  module MediaEntries
    module Permissions
      class MediaEntryUserPermission < \
        Presenters::Shared::MediaResources::Permissions::\
          MediaResourceUserPermission

        delegate :get_full_size, to: :@app_resource
      end
    end
  end
end
