class MediaEntriesController < ApplicationController
  include Concerns::MediaResources::CrudActions
  include Concerns::MediaResources::CustomUrlsForController
  include Concerns::MediaResources::PermissionsActions
  include Concerns::ResourceListParams
  include Concerns::UserScopes::MediaResources
  include Modules::FileStorage
  include Modules::MediaEntries::MetaDataUpdate
  include Modules::MediaEntries::PermissionsUpdate
  include Modules::MetaDataStorage

  # list of all 'show' action sub-tabs
  SHOW_TABS = {
    nil => { title: 'Entry' },
    relations: { title: 'Relations' },
    more_data: { title: 'More Data' },
    permissions: { title: 'Permissions', icon_type: :privacy_status_icon }
  }

  def show
    # TODO: handle in MediaResources::CrudActions
    @tabs = SHOW_TABS
    media_entry = get_authorized_resource
    @get = Presenters::MediaEntries::MediaEntryShow.new(
      media_entry,
      current_user,
      user_scopes_for_media_resource(media_entry),
      list_conf: resource_list_params)
    respond_with @get
  end

  # tabs that work like 'show':
  alias_method :relations, :show
  alias_method :more_data, :show
  alias_method :permissions, :show
  alias_method :permissions_edit, :show

  def preview
    media_entry = MediaEntry.unscoped.find(id_param)
    size = params[:size] || 'small'

    begin
      preview = media_entry.media_file.preview(size)
      authorize preview
      send_file preview.file_path,
                type: preview.content_type,
                disposition: 'inline'
    rescue
      Rails.logger.warn "Preview not found! Entry##{id_param}"
      render nothing: true, status: 404
    end
  end

  def new
    authorize MediaEntry
  end

  def edit_meta_data
    represent(find_resource, Presenters::MediaEntries::MediaEntryEdit)
  end

  def create
    media_entry = MediaEntry.new(
      media_file: MediaFile.new(media_file_attributes),
      responsible_user: current_user,
      creator: current_user,
      is_published: false
    )

    authorize media_entry

    ActiveRecord::Base.transaction do
      media_entry.save!
      store_file_and_create_previews!(file, media_entry.media_file)
    end

    extract_and_store_metadata(media_entry)
    add_to_collection(media_entry, collection_id_param)

    represent(media_entry.reload, Presenters::MediaEntries::MediaEntryIndex)
  end

  def publish
    media_entry = MediaEntry.unscoped.where(is_published: false).find(id_param)
    authorize media_entry
    ActiveRecord::Base.transaction do # TODO: validation etc
      media_entry.is_published = true
      media_entry.save!
    end
    redirect_to media_entry_path,
                flash: { success: 'Entry was published!' }
  end

  def destroy
    media_entry = MediaEntry.unscoped.find(id_param)
    authorize media_entry
    begin
      ActiveRecord::Base.transaction do
        # TODO: remove this when cascade delete works:
        media_entry.meta_data.each(&:destroy!)
        media_entry.destroy!
      end
    rescue Exception => e
      redirect_to my_dashboard_path, flash: { error: 'Error deleting! ' + e.to_s }
    end

    redirect_to my_dashboard_path, flash: { success: 'Deleted!' }
  end

  ###############################################################

  private

  def find_resource
    get_authorized_resource(MediaEntry.unscoped.find(id_param))
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

  def store_file_and_create_previews!(file, media_file)
    store_file!(file.tempfile.path, media_file.original_store_location)
    media_file.create_previews! if media_file.needs_previews?
    process_with_zencoder(media_file) if media_file.audio_video?
  end

  def media_file_attributes
    { uploader: current_user,
      content_type: file.content_type,
      filename: file.original_filename,
      extension: extension(file.original_filename),
      size: file.size }
  end

  def media_entry_params
    params.require(:media_entry)
  end

  def meta_data_params
    media_entry_params.require(:meta_data)
  end

  def collection_id_param
    media_entry_params.fetch(:collection_id) { nil } # optional param, default nil
  end

  def file
    media_entry_params.require(:media_file)
  end

  def process_with_zencoder(media_file)
    ZencoderRequester.new(media_file).process
  end
end
