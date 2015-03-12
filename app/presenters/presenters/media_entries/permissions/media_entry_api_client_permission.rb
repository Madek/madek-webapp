module Presenters
  module MediaEntries
    module Permissions
      class MediaEntryApiClientPermission < \
        Presenters::Shared::MediaResources::Permissions::\
          MediaResourceApiClientPermission

        delegate :get_full_size, to: :@app_resource
      end
    end
  end
end
