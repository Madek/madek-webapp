module WorkflowLocker
  module MetaData
    private

    def apply_meta_data(allow_blank_values: false)
      @meta_data.each do |resource_type, ids_with_values|
        ids_with_values.each do |id, meta_keys_with_values|
          meta_keys_with_values.each do |meta_key_id, value|
            value = sanitize_value(value, meta_key_id)
            next if value.blank? && !allow_blank_values
            resource = find_resource(resource_type, id)
            resource = resource.cast_to_type if resource_type != 'Collection'
            create_meta_datum!(resource, meta_key_id, value, true)
          end
        end
      end
    end

    def find_resource(type, id)
      klass =
        case type
        when 'Collection'
          Collection
        when 'MediaEntry'
          nested_resources
        end

      klass.find(id)
    end

    def sanitize_value(value, meta_key_id)
      meta_key = MetaKey.find(meta_key_id)
      if %w(MetaDatum::Text MetaDatum::TextDate).include?(meta_key.meta_datum_object_type)
        value.reject(&:blank?)
      else
        value
      end
    end
  end
end
