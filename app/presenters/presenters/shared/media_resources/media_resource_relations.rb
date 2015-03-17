module Presenters
  module Shared
    module MediaResources
      class MediaResourceRelations < Presenters::Shared::AppResource
        def initialize(app_resource, user)
          super(app_resource)
          @user = user
        end

        def any?
          # parents can only be collections anyway
          parent_media_resources.collections.any? or
            sibling_media_resources.media_entries.any? or
            sibling_media_resources.collections.any? or
            sibling_media_resources.filter_sets.any?
        end

        def parent_media_resources
          Presenters::Shared::MediaResources::MediaResources.new \
            @user,
            collections: @app_resource.parent_collections
        end

        def sibling_media_resources
          Presenters::Shared::MediaResources::MediaResources.new \
            @user,
            collections: @app_resource.sibling_collections
        end
      end
    end
  end
end
