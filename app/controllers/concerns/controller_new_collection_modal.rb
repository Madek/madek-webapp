module Concerns
  module ControllerNewCollectionModal
    extend ActiveSupport::Concern

    def new_collection
      modal_presenter = Presenters::Collections::CollectionNew.new
      modal_presenter.error = flash[:error]
      flash.discard
      @get.modal_presenter = modal_presenter
      respond_with @get, template: 'my/dashboard'
    end

  end
end
