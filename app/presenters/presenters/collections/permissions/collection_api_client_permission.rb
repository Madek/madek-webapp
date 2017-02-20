module Presenters
  module Collections
    module Permissions
      class CollectionApiClientPermission < \
        Presenters::Shared::Resource::ResourceApiClientPermission
        include Presenters::Shared::MediaResource::\
          Permissions::MediaResourceCommonPermissions
      end
    end
  end
end
