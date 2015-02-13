class MediaEntriesController < ApplicationController

  include Concerns::Filters

  def preview
    # TODO: review/cleanup
    media_entry = MediaEntry.find(params[:id])

    begin
      preview = media_entry.media_file.preview(size)
      send_file preview.file_path,
                type: preview.content_type,
                disposition: 'inline'
    rescue
      Rails.logger.warn 'image not found!'
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
    @media_entry = MediaEntry.find(params[:id])
  end

  private

  def filter_by_imported(media_entries)
    filter_by_param_or_return_unchanged \
      media_entries, :created_by,
      params[:imported], 'true'
  end
end
