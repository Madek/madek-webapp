module Presenters
  module MediaEntries
    class MediaEntryPermissionsShow < \
      Presenters::Shared::MediaResources::MediaResourcePermissionsShow

      define_permissions_api MediaEntry
    end
  end
end
