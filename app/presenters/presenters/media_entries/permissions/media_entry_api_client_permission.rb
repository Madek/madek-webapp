module Presenters
  module MediaEntries
    module Permissions
      class MediaEntryApiClientPermission < \
        Presenters::Shared::Resource::ResourceApiClientPermission

        include Presenters::Shared::MediaResource::\
          Permissions::MediaResourceCommonPermissions

        delegate :get_full_size, to: :@app_resource
      end
    end
  end
end
