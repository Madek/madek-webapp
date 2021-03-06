module Concerns
  module NewCollectionModal
    extend ActiveSupport::Concern

    def new_collection
      auth_authorize :dashboard, :logged_in?

      error = flash[:error]

      @get = Presenters::Collections::CollectionNew.new(error)

      flash.clear
      respond_with @get, template: 'my/new_collection', layout: 'application'
    end

  end
end
