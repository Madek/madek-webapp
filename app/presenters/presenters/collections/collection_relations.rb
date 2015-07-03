module Presenters
  module Collections
    class CollectionRelations < \
      Presenters::Shared::MediaResources::MediaResourceRelations

      def any?
        super or
          self.child_media_resources.resources.any?
      end

      def child_media_resources
        Presenters::Collections::ChildMediaResources
          .new(@user, @app_resource.child_media_resources)
      end
    end
  end
end
