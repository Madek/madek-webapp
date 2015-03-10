module Presenters
  module Collections
    module Permissions
      class CollectionUserPermission < \
        Presenters::Shared::MediaResources::Permissions::\
          MediaResourceUserPermission

        delegate :edit_metadata_and_relations, to: :@resource
      end
    end
  end
end
