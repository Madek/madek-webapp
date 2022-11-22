module Modules
  module MetaDataStorage
    extend ActiveSupport::Concern
    include Concerns::MetaData

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
      media_file.update_attributes(meta_data: hash_for_media_file)
      if media_file.media_type == 'image'
        begin
          dimensions = FileConversion.get_dimensions(media_file.original_store_location)
        rescue => e
          Rails.logger.warn 'Silently ignored exception getting dimensions '\
            "of original image file. Class: #{e.class}. Message: #{e.message}"
        end
        media_file.update_attributes(dimensions) unless dimensions.nil?
      end
    end

    private

    def extract_and_store_metadata_for_media_entry(extractor, media_entry)
      hash_for_media_entry = extractor.hash_for_media_entry

      hash_for_media_entry.each do |key_map, value|
        next if value.blank? # ignore empty values silently

        meta_key_ids = IoMapping.where(key_map: key_map).map(&:meta_key_id)
        meta_key_ids.each do |meta_key_id|
          begin
            create_meta_datum!(media_entry, meta_key_id, value)
          rescue
            next # skip this corrupt meta_datum silently
          end
        end
      end
    end

    def detect_and_set_media_type(extractor, media_file)
      mime_type = extractor.hash_for_media_file['File:MIMEType']
      mime_type ||= mime_type.presence || DEFAULT_MIME_TYPE
      media_file.content_type = mime_type
      media_file.set_media_type
    end

    def create_meta_datum!(media_entry, meta_key_id, value)
      meta_datum_klass = \
        MetaKey.find(meta_key_id).meta_datum_object_type.constantize

      meta_datum_klass.create_with_user! \
        current_user,
        media_entry_id: media_entry.id,
        meta_key_id: meta_key_id,
        created_by: current_user,
        value: \
          (if [MetaDatum::Text, MetaDatum::TextDate].include?(meta_datum_klass)
             value
           else
             extract_related_uuids(value)
           end)
    end

    def extract_related_uuids(value)
      value.split(',').map do |val|
        url = val.match(/<(.*)>/).try(:[], 1) || val
        begin
          Rails.application.routes.recognize_path(url)[:id]
        rescue
          url
        end
      end
    end
  end
end
