# rubocop:disable Metrics/ClassLength
class CollectionsController < ApplicationController
  include Concerns::MediaResources::PermissionsActions
  include Concerns::MediaResources::CrudActions
  include Concerns::MediaResources::CustomUrlsForController
  include Concerns::UserScopes::MediaResources
  include Concerns::CollectionHighlights
  include Concerns::ControllerFavoritable
  include Concerns::CollectionSelection
  include Modules::Collections::PermissionsUpdate
  include Modules::Collections::Create
  include Modules::Resources::ResourceCustomUrls
  include Modules::Resources::ResourceTransferResponsibility
  include Modules::Resources::BatchResourceTransferResponsibility
  include Modules::Resources::Share
  include Concerns::AllowedSorting
  include Modules::Resources::MetaDataUpdate
  include Modules::SharedBatchUpdate

  def index
    respond_with(@get = Presenters::Collections::Collections.new(
      auth_policy_scope(current_user, Collection),
      current_user,
      can_filter: true,
      disable_file_search: true,
      list_conf: collections_list_params))
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
        list_conf: resource_list_by_type_param,
        children_list_conf: children_list_conf,
        context_id: (params[:context_id] if action_name == 'context'),
        load_meta_data: false
    respond_with @get
  end

  # actions/tabs that work like 'show':
  [
    :relations, :relation_children, :relation_siblings, :relation_parents,
    :usage_data, :more_data, :permissions, :permissions_edit]
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

  def update_transfer_responsibility
    resource_update_transfer_responsibility(Collection, id_param)
  end

  def batch_update_transfer_responsibility
    batch_resource_update_transfer_responsibility(Collection)
  end

  def select_collection
    shared_select_collection
  end

  def add_remove_collection
    shared_add_remove_collection('collection_select_collection_flash_result')
  end

  def batch_update_all
    shared_batch_meta_data_update(params[:type].camelize.constantize)
  end

  def batch_edit_meta_data_by_context
    shared_batch_edit_meta_data_by_context(Collection)
  end

  def batch_edit_meta_data_by_vocabularies
    shared_batch_edit_meta_data_by_vocabularies(Collection)
  end

  def batch_meta_data_update
    shared_batch_meta_data_update(Collection)
  end

  def batch_edit_all
    shared_batch_edit_all
  end

  def edit_meta_data_by_context
    shared_edit_meta_data_by_context
  end

  def edit_meta_data_by_vocabularies
    shared_edit_meta_data_by_vocabularies
  end

  def meta_data_update
    shared_meta_data_update
  end

  def advanced_meta_data_update
    advanced_shared_meta_data_update
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  def change_position
    collection = get_authorized_resource

    position_change = JSON.parse(params.fetch('positionChange', '{}'))
    (head :bad_request and return) if position_change.blank?

    prev_order, resource_id, direction = position_change.values_at('prevOrder',
                                                                   'resourceId',
                                                                   'direction')
    prev_order ||= collection.sorting

    (head :bad_request and return) if [prev_order, resource_id].any?(&:blank?)

    if prev_order == 'manual DESC'
      direction = {
        -2 => 2,
        -1 => 1,
        1 => -1,
        2 => -2
      }[direction]

      prev_order = 'manual ASC'
    end

    media_entry_ids =
      user_scopes_for_collection(collection)[:child_media_entries]
        .custom_order_by(prev_order)
        .to_a
        .map(&:id)

    arcs = media_entry_ids.map do |media_entry_id|
      Arcs::CollectionMediaEntryArc.find_by(collection: collection, media_entry_id: media_entry_id)
    end

    resource_index = media_entry_ids.find_index do |media_entry_id|
      media_entry_id == resource_id
    end

    # continue with at least 2 entries
    (head :ok and return) if arcs.size < 2

    ActiveRecord::Base.transaction do
      # reset ids
      arcs.each_with_index do |arc, index|
        arc.update!(position: index)
      end

      last_index = arcs.size - 1

      # update position
      case direction
      when -2
        arcs[0...resource_index].each { |arc| arc.increment!(:position) }
        arcs[resource_index].update!(position: 0)
      when -1
        if (previous_resource = arcs[resource_index - 1])
          previous_resource.increment!(:position)
          arcs[resource_index].decrement!(:position)
        end
      when 1
        if (next_resource = arcs[resource_index + 1])
          next_resource.decrement!(:position)
          arcs[resource_index].increment!(:position)
        end
      when 2
        arcs[(resource_index + 1)..last_index].each { |arc| arc.decrement!(:position) }
        arcs[resource_index].update!(position: last_index)
      end
    end

    head :ok
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity

  private

  def determine_list_conf(collection)
    list_conf = resource_list_by_type_param
    unless list_conf[:order]
      list_conf[:order] = allowed_sorting(collection)
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
      resource_list_by_type_param)

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
# rubocop:enable Metrics/ClassLength
