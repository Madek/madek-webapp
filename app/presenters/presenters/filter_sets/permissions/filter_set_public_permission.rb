module Presenters
  module FilterSets
    module Permissions
      class FilterSetPublicPermission < \
        Presenters::Shared::Resource::ResourcePublicPermission
        include Presenters::Shared::MediaResource::\
          Permissions::MediaResourceCommonPermissions
      end
    end
  end
end
