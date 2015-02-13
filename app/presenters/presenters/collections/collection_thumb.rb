module Presenters
  module Collections
    class CollectionThumb < Presenters::Shared::Resources::ResourcesThumb

      def url
        collection_path @resource
      end

      def image_url
        media_entry = choose_media_entry_for_preview

        if media_entry and media_entry.media_file.representable_as_image?
          preview_media_entry_path(media_entry, :small)
        else
          generic_thumbnail_url
        end
      end

      private

      def choose_media_entry_for_preview
        if @resource.media_entries.exists?
          cover_or_first_media_entry(@resource)
        elsif @resource.collections.exists?
          collection_with_preview_media_entry = \
            @resource.collections.find { |c| cover_or_first_media_entry(c) }
          cover_or_first_media_entry(collection_with_preview_media_entry)
        end
      end

      def cover_or_first_media_entry(collection)
        return unless collection.media_entries # collection can be empty!
        collection.media_entries.cover \
          || collection.media_entries.first
      end
    end
  end
end
