class CollectionsController < ApplicationController

  include Concerns::Filters

  def index
    @collections = \
      filter_by_entrusted \
        filter_by_favorite \
          filter_by_responsible \
            Collection.all
  end

  def show
    @get = ::Presenters::Collections::CollectionShow.new(
      Collection.find(params[:id]), current_user
    )
    respond_with_presenter_formats
  end

  def permissions_show
    collection = Collection.find(params[:id])
    @get = \
      ::Presenters::Collections::CollectionPermissionsShow
        .new(collection, current_user)
  end
end
