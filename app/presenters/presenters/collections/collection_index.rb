module Presenters
  module Collections
    class CollectionIndex < Presenters::Shared::MediaResource::MediaResourceIndex
      include Presenters::Collections::Modules::CollectionCommon

      def url
        prepend_url_context_fucking_rails collection_path @app_resource
      end

      def image_url
        media_entry = choose_media_entry_for_preview

        preview = if media_entry and media_entry.media_file.representable_as_image?
                    media_entry.media_file.preview(:small)
                  end

        if preview.present?
          preview_path(preview)
        else
          generic_thumbnail_url
        end
      end

      private

      # TODO: shared CollectionPresenter?
      def generic_thumbnail_url
        prepend_url_context_fucking_rails \
          ActionController::Base.helpers.image_path \
            Madek::Constants::Webapp::UI_GENERIC_THUMBNAIL[:collection]
      end

      def choose_media_entry_for_preview
        c = @app_resource # the collection in question
        child_entries = c.media_entries.viewable_by_user_or_public(@user)
        child_collections = c.collections.viewable_by_user_or_public(@user)

        if child_entries.exists?
          return cover_or_first_media_entry(@app_resource)
        end

        if child_collections.exists?
          collection_with_preview_media_entry = child_collections.find do |c|
            cover_or_first_media_entry(c)
          end
          cover_or_first_media_entry(collection_with_preview_media_entry)
        end
      end

      def cover_or_first_media_entry(collection)
        return unless collection
        child_entries = collection.media_entries.viewable_by_user_or_public(@user)
        return unless child_entries
        collection.cover or child_entries.first
      end

      # TEMP HIDDEN TILL WE CLEAR UP THIS TOPIC:
      #
      # # TODO: to shared, we need this logic for not just thumbs
      #
      # # TODO: this needs more cleverness.
      # # we actually want to build a list of candidates and then select
      # # the first one from the list which is representable as an image.
      # # Right now, if the first entry is an image but the second is a pic,
      # # we still show the generic thumbnail.
      # #
      # # But maybe we throw this all away anyhow, let's wait for the Spec.
      #
      # def select_collection_preview(collection)
      #   representative_entry = select_representative_entry(collection)
      #
      #   if representative_entry \
      #     and representative_entry.media_file.representable_as_image?
      #       preview_media_entry_path(media_entry, :small)
      #   else
      #     generic_thumbnail_url
      #   end
      # end
      #
      # def select_representative_entry(collection)
      #   return unless collection
      #   # First decide from which collection we'll select an entry
      #   selected_collection = \
      #     case
      #     # Preferably the collection itself
      #     when collection.media_entries.exists? then collection
      #     # Otherwise we select a belonging collection we can work with
      #     when collection.collections.exists?
      #       collection.collections.find { |c| cover_or_first_media_entry(c) }
      #     end
      #   # and we get the appropriate entry from that collection
      #   cover_or_first_media_entry(selected_collection)
      # end
      #
      # def cover_or_first_media_entry(collection)
      #   return unless (collection and collection.media_entries)
      #   collection.cover or collection.media_entries.first
      # end

    end
  end
end
