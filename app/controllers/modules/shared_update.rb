module Modules
  module SharedUpdate
    extend ActiveSupport::Concern

    private

    def update_all_meta_data_transaction!(resource, meta_data_params)
      errors = {}

      ActiveRecord::Base.transaction do
        meta_data_params.each do |meta_key_id, value|
          begin
            handle_meta_datum_in_case_of_single_update!(
              resource, meta_key_id, value)
          rescue => e
            errors[meta_key_id] = [e.message]
          end

        end
        raise ActiveRecord::Rollback unless errors.empty?
      end

      errors
    end

    def determine_values_by_options(resource, meta_key_id, data)
      if data['options'] && data['options']['action'] == 'add'
        existing = resource.meta_data.where(meta_key_id: meta_key_id).first
        if existing && existing.keywords
          existing.keywords.map(&:id) + data['values']
        else
          data['values']
        end
      else
        data['values']
      end
    end

    def advanced_update_all_meta_data_transaction!(resource, meta_data_params)
      errors = {}

      ActiveRecord::Base.transaction do
        meta_data_params.each do |meta_key_id, data|
          begin
            values = determine_values_by_options(resource, meta_key_id, data)
            handle_meta_datum_in_case_of_single_update!(
              resource, meta_key_id, values)
          rescue => e
            errors[meta_key_id] = [e.message]
          end

        end
        raise ActiveRecord::Rollback unless errors.empty?
      end

      errors
    end

    def handle_meta_datum_in_case_of_single_update!(resource, meta_key_id, value)
      # These 4 cases are handled by the datalayer:
      # 1. MD exists, value is present: update MD
      # 2. MD exists, value is empty: delete MD
      # 3. MD does not exist, value is present: create MD
      # 4. MD does not exist, value is empty: ignore/skip
      # (MD="A MetaDatum for this MetaKey on this MediaResource")

      # binding.pry if meta_key_id == 'media_content:other_creative_participants'
      # binding.pry if meta_key_id == 'madek_core:authors'

      if meta_datum = resource.meta_data.find_by(meta_key_id: meta_key_id)
        meta_datum.set_value!(value, current_user)
      else
        create_meta_datum_during_meta_data_update_transaction!(resource,
                                                               meta_key_id,
                                                               value)
      end
    end

    def create_meta_datum_during_meta_data_update_transaction!(resource,
                                                               meta_key_id,
                                                               value)
      meta_datum_klass = find_meta_datum_klass(meta_key_id)
      meta_datum_klass.create_with_user!(current_user,
                                         id_name(resource) => resource.id,
                                         meta_key_id: meta_key_id,
                                         value: value)
    end

    def find_meta_datum_klass(meta_key_id)
      MetaKey.find(meta_key_id).meta_datum_object_type.constantize
    end

    def id_name(resource)
      (resource.class.name.underscore + '_id').to_sym
    end
  end
end
