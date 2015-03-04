module Presenters
  module Collections
    class CollectionShow < Presenters::Shared::MediaResources::MediaResourceShow
      include Presenters::Collections::Modules::CollectionCommon

      def initialize(resource, user)
        super(resource, user)
        @relations = \
          Presenters::Collections::CollectionRelations.new(@resource, @user)
      end

      def preview_thumb_url
        ActionController::Base.helpers.image_path \
          ::UI_GENERIC_THUMBNAIL[:collection]
      end

      def highlights_thumbs
        @resource \
          .media_entries
          .highlights
          .map { |me| Presenters::MediaEntries::MediaEntryIndex.new(me, @user) }
      end
    end
  end
end
