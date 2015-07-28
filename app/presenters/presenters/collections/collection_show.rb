module Presenters
  module Collections
    class CollectionShow < Presenters::Shared::MediaResources::MediaResourceShow
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

      def highlights_thumbs
        @app_resource \
          .media_entries
          .highlights
          .map { |me| Presenters::MediaEntries::MediaEntryIndex.new(me, @user) }
      end
    end
  end
end
