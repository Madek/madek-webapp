module Modules
  module MetaDataStorage
    extend ActiveSupport::Concern
    include Concerns::MetaData

    def extract_and_store_metadata!(media_entry)
      # this includes 'real' meta data as well as 'meta_data' for the media file
      # and media file attributes like width and height.

      media_file = media_entry.media_file
      extractor = MetadataExtractor.new(media_file.original_store_location)
      extract_and_store_metadata_for_media_file!(extractor, media_file)
      extract_and_store_metadata_for_media_entry!(extractor, media_entry)
    end

    def extract_and_store_metadata_for_media_file!(extractor, media_file)
      hash_for_media_file = extractor.hash_for_media_file
      media_file.update_attributes!(meta_data: hash_for_media_file,
                                    width: hash_for_media_file[:image_width],
                                    height: hash_for_media_file[:image_height])
    end

    def extract_and_store_metadata_for_media_entry!(extractor, media_entry)
      hash_for_media_entry = extractor.hash_for_media_entry
      hash_for_media_entry.each do |key_map, value|
        meta_key_id = IoMapping.find_by_key_map(key_map).try(:meta_key_id)
        if meta_key_id
          create_meta_datum!(media_entry, meta_key_id, value)
        end
      end
    end

    def create_meta_datum!(media_entry, meta_key_id, value)
      meta_datum_klass = \
        MetaKey.find(meta_key_id).meta_datum_object_type.constantize
      meta_datum_klass.create!(media_entry_id: media_entry.id,
                               meta_key_id: meta_key_id,
                               created_by: current_user,
                               value: value)
    end
  end
end
