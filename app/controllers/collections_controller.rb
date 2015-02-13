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
    collection = Collection.find(params[:id])
    @get = ::Presenters::Collections::CollectionShow.new(collection)
  end
end
