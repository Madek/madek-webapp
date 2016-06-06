module Concerns
  module NewCollectionModal
    extend ActiveSupport::Concern

    def new_collection
      error = flash[:error]
      @get = Presenters::HashPresenter.new(
        Pojo.new(
          user_dashboard: user_dashboard_presenter,
          new_collection: new_collection_presenter(error)
        )
      )
      flash.clear
      respond_with @get, template: 'my/new_collection'
    end

    private

    def new_collection_presenter(error)
      Presenters::Collections::CollectionNew.new(error)
    end

    def user_dashboard_presenter
      Presenters::Users::UserDashboard.new(
        current_user,
        user_scopes_for_dashboard(current_user),
        list_conf: resource_list_params)
    end

  end
end
