module Presenters
  module Collections
    class CollectionPermissions < \
      Presenters::Shared::MediaResource::MediaResourcePermissionsShow

      def permission_types
        ::Permissions::Modules::Collection::PERMISSION_TYPES
      end

      define_permissions_api Collection

      def update_transfer_responsibility_url
        update_transfer_responsibility_collection_path(@app_resource)
      end
    end
  end
end
