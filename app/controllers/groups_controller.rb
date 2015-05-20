class GroupsController < ApplicationController
  include Concerns::JSONSearch

  def index
    get_and_respond_with_json
  end

  def show
    @get = Presenters::Groups::GroupShow
            .new(Group.find(params[:id]), current_user)
    respond_with @get
  end

end
