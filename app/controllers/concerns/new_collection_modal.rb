module Concerns
  module NewCollectionModal
    extend ActiveSupport::Concern

    def new_collection
      @get = Presenters::Collections::CollectionNew.new(
        current_user,
        user_scopes_for_dashboard(current_user),
        list_conf: resource_list_params)
      @get.error = flash[:error]
      flash.discard
      respond_with @get, template: 'my/new_collection'
    end

  end
end
