# rubocop:disable Metrics/ClassLength
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
  include Modules::Resources::ResourceCustomUrls

  ALLOWED_FILTER_PARAMS = [:search].freeze

  ALLOWED_SORTING = [
    'created_at ASC',
    'created_at DESC',
    'title ASC',
    'title DESC',
    'last_change'].freeze

  def index
    respond_with(@get = Presenters::Collections::Collections.new(
      auth_policy_scope(current_user, Collection),
      current_user,
      can_filter: true,
      list_conf: resource_list_params))
  end

  def context
    show
  end

  # this overwrites the concern method
  def show
    collection = get_authorized_resource
    # NOTE: for sync call load_meta_data should be
    # load_meta_data: resource_list_params
    #   .try(:[], :for_url)
    #   .try(:[], :query)
    #   .try(:[], :list)
    #   .try(:[], :layout) == 'list'

    children_list_conf = determine_list_conf(collection)

    @get = \
      Presenters::Collections::CollectionShow.new \
        collection,
        current_user,
        user_scopes_for_collection(collection),
        action: action_name,
        type_filter: type_param,
        list_conf: resource_list_params,
        children_list_conf: children_list_conf,
        context_id: (params[:context_id] if action_name == 'context'),
        load_meta_data: false
    respond_with @get
  end

  # actions/tabs that work like 'show':
  [
    :relations, :relation_children, :relation_siblings, :relation_parents,
    :more_data, :permissions, :permissions_edit]
    .each { |action| alias_method action, :show }

  def update
    collection = Collection.find(id_param)
    auth_authorize collection
    collection.update_attributes! update_params
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def destroy
    collection = Collection.find(params[:id])
    auth_authorize collection
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
    auth_authorize collection
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
    auth_authorize collection
    media_entry_uuid = params[:selected_resource]
    if media_entry_uuid
      collection.cover = MediaEntry.find(media_entry_uuid)
      collection.save!
    end
    redirect_to collection_path(collection)
  end

  def custom_urls
    collection = Collection.find(id_param)
    resource_custom_urls(collection)
  end

  def edit_custom_urls
    collection = Collection.find(id_param)
    resource_edit_custom_urls(collection)
  end

  def update_custom_urls
    collection = Collection.find(id_param)
    resource_update_custom_urls(current_user, collection)
  end

  def set_primary_custom_url
    collection = Collection.find(id_param)
    resource_set_primary_custom_url(collection)
  end

  def collection_params
    params.require(:collection)
  end

  def meta_data_params
    collection_params.require(:meta_data)
  end

  private

  def determine_list_conf(collection)
    list_conf = resource_list_params
    unless list_conf[:order]
      list_conf[:order] =
        if ALLOWED_SORTING.include? collection.sorting
          collection.sorting
        else
          'created_at DESC'
        end
    end
    list_conf
  end

  def authorize_and_respond_with_presenter_and_template(name, template)
    collection = Collection.find(params[:id])
    auth_authorize collection

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

  def update_params
    collection_params.permit(:layout, :sorting)
  end

  def type_param
    params.permit(:type).fetch(:type, nil)
  end
end
