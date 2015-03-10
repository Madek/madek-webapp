module Presenters
  module MediaEntries
    module Permissions
      class MediaEntryUserPermission < \
        Presenters::Shared::MediaResources::Permissions::\
          MediaResourceUserPermission

        delegate :get_full_size, to: :@resource
      end
    end
  end
end
