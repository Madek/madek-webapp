module WorkflowLocker
  module CommonMetaData
    private

    def apply_common_meta_data
      configuration['common_meta_data'].each do |md|
        next unless (md['meta_key_id'].present? and md['is_common'])
        meta_key = MetaKey.find(md['meta_key_id']) rescue next
        create_meta_datum!(@workflow.master_collection, meta_key.id, md['value'])
        nested_resources.each do |resource|
          create_meta_datum!(resource.cast_to_type, meta_key.id, md['value'])
        end
      end
    end

    def prepare_value(value, meta_datum_klass, raw_value = false)
      return value if raw_value

      if meta_datum_klass == MetaDatum::Keywords
        value.map { |v| v['uuid'] }
      else
        value.map { |v| v['string'].presence || ActionController::Parameters.new(v) }
      end
    end

    def create_meta_datum!(resource, meta_key_id, value, raw_value = false)
      meta_datum_klass = MetaKey.find(meta_key_id).meta_datum_object_type.constantize
      resource_fk = resource.class.name.foreign_key

      meta_datum_klass.find_by(meta_key_id: meta_key_id, resource_fk => resource.id).try(:destroy)

      return if value.blank?

      meta_datum_klass.create_with_user!(
        @workflow.creator,
        {
          meta_key_id: meta_key_id,
          created_by: @workflow.creator,
          value: prepare_value(value, meta_datum_klass, raw_value)
        }.merge(resource_fk => resource.id)
      )
    end
  end
end
