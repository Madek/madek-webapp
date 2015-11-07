class CollectionsController < ApplicationController
  include Concerns::MediaResources::PermissionsActions
  include Concerns::MediaResources::CrudActions
  include Concerns::CollectionHighlights
  include Modules::Collections::PermissionsUpdate

  alias_method :edit_cover, :edit_highlights

  def update_cover
    collection = Collection.find(params[:id])
    authorize collection
    collection.cover = MediaEntry.find(params[:cover])
    redirect_to collection_path(collection)
  end

  def collection_params
    params.require(:collection)
  end
end
