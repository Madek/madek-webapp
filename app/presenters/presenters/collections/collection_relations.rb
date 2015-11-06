module Presenters
  module Collections
    class CollectionRelations < \
      Presenters::Shared::MediaResource::MediaResourceRelations

      def any?
        super or
          self.child_media_resources.resources.any?
      end

      def child_media_resources
        Presenters::Collections::ChildMediaResources
          .new(@app_resource.child_media_resources, @user, list_conf: @list_conf)
      end
    end
  end
end
