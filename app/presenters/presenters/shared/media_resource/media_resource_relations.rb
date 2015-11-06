module Presenters
  module Shared
    module MediaResource
      class MediaResourceRelations < Presenters::Shared::AppResource
        def initialize(app_resource, user, list_conf: nil)
          super(app_resource)
          @user = user
          @list_conf = list_conf
        end

        def any?
          parent_media_resources.resources.any? or
            sibling_media_resources.any?
        end

        def parent_media_resources
          Presenters::MediaResources::MediaResources.new(
            @app_resource.parent_collections, @user, list_conf: @list_conf)
        end

        def sibling_media_resources
          Presenters::MediaResources::MediaResources.new(
            @app_resource
              .sibling_collections
              .where.not(collections: { id: @app_resource.id }),
            @user,
            list_conf: @list_conf)
        end
      end
    end
  end
end
