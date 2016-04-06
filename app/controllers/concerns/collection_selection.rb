module Concerns
  module CollectionSelection
    extend ActiveSupport::Concern
    include Concerns::ResourceListParams

    def select_collection
      resource = get_authorized_resource

      search_term = params[:clear] ? '' : params[:search_term]

      @get = presenter_canonical_name.constantize.new(
        current_user,
        resource,
        user_scopes_for_resource(resource),
        search_term,
        list_conf: resource_list_params)

      respond_with(@get, template: template_path)
    end

    def add_remove_collection
      resource = get_authorized_resource

      collection_selection = read_checkboxes

      added_count = 0
      removed_count = 0

      collection_selection.each do |uuid, checked|
        collection = Collection.find(uuid)

        exists_already = child_resources(collection).include?(resource)
        if checked and not exists_already
          child_resources(collection) << resource
          added_count += 1
        elsif not checked and exists_already
          child_resources(collection).delete(resource)
          removed_count += 1
        end
      end

      message = I18n.t(
        success_message_key,
        removed_count: removed_count,
        added_count: added_count)

      redirect_to redirect_to_resource_path(resource), flash: { success: message }
    end

    private

    def read_checkboxes
      if not params[:selected_collections]
        {}
      else
        Hash[
          params.require(:selected_collections).map do |key, checks|
            [key, checks.include?('true')]
          end
        ]
      end
    end

  end
end
