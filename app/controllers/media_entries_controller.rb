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

  def show
    # TODO: handle in MediaResources::CrudActions
    media_entry = get_authorized_resource
    respond_with(@get = Presenters::MediaEntries::MediaEntryShow.new(
      media_entry,
      current_user,
      user_scopes_for_media_resource(media_entry),
      list_conf: resource_list_params))
  end

  # tabs that work like 'show':
  [:relations, :more_data, :permissions, :permissions_edit]
    .each { |action| alias_method action, :show }

  def destroy
    media_entry = MediaEntry.unscoped.find(id_param)
    authorize media_entry
    begin
      ActiveRecord::Base.transaction do
        # TODO: remove this when cascade delete works:
        media_entry.meta_data.each(&:destroy!)
        media_entry.destroy!
      end
    rescue Exception => e
      redirect_to my_dashboard_path, flash: { error: 'Error deleting! ' + e.to_s }
      return
    end

    redirect_to my_dashboard_path, flash: { success: 'Deleted!' }
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
