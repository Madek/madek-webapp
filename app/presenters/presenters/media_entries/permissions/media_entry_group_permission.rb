module Presenters
  module MediaEntries
    module Permissions
      class MediaEntryGroupPermission < \
        Presenters::Shared::Resource::ResourceGroupPermission

        include Presenters::Shared::MediaResource::\
          Permissions::MediaResourceCommonPermissions

        delegate :get_full_size, to: :@app_resource
        delegate :edit_metadata, to: :@app_resource
      end
    end
  end
end
