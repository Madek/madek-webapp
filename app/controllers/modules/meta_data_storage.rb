module Modules
  module MetaDataStorage
    extend ActiveSupport::Concern
    include Modules::MetaDataImport

    DEFAULT_MIME_TYPE = Madek::Constants::DEFAULT_MIME_TYPE

    def extract_and_store_metadata(media_entry)
      # this includes 'real' meta data as well as 'meta_data' for the media file
      # and media file attributes like width and height.

      media_file = media_entry.media_file
      extractor = MetadataExtractor.new(media_file.original_store_location)
      extract_and_store_metadata_for_media_file(extractor, media_file)
      extract_and_store_metadata_for_media_entry(extractor, media_entry)
    end

    def extract_and_store_metadata_for_media_file(extractor, media_file)
      hash_for_media_file = extractor.hash_for_media_file
      detect_and_set_media_type(extractor, media_file)
      media_file.update(meta_data: hash_for_media_file)
      if media_file.media_type == 'image'
        begin
          dimensions = FileConversion.get_dimensions(media_file.original_store_location)
        rescue => e
          Rails.logger.warn 'Silently ignored exception getting dimensions '\
            "of original image file. Class: #{e.class}. Message: #{e.message}"
        end
        media_file.update(dimensions) unless dimensions.nil?
      end
    end

    private

    def extract_and_store_metadata_for_media_entry(extractor, media_entry)
      data = extractor.hash_for_media_entry
        .merge("Filename" => media_entry.media_file.filename)

      store_io_mapped_meta_data!(media_entry, data, overwrite: false)
    end

    def detect_and_set_media_type(extractor, media_file)
      mime_type = extractor.hash_for_media_file['File:MIMEType']
      mime_type ||= mime_type.presence || DEFAULT_MIME_TYPE
      media_file.content_type = mime_type
      media_file.set_media_type
    end

    def create_meta_datum!(media_entry, meta_key_id, value)
      meta_key = MetaKey.find(meta_key_id)

      meta_key.meta_datum_object_type.constantize.create_with_user! \
        current_user,
        media_entry_id: media_entry.id,
        meta_key_id: meta_key_id,
        value: meta_datum_value(meta_key, value)
    end
  end
end
