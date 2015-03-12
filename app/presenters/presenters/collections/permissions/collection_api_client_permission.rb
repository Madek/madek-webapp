module Presenters
  module Collections
    module Permissions
      class CollectionApiClientPermission < \
        Presenters::Shared::MediaResources::Permissions::\
          MediaResourceApiClientPermission

        delegate :edit_metadata_and_relations, to: :@app_resource
      end
    end
  end
end
