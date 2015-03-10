class MediaEntriesController < ApplicationController

  include Concerns::Filters

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

  def index
    @media_entries = \
      filter_by_entrusted \
        filter_by_favorite \
          filter_by_imported \
            filter_by_responsible \
              MediaEntry.all
  end

  def show
    entry = MediaEntry.find(params[:id])
    @get = ::Presenters::MediaEntries::MediaEntryShow.new(entry, current_user)
  end

  def permissions_show
    entry = MediaEntry.find(params[:id])
    @get = \
      ::Presenters::MediaEntries::MediaEntryPermissionsShow.new(entry,
                                                                current_user)
  end

  private

  def filter_by_imported(media_entries)
    filter_by_param_or_return_unchanged \
      media_entries, :created_by,
      params[:imported], 'true'
  end
end
