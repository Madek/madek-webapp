# rubocop:disable all
module Modules
  module MediaEntries
    module MetaDataUpdate
      extend ActiveSupport::Concern

      def batch_edit_meta_data
        entries_ids = params.require(:id)
        entries = MediaEntry.unscoped.where(id: entries_ids)

        # HACK: disable pundit and do everything manually
        skip_authorization
        entries = entries.editable_by_user(current_user)

        @get = Presenters::MediaEntries::MediaEntryBatchEdit.new(
          entries, current_user)
      end

      def batch_meta_data_update
        entries_ids = params.require(:batch_resource_meta_data).require(:id)
        entries = MediaEntry.unscoped.where(id: entries_ids)

        # HACK: disable pundit and do everything manually
        skip_authorization
        entries.each do |e|
          raise Errors::ForbiddenError unless e.editable_by_user?(current_user)
        end

        errors = batch_update_transaction!(entries, meta_data_params)

        if errors.empty?
          redirect_to(
            my_dashboard_path,
            flash: { success: I18n.t('meta_data_batch_success') })
        else
          redirect_to(
            my_dashboard_path,
            flash: { error: I18n.t('meta_data_batch_failure') })
        end
      end

      def batch_update_inside_transaction!(entries, meta_data_params, errors)
        entries.each do |media_entry|
          meta_data_params.each do |meta_key_id, value|
            data_entered = false
            value[:values].each { |val| data_entered if val.strip != '' }
            all_equal = value[:difference][:all_equal] == 'true'
            all_empty = value[:difference][:all_empty] == 'true'

            next unless all_equal or all_empty or (not all_equal and data_entered)

            begin
              handle_meta_datum!(media_entry, meta_key_id, value[:values])
            rescue => exception
              errors[meta_key_id] = [exception.message]
            end
          end
        end
      end

      def batch_update_transaction!(entries, meta_data_params)
        errors = {}
        ActiveRecord::Base.transaction do
          batch_update_inside_transaction!(entries, meta_data_params, errors)
          raise ActiveRecord::Rollback unless errors.empty?
        end
        errors
      end

      def edit_meta_data
        represent(find_resource, Presenters::MediaEntries::MediaEntryEdit)
      end

      def meta_data_update
        authorize (@media_entry = MediaEntry.unscoped.find(params[:id]))
        errors = update_all_meta_data_transaction!(@media_entry, meta_data_params)

        if errors.empty?
          @get = Presenters::MediaEntries::MediaEntryShow.new(
            @media_entry.reload,
            current_user,
            user_scopes_for_media_resource(@media_entry),
            list_conf: resource_list_params)
          respond_with @get, location: -> { media_entry_path(@media_entry) }
        else
          render json: { errors: errors }, status: :bad_request
        end
      end

      def update_all_meta_data_transaction!(media_entry, meta_data_params)
        errors = {}

        ActiveRecord::Base.transaction do
          meta_data_params.each do |meta_key_id, value|
            begin
              handle_meta_datum!(media_entry, meta_key_id, value)
            rescue => e
              errors[meta_key_id] = [e.message]
            end

          end
          raise ActiveRecord::Rollback unless errors.empty?
        end

        errors
      end

      def handle_meta_datum!(media_entry, meta_key_id, value)
        # These 4 cases are handled by the datalayer:
        # 1. MD exists, value is present: update MD
        # 2. MD exists, value is empty: delete MD
        # 3. MD does not exist, value is present: create MD
        # 4. MD does not exist, value is empty: ignore/skip
        # (MD="A MetaDatum for this MetaKey on this MediaResource")

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
# rubocop:enable all
