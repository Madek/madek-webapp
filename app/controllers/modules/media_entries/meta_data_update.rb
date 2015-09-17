module Modules
  module MediaEntries
    module MetaDataUpdate
      extend ActiveSupport::Concern

      def meta_data_update
        media_entry = MediaEntry.find(params[:id])
        authorize media_entry

        errors = update_all_meta_data_transaction!(media_entry.meta_data,
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

      def update_all_meta_data_transaction!(meta_data, meta_data_params)
        errors = {}

        ActiveRecord::Base.transaction do
          meta_data_params.each do |key_value|
            meta_key_id = key_value.first
            value = key_value.second
            begin
              meta_datum = meta_data.find_by_meta_key_id!(meta_key_id)
              meta_datum.set_value!(value, current_user)
            rescue => e
              errors[meta_key_id] = [e.message]
            end
          end
          raise ActiveRecord::Rollback unless errors.empty?
        end

        errors
      end
    end
  end
end
