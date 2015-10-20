module Presenters
  module FilterSets
    module Permissions
      class FilterSetUserPermission < \
        Presenters::Shared::MediaResource::Permissions::\
          MediaResourceUserPermission

        delegate_to_app_resource :edit_metadata_and_filter
      end
    end
  end
end
