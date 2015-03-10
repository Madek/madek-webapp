module Presenters
  module Collections
    module Permissions
      class CollectionPublicPermission < \
        Presenters::Shared::MediaResources::Permissions::\
          MediaResourcePublicPermission
      end
    end
  end
end
