module Modules
  module SharedBatchUpdate
    extend ActiveSupport::Concern

    include Modules::Batch::BatchAutoPublish
    include Modules::Batch::BatchLogIntoEditSessions
    include Modules::SharedUpdate
    include Modules::Batch::BatchAuthorization

    private

    def shared_batch_edit_meta_data_by_context(type)
      shared_batch_edit_meta_data(type, params[:context_id], false)
    end

    def shared_batch_edit_meta_data_by_vocabularies(type)
      shared_batch_edit_meta_data(type, nil, true)
    end

    def shared_batch_edit_all
      auth_authorize :dashboard, :logged_in?

      collection_id = params.require(:id)
      type = params.require(:type)

      collection = Collection.unscoped.find(collection_id)

      scope = batch_scope_by_type(collection, type)
      authorize_resources_for_batch_edit!(current_user, scope)

      all_resources = scope
      authorized_resources = auth_policy_scope(
        current_user, all_resources, MediaResourcePolicy::EditableScope)

      shared_handle_batch_edit_response(
        type.camelize.constantize,
        all_resources,
        authorized_resources,
        collection,
        params[:context_id],
        params[:by_vocabulary]
      )
    end

    # rubocop:disable Metrics/MethodLength
    def shared_handle_batch_edit_response(
      type,
      all_resources,
      authorized_resources,
      collection,
      context_id,
      by_vocabularies)

      if !all_resources.any?
        redirect_to(
          return_to_param,
          flash: {
            warning: I18n.t("batch_warning_no_contents_#{type.name.underscore}")
          }
        )
      elsif !authorized_resources.any?
        redirect_to(
          return_to_param,
          flash: {
            warning: I18n.t(
              "batch_warning_no_authorized_contents_#{type.name.underscore}")
          }
        )
      else
        @get = Presenters::MediaEntries::BatchEditContextMetaData.new(
          type,
          current_user,
          context_id: context_id,
          by_vocabularies: by_vocabularies,
          return_to: return_to_param,
          all_resources: all_resources,
          authorized_resources: authorized_resources,
          collection: collection)
      end
    end
    # rubocop:enable Metrics/MethodLength

    def shared_batch_edit_meta_data(type, context_id, by_vocabularies)
      auth_authorize type, :logged_in?
      entries = type.unscoped.where(id: entries_ids_param)
      authorize_resources_for_batch_edit!(current_user, entries)

      all_resources = entries
      authorized_resources = auth_policy_scope(
        current_user, all_resources, MediaResourcePolicy::EditableScope)

      shared_handle_batch_edit_response(
        type,
        all_resources,
        authorized_resources,
        nil,
        context_id,
        by_vocabularies
      )
    end

    def determine_entries_to_update(type)
      collection_id = params[:collection_id]
      params_type = params[:type]
      scope = \
        if collection_id
          if params_type == 'media_entry'
            Collection.unscoped.find(collection_id).media_entries
          elsif params_type == 'collection'
            Collection.unscoped.find(collection_id).collections
          else
            throw 'Unexpected type: ' + params_type
          end
        else
          entries_ids = entries_ids_param(
            params.require(:batch_resource_meta_data))
          type.unscoped.where(id: entries_ids)
        end
      auth_policy_scope(
        current_user, scope, MediaResourcePolicy::EditableScope)
    end

    def determine_meta_data_from_params
      if params[:collection_id]
        case params[:type]
        when 'media_entry' then params.require(:media_entry).require(:meta_data)
        when 'collection' then params.require(:collection).require(:meta_data)
        else throw 'Unxpected type: ' + params[:type]
        end
      else
        meta_data_params
      end
    end

    def shared_batch_meta_data_update(type)
      auth_authorize type, :logged_in?
      return_to = return_to_param

      entries = determine_entries_to_update(type)

      authorize_resources_for_batch_update!(current_user, entries)

      data_params = determine_meta_data_from_params

      errors = batch_update_transaction!(entries, data_params)

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

    def batch_scope_by_type(collection, type)
      children =
        case type
        when 'media_entry' then collection.media_entries
        when 'collection' then collection.collections
        else
          throw 'Unexpected type: ' + type
        end
      auth_policy_scope(
        current_user, children, MediaResourcePolicy::ViewableScope)
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
  end
end
