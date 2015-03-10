module Presenters
  module FilterSets
    module Permissions
      class FilterSetPublicPermission < \
        Presenters::Shared::MediaResources::Permissions::\
          MediaResourcePublicPermission
      end
    end
  end
end
