module Presenters
  module Collections
    class CollectionPermissionsShow < \
      Presenters::Shared::MediaResources::MediaResourcePermissionsShow

      def permission_types
        ::Permissions::Modules::Collection::PERMISSION_TYPES
      end

      define_permissions_api Collection
    end
  end
end
