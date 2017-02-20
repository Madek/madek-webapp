module Presenters
  module FilterSets
    module Permissions
      class FilterSetApiClientPermission < \
        Presenters::Shared::Resource::ResourceApiClientPermission

        include Presenters::Shared::MediaResource::\
          Permissions::MediaResourceCommonPermissions

        delegate :edit_metadata_and_filter, to: :@app_resource
      end
    end
  end
end
