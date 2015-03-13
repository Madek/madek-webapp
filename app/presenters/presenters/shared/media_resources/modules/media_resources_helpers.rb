module Presenters
  module Shared
    module MediaResources
      module Modules
        module MediaResourcesHelpers
          def standard_media_resources
            Presenters::Shared::MediaResources::MediaResources.new \
              @user,
              media_entries: @app_resource.media_entries,
              collections: @app_resource.collections,
              filter_sets: @app_resource.filter_sets
          end
        end
      end
    end
  end
end
