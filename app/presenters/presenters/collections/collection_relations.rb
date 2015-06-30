module Presenters
  module Collections
    class CollectionRelations < \
      Presenters::Shared::MediaResources::MediaResourceRelations

      def any?
        super or
          child_media_resources.media_resources.any?
      end

      def child_media_resources
        Presenters::Shared::MediaResources::MediaResources.new \
          @user,
          media_resources: @app_resource.media_resources
      end
    end
  end
end
