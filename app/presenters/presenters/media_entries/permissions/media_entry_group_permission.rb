module Presenters
  module MediaEntries
    module Permissions
      class MediaEntryGroupPermission < \
        Presenters::Shared::MediaResource::Permissions::\
          MediaResourceGroupPermission

        include Presenters::\
                MediaEntries::\
                Permissions::\
                Modules::\
                MediaEntryCommonPermissions
      end
    end
  end
end
