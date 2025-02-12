# rubocop:disable Metrics/ClassLength
class MediaEntriesController < ApplicationController
  include MediaResources::CrudActions
  include MediaResources::CustomUrlsForController
  include MediaResources::PermissionsActions
  include ResourceListParams
  include UserScopes::MediaResources
  include ControllerFavoritable
  include CollectionSelection
  include Modules::FileStorage
  include Modules::MediaEntries::Upload
  include Modules::MediaEntries::PermissionsUpdate
  include Modules::MediaEntries::Embedded
  include Modules::MediaEntries::RdfExport
  include Modules::MediaEntries::MediaShortcut
  include Modules::MetaDataStorage
  include Modules::Resources::ResourceCustomUrls
  include Modules::Resources::ResourceConfidentialLinks
  include Modules::Resources::ResourceTransferResponsibility
  include Modules::Resources::BatchResourceTransferResponsibility
  include Modules::Resources::Share
  include Modules::Resources::MetaDataUpdate
  include Modules::SharedBatchUpdate

  # used in Concerns::ResourceListParams
  ALLOWED_FILTER_PARAMS = [:search, :meta_data, :media_files, :permissions].freeze

  def index
    resources = auth_policy_scope(current_user, model_klass)
    @get = presenterify(resources, nil, sub_filters: { context_key_id: params[:context_key_id], search_term: params[:search_term] })

    if !media_files_filter? && @get.resources.empty?
      collections = auth_policy_scope(current_user, Collection)
      collections_get = presenterify(
        collections, Presenters::Collections::Collections)
      unless collections_get.resources.empty?
        @get.try_collections = true
      end
    end

    respond_with @get
  end

  def show
    @media_entry = get_authorized_resource
    @get = Presenters::MediaEntries::MediaEntryShow.new(
      @media_entry,
      current_user,
      user_scopes_for_media_resource(@media_entry),
      action: action_name,
      list_conf: resource_list_params,
      section_meta_key_id: settings.section_meta_key_id,
      sub_filters: { context_key_id: params[:context_key_id], search_term: params[:search_term] })
    respond_with(@get)
  end

  # tabs that work like 'show':
  [
    :relations, :relation_children, :relation_siblings, :relation_parents,
    :usage_data, :more_data, :permissions, :permissions_edit,
    :show_by_confidential_link]
    .each { |action| alias_method action, :show }

  # NOTE: modal "on top of" #show
  def export
    show
  end

  def browse
    media_entry = get_authorized_resource
    @get = Presenters::MediaEntries::MediaEntryBrowse.new(
      media_entry, current_user)
    respond_with(@get)
  end

  def siblings
    media_entry = get_authorized_resource
    @get = Presenters::MediaEntries::MediaEntrySiblings.new(media_entry, current_user)
    respond_with(@get)
  end

  def destroy
    media_entry = MediaEntry.unscoped.find(id_param)
    auth_authorize media_entry
    media_entry.soft_delete

    respond_to do |format|
      format.json do
        flash[:success] = I18n.t(:media_entry_delete_success)
        render(json: {})
      end
      format.html do
        redirect_to(
          my_dashboard_path,
          flash: { success: I18n.t(:media_entry_delete_success) })
      end
    end
  end

  def ask_delete
    initialize_presenter(
      'Presenters::MediaEntries::MediaEntryAskDelete',
      'media_entries/ask_delete')
  end

  def custom_urls
    media_entry = MediaEntry.find(id_param)
    resource_custom_urls(media_entry)
  end

  def edit_custom_urls
    media_entry = MediaEntry.find(id_param)
    resource_edit_custom_urls(media_entry)
  end

  def update_custom_urls
    media_entry = MediaEntry.find(id_param)
    resource_update_custom_urls(current_user, media_entry)
  end

  def set_primary_custom_url
    media_entry = MediaEntry.find(id_param)
    resource_set_primary_custom_url(media_entry)
  end

  def update_transfer_responsibility
    resource_update_transfer_responsibility(MediaEntry, id_param)
  end

  def batch_update_transfer_responsibility
    batch_resource_update_transfer_responsibility(MediaEntry)
  end

  def select_collection
    shared_select_collection
  end

  def add_remove_collection
    shared_add_remove_collection('media_entry_select_collection_flash_result')
  end

  def batch_edit_meta_data_by_context
    shared_batch_edit_meta_data_by_context(MediaEntry)
  end

  def batch_edit_meta_data_by_vocabularies
    shared_batch_edit_meta_data_by_vocabularies(MediaEntry)
  end

  def batch_meta_data_update
    shared_batch_meta_data_update(MediaEntry)
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

  private

  def initialize_presenter(name, template)
    media_entry = MediaEntry.unscoped.find(id_param)
    auth_authorize media_entry

    @get = name.constantize.new(
      current_user,
      media_entry,
      user_scopes_for_media_resource(media_entry),
      list_conf: resource_list_params)

    respond_with(@get, template: template)
  end

  def media_files_filter?
    return true if resource_list_params[:filter].try(:[], :media_files)
  end

  def get_authorized_resource
    init_scope = MediaEntry.unscoped
    unless uberadmin_mode
      init_scope = init_scope.not_deleted
    end
    resource = init_scope.find(id_param)
    super(resource)
  end

  def find_resource
    get_authorized_resource
  end

  def media_entry_params
    params.require(:media_entry)
  end

  def meta_data_params
    media_entry_params.require(:meta_data)
  end

  def collection_id_param
    media_entry_params.fetch(:collection_id) { nil } # optional param, default nil
  end

  def process_with_zencoder(media_file)
    ZencoderRequester.new(media_file).process
  end
end
# rubocop:enable Metrics/ClassLength
