module Presenters
  module MediaEntries
    module Permissions
      class MediaEntryPublicPermission < \
        Presenters::Shared::MediaResources::Permissions::\
          MediaResourcePublicPermission

        delegate :get_full_size, to: :@resource
      end
    end
  end
end
