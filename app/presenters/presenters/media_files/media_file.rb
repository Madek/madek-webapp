module Presenters
  module MediaFiles

    # NOTE: Belongs to MediaEntry, returns all Previews!
    class MediaFile < Presenters::Shared::AppResource

      THUMBNAIL_SIZES = Madek::Constants::THUMBNAILS

      delegate_to_app_resource :content_type

      # NOTE: initialized with Entry! otherwise we would have to query the DB!
      def initialize(media_entry_with_media_file, user)
        unless media_entry_with_media_file.is_a?(::MediaEntry) \
          and media_entry_with_media_file.try(:media_file).is_a?(::MediaFile)
          raise 'invalid resource!'
        end
        super(media_entry_with_media_file.media_file)
        @user = user
      end

      # NOTE: always returns PreviewPresenters, for non-images an Array of them
      def previews
        @_previews ||= {
          images: image_previews,
          audios: get_previews_by_type('audio'),
          videos: get_previews_by_type('video')
        }.compact.presence
      end

      def image_previews
        return @image_previews if @image_previews.present?

        # HACK: only return *large* previews from video (for consistent frames)
        img_sizes = \
          @app_resource.media_type == 'video' ? [:large] : THUMBNAIL_SIZES.keys

        @image_previews ||= img_sizes.map do |size|
          [size, get_image_by(size: size)]
        end.to_h.compact
      end

      def original_file_url
        return unless Pundit.policy(@user, @app_resource).show?
        media_file_path(@app_resource)
      end

      def url
        nil # not a CRUD/REST resource
      end

      def get_image_by(size:)
        # NOTE: optimize/memo
        @image_previews ||= @app_resource.previews.where(media_type: :image)
        get_image_preview(@image_previews, size)
      end

      def conversion_progress
        if (latest = latest_zencoder_job).present? && latest.submitted?
          latest.fetch_progress.round(1)
        end
      end

      def conversion_status
        latest = latest_zencoder_job
        return latest.state if latest
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

      def get_previews_by_type(type)
        @app_resource.previews.where(media_type: type).map do |preview|
          Presenters::Previews::Preview.new(preview) if preview.present?
        end.compact.presence
      end

      def get_first_or_30_percent(previews)
        # If thumbnail is from video and there is more than one available:
        is_from_video = @app_resource.media_type == 'video'
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
        list[[(list.length.to_f / 10 * 3.0).ceil, list.length - 1].min]
      end

      def latest_zencoder_job
        if @app_resource.previews_zencoder? == 0
          @app_resource.zencoder_jobs.order(created_at: :DESC).first
        end
      end
    end
  end
end
