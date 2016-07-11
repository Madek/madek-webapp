module Modules
  module MediaEntries
    module MetaDataUpdate
      extend ActiveSupport::Concern

      include Modules::Resources::MetaDataUpdate
      include Modules::Batch::BatchAutoPublish

      def batch_edit_context_meta_data
        authorize MediaEntry, :logged_in?
        entries = MediaEntry.unscoped.where(id: entries_ids_param)
        authorize_entries_for_batch_edit! entries

        @get = Presenters::MediaEntries::BatchEditContextMetaData.new(
          entries,
          current_user,
          context_id: params[:context_id],
          return_to: return_to_param)
      end

      def batch_edit_meta_data
        authorize MediaEntry, :logged_in?
        entries = MediaEntry.unscoped.where(id: entries_ids_param)
        authorize_entries_for_batch_edit! entries

        @get = Presenters::MediaEntries::MediaEntryBatchEdit.new(
          entries,
          current_user,
          return_to: return_to_param)
      end

      def batch_meta_data_update
        authorize MediaEntry, :logged_in?
        return_to = return_to_param
        entries_ids = entries_ids_param(params.require(:batch_resource_meta_data))

        entries = MediaEntry.unscoped.where(id: entries_ids)
        authorize_entries_for_batch_edit! entries

        errors = batch_update_transaction!(entries, meta_data_params)

        if errors.empty?

          stats = batch_publish_transaction!(entries.reload)

          flash_message = flash_message_by_stats(stats)
          batch_respond_success('success', flash_message, return_to)
        else
          render json: { errors: errors }, status: :bad_request
        end
      end

      private

      def entries_ids_param(parameters = params)
        parameters.require(:id)
      end

      def return_to_param(parameters = params)
        parameters.require(:return_to)
      end

      def batch_respond_success(type, flash_message, return_to)
        flash[type] = flash_message.html_safe
        respond_to do |format|
          format.json { render(json: { forward_url: return_to }) }
          format.html { redirect_to(return_to) }
        end
      end

      def update_all_meta_data_transaction!(media_entry, meta_data_params)
        errors = {}

        ActiveRecord::Base.transaction do
          meta_data_params.each do |meta_key_id, value|
            begin
              handle_meta_datum_in_case_of_single_update!(media_entry,
                                                          meta_key_id,
                                                          value)
            rescue => e
              errors[meta_key_id] = [e.message]
            end

          end
          raise ActiveRecord::Rollback unless errors.empty?
        end

        errors
      end

      def batch_update_transaction!(entries, meta_data_params)
        errors = {}
        ActiveRecord::Base.transaction do
          entries.each do |media_entry|
            meta_data_params.each do |meta_key_id, value|
              begin
                handle_meta_datum_in_case_of_batch_update!(media_entry,
                                                           meta_key_id,
                                                           value[:values])
              rescue => exception
                errors[media_entry.id] = [meta_key_id, exception.message]
              end
            end
          end
          raise ActiveRecord::Rollback unless errors.empty?
        end
        errors
      end

      def handle_meta_datum_in_case_of_single_update!(media_entry,
                                                      meta_key_id,
                                                      value)
        # These 4 cases are handled by the datalayer:
        # 1. MD exists, value is present: update MD
        # 2. MD exists, value is empty: delete MD
        # 3. MD does not exist, value is present: create MD
        # 4. MD does not exist, value is empty: ignore/skip
        # (MD="A MetaDatum for this MetaKey on this MediaResource")

        if meta_datum = media_entry.meta_data.find_by(meta_key_id: meta_key_id)
          meta_datum.set_value!(value, current_user)
        else
          create_meta_datum_during_meta_data_update_transaction!(media_entry,
                                                                 meta_key_id,
                                                                 value)
        end
      end

      def handle_meta_datum_in_case_of_batch_update!(media_entry,
                                                     meta_key_id,
                                                     value)
        # There are following 3 cases:
        # 1. Value is empty: skip (do nothing)
        # 2. Value is present, MD does not exist: create MD
        # 3. Value is present, MD exists: update MD
        # (MD="A MetaDatum for this MetaKey on this MediaResource")

        # 1
        unless value.delete_if(&:blank?).empty?
          # 3
          if meta_datum = media_entry.meta_data.find_by(meta_key_id: meta_key_id)
            meta_datum.set_value!(value, current_user)
          # 2
          else
            create_meta_datum_during_meta_data_update_transaction!(media_entry,
                                                                   meta_key_id,
                                                                   value)
          end
        end
      end

      def create_meta_datum_during_meta_data_update_transaction!(media_entry,
                                                                 meta_key_id,
                                                                 value)
        meta_datum_klass = find_meta_datum_klass(meta_key_id)
        meta_datum_klass.create_with_user!(current_user,
                                           media_entry_id: media_entry.id,
                                           meta_key_id: meta_key_id,
                                           value: value)
      end

      def find_meta_datum_klass(meta_key_id)
        MetaKey.find(meta_key_id).meta_datum_object_type.constantize
      end

      def authorize_entries_for_batch_edit!(entries)
        authorized_entries = \
          MediaEntryPolicy::EditableScope.new(current_user, entries).resolve
        if entries.count != authorized_entries.count
          raise Errors::ForbiddenError, 'Not allowed to edit all resources!'
        end
      end

    end
  end
end
