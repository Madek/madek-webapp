class MediaEntriesController < ApplicationController

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

  def show
    @get = ::Presenters::MediaEntries::MediaEntryShow.new(
      MediaEntry.find(params[:id]), current_user
    )
    respond_with @get
  end

  def permissions_show
    entry = MediaEntry.find(params[:id])
    @get = \
      ::Presenters::MediaEntries::MediaEntryPermissionsShow.new(entry,
                                                                current_user)
  end
end
