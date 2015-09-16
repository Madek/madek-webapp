module Presenters
  module FilterSets
    class FilterSetPermissionsShow < \
      Presenters::Shared::MediaResources::MediaResourcePermissionsShow

      def permission_types
        ::Permissions::Modules::FilterSet::PERMISSION_TYPES
      end

      define_permissions_api FilterSet
    end
  end
end
