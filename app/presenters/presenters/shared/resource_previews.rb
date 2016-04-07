module Presenters
  module Shared

    # NOTE: always returns PreviewPresenters, for non-images an Array of them
    # TODO: image helper should return all sizes instead of choosing by arg;
    #       it's tricky because of the video frame case, though.
    # TODO: long-term, this should just return a hash for all formats
    class ResourcePreviews < Presenter

      def initialize(entry)
        raise 'invalid resource!' unless entry.is_a?(MediaEntry)
        @media_file = entry.media_file
      end

      def image(size:)
        return unless @media_file.present?
        previews = @media_file.previews.where(media_type: :image)
        # HACK: only return *large* previews from video (for consistent frames)
        size = :large if (@media_file.media_type == 'video')
        get_image_preview(previews, size) if previews.present?
      end

      def audios
        return unless @media_file.present?
        previews = @media_file.previews.where(media_type: :audio)
        get_audio_previews(previews) if previews.present?
      end

      def videos
        return unless @media_file.present?
        previews = @media_file.previews.where(media_type: :video)
        get_video_previews(previews) if previews.present?
      end

      private

      def get_audio_previews(previews)
        # get the latest audio for each format
        ['ogg'].map do |format|
          audio = previews.where(content_type: "audio/#{format}")
            .reorder(created_at: :desc).first
          Presenters::Previews::Preview.new(audio) if audio.present?
        end.compact
      end

      def get_video_previews(previews)
        # get the largest available video for each format
        ['webm', 'mp4'].map do |format|
          video = previews.where(content_type: "video/#{format}")
            .reorder(height: :desc, created_at: :desc).first
          Presenters::Previews::Preview.new(video) if video.present?
        end.compact
      end

      def get_image_preview(previews, size)
        # Get the just wanted height from the legacy interal "size classes"!
        wanted_size = Madek::Constants::THUMBNAILS[size]
        raise 'invalid size!' unless wanted_size.present?
        wanted_height = wanted_size[:height]

        if previews.present? and previews[0].media_file.representable_as_image?
          # find by size class
          images = previews.where(thumbnail: size)
            .reorder(created_at: :desc).presence
          # OR newest, smallest previews that are AT LEAST the wanted size
          images ||= previews
            .where('previews.height >= ?', wanted_height)
            .reorder(height: :asc, created_at: :desc).presence
          # OR if that doesnt exist, get the LARGEST there are
          images ||= previews
            .reorder(height: :desc, created_at: :desc).presence
          # select first or apply 30% rule for videos
          image = get_first_or_30_percent(images) if images
        end
        Presenters::Previews::Preview.new(image) if image.present?
      end

      def get_first_or_30_percent(previews)
        # If thumbnail is from video and there is more than one available:
        is_from_video = @media_file.media_type == 'video'
        if (previews.length > 1 and is_from_video)
          # get frames, ensure timing order (*_0000.jpg, …)
          frames = previews.group_by(&:height).first.second.sort_by(&:filename)
          # take one from around 30% of the list
          calc_30_percent_position(frames)
        else # otherwise return first preview:
          previews.first
        end
      end

      def calc_30_percent_position(list) # NOTE: extracted because flog hates math
        list[(list.length.to_f / 10 * 3).to_i]
      end

    end
  end
end
