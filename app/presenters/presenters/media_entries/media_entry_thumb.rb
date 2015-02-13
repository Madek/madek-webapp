module Presenters
  module MediaEntries
    class MediaEntryThumb < Presenters::Shared::Resources::ResourcesThumb

      def url
        media_entry_path @resource
      end

      def image_url
        result = generic_thumbnail_url # fallback from "superclass"

        media_file = @resource.media_file
        if result and media_file.representable_as_image?
          # TODO: for all ResourceThumbs…
          # if media_file.the_preview_was_created_and_should_exist_in_filesystem
          result = preview_media_entry_path(@resource, :small)
          # else
          # url = ActionController::Base.helpers.image_path \
          #     ::UI_GENERIC_THUMBNAIL[:incomplete]
        end
        result
      end

      def authors
        @resource.meta_data.find_by(meta_key_id: 'author').to_s
      end

    end
  end
end
