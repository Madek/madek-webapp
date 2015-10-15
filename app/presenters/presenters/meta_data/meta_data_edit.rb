module Presenters
  module MetaData

    # TODO: all Resource types

    class MetaDataEdit < Presenters::MetaData::MetaDataCommon

      private

      def fetch_relevant_meta_data
        MetaKey
          .where(is_enabled_for_media_entries: true)
          .joins(:vocabulary)
          .where(vocabularies: { id: relevant_vocabularies })
          .map do |key|
            existing_datum = @app_resource.meta_data.where(meta_key: key).first
            if existing_datum.present?
              existing_datum
            else # prepare a new, blank instance to "fill out":
              md_klass = key.meta_datum_object_type.constantize
              md_klass.new(meta_key: key, media_entry: @app_resource)
            end
          end
      end

    end
  end
end
