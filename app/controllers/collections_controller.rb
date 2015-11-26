class CollectionsController < ApplicationController
  include Concerns::MediaResources::PermissionsActions
  include Concerns::MediaResources::CrudActions
  include Concerns::UserScopes::MediaResources
  include Concerns::CollectionHighlights
  include Modules::Collections::PermissionsUpdate

  alias_method :edit_cover, :edit_highlights

  # this overwrites the concern method
  def show
    collection = get_authorized_resource
    @get = \
      Presenters::Collections::CollectionShow.new \
        collection,
        current_user,
        user_scopes_for_collection(collection),
        list_conf: resource_list_params
    respond_with @get
  end

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
