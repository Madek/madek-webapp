class CollectionsController < ApplicationController
  include Concerns::MediaResources::PermissionsActions
  include Concerns::MediaResources::CrudActions
  include Concerns::MediaResources::CustomUrlsForController
  include Concerns::UserScopes::MediaResources
  include Concerns::CollectionHighlights
  include Concerns::ControllerFavoritable
  include Concerns::CollectionCollectionSelection
  include Modules::Collections::PermissionsUpdate
  include Modules::Collections::MetaDataUpdate
  include Modules::Collections::Create
  include Modules::Collections::Store

  ALLOWED_FILTER_PARAMS = [:search].freeze

  def index
    respond_with(@get = Presenters::Collections::Collections.new(
      policy_scope(Collection),
      current_user,
      can_filter: true,
      list_conf: resource_list_params))
  end

  def relations
    show
  end

  def more_data
    show
  end

  def permissions_show
    show
  end

  def permissions_edit
    show
  end

  # # tabs that work like 'show':
  # [:relations, :more_data, :permissions_show, :permissions_edit]
  #   .each { |action| alias_method action, :show }

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

  def destroy
    collection = Collection.find(params[:id])
    authorize collection
    collection.destroy!

    respond_to do |format|
      format.json do
        flash[:success] = I18n.t(:collection_delete_success)
        render(json: {})
      end
      format.html do
        redirect_to(
          my_dashboard_path,
          flash: { success: I18n.t(:collection_delete_success) })
      end
    end
  end

  def ask_delete
    authorize_and_respond_with_presenter_and_template(
      'Presenters::Collections::CollectionAskDelete',
      'collections/ask_delete')
  end

  def cover
    collection = Collection.find(id_param)
    authorize collection
    path = CollectionThumbUrl.new(collection, current_user).get(size: size_param)
    redirect_to path
  end

  def edit_cover
    authorize_and_respond_with_presenter_and_template(
      'Presenters::Collections::CollectionEditCover',
      'collections/edit_cover')
  end

  def edit_highlights
    authorize_and_respond_with_presenter_and_template(
      'Presenters::Collections::CollectionEditHighlights',
      'collections/edit_highlights')
  end

  def update_cover
    collection = Collection.find(id_param)
    authorize collection
    media_entry_uuid = params[:selected_resource]
    if media_entry_uuid
      collection.cover = MediaEntry.find(media_entry_uuid)
      collection.save!
    end
    redirect_to collection_path(collection)
  end

  def collection_params
    params.require(:collection)
  end

  def meta_data_params
    collection_params.require(:meta_data)
  end

  private

  def authorize_and_respond_with_presenter_and_template(name, template)
    collection = Collection.find(params[:id])
    authorize collection

    @get = name.constantize.new(
      current_user,
      collection,
      user_scopes_for_collection(collection),
      resource_list_params)

    respond_with(@get, template: template)
  end

  def find_resource
    get_authorized_resource(Collection.unscoped.find(id_param))
  end

  def size_param
    params.require(:size).to_sym
  end
end
