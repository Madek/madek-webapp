module Presenters
  module FilterSets
    class FilterSetPermissionsShow < \
      Presenters::Shared::MediaResource::MediaResourcePermissionsShow

      def permission_types
        ::Permissions::Modules::FilterSet::PERMISSION_TYPES
      end

      define_permissions_api FilterSet
    end
  end
end
