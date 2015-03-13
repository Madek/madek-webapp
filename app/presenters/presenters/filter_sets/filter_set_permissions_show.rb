module Presenters
  module FilterSets
    class FilterSetPermissionsShow < \
      Presenters::Shared::MediaResources::MediaResourcePermissionsShow

      TYPES_MAP = \
        { edit_metadata_and_filter: :edit_data }.merge(SHARED_TYPES_MAP)

      setup FilterSet, TYPES_MAP
    end
  end
end
