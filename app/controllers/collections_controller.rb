class CollectionsController < ApplicationController

  respond_to 'json'

  before_filter do 
    @collection_id = params[:id]
    filter = MediaResource.get_filter_params params
    @ids = MediaResource.filter(current_user, filter).pluck("media_resources.id")
  end

  def add 
    collection = Collection.add @ids, @collection_id
    respond_to do |format|
      format.json {render :json => {:id => collection[:id], :count => collection[:count], :ids => collection[:ids]}}
    end
  end

  def remove
    collection = Collection.remove @ids, @collection_id
    respond_to do |format|
      format.json {render :json => {:id => collection[:id], :count => collection[:count], :ids => collection[:ids], :removed_ids => Array(@ids) - Array(collection[:ids])}}
    end
  end

  def destroy
    Collection.destroy @collection_id
    respond_to do |format|
      format.json {render :nothing => true, :status => :ok}
    end
  end
end
