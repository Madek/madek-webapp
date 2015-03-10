module Presenters
  module FilterSets
    class FilterSetPermissionsShow < \
      Presenters::Shared::MediaResources::MediaResourcePermissionsShow

      define_permissions_api FilterSet
    end
  end
end
