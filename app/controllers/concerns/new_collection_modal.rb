module Concerns
  module NewCollectionModal
    extend ActiveSupport::Concern

    def new_collection
      error = flash[:error]

      @get = Presenters::Users::UserDashboard.new(
        current_user,
        user_scopes_for_dashboard(current_user),
        Presenters::Users::DashboardHeader.new(
          Presenters::Collections::CollectionNew.new(error)
        ),
        list_conf: resource_list_by_type_param,
        action: params[:action])

      flash.clear
      respond_with @get, template: 'my/new_collection'
    end

  end
end
