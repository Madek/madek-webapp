module Presenters
  module Collections
    module Permissions
      class CollectionUserPermission < \
        Presenters::Shared::MediaResource::Permissions::MediaResourceUserPermission

        include Presenters::Shared::MediaResource::\
          Permissions::MediaResourceCommonPermissions

        delegate :edit_metadata_and_relations, to: :@app_resource
      end
    end
  end
end
