module Presenters
  module MediaEntries
    module Modules
      module MediaEntryPreviews
        extend ActiveSupport::Concern

        included do

          private

          # NOTE: always returns PreviewPresenters, for non-images an Array of them
          # TODO: image helper should return all sizes instead of choosing by arg.
          #       it's tricky because of the video frame case, though.
          #       finally, this helper would just return a hash for all formats
          #       (no args, simple module, no private method inheritance…)
          def preview_helper(type:, size:)
            valid_types = [:image, :video, :audio]
            raise 'invalid type!' unless valid_types.include?(type)

            media_file = @app_resource.media_file
            return unless media_file.present?

            previews = media_file.previews.where(media_type: type)
            return unless previews.present?

            case type
            when :image
              _get_image_preview(previews, size)
            when :audio
              _get_audio_previews(previews)
            when :video
              _get_video_previews(previews)
            end
          end

          def _get_audio_previews(previews)
            # get the latest audio for each format
            ['ogg'].map do |format|
              audio = previews.where(content_type: "audio/#{format}")
                .reorder(created_at: :desc).first
              Presenters::Previews::Preview.new(audio) if audio.present?
            end.compact
          end

          def _get_video_previews(previews)
            # get the largest available video for each format
            ['webm', 'mp4'].map do |format|
              video = previews.where(content_type: "video/#{format}")
                .reorder(height: :desc, created_at: :desc).first
              Presenters::Previews::Preview.new(video) if video.present?
            end.compact
          end

          def _get_image_preview(previews, size)
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
              image = _get_first_or_30_percent(images) if images
            end
            Presenters::Previews::Preview.new(image) if image.present?
          end

          def _get_first_or_30_percent(previews)
            # NOTE: this does not work for all sizes,
            # because we only get multiple frame previews from Zencoder for 'large'

            # If thumbnail is from video and there is more than one available:
            is_from_video = previews.first.media_file.media_type == 'video'
            if (previews.length > 1 and is_from_video)
              # get frames, ensure timing order (*_0000.jpg, …)
              frames = previews.group_by(&:height).first.second.sort_by(&:filename)
              # take one from around 30% of the list
              _30_percent_position(frames)
            else # otherwise return first preview:
              previews.first
            end
          end

          def _30_percent_position(list) # NOTE: extracted because flog hates math
            list[(list.length.to_f / 10 * 3).to_i]
          end

        end
      end
    end
  end
end
