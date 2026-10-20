module Modules
  module MediaEntries
    module XmpImport
      extend ActiveSupport::Concern
      include Modules::MetaDataImport

      # modal "on top of" #show
      def xmp_import
        show
      end

      def xmp_import_create
        media_entry = get_authorized_resource
        file = params.require(:xmp_file)

        unless File.extname(file.original_filename.to_s).casecmp?('.xmp')
          return redirect_to(
            media_entry_path(media_entry),
            flash: { error: I18n.t(:media_entry_xmp_import_flash_invalid_file) })
        end

        begin
          data = read_xmp_sidecar!(file)
        rescue => e
          return redirect_to(
            media_entry_path(media_entry),
            flash: { error: I18n.t(:media_entry_xmp_import_flash_unreadable) + e.message })
        end

        store_xmp_sidecar!(media_entry, file, data)

        imported, failed = store_io_mapped_meta_data!(media_entry, data, overwrite: true)
        log_into_edit_sessions!(media_entry) if imported.any?

        redirect_to(
          media_entry_path(media_entry),
          flash: xmp_import_flash(imported, failed))
      end

      private

      def read_xmp_sidecar!(file)
        # Postgres can't store NUL in text columns
        raise 'file contains NUL bytes' if File.binread(file.tempfile.path).include?("\0")
        data = MetadataExtractor.new(file.tempfile.path).hash_for_media_entry
        raise data['ExifTool:Error'] if data['ExifTool:Error']
        # exiftool reports broken XMP only as warning
        if (warning = data['ExifTool:Warning'].to_s).start_with?('XMP format error')
          raise warning
        end
        unless (type = data['File:FileType']) == 'XMP'
          raise "unexpected file type #{type}"
        end
        data
      end

      def store_xmp_sidecar!(media_entry, file, data)
        XmpSidecar.create!(
          media_entry: media_entry,
          user: current_user,
          filename: file.original_filename,
          meta_data: data.reject { |k, v| upload_file_key?(k) || !json_safe?(v) },
          xml: File.read(file.tempfile.path, encoding: 'UTF-8').scrub)
      end

      # Describes the temporary upload, not the sidecar
      def upload_file_key?(key)
        key == 'SourceFile' || key.start_with?('System:')
      end

      def json_safe?(value)
        value.to_json
        true
      rescue
        false
      end

      def xmp_import_flash(imported, failed)
        labels = ->(meta_keys) { meta_keys.map { |mk| mk.label.presence || mk.id }.join(', ') }
        flash = {}
        if imported.any?
          flash[:success] = I18n.t(:media_entry_xmp_import_flash_success) + labels.(imported)
        elsif failed.empty?
          flash[:warning] = I18n.t(:media_entry_xmp_import_flash_nothing)
        end
        if failed.any?
          level = imported.any? ? :warning : :error
          flash[level] = I18n.t(:media_entry_xmp_import_flash_failed) + labels.(failed)
        end
        flash
      end
    end
  end
end
