# -*- encoding : utf-8 -*-
class Admin::GroupsController < Admin::AdminController

  before_filter :pre_load

  def index
    @groups = Group.all
  end

  def show
  end

  def new
    @group = Group.new
    respond_to do |format|
      format.js
    end
  end

  def create
    Group.create(params[:group])
    redirect_to admin_groups_path    
  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def update
    @group.update_attributes(params[:group])
    redirect_to admin_groups_path
  end

  def destroy
    @group.destroy if @group.users.empty?
    redirect_to admin_groups_path
  end

#####################################################

  private

  def pre_load
    unless (params[:group_id] ||= params[:id]).blank?
      @group = Group.find(params[:group_id])
    end
  end

end
