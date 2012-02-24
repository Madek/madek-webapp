# -*- encoding : utf-8 -*-
class GroupsController < ApplicationController

  before_filter do
    unless (params[:group_id] ||= params[:id]).blank?
      @group = current_user.groups.find(params[:group_id])
    end
  end

######################################################
  
  def index
    # OPTIMIZE
    respond_to do |format|
      format.html {
        @groups = current_user.groups
      }
      format.js {
        # OPTIMIZE index groups to fulltext ??
        groups = Group.where("name LIKE :term OR ldap_name LIKE :term", {:term => "%#{params[:term]}%"})
        render :json => groups.map {|x| {:id => x.id, :value => x.to_s} }
      }
    end
  end

  def show
    @users = @group.type == "MetaDepartment" ? [] : @group.users
  end

  def new
    @group = current_user.groups.build
  end

  def create
    group = current_user.groups.build(params[:group])
    if group.save
      # FIXME Rails 3.0.7 build: the association isn't saved properly
      current_user.groups << group unless current_user.groups(true).exists?(group)
      redirect_to edit_group_path(group)
    else
      flash[:error] = group.errors.full_messages
      redirect_to :back
    end
  end

  def edit
    not_authorized! and return if @group.is_readonly?
    # TODO authorized?
  end

  def update
    not_authorized! and return if @group.is_readonly?
    # TODO authorized?
    @group.update_attributes(params[:group])
    respond_to do |format|
      format.html { redirect_to edit_group_path(@group) }
      format.js { render :text => @group.name } # OPTIMIZE
    end
  end

  def destroy
    not_authorized! and return if @group.is_readonly?
    @group.destroy
    redirect_to groups_path
  end

######################################################

  # TODO refactor to update method and use accepted_nested_attributes ?? 
  def membership
    @user = User.find(params[:user_id])
    if request.post?
      @group.users << @user
      respond_to do |format|
        format.js { render :partial => "user", :object => @user }
      end
    elsif request.delete?
      @group.users.delete(@user)
      respond_to do |format|
        format.js { render :nothing => true } # TODO check if successfully deleted
      end
    end
  end

end
