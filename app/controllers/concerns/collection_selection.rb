module Concerns
  module CollectionSelection
    extend ActiveSupport::Concern
    include Concerns::ResourceListParams

    def select_collection
      resource = get_authorized_resource

      # Here do binding.pry.
      search_term = params[:clear] ? '' : params[:search_term]

      collection_selection = presenter_canonical_name.constantize.new(
        current_user,
        resource,
        search_term,
        list_conf: resource_list_params)

      resource_show = show_presenter_by_resource(resource)
      resource_show.collection_selection = collection_selection
      @get = resource_show
      respond_with(@get, template: template_path)
    end

    def show_presenter_by_resource(resource)
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
        list_conf: resource_list_params)
    end

    def add_remove_collection
      resource = get_authorized_resource

      existing_counter = save_existing_collections(resource)
      new_counter = save_new_collections(resource)

      added_count = existing_counter[:added_count] + new_counter
      removed_count = existing_counter[:removed_count]

      message = I18n.t(
        success_message_key,
        removed_count: removed_count,
        added_count: added_count)

      redirect_to redirect_to_resource_path(resource), flash: { success: message }
    end

    private

    def save_existing_collections(resource)
      added_count = 0
      removed_count = 0
      collection_selection = read_checkboxes(:selected_collections)
      collection_selection.each do |uuid, checked|
        collection = Collection.find(uuid)

        exists_already = exists_already_in_collection(resource, collection)
        if checked and not exists_already
          child_resources(collection) << resource
          added_count += 1
        elsif not checked and exists_already
          child_resources(collection).delete(resource)
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
          child_resources(collection) << resource
          added_count += 1
        end
      end
      added_count
    end

    def exists_already_in_collection(resource, collection)
      if resource.class == Collection
        child_resources(collection).include?(resource)
      elsif resource.class == MediaEntry
        child_resources(collection).rewhere(
          is_published: [true, false]).include?(resource)
      else
        raise 'not implemented'
      end
    end

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

    def read_checkboxes(key_sym)
      if not params[key_sym]
        {}
      else
        Hash[
          params.require(key_sym).map do |key, checks|
            [key, checks.include?('true')]
          end
        ]
      end
    end

    def read_new_checkboxes(key_sym)
      if not params[key_sym]
        {}
      else
        Hash[
          params.require(key_sym).map do |key, checks|
            [
              key,
              {
                checked: checks[:checked] == 'true',
                name: checks[:name]
              }
            ]
          end
        ]
      end
    end

  end
end
