class MediaEntriesController < ApplicationController
  include Concerns::MediaResourcesShowActions
  include Modules::FileStorage
  include Modules::MetaDataStorage

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
    media_entry = MediaEntry.new(media_entry_params)
    media_entry.media_file = MediaFile.new(media_file_attributes)

    ActiveRecord::Base.transaction do
      media_entry.save!
      store_file_and_create_previews!(file, media_entry.media_file)
      # TODO: extract and store metadata
      # this includes 'real' meta data as well as 'meta data' for the media file
      # and media file attributes like width and height.
      # extract_and_store_metadata!
      store_meta_data!(media_entry.id, meta_data_params)
    end

    respond_with media_entry
  end

  ###############################################################

  private

  def store_file_and_create_previews!(file, media_file)
    store_file!(file.tempfile.path, media_file.store_location)
    media_file.create_previews! if media_file.needs_previews?
  end

  def media_file_attributes
    { content_type: file.content_type,
      filename: file.original_filename,
      extension: extension(file.original_filename),
      size: file.size,
      uploader_id: media_file_params[:uploader_id] }
  end

  def file
    media_file_params.require(:file)
  end

  def media_file_params
    params
      .require(:media_entry)
      .require(:media_file)
      .permit(:file, :uploader_id)
  end

  def media_entry_params
    params
      .require(:media_entry)
      .permit(:responsible_user_id,
              :creator_id)
  end

  def meta_data_params
    params
      .require(:media_entry)
      .require(:meta_data)
  end
end
