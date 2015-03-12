module Presenters
  module FilterSets
    module Permissions
      class FilterSetUserPermission < \
        Presenters::Shared::MediaResources::Permissions::\
          MediaResourceUserPermission

        [:edit_metadata_and_filter]
          .each { |m| delegate m, to: :@app_resource }
      end
    end
  end
end
