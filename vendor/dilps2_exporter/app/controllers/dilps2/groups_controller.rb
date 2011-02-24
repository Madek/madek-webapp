class Dilps2::GroupsController < ApplicationController

  def index
    groups = Dilps2::Group.roots

    json = groups.to_json(:include => {:children => {:include => :children}} )
    render :text => JSON.parse(json).to_yaml
  end

  def show
    
    # id 1  => user
    # id 4  => index
    group = Dilps2::Group.find(params[:id])

    json = group.to_json(:include => {:children => {:include => :children}} )
    render :text => JSON.parse(json).to_yaml
  end

end
