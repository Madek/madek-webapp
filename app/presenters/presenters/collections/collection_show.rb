module Presenters
  module Collections
    class CollectionShow < Presenters::Shared::MediaResource::MediaResourceShow
      include Presenters::Collections::Modules::CollectionCommon

      def initialize(app_resource, user)
        super(app_resource, user)
        @relations = \
          Presenters::Collections::CollectionRelations.new(@app_resource, @user)
      end

      def preview_thumb_url
        prepend_url_context_fucking_rails \
          ActionController::Base.helpers.image_path \
            ::UI_GENERIC_THUMBNAIL[:collection]
      end

      def highlighted_media_resources
        Presenters::Collections::ChildMediaResources.new \
          @user,
          @app_resource.highlighted_media_resources
      end
    end
  end
end
