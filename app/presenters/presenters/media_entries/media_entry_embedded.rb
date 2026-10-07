module Presenters
  module MediaEntries
    class MediaEntryEmbedded < Presenters::Shared::AppResource

      include Presenters::MediaEntries::Modules::MediaEntryCommon

      def initialize(app_resource, config)
        raise TypeError unless config.is_a?(ActionController::Parameters)
        super(app_resource, nil) # MediaEntryCommon!
        @embed_config = config
      end

      attr_reader :embed_config

      def playback
        media_file = @app_resource.media_file
        return unless media_file && (media_file.video? || media_file.audio?)

        config = media_file.media_config
        config = {} unless config.is_a?(Hash)
        locale = I18n.locale.to_s
        token = used_confidential_access_token

        {
          headers: array_value(config, 'headers').filter_map { |header| playback_header(header) },
          overlays: array_value(config, 'overlays').filter_map { |overlay| playback_overlay(overlay) },
          tracks: playback_tracks(media_file, locale, token)
        }
      end

      def caption_conf(resource = @app_resource)
        {
          title: title,
          link: url,
          logoTitle: ::AppSetting.first.brand_text,
          subtitle: [
            resource.authors.presence,
            resource.copyright_notice.presence
          ].compact.join(' — ')
        }
      end

      private

      def array_value(config, key)
        value = config[key] || config[key.to_sym]
        value.is_a?(Array) ? value : []
      end

      def hash_value(value, key)
        return unless value.is_a?(Hash)

        value[key] || value[key.to_sym]
      end

      def safe_url(value)
        url = value.to_s.strip
        return if url.blank?
        return url if url.start_with?('/') && !url.start_with?('//')

        uri = URI.parse(url)
        url if uri.is_a?(URI::HTTP)
      rescue URI::InvalidURIError
        nil
      end

      def playback_header(header)
        src = safe_url(hash_value(header, 'src'))
        return unless src

        {
          src: src,
          alt: hash_value(header, 'alt').to_s,
          href: safe_url(hash_value(header, 'href')),
          target: hash_value(header, 'target').presence || '_blank',
          start: hash_value(header, 'start').to_f,
          end: hash_value(header, 'end').to_f
        }
      end

      def playback_overlay(overlay)
        text = hash_value(overlay, 'text')
        return unless text.is_a?(Hash)

        strings = text.each_with_object({}) do |(code, value), result|
          language = code.to_s
          next unless language.match?(/\A[a-z]{2,3}(-[a-z0-9]{2,8})?\z/)
          next unless value.is_a?(String) && value.present?

          result[language] = value
        end
        return if strings.empty?

        {
          start: hash_value(overlay, 'start').to_f,
          end: hash_value(overlay, 'end').to_f,
          stop_media_during_overlay: ActiveModel::Type::Boolean.new.cast(
            hash_value(overlay, 'stop_media_during_overlay')
          ) == true,
          text: strings
        }
      end

      def playback_tracks(media_file, locale, token)
        media_file.subtitles.order(:kind, :language).group_by(&:kind).flat_map do |_kind, rows|
          chosen = rows.find { |row| row.language == locale } || rows.find(&:is_default)
          rows.map do |row|
            url = show_subtitle_media_entry_path(@app_resource, row.id)
            url = "#{url}?#{Rack::Utils.build_query(accessToken: token)}" if token.present?
            {
              src: url,
              kind: row.kind,
              srclang: row.language,
              label: row.label.presence || row.language,
              default: row.kind != 'chapters' && chosen&.id == row.id
            }
          end
        end
      end

    end
  end
end
