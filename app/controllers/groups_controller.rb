# -*- encoding : utf-8 -*-
class GroupsController < ApplicationController
  include SQLHelper

  before_filter do
    unless (params[:group_id] ||= params[:id]).blank?
      @group = current_user.groups.find(params[:group_id])
    end
  end


  def index(query = params[:query])
    respond_to do |format|
      format.html {
        @groups = current_user.groups
        @private_groups = @groups.select{|g| g.type == "Group" and not g.is_readonly?}
        @system_groups = @groups.select{|g| g.type == "Group" and g.is_readonly?}
        @department_groups = @groups.select{|g| g.type == "MetaDepartment"}
      }
      format.json {
        groups = Group.where("name ilike :query OR ldap_name ilike :query", {:query => "%#{query}%"})
        render :json => view_context.json_for(groups)
      }
    end
  end

  def show
    respond_to do |format|
      format.json {
        # TODO what is this for ???
        @include_users = params[:include_users] and params[:include_users] == 'true'
        
        with = { users: {} }
        render :json => view_context.json_for(@group, with)
      }
    end
  end
  
  def create(name = params[:name] || raise("Name has to be present."))
    group = current_user.groups.create(:name => name)
    respond_to do |format|
      format.json {
        if group.persisted?
          render json: view_context.json_for(group)
        else
          render json: {:error => group.errors.full_messages}, :status => :bad_request 
        end        
      }
    end
  end

  def update(name = params[:name], user_ids = params[:user_ids])
    not_authorized! and return if @group.is_readonly?
    @group.name = name unless name.blank?        
    @group.users = User.where(:id => user_ids) unless user_ids.blank? # FIXME can we delete all members ??
        
    respond_to do |format|
      format.html { redirect_to edit_group_path(@group) }
      format.json {
        if @group.save
          render json: view_context.json_for(@group)
        else
          render json: {:error => group.errors.full_messages}, :status => :bad_request 
        end
      }
    end
  end

  def destroy
    if @group.is_readonly? or @group.users.count > 1
      not_authorized! and return 
    end

    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_path }
      format.json { render json: "", :status => :ok }
    end
  end

end
