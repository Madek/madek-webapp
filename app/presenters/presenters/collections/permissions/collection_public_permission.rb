module Presenters
  module Collections
    module Permissions
      class CollectionPublicPermission < \
        Presenters::Shared::MediaResource::Permissions::\
          MediaResourcePublicPermission
      end
    end
  end
end
