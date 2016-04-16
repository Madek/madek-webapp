module Presenters
  module MediaFiles

    # NOTE: Belongs to MediaEntry, returns all Previews!
    class MediaFile < Presenters::Shared::AppResource

      THUMBNAIL_SIZES = Madek::Constants::THUMBNAILS

      def initialize(entry, user)
        raise 'invalid resource!' unless entry.is_a?(MediaEntry)
        return unless entry.media_file.present?
        super(entry.media_file)
        @media_file = @app_resource
        @user = user
      end

      # NOTE: always returns PreviewPresenters, for non-images an Array of them
      def previews
        return unless @media_file.present?
        @previews ||= {
          images: THUMBNAIL_SIZES.keys.map do |size|
            [size, get_image_by(size: size)]
          end.to_h.compact,
          audios: get_audio_previews,
          videos: get_video_previews
        }.compact.presence
      end

      def original_file_url
        return unless @media_file and Pundit.policy(@user, @media_file).show?
        media_file_path(@media_file)
      end

      def url
        nil # not a CRUD/REST resource
      end

      def get_image_by(size:)
        # HACK: only return *large* previews from video (for consistent frames)
        size = :large if (@media_file.media_type == 'video')
        # NOTE: optimize/memo
        @image_previews ||= @media_file.previews.where(media_type: :image)
        get_image_preview(@image_previews, size)
      end

      private

      def get_image_preview(previews, size)
        raise 'invalid size!' unless THUMBNAIL_SIZES.keys.include?(size)
        # Get the just wanted height from the legacy interal "size classes"!
        wanted_size = THUMBNAIL_SIZES[size]
        wanted_height = wanted_size.try(:height) or nil

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

      def get_audio_previews
        audio_previews = @media_file.previews.where(media_type: :audio)
        # get the latest audio for each format
        ['ogg'].map do |format|
          audio = audio_previews.where(content_type: "audio/#{format}")
            .reorder(created_at: :desc).first
          Presenters::Previews::Preview.new(audio) if audio.present?
        end.compact.presence
      end

      def get_video_previews
        video_previews = @media_file.previews.where(media_type: :video)
        # get the largest available video for each format
        ['webm', 'mp4'].map do |format|
          video = video_previews.where(content_type: "video/#{format}")
            .reorder(height: :desc, created_at: :desc).first
          Presenters::Previews::Preview.new(video) if video.present?
        end.compact.presence
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

      def calc_30_percent_position(list) # NOTE: extracted bc. `flog` hates math
        list[(list.length.to_f / 10 * 3).to_i]
      end

    end
  end
end
