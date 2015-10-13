module Modules
  module MediaEntries
    module MetaDataUpdate
      extend ActiveSupport::Concern

      def meta_data_update
        media_entry = MediaEntry.find(params[:id])
        authorize media_entry

        errors = update_all_meta_data_transaction!(media_entry,
                                                   meta_data_params)
        respond_to do |f|
          f.json do
            if errors.empty?
              respond_with \
                Presenters::MediaEntries::MediaEntryShow.new(media_entry.reload,
                                                             current_user)
            else
              render json: { errors: errors }, status: :bad_request
            end
          end
        end
      end

      def update_all_meta_data_transaction!(media_entry, meta_data_params)
        errors = {}

        ActiveRecord::Base.transaction do
          meta_data_params.each do |key_value|
            meta_key_id = key_value.first
            value = key_value.second
            begin
              update_or_create_meta_datum!(media_entry, meta_key_id, value)
            rescue => e
              errors[meta_key_id] = [e.message]
            end
          end
          raise ActiveRecord::Rollback unless errors.empty?
        end

        errors
      end

      def update_or_create_meta_datum!(media_entry, meta_key_id, value)
        if meta_datum = media_entry.meta_data.find_by(meta_key_id: meta_key_id)
          meta_datum.set_value!(value, current_user)
        else
          meta_datum_klass = \
            MetaKey.find(meta_key_id).meta_datum_object_type.constantize
          meta_datum_klass.create_with_user!(current_user,
                                             media_entry_id: media_entry.id,
                                             meta_key_id: meta_key_id,
                                             value: value)
        end
      end
    end
  end
end
