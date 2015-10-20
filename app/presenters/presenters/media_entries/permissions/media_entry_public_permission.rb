module Presenters
  module MediaEntries
    module Permissions
      class MediaEntryPublicPermission < \
        Presenters::Shared::MediaResource::Permissions::\
          MediaResourcePublicPermission

        delegate :get_full_size, to: :@app_resource
      end
    end
  end
end
