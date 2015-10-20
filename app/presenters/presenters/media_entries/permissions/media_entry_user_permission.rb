module Presenters
  module MediaEntries
    module Permissions
      class MediaEntryUserPermission < \
        Presenters::Shared::MediaResource::Permissions::\
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
