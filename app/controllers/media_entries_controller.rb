class MediaEntriesController < ApplicationController
  include Concerns::MediaResourcesShowActions
  include Modules::FileStorage
  include Modules::MetaDataStorage

  # list of all 'show' action sub-tabs
  SHOW_TABS = {
    relations: 'Relations',
    more_data: 'More Data'
  }

  def show
    @get = get_authorized_presenter(MediaEntry.unscoped.find(params[:id]))
    @tabs = SHOW_TABS
    handle_tabs
    # render "tab_#{tab.to_s}" if tab
  end

  def more_data
  end

  def preview
    media_entry = MediaEntry.find(params[:id])
    size = params[:size] || 'small'

    begin
      preview = media_entry.media_file.preview(size)
      send_file preview.file_path,
                type: preview.content_type,
                disposition: 'inline'
    rescue
      Rails.logger.warn "Preview not found! Entry##{params[:id]}"
      render nothing: true, status: 404
    end
  end

  def new
  end

  def create
    ActiveRecord::Base.transaction do
      media_entry = MediaEntry.new(
        media_file: MediaFile.new(media_file_attributes),
        responsible_user: current_user,
        creator: current_user,
        is_published: false
      )
      media_entry.save!
      store_file_and_create_previews!(file, media_entry.media_file)
      extract_and_store_metadata!(media_entry)

      respond_with media_entry
    end

    # TODO: `rescue` here? what happens if the transaction fails?
  end

  def publish
    media_entry = MediaEntry.unscoped.where(is_published: false).find(params[:id])
    ActiveRecord::Base.transaction do
      # TODO: validation etc
      media_entry.is_published = true
      media_entry.save!
    end
    redirect_to media_entry_path,
                flash: { success: 'Entry was published!' }
  end

  ###############################################################

  private

  def handle_tabs
    # if tab given: show if known, otherwise redirect to normal show
    if (tab_name = params[:tab]).present?
      if @tabs.keys.include?(tab_name.to_sym)
        render("show_#{tab_name}") and return
      else
        redirect_to(media_entry_path(params[:id])) and return
      end
    end
  end

  def store_file_and_create_previews!(file, media_file)
    store_file!(file.tempfile.path, media_file.store_location)
    media_file.create_previews! if media_file.needs_previews?
  end

  def media_file_attributes
    {
      uploader: current_user,
      content_type: file.content_type,
      filename: file.original_filename,
      extension: extension(file.original_filename),
      size: file.size
    }
  end

  def media_entry_params
    params.require(:media_entry)
  end

  def file
    media_entry_params.require(:media_file)
  end

end
