class GroupsController < ApplicationController

  def show
    @get = Presenters::Groups::GroupShow
            .new(Group.find(params[:id]), current_user)
    respond_with_presenter_formats
  end

end
