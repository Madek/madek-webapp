module Presenters
  module Collections
    class CollectionPermissionsShow < \
      Presenters::Shared::MediaResources::MediaResourcePermissionsShow

      TYPES_MAP = \
        { edit_metadata_and_relations: :edit_data }.merge(SHARED_TYPES_MAP)

      setup Collection, TYPES_MAP
    end
  end
end
