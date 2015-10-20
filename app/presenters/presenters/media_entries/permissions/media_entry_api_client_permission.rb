module Presenters
  module MediaEntries
    module Permissions
      class MediaEntryApiClientPermission < \
        Presenters::Shared::MediaResource::Permissions::\
          MediaResourceApiClientPermission

        delegate :get_full_size, to: :@app_resource
      end
    end
  end
end
