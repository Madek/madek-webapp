module Presenters
  module FilterSets
    module Permissions
      class FilterSetUserPermission < \
        Presenters::Shared::Resource::ResourceUserPermission

        include Presenters::Shared::MediaResource::\
          Permissions::MediaResourceCommonPermissions

        delegate_to_app_resource :edit_metadata_and_filter
      end
    end
  end
end
