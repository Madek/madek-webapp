module Presenters
  module MediaEntries
    class MediaEntryPermissions < \
      Presenters::Shared::MediaResource::MediaResourcePermissionsShow

      def permission_types
        ::Permissions::Modules::MediaEntry::PERMISSION_TYPES
      end

      define_permissions_api MediaEntry

      def update_transfer_responsibility_url
        update_transfer_responsibility_media_entry_path(@app_resource)
      end
    end
  end
end
