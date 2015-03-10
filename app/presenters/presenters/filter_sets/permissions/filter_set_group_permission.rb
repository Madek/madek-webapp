module Presenters
  module FilterSets
    module Permissions
      class FilterSetGroupPermission < \
        Presenters::Shared::MediaResources::Permissions::\
          MediaResourceGroupPermission
      end
    end
  end
end
