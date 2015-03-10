module Presenters
  module Collections
    class CollectionPermissionsShow < \
      Presenters::Shared::MediaResources::MediaResourcePermissionsShow

      define_permissions_api Collection
    end
  end
end
