module Modules
  module Collections
    module MetaDataUpdate
      extend ActiveSupport::Concern

      include Modules::Resources::MetaDataUpdate

      private

      def update_all_meta_data_transaction!(collection, meta_data_params)
        errors = {}

        ActiveRecord::Base.transaction do
          meta_data_params.each do |meta_key_id, value|
            begin
              handle_meta_datum!(collection, meta_key_id, value)
            rescue => e
              errors[meta_key_id] = [e.message]
            end

          end
          raise ActiveRecord::Rollback unless errors.empty?
        end

        errors
      end

      def handle_meta_datum!(collection, meta_key_id, value)
        # These 4 cases are handled by the datalayer:
        # 1. MD exists, value is present: update MD
        # 2. MD exists, value is empty: delete MD
        # 3. MD does not exist, value is present: create MD
        # 4. MD does not exist, value is empty: ignore/skip
        # (MD="A MetaDatum for this MetaKey on this MediaResource")

        if meta_datum = collection.meta_data.find_by(meta_key_id: meta_key_id)
          meta_datum.set_value!(value, current_user)
        else
          meta_datum_klass = \
            MetaKey.find(meta_key_id).meta_datum_object_type.constantize
          meta_datum_klass.create_with_user!(current_user,
                                             collection_id: collection.id,
                                             meta_key_id: meta_key_id,
                                             value: value)
        end
      end
    end
  end
end
