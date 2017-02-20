module Presenters
  module MediaEntries
    module Permissions
      class MediaEntryPublicPermission < \
        Presenters::Shared::Resource::ResourcePublicPermission

        include Presenters::Shared::MediaResource::\
          Permissions::MediaResourceCommonPermissions

        delegate :get_full_size, to: :@app_resource
      end
    end
  end
end
