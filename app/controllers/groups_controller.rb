# -*- encoding : utf-8 -*-
class GroupsController < ApplicationController
  include SQLHelper

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
        @private_groups = @groups.select{|g| g.type == "Group" and not g.is_readonly?}
        @system_groups = @groups.select{|g| g.type == "Group" and g.is_readonly?}
        @department_groups = @groups.select{|g| g.type == "MetaDepartment"}
      }
      format.json {
        # OPTIMIZE index groups to fulltext ??
        groups = 
          if  adapter_is_mysql?
            Group.where("name LIKE :query OR ldap_name LIKE :query", {:query => "%#{query}%"})
          elsif adapter_is_postgresql?
            Group.where("name ILIKE :query OR ldap_name ILIKE :query", {:query => "%#{query}%"})
          else 
            raise "sql adapter is not supported"
          end
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
  
  ##
  # Create group:
  # 
  # @resource /groups
  #
  # @action POST
  # 
  # @required [String] name The name of the group that has to be created. 
  #
  # @example_request {"name": "Librarian-Workgroup"}
  # @example_request_description This creates a group with the name "Librarian-Workgroup"
  # @example_response {"id": 6, "name": "Librarian-Workgroup"}
  # @example_response_description The response contains the new created group.
  # 
  # @response_field [Integer] id The id of the new group.
  # @response_field [Sgtring] name The name of the new group.
  # 
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

  ##
  # Update group:
  # 
  # @resource /groups
  #
  # @action PUT
  # 
  # @required [Integer] id The id of the group. 
  # @optional [String] name The new name of the group. 
  # @optional [Array] users The collection of new users of that group. 
  #
  # @example_request {"id": 6, "name": "Master-Workgroup", "users": [1,7,12]}
  # @example_request_description Rename the group to "Master-Workgroup", the new users of that group are the users with id 1, 7 and 12. 
  # @example_response {} 
  # @example_response_description Status: 200 (OK)
  # 
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
    not_authorized! and return if @group.is_readonly?
    @group.destroy
    redirect_to groups_path
  end

end
