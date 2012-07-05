module Json
  module MetaDatumHelper

    def hash_for_meta_datum(meta_datum, with = nil)
      h = { 
        name: "#{meta_datum.meta_key.label}",
        value: ((s = meta_datum.to_s).blank? ? nil : s),
        raw_value: meta_datum.is_a?(MetaDatumString) ? meta_datum.value(current_user) : meta_datum.value,
        type: MetaDatum.value_type_name(meta_datum.class)
      }
      
      if with ||= nil
        if with[:label] and with[:label][:context] and (context = MetaContext.send(with[:label][:context]))
          definition = meta_datum.meta_key.meta_key_definitions.for_context(context)
          h[:label] = definition.label.to_s 
        end
      end
      
      h
    end
    
    alias :hash_for_meta_datum_copyright :hash_for_meta_datum
    alias :hash_for_meta_datum_date :hash_for_meta_datum
    alias :hash_for_meta_datum_departments :hash_for_meta_datum
    alias :hash_for_meta_datum_keywords :hash_for_meta_datum
    alias :hash_for_meta_datum_meta_terms :hash_for_meta_datum
    alias :hash_for_meta_datum_people :hash_for_meta_datum
    alias :hash_for_meta_datum_string :hash_for_meta_datum
    alias :hash_for_meta_datum_users :hash_for_meta_datum
    
  end
end
      