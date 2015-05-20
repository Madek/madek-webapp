class CollectionsController < ApplicationController

  def show
    @get = ::Presenters::Collections::CollectionShow.new(
      Collection.find(params[:id]), current_user
    )
    respond_with @get
  end

  def permissions_show
    collection = Collection.find(params[:id])
    @get = \
      ::Presenters::Collections::CollectionPermissionsShow
        .new(collection, current_user)
  end
end
