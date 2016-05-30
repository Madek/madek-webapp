module Concerns
  module NewCollectionModal
    extend ActiveSupport::Concern

    def new_collection
      @get = HashPresenter.new(
        Pojo.new(
          user_dashboard: user_dashboard_presenter,
          new_collection: new_collection_presenter
        )
      )
      respond_with @get, template: 'my/new_collection'
    end

    private

    def new_collection_presenter
      get = Presenters::Collections::CollectionNew.new
      get.error = flash[:error]
      flash.discard
      get
    end

    def user_dashboard_presenter
      Presenters::Users::UserDashboard.new(
        current_user,
        user_scopes_for_dashboard(current_user),
        list_conf: resource_list_params)
    end

  end
end
