module Presenters
  module Collections
    class CollectionShow < Presenters::Shared::MediaResource::MediaResourceShow
      include Presenters::Collections::Modules::CollectionCommon

      def initialize(app_resource, user, list_conf: nil)
        super(app_resource, user)
        @list_conf = list_conf
        @relations = \
          Presenters::Collections::CollectionRelations.new(
            @app_resource, @user, list_conf: @list_conf)
      end

      def preview_thumb_url
        prepend_url_context_fucking_rails \
          ActionController::Base.helpers.image_path \
            Madek::Constants::UI_GENERIC_THUMBNAIL[:collection]
      end

      def highlighted_media_resources
        Presenters::Collections::ChildMediaResources.new \
          @app_resource.highlighted_media_resources,
          @user,
          list_conf: @list_conf
      end
    end
  end
end
