module Modules
  module MediaEntries
    module MediaShortcut
      extend ActiveSupport::Concern
      include ServeFiles

      def image
        entry = get_authorized_resource
        media_type = entry.media_file.media_type

        # Allowed media type
        raise_404 unless ['image', 'video', 'document'].include? media_type
        raise_404 if media_type == 'document' && entry.media_file.extension != 'pdf'
        
        # Allowed route "image.jpg"
        raise_404 unless format_param == 'jpg'

        # Allowed resolutions
        thumbnail = (resolution_param || 'large')
        raise_404 unless ['maximum', 'x_large', 'large', 'medium'].include? thumbnail

        # Find all preview images for resolution (videos have one for each minute, but there are also duplicates due to some issue)
        previews = entry.media_file.previews.to_a
                      .filter { |x| x.content_type == 'image/jpeg' && x.thumbnail == thumbnail}
        raise_404 if previews.length == 0

        # Find the right preview image
        if media_type == 'video'
          # "get_first_or_30_percent"
          index = [(previews.length.to_f / 10 * 3.0).ceil, previews.length - 1].min
          preview = previews.sort_by(&:filename)[index]
        else
          preview = previews.first
        end

        send_preview preview
      end

      def video
        entry = get_authorized_resource

        # Allowed media type
        raise_404 unless 'video' == entry.media_file.media_type

        # Allowed routes "video.mp4", "video.webm"
        raise_404 unless format_param == 'mp4' || format_param == 'webm'

        # Allowed resolutions (and map to conversion_profile)
        conversion_profile = case (resolution_param || 'SD')
          when 'SD' then format_param
          when 'HD' then "#{format_param}_HD"
          else raise_404
        end

        # Find the right preview image
        preview = entry.media_file.previews.find { |x| x.conversion_profile == conversion_profile }

        send_preview preview
      end

      def audio
        entry = get_authorized_resource

        # Allowed media type
        raise_404 unless 'audio' == entry.media_file.media_type

        # Allowed routes "audio.mp3", "audio.ogg" (and map to content_type)
        content_type = case format_param
          when 'mp3' then 'audio/mpeg'
          when 'ogg' then 'audio/ogg'
          else raise_404
        end

        # Find the right preview image
        preview = entry.media_file.previews.find { |x| x.content_type == content_type }

        send_preview preview
      end

      def document
        entry = get_authorized_resource

        # Allowed media type
        raise_404 unless entry.media_file.media_type == 'document' && entry.media_file.extension == 'pdf'

        # Allowed route: "document.pdf"
        raise_404 unless format_param == 'pdf'
        
        # additional authorization check (`get_full_size` permission is needed for PDF)
        if uberadmin_mode
          skip_authorization
        else
          Pundit.authorize(current_user, entry.media_file, :show?)
        end

        send_media_file entry.media_file
      end

      private
      
      def format_param
        params.fetch(:format, nil)
      end
      
      def resolution_param
        params.fetch(:resolution, nil)
      end
      
      def raise_404
        raise ActionController::RoutingError.new('Not Found')           
      end

      def send_preview(preview)
        raise_404 if preview.nil?
        if stale?(preview, public: false, template: false)
          serve_file(
            preview.file_path,
            content_type: preview.content_type,
            filename: shortcut_download_filename(preview))
        end
      end

      def send_media_file(media_file)
        if stale?(media_file, public: false, template: false)
          serve_file(
            media_file.original_store_location,
            content_type: media_file.content_type,
            filename: media_file.filename)
        end
      end

      def shortcut_download_filename(preview)
        media_file = preview.media_file
        return unless (media_file and media_file.filename)
    
        extension = File.extname(preview.filename)
        size = (preview.width and preview.height) ? ".#{preview.width}x#{preview.height}" : ''
        "#{media_file.filename}#{size}#{extension}"
      end

    end
  end
end
