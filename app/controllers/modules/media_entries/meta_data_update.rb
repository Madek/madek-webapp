module Modules
  module MediaEntries
    module MetaDataUpdate
      extend ActiveSupport::Concern

      def meta_data_update
        authorize (media_entry = MediaEntry.find(params[:id]))
        errors = update_all_meta_data_transaction!(media_entry, meta_data_params)

        if errors.empty?
          # FIXME: handle this distinction in Responders:
          respond_to do |f|
            f.json { render json: { ok: true } }
            f.html do
              respond_with \
                media_entry, location: -> { media_entry_path(media_entry) }
            end
          end
        else
          render json: { errors: errors }, status: :bad_request
        end
      end

      def update_all_meta_data_transaction!(media_entry, meta_data_params)
        # These 4 cases are handled by the datalayer:
        # 1. MD exists, value is present: update MD
        # 2. MD exists, value is empty: delete MD
        # 3. MD does not exist, value is present: create MD
        # 4. MD does not exist, value is empty: ignore/skip
        # (MD="A MetaDatum for this MetaKey on this MediaResource")

        errors = {}
        ActiveRecord::Base.transaction do
          meta_data_params.each do |key_value|
            meta_key_id = key_value.first
            value = key_value.second
            exisiting_meta_datum = media_entry.meta_data
                                              .find_by(meta_key: meta_key_id)

            # handle case 4:
            # FIXME: handle this in the db (constraint/trigger auto-delete…)
            next unless exisiting_meta_datum.present? and value.present?

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
