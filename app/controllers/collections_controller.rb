class CollectionsController < ApplicationController
  include Concerns::MediaResourcesShowActions
  include Concerns::CollectionHighlights

  alias_method :edit_cover, :edit_highlights

  def update_cover
    collection = Collection.find(params[:id])
    authorize collection
    collection.cover = MediaEntry.find(params[:cover])
    redirect_to collection_path(collection)
  end
end
