module Presenters
  module MediaEntries
    module Permissions
      class MediaEntryUserPermission < \
        Presenters::Shared::MediaResources::Permissions::\
          MediaResourceUserPermission

        include Presenters::\
                MediaEntries::\
                Permissions::\
                Modules::\
                MediaEntryCommonPermissions
      end
    end
  end
end
