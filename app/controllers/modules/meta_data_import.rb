module Modules
  module MetaDataImport
    extend ActiveSupport::Concern
    include Modules::SharedUpdate

    private

    # Stores the values mapped by `IoMapping`; a failing key is skipped without
    # affecting the others. Returns the imported and the failed meta keys.
    def store_io_mapped_meta_data!(media_entry, data, overwrite:)
      imported = []
      failed = []

      io_mapped_values(data).each do |meta_key, value|
        next if !overwrite && media_entry.meta_data.find_by_meta_key_id(meta_key.id)

        in_savepoint_with_immediate_constraints do
          handle_meta_datum_in_case_of_single_update!(
            media_entry, meta_key.id, meta_datum_value(meta_key, value))
        end
        imported << meta_key
      rescue => e
        Rails.logger.info "Metadata import: #{meta_key.id}: #{e.message}"
        failed << meta_key
      end

      [imported, failed]
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

          value = mapping.key_map.to_s.split(',').map(&:strip)
                    .map { |key| data[key] }.find(&:present?)
          result[mapping.meta_key] = value if value.present?
        end
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
