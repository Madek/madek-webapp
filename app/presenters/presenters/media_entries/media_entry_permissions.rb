module Presenters
  module MediaEntries
    class MediaEntryPermissions < \
      Presenters::Shared::MediaResource::MediaResourcePermissionsShow

      def permission_types
        ::Permissions::Modules::MediaEntry::PERMISSION_TYPES
      end

      define_permissions_api MediaEntry
    end
  end
end
