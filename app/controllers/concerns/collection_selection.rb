module CollectionSelection
  extend ActiveSupport::Concern
  include ResourceListParams

  include Modules::Collections::Store

  include Modules::Batch::BatchShared
  include Modules::Batch::BatchAddToClipboard

  include Clipboard

  def shared_select_collection
    resource = get_authorized_resource

    search_term = params[:clear] ? '' : params[:search_term]

    @get = show_presenter_by_resource(resource, search_term)
    template_path =
      "#{resource.class.name.underscore.pluralize}/select_collection"
    respond_with(@get, template: template_path)
  end

  def show_presenter_by_resource(resource, search_term)
    if resource.class == MediaEntry
      show_class = Presenters::MediaEntries::MediaEntryShow
      scopes = user_scopes_for_media_resource(resource)
    elsif resource.class == Collection
      show_class = Presenters::Collections::CollectionShow
      scopes = user_scopes_for_collection(resource)
    end

    show_class.new(
      resource,
      current_user,
      scopes,
      list_conf: resource_list_by_type_param,
      show_collection_selection: true,
      search_term: search_term)
  end

  def shared_add_remove_collection(success_message_key)
    resource ||= model_klass.unscoped.find(id_param)
    auth_authorize resource, :select_collection?

    existing_counter = nil
    new_counter = nil
    ActiveRecord::Base.transaction do
      add_to_clipboard(resource) if params[:add_to_clipboard] == 'on'

      existing_counter = save_existing_collections(resource)
      new_counter = save_new_collections(resource)
    end

    added_count = existing_counter[:added_count] + new_counter
    removed_count = existing_counter[:removed_count]

    message = I18n.t(
      success_message_key,
      removed_count: removed_count,
      added_count: added_count)

    redirect_to(
      self.send("#{resource.class.name.underscore}_path", resource),
      flash: { success: message })
  end

  private

  def add_to_clipboard(resource)
    ensure_clipboard_collection(current_user)
    clipboard = clipboard_collection(current_user)
    add_transaction(
      clipboard,
      resource.class == MediaEntry ? [resource] : [],
      resource.class == Collection ? [resource] : []
    )
  end

  def child_resources_for_resource(resource, collection)
    if resource.class == MediaEntry
      collection.media_entries
    elsif resource.class == Collection
      collection.collections
    else
      throw 'No child resources for class: ' + resource.class.name
    end
  end

  def save_existing_collections(resource)
    added_count = 0
    removed_count = 0
    collection_selection = read_checkboxes(:selected_collections)
    collection_selection.each do |uuid, checked|
      collection = Collection.find(uuid)

      auth_authorize(collection, :add_remove_collection?)

      exists_already = exists_already_in_collection(resource, collection)
      if checked and not exists_already
        child_resources_for_resource(resource, collection) << resource
        added_count += 1
      elsif not checked and exists_already
        child_resources_for_resource(resource, collection).delete(resource)
        removed_count += 1
      end
    end
    {
      added_count: added_count,
      removed_count: removed_count
    }
  end

  def save_new_collections(resource)
    added_count = 0
    new_collections = read_new_checkboxes(:new_collections)
    new_collections.each do |name, info|
      unless info[:checked]
        next
      end
      name = info[:name]
      collection = store_collection(name)
      unless exists_already_in_collection(resource, collection)
        child_resources_for_resource(resource, collection) << resource
        added_count += 1
      end
    end
    added_count
  end

  def exists_already_in_collection(resource, collection)
    if resource.class == Collection
      child_resources_for_resource(resource, collection).include?(resource)
    elsif resource.class == MediaEntry
      child_resources_for_resource(resource, collection).rewhere(
        is_published: [true, false]).include?(resource)
    else
      raise 'not implemented'
    end
  end

  def read_checkboxes(key_sym)
    Hash[
      params.fetch(key_sym, {}).permit!.to_h.map do |key, checks|
        [key, checks.include?('true')]
      end
    ]
  end

  def read_new_checkboxes(key_sym)
    Hash[
      params.fetch(key_sym, {}).permit!.to_h.map do |key, checks|
        [key,
          {
            checked: checks[:checked] == 'true',
            name: checks[:name]
          }]
      end
    ]
  end

end
