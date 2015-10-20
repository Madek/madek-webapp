module Presenters
  module FilterSets
    module Permissions
      class FilterSetPublicPermission < \
        Presenters::Shared::MediaResource::Permissions::\
          MediaResourcePublicPermission
      end
    end
  end
end
