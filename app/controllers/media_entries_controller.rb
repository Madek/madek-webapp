class MediaEntriesController < ApplicationController
  include Concerns::MediaResources::CrudActions
  include Concerns::MediaResources::CustomUrlsForController
  include Concerns::MediaResources::PermissionsActions
  include Concerns::ResourceListParams
  include Concerns::UserScopes::MediaResources
  include Concerns::ControllerFavoritable
  include Concerns::MediaEntryCollectionSelection
  include Modules::FileStorage
  include Modules::MediaEntries::Upload
  include Modules::MediaEntries::MetaDataUpdate
  include Modules::MediaEntries::PermissionsUpdate
  include Modules::MetaDataStorage

  # used in Concerns::ResourceListParams
  ALLOWED_FILTER_PARAMS = [:search, :meta_data, :media_files, :permissions].freeze

  layout false, only: [:embedded] # LOL Rails

  def show
    # TODO: handle in MediaResources::CrudActions
    media_entry = get_authorized_resource
    @get = Presenters::MediaEntries::MediaEntryShow.new(
      media_entry,
      current_user,
      user_scopes_for_media_resource(media_entry),
      action: action_name,
      list_conf: resource_list_params)
    respond_with(@get)
  end

  # tabs that work like 'show':
  [:relations, :relation_children, :relation_siblings, :relation_parents,
    :more_data, :permissions, :permissions_edit]
    .each { |action| alias_method action, :show }

  # NOTE: modal "on top of" #show
  def export
    show
  end

  def embedded
    # custom auth, only public entries supported!
    skip_authorization
    media_entry = MediaEntry.find(id_param)
    raise Errors::ForbiddenError unless media_entry.get_metadata_and_previews

    conf = params.permit(:maxwidth, :maxheight)
    @get = Presenters::MediaEntries::MediaEntryEmbedded.new(media_entry, conf)

    # allow this to be displaye inside an <iframe>
    response.headers.delete('X-Frame-Options')
  end

  def destroy
    media_entry = MediaEntry.unscoped.find(id_param)
    authorize media_entry

    ActiveRecord::Base.transaction do
      # TODO: Remove this when cascade delete works:
      media_entry.meta_data.each(&:destroy!)
      media_entry.destroy!
    end

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

  def initialize_presenter(name, template)
    # TODO: Merge with the same method in collections_controller

    media_entry = MediaEntry.unscoped.find(params[:id])
    authorize media_entry

    @get = name.constantize.new(
      current_user,
      media_entry,
      user_scopes_for_resource(media_entry),
      resource_list_params)

    respond_with(@get, template: template)
  end

  ###############################################################

  private

  def find_resource
    get_authorized_resource(MediaEntry.unscoped.find(id_param))
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
