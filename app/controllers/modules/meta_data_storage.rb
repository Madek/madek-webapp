module Modules
  module MetaDataStorage
    extend ActiveSupport::Concern
    include Concerns::MetaData

    def store_meta_data!(media_entry_id, meta_data)
      meta_data.each do |meta_datum_attrs|
        md_attrs = \
          { meta_key_id: meta_key_id_param(meta_datum_attrs),
            type: type_param(meta_datum_attrs),
            value: value_param(meta_datum_attrs),
            media_entry_id: media_entry_id }

        meta_datum_klass = \
          constantize_type_param(md_attrs[:type])
        meta_datum_klass.create!(md_attrs)
      end
    end
  end
end
