module Modules
  module MediaEntries
    module Upload
      extend ActiveSupport::Concern

      def new
        auth_authorize MediaEntry
        workflow = find_workflow_and_authorize
        workflow_presenter = if workflow
          Presenters::Workflows::WorkflowCommon.new(workflow, current_user)
        end
        @get = Presenters::MediaEntries::MediaEntryNew.new(workflow_presenter)
      end

      def create
        media_entry = MediaEntry.new(
          media_file: MediaFile.new(media_file_attributes),
          responsible_user: current_user,
          creator: current_user,
          is_published: false)

        auth_authorize media_entry

        workflow = find_workflow_and_authorize

        ActiveRecord::Base.transaction do
          media_entry.save!
          store_uploaded_file!(file, media_entry.media_file)
        end

        # optional steps, errors are ignored but logged:
        begin
          add_default_license(media_entry)
          extract_and_store_metadata(media_entry)
          add_to_collection(media_entry,
                            collection_id_param || workflow&.master_collection&.id)
        rescue => e
          Rails.logger.warn "Upload Soft-Error: #{e.inspect}, #{e.backtrace}"
        end

        # NOTE: creating previews must come last, because in we try to detect
        #       a correct media type in `extract_and_store_metadata`
        create_previews!(media_entry.media_file)

        represent(media_entry.reload, Presenters::MediaEntries::MediaEntryIndex)
      end

      def publish
        media_entry = MediaEntry.unscoped.where(is_published: false).find(id_param)
        auth_authorize media_entry
        ActiveRecord::Base.transaction do
          media_entry.is_published = true
          media_entry.save!
        end
        redirect_to(
          media_entry_path,
          flash: { success: I18n.t(:meta_data_edit_media_entry_published) })
      end

      private

      def file
        media_entry_params.require(:media_file)
      end

      def media_file_attributes
        { uploader: current_user,
          content_type: Madek::Constants::DEFAULT_MIME_TYPE,
          filename: file.original_filename,
          extension: extension(file.original_filename),
          size: file.size }
      end

      def add_to_collection(media_entry, collection_id)
        unless collection_id.blank?
          if collection = Collection.find_by_id(collection_id)
            collection.media_entries << media_entry
          else
            flash[:warning] = 'The collection does not exist!' # TODO: i18n!
          end
        end
      end

      def store_uploaded_file!(file, media_file)
        store_file!(file.tempfile.path, media_file.original_store_location)
      end

      def create_previews!(media_file)
        media_file.create_previews! if media_file.previews_internal?
        process_with_zencoder(media_file) if media_file.previews_zencoder?
      end

      def add_default_license(media_entry)
        license = Keyword.find_by(id: settings.media_entry_default_license_id)
        license_meta_key = MetaKey.find_by(
          id: settings.media_entry_default_license_meta_key)

        if license_meta_key && license
          create_meta_datum!(media_entry, license_meta_key.id, license.id)
        end

        usage_text = settings.media_entry_default_license_usage_text.presence
        usage_meta_key = MetaKey.find_by(
          id: settings.media_entry_default_license_usage_meta_key,
          meta_datum_object_type: 'MetaDatum::Text')

        if usage_meta_key && usage_text
          create_meta_datum!(media_entry, usage_meta_key.id, usage_text)
        end
      end

      def workflow_id_param
        @_workflow_id_param ||= params.fetch(:workflow_id, nil) || \
          params.fetch(:media_entry, {}).fetch(:workflow_id, nil)
      end

      def find_workflow_and_authorize(perm_name = :add_resource?)
        if workflow_id_param
          workflow = Workflow.find(workflow_id_param)
          auth_authorize workflow, perm_name
          workflow
        end
      end
    end
  end
end
