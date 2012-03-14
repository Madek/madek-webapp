# -*- encoding : utf-8 -*-
class GroupsController < ApplicationController

  before_filter do
    unless (params[:group_id] ||= params[:id]).blank?
      @group = current_user.groups.find(params[:group_id])
    end
  end

######################################################

  ##
  # Get a collection of Groups
  # 
  # @resource /groups
  #
  # @action GET
  # 
  # @optional [String] query The search query to find matching groups 
  #
  # @example_request {}
  # @example_response [{"id":1,"name":"Editors"},{"id":2,"name":"Archiv"},{"id":3,"name":"Experts"}] 
  #
  # @example_request {"query": "editors"}
  # @example_response [{"id":1,"name":"Editors"}] 
  #
  def index(query = params[:query])
    respond_to do |format|
      format.html {
        @groups = current_user.groups
      }
      format.json {
        # OPTIMIZE index groups to fulltext ??
        @groups = Group.where("name LIKE :query OR ldap_name LIKE :query", {:query => "%#{query}%"})
      }
    end
  end

  def show
    @include_users = params[:include_users] and params[:include_users] == 'true'
    @users = @group.type != "MetaDepartment" ?  @group.users : []
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
