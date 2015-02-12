class MediaEntriesController < ApplicationController

  include Concerns::Filters
  include Concerns::Image

  def preview
    media_entry = MediaEntry.find(params[:id])
    get_preview_and_send_image(media_entry, params[:size])
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
