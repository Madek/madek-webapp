module Presenters
  module MediaEntries
    class MediaEntryPermissions < \
      Presenters::Shared::MediaResources::MediaResourcePermissionsShow

      TYPES_MAP = \
        { edit_metadata: :edit_data,
          get_full_size: :fullsize }.merge(SHARED_TYPES_MAP)

      setup MediaEntry, TYPES_MAP
    end
  end
end
