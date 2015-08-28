module Presenters
  module MediaEntries
    module Permissions
      class MediaEntryGroupPermission < \
        Presenters::Shared::MediaResources::Permissions::\
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
