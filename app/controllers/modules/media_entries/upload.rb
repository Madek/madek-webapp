module Modules
  module MediaEntries
    module Upload
      extend ActiveSupport::Concern

      def new
        authorize MediaEntry
        @get = Presenters::MediaEntries::MediaEntryNew.new
      end

      def create
        media_entry = MediaEntry.new(
          media_file: MediaFile.new(media_file_attributes),
          responsible_user: current_user,
          creator: current_user,
          is_published: false)

        authorize media_entry

        ActiveRecord::Base.transaction do
          media_entry.save!
          store_file_and_create_previews!(file, media_entry.media_file)
        end

        # optional steps, errors are ignored but logged:
        begin
          hack_add_default_license(media_entry)
          extract_and_store_metadata(media_entry)
          add_to_collection(media_entry, collection_id_param)
        rescue => e
          Rails.logger.warn "Upload Soft-Error: #{e.inspect}, #{e.backtrace}"
        end

        represent(media_entry.reload, Presenters::MediaEntries::MediaEntryIndex)
      end

      def publish
        media_entry = MediaEntry.unscoped.where(is_published: false).find(id_param)
        authorize media_entry
        ActiveRecord::Base.transaction do
          media_entry.is_published = true
          media_entry.save!
        end
        redirect_to media_entry_path,
                    flash: { success: 'Entry was published!' }
      end

      private

      def file
        media_entry_params.require(:media_file)
      end

      def media_file_attributes
        { uploader: current_user,
          content_type: file.content_type,
          filename: file.original_filename,
          extension: extension(file.original_filename),
          size: file.size }
      end

      def add_to_collection(media_entry, collection_id)
        unless collection_id.blank?
          if collection = Collection.find_by_id(collection_id)
            collection.media_entries << media_entry
          else
            flash[:warning] = 'The collection does not exist!' # TODO: i18n!
          end
        end
      end

      def store_file_and_create_previews!(file, media_file)
        store_file!(file.tempfile.path, media_file.original_store_location)
        media_file.create_previews! if media_file.previews_internal?
        process_with_zencoder(media_file) if media_file.previews_zencoder?
      end

      def hack_add_default_license(media_entry)
        # TEMPORARY FIX so that data is set like in v2 till it is cleaned up

        meta_key_license = MetaKey.find_by(id: 'copyright:license') \
          || MetaKey.where(meta_datum_object_type: 'MetaDatum::Licenses').first
        return unless meta_key_license.present?
        meta_key_usage = MetaKey.find_by(id: 'copyright:copyright_usage')

        license = License.where(is_default: true).first

        create_meta_datum!(media_entry, meta_key_license.id, license.id)
        if meta_key_usage
          create_meta_datum!(media_entry, meta_key_usage.id, license.usage)
        end
      end

    end
  end
end
