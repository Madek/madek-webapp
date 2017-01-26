module Modules
  module SharedBatchUpdate
    extend ActiveSupport::Concern

    include Modules::Batch::BatchAutoPublish

    private

    def shared_batch_edit_meta_data_by_context(type)
      auth_authorize type, :logged_in?
      entries = type.unscoped.where(id: entries_ids_param)
      authorize_entries_for_batch_edit!(entries)

      @get = Presenters::MediaEntries::BatchEditContextMetaData.new(
        type,
        entries,
        current_user,
        context_id: params[:context_id],
        by_vocabularies: false,
        return_to: return_to_param)
    end

    def shared_batch_edit_meta_data_by_vocabularies(type)
      auth_authorize type, :logged_in?
      entries = type.unscoped.where(id: entries_ids_param)
      authorize_entries_for_batch_edit!(entries)

      @get = Presenters::MediaEntries::BatchEditContextMetaData.new(
        type,
        entries,
        current_user,
        context_id: nil,
        by_vocabularies: true,
        return_to: return_to_param)
    end

    def shared_batch_meta_data_update(type)
      auth_authorize type, :logged_in?
      return_to = return_to_param
      entries_ids = entries_ids_param(params.require(:batch_resource_meta_data))

      entries = type.unscoped.where(id: entries_ids)
      authorize_entries_for_batch_edit!(entries)

      errors = batch_update_transaction!(entries, meta_data_params)

      if errors.empty?

        flash_message =
          if type == MediaEntry
            stats = batch_publish_transaction!(entries.reload)
            flash_message_by_stats(stats)
          else
            collections_flash_message(entries)
          end

        batch_log_into_edit_sessions! entries

        batch_respond_success('success', flash_message, return_to)
      else
        render json: { errors: errors }, status: :bad_request
      end
    end

    def collections_flash_message(entries)
      t('meta_data_collection_batch_summary_all_pre') +
        entries.length.to_s +
        t('meta_data_collection_batch_summary_all_post')
    end

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

    def authorize_entries_for_batch_edit!(entries)
      authorized_entries = auth_policy_scope(
        current_user, entries, MediaResourcePolicy::EditableScope)
      if entries.count != authorized_entries.count
        raise Errors::ForbiddenError, 'Not allowed to edit all resources!'
      end
    end
  end
end
