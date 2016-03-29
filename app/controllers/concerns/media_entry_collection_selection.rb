module Concerns
  module MediaEntryCollectionSelection
    extend ActiveSupport::Concern
    include Concerns::ResourceListParams

    def select_collection
      media_entry = get_authorized_resource

      search_term = params[:clear] ? '' : params[:search_term]

      @get = Presenters::MediaEntries::MediaEntrySelectCollection.new(
        current_user,
        media_entry,
        user_scopes_for_media_resource(media_entry),
        search_term,
        list_conf: resource_list_params)

      respond_with(@get, template: 'media_entries/select_collection')
    end

    def add_remove_collection
      media_entry = get_authorized_resource

      collection_selection = read_checkboxes

      added_count = 0
      removed_count = 0
      collection_selection.each do |uuid, checked|
        collection = Collection.find(uuid)

        exists_already = collection.media_entries.include?(media_entry)
        if checked and not exists_already
          collection.media_entries << media_entry
          added_count += 1
        elsif not checked and exists_already
          collection.media_entries.delete(media_entry)
          removed_count += 1
        end
      end

      message = I18n.t(
        'media_entry_select_collection_flash_result',
        removed_count: removed_count,
        added_count: added_count)

      redirect_to media_entry_path(media_entry), flash: { success: message }
    end

    private

    def read_checkboxes
      Hash[
        params.require(:selected_collections).map do |key, checks|
          [key, checks.include?('true')]
        end
      ]
    end

  end
end
