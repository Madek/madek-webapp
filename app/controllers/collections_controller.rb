class CollectionsController < ApplicationController

  include Concerns::Filters
  include Concerns::Image

  def preview
    collection = Collection.find(params[:id])
    media_entry = \
      collection.media_entries.cover \
        or collection.media_entries.first
    get_preview_and_send_image(media_entry, params[:size])
  end

  def index
    @collections = \
      filter_by_entrusted \
      filter_by_favorite \
      filter_by_responsible \
      Collection.all
  end

  def show
    collection = Collection.find(params[:id])
    @get = ::Presenters::Collections::CollectionShow.new(collection)
  end
end
