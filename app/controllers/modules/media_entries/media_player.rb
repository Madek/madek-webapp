module Modules
  module MediaEntries
    module MediaPlayer
      extend ActiveSupport::Concern

      def update_media_config
        media_entry = editable_media_entry
        media_file = playable_media_file!(media_entry)
        media_file.update!(media_config: parse_media_config(params.dig(:media_file, :media_config)))
        redirect_to_media_player_edit(media_entry, :success, t('media_player_config_saved'))
      rescue JSON::ParserError, ArgumentError
        redirect_to_media_player_edit(media_entry, :error, t('media_player_config_invalid'))
      end

      def create_subtitle
        media_entry = editable_media_entry
        media_file = playable_media_file!(media_entry)
        upload = params.require(:subtitle).permit(:language, :label, :kind, :file)
        file = upload[:file]
        raise ArgumentError, t('media_player_subtitle_file_missing') unless file.respond_to?(:read)
        raise ArgumentError, t('media_player_subtitle_too_large') if file.size.to_i > Subtitle::MAX_BYTES
        language = upload[:language].to_s.strip.downcase

        Subtitle.store!(
          media_file: media_file,
          language: language,
          kind: upload[:kind],
          label: upload[:label],
          filename: subtitle_filename(file),
          content: read_vtt(file),
          is_default: language == I18n.locale.to_s
        )
        redirect_to_media_player_edit(media_entry, :success, t('media_player_subtitle_saved'))
      rescue ActiveRecord::RecordInvalid => err
        redirect_to_media_player_edit(media_entry, :error, err.record.errors.full_messages.to_sentence)
      rescue ArgumentError => err
        redirect_to_media_player_edit(media_entry, :error, err.message)
      end

      def destroy_subtitle
        media_entry = editable_media_entry
        media_file = playable_media_file!(media_entry)
        media_file.subtitles.find(params[:subtitle_id]).destroy!
        redirect_to_media_player_edit(media_entry, :success, t('media_player_subtitle_deleted'))
      end

      def show_subtitle
        media_entry = MediaEntry.unscoped.not_deleted.find(id_param)
        handle_confidential_links(media_entry)
        auth_authorize media_entry, :show?
        subtitle = media_entry.media_file&.subtitles&.find(params[:subtitle_id])
        raise ActiveRecord::RecordNotFound if subtitle.nil?
        send_data subtitle.content,
                  type: 'text/vtt; charset=utf-8',
                  disposition: 'inline',
                  filename: subtitle.filename
      end

      private

      def editable_media_entry
        media_entry = MediaEntry.unscoped.not_deleted.find(id_param)
        auth_authorize media_entry, :update?
        media_entry
      end

      def playable_media_file!(media_entry)
        media_file = media_entry.media_file
        unless media_file&.video? || media_file&.audio?
          raise ActiveRecord::RecordNotFound
        end
        media_file
      end

      def parse_media_config(raw)
        return {} if raw.blank?
        raise ArgumentError unless raw.is_a?(String)

        parsed = JSON.parse(raw)
        raise ArgumentError unless parsed.is_a?(Hash)

        parsed.except('sources')
      end

      def subtitle_filename(file)
        name = File.basename(file.original_filename.to_s)
        name = 'subtitle.vtt' if name.blank? || name == '.'
        name.end_with?('.vtt') ? name : "#{name}.vtt"
      end

      def read_vtt(file)
        text = file.read.to_s.dup.force_encoding('UTF-8')
        unless text.valid_encoding?
          text = text.encode('UTF-8', 'binary', invalid: :replace, undef: :replace)
        end
        text.sub(/\A\uFEFF/, '')
      end

      def redirect_to_media_player_edit(media_entry, type, message)
        flash[type] = message
        redirect_to edit_meta_data_by_context_media_entry_path(media_entry, media_player: 1)
      end
    end
  end
end
