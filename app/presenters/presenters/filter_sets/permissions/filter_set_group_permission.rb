module Presenters
  module FilterSets
    module Permissions
      class FilterSetGroupPermission < \
        Presenters::Shared::Resource::ResourceGroupPermission
        include Presenters::Shared::MediaResource::\
          Permissions::MediaResourceCommonPermissions
      end
    end
  end
end
