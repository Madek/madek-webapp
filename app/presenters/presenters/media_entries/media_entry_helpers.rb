module Presenters
  module MediaEntries
    module MediaEntryHelpers
      extend ActiveSupport::Concern

      included do

        private

        def image_url_helper(size)
          result = generic_thumbnail_url # fallback from "superclass"

          media_file = @resource.media_file
          if result and media_file.representable_as_image?
            # TODO: for all ResourceThumbs…
            # if media_file.the_preview_was_created_and_should_exist_in_filesystem
            result = preview_media_entry_path(@resource, size)
            # else
            # url = ActionController::Base.helpers.image_path \
            #     ::UI_GENERIC_THUMBNAIL[:incomplete]
          end
          result
        end
      end
    end
  end
end
