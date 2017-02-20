module Presenters
  module Collections
    module Permissions
      class CollectionGroupPermission < \
        Presenters::Shared::Resource::ResourceGroupPermission

        include Presenters::Shared::MediaResource::\
          Permissions::MediaResourceCommonPermissions

        delegate :edit_metadata_and_relations, to: :@app_resource
      end
    end
  end
end
