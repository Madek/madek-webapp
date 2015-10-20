module Presenters
  module FilterSets
    module Permissions
      class FilterSetGroupPermission < \
        Presenters::Shared::MediaResource::Permissions::\
          MediaResourceGroupPermission
      end
    end
  end
end
