module Modules
  module MediaEntries
    module XmpImport
      extend ActiveSupport::Concern

      def xmp_import
        media_entry = get_authorized_resource
        file = params.require(:xmp_file)

        unless File.extname(file.original_filename.to_s).casecmp?('.xmp')
          return redirect_to(
            media_entry_path(media_entry),
            flash: { error: I18n.t(:media_entry_xmp_import_flash_invalid_file) })
        end

        data = MetadataExtractor.new(file.tempfile.path).hash_for_media_entry
        imported, failed = import_xmp_meta_data!(media_entry, data)
        log_into_edit_sessions!(media_entry) if imported.any?

        redirect_to(
          media_entry_path(media_entry),
          flash: xmp_import_flash(imported, failed))
      end

      private

      # Overwrites existing meta data; a failing key is skipped without
      # affecting the others.
      def import_xmp_meta_data!(media_entry, data)
        imported = []
        failed = []

        io_mapped_values(data).each do |meta_key, value|
          in_savepoint_with_immediate_constraints do
            handle_meta_datum_in_case_of_single_update!(
              media_entry, meta_key.id, meta_datum_value(meta_key, value))
          end
          imported << meta_key
        rescue => e
          Rails.logger.info "XMP import: #{meta_key.id}: #{e.message}"
          failed << meta_key
        end

        [imported, failed]
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
