class Dilps2::ItemsController < ApplicationController

  before_filter :pre_load

  def index
    if @collection
      items = @collection.items
    elsif @group
      items = @group.items
    end  

    # reject uncomplete
    items.delete_if {|x| x.item_rev.nil? or x.main_resource.nil? }

    
    json = items.to_json
    render :text => JSON.parse(json).to_yaml
  end

  def show
    if @collection
      item = @collection.items.find(params[:id])
    elsif @group
      item = @group.items.detect {|x| x.imageid == params[:id].to_i}
    end  

    json = item.to_json
    render :text => JSON.parse(json).to_yaml
  end


  private

  def pre_load
    if params[:collection_id]
      @collection = Dilps2::Collection.find(params[:collection_id])
    elsif params[:group_id]
      @group = Dilps2::Group.find(params[:group_id])
    end
  end

end
