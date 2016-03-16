class CollectionsController < ApplicationController
  include Concerns::MediaResources::PermissionsActions
  include Concerns::MediaResources::CrudActions
  include Concerns::MediaResources::CustomUrlsForController
  include Concerns::UserScopes::MediaResources
  include Concerns::CollectionHighlights
  include Concerns::ControllerFavoritable
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

  def create
    authorize Collection
    title = params[:collection_title]

    if title.present?
      collection = store_collection(title)
      redirect_to(
        collection_path(collection),
        flash: { success: I18n.t(:collection_new_flash_successful) })
    else
      redirect_to(
        :back,
        flash: { error: I18n.t(:collection_new_flash_title_needed) })
    end
  end

  def update_cover
    collection = Collection.find(id_param)
    authorize collection
    collection.cover = MediaEntry.find(params[:cover])
    redirect_to collection_path(collection)
  end

  def collection_params
    params.require(:collection)
  end

  private

  def find_resource
    get_authorized_resource(Collection.unscoped.find(id_param))
  end

  private

  def store_collection(title)
    collection = Collection.create!(
      get_metadata_and_previews: true,
      responsible_user: current_user,
      creator: current_user)
    meta_key = MetaKey.find_by(id: 'madek_core:title')
    MetaDatum::Text.create!(
      collection: collection,
      string: title,
      meta_key: meta_key,
      created_by: current_user)
    collection
  end

end
