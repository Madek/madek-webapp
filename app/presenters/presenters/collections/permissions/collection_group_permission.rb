module Presenters
  module Collections
    module Permissions
      class CollectionGroupPermission < \
        Presenters::Shared::MediaResources::Permissions::\
          MediaResourceGroupPermission

        delegate :edit_metadata_and_relations, to: :@resource
      end
    end
  end
end
