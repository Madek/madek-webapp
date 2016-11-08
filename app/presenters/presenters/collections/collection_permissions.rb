module Presenters
  module Collections
    class CollectionPermissions < \
      Presenters::Shared::MediaResource::MediaResourcePermissionsShow

      def permission_types
        ::Permissions::Modules::Collection::PERMISSION_TYPES
      end

      define_permissions_api Collection
    end
  end
end
