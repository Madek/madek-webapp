module Modules
  module MetaDataStorage
    extend ActiveSupport::Concern
    include MetaData

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

      io_mapped_values(data).each do |meta_key, value|
        next if media_entry.meta_data.find_by_meta_key_id(meta_key.id)

        begin
          in_savepoint_with_immediate_constraints do
            create_meta_datum!(media_entry, meta_key.id, value)
          end
        rescue
          next # skip this corrupt meta_datum silently
        end
      end
    end

    # Checks deferred constraints within a savepoint instead of at commit,
    # so a violation only rolls back the block.
    def in_savepoint_with_immediate_constraints
      ActiveRecord::Base.transaction(requires_new: true) do
        yield
        ActiveRecord::Base.connection.execute('SET CONSTRAINTS ALL IMMEDIATE')
      end
    ensure
      ActiveRecord::Base.connection.execute('SET CONSTRAINTS ALL DEFERRED')
    end

    # `key_map` may hold several comma-separated keys, the first present one wins.
    def io_mapped_values(data)
      IoMapping
        .includes(:meta_key)
        .each_with_object({}) do |mapping, result|
          next if result.key?(mapping.meta_key)

          value = mapping.key_map.split(',').map(&:strip)
                    .map { |key| data[key] }.find(&:present?)
          result[mapping.meta_key] = value if value.present?
        end
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
        created_by: current_user,
        value: meta_datum_value(meta_key, value)
    end

    def meta_datum_value(meta_key, value)
      value = Array(value).map(&:to_s).join(', ')
      case meta_key.meta_datum_object_type
      when 'MetaDatum::Text', 'MetaDatum::TextDate' then value
      else extract_related_uuids(value)
      end
    end

    def extract_related_uuids(value)
      value.split(',').map do |val|
        val = val.strip
        url = val.match(/<(.*)>/).try(:[], 1) || val
        next url if (UUIDTools::UUID.parse(url) rescue nil)

        begin
          route_params = Rails.application.routes.recognize_path(url)
          route_params[:id] || route_params.except(:controller, :action).values.first
        rescue
          url
        end
      end
    end
  end
end
