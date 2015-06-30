module Presenters
  module Shared
    module MediaResources
      class MediaResourceRelations < Presenters::Shared::AppResource
        def initialize(app_resource, user)
          super(app_resource)
          @user = user
        end

        def any?
          parent_media_resources.media_resources.any? or
            sibling_media_resources.media_resources.any?
        end

        def parent_media_resources
          Presenters::Shared::MediaResources::MediaResources.new \
            @user,
            media_resources: @app_resource.parent_collections
        end

        def sibling_media_resources
          Presenters::Shared::MediaResources::MediaResources.new \
            @user,
            media_resources: \
              @app_resource
                .sibling_collections
                .where.not(collections: { id: @app_resource.id })
        end
      end
    end
  end
end
