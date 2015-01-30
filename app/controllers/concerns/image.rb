module Concerns
  module Image
    extend ActiveSupport::Concern

    def get_preview_and_send_image(media_entry, size)
      preview = media_entry.media_file.preview(size)
      send_file preview.file_path,
                type: preview.content_type,
                disposition: 'inline'
    end

  end
end
