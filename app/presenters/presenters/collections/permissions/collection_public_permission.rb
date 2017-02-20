module Presenters
  module Collections
    module Permissions
      class CollectionPublicPermission < \
        Presenters::Shared::Resource::ResourcePublicPermission
        include Presenters::Shared::MediaResource::\
          Permissions::MediaResourceCommonPermissions
      end
    end
  end
end
