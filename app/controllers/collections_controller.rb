class CollectionsController < ApplicationController

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
