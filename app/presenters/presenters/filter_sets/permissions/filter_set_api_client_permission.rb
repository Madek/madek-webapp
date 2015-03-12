module Presenters
  module FilterSets
    module Permissions
      class FilterSetApiClientPermission < \
        Presenters::Shared::MediaResources::Permissions::\
          MediaResourceApiClientPermission

        delegate :edit_metadata_and_filter, to: :@app_resource
      end
    end
  end
end
