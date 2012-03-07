# -*- encoding : utf-8 -*-

##
# Permissions are actions that specify if or if not a subject can perform those actions on a specific resource.
# Possible actions are: view, edit, manage, download
# 
class PermissionsController < ApplicationController

  ##
  # Get permissions for a collection of resources
  # 
  # @resource /permissions
  #
  # @action GET
  # 
  # @required [Array] media_resource_ids The collection of resources you want to fetch the permissios for
  #
  # @optional [Hash] with[users] Adds all users to the respond that have the same permissions than you 
  # @optional [Hash] with[groups] Adds all groups to the respond that have the same permissions than you 
  #
  # @example_request {"media_resources_ids": [1,2,3]} Request the setted permissions for the media resources with id 1,2 and 3
  # @example_response {"public":{"view":[],"edit":[],"download":[]},"you":{"name":"Muster,Max","id":31,"view":[1],"edit":[1],"download":[1],"manage":[1]}} This response asserts that the public cannot view the MediaResources (with id 1,2 and three) but that you can view the MediaResource with id 1
  #
  # @example_request {"media_resources_ids": [1,2,3], "with": {"users": true}} Request the setted permissions for the media resources with id 1,2 and 3. This Request adds all users to the respond that have the same permissions than you 
  # @example_response {"public":{"view":[],"edit":[],"download":[]},"you":{"name":"Muster,Max","id":31,"view":[1],"edit":[1],"download":[1],"manage":[1]},"users":[{"id":31, "name": "Muster, Max", "view": [1], "edit": [1], "download": [], "edit": [1]}]}
  # 
  # @example_request {"media_resources_ids": [1,2,3], "with": {"users": true, "groups": true}} Request the setted permissions for the media resources with id 1,2 and 3. This Request adds all users to the respond that have the same permissions than you 
  # @example_response {"public":{"view":[],"edit":[],"download":[]},"you":{"name":"Muster,Max","id":31,"view":[1],"edit":[1],"download":[1],"manage":[1]},"users":[{"id":31, "name": "Muster, Max", "view": [1], "edit": [1], "download": [], "edit": [1]}],"groups":[{"id":31, "name": "Group of Users", "view": [1], "edit": [1], "download": [], "edit": [1]}]}
  #   
  # @example_request {"media_resources_ids": [1,2,3]} Request the setted permissions for the media resources with id 1,2 and 3 and add additionally the owners of the provided MediaResources to the respond.
  # @example_response {"public":{"view":[],"edit":[],"download":[]},"you":{"name":"Muster,Max","id":31,"view":[1],"edit":[1],"download":[1],"manage":[1]},"owners":[{"id":170371,"name":"Muster, Max","media_resource_ids":[1]}]}
  #
  # @response_field [Hash] public The object containing permission-actions for the public 
  # @response_field [Array] public.view The MediaResourceIds that the public can view  
  # @response_field [Array] public.edit The MediaResourceIds that the public can edit  
  # @response_field [Array] public.download The MediaResourceIds that the public can download
  #
  # @response_field [Hash] you The object containing permission-actions for you 
  # @response_field [Array] you.view The MediaResourceIds that you can view  
  # @response_field [Array] you.edit The MediaResourceIds that you can edit  
  # @response_field [Array] you.download The MediaResourceIds that you can download  
  # @response_field [Array] you.manage The MediaResourceIds that you can manage  
  #
  def index(media_resource_ids = params[:media_resource_ids])
    begin
      @media_resources = MediaResource.accessible_by_user(current_user, :view).find(media_resource_ids)
    rescue
      not_authorized!
    end
  end

  ##
  # Update/set permissions for a collection of resources
  # 
  # @resource /permissions
  #
  # @action PUT
  # 
  # @required [Array] media_resource_ids The collection of resources you want to fetch the permissios for
  #
  # @optional [Integer] owner The user-id that will be set as owner for the defined MediaResources
  #
  # @optional [Array] users A collection of users that get the defined access for the defined MediaResources
  # @optional [Hash] users[] A hash representing a user-permission
  # @optional [Integer] users[].id The id of a specific user
  # @optional [Boolean] users[].view The view permission to set for the specified user and the defined MediaResources
  # @optional [Boolean] users[].download The download permission to set for the specified user and the defined MediaResources
  # @optional [Boolean] users[].edit The edit permission to set for the specified user and the defined MediaResources
  # @optional [Boolean] users[].manage The manage permission to set for the specified user and the defined MediaResources
  #
  # @optional [Array] groups A collection of groups that get the defined access for the defined MediaResources
  # @optional [Hash] group[] A hash representing a group-permission
  # @optional [Integer] groups[].id The id of a specific group
  # @optional [Boolean] groups[].view The view permission to set for the specified group and the defined MediaResources
  # @optional [Boolean] groups[].download The download permission to set for the specified group and the defined MediaResources
  # @optional [Boolean] groups[].edit The edit permission to set for the specified group and the defined MediaResources
  # @optional [Boolean] groups[].manage The manage permission to set for the specified group and the defined MediaResourc
  #
  # @optional [Hash] public The permission hash to set for public.
  # @optional [Boolean] public[].view The public view permission to set for the defined MediaResources
  # @optional [Boolean] public[].download The public download permission to set for the defined MediaResources
  # @optional [Boolean] public[].edit The public edit permission to set for the defined MediaResources
  #
  # @example_request {"media_resources_ids": [1,2,3], "owner": 15} Sets the owner for the MediaResources 1,2 and 3 to the user with id 15
  # @example_response "" (empty response body with status: 200 OK)
  #
  # @example_request {"media_resources_ids": [1,2,3], "users": [{"id": 191, "edit": false, "manage": false, "download": true}]} Sets the permissions for the user with id 191 for the MediaResources with id 1,2 and 3. It doent touches the view permissions (because the information is not delivered) and sets edit and manage to false, but download to true.
  # @example_response "" (empty response body with status: 200 OK)
  #
  # @example_request {"media_resources_ids": [1,2,3], "groups": [{"id": 231, "view": true}]} Sets the permissions for the group with id 231 for the MediaResources with id 1,2 and 3. It just sets the view-permission to true and doesnt touch the other pemissions.
  # @example_response "" (empty response body with status: 200 OK)
  #
  # @example_request {"media_resources_ids": [1,2,3], "public": {"view": true}} Sets the public-permissions for the MediaResources with id 1,2 and 3. It just sets the view-permission to true and doesnt touch the other pemissions.
  # @example_response "" (empty response body with status: 200 OK)
  #
  def update

    require 'set'

    ActiveRecord::Base.transaction do

      params[:users]= (params[:users] or [])
      params[:groups]= (params[:groups] or [])

      media_resource_ids = Set.new params[:media_resource_ids].map{|i| i.to_i}
      affected_user_ids=  Set.new params[:users].map{|up| up["id"].to_i}
      affected_group_ids=  Set.new params[:groups].map{|gp| gp["id"].to_i}

      # destroy deleted or no more wanted user_permissions
      media_resource_ids.each do |mr_id| 
        existing_up_user_ids = Set.new Userpermission.where("media_resource_id= ?",mr_id).map(&:user_id)
        (existing_up_user_ids - affected_user_ids).each do |uid|
          Userpermission.where("media_resource_id= ?",mr_id).where("user_id = ?",uid).first.destroy
        end
      end

      # create or update userpermission 
      media_resource_ids.each do |mr_id| 
        params[:users].each do |newup| 
          uid= newup[:id].to_i
          up = Userpermission.where("media_resource_id= ?",mr_id).where("user_id = ?",uid).first || (Userpermission.new user_id: uid, media_resource_id: mr_id)
          up.update_attributes! newup.select{|k,v| v == true || v == false}
        end
      end

      # destroy deleted or no more wanted group_permissions
      media_resource_ids.each do |mr_id| 
        existing_gp_group_ids = Set.new Grouppermission.where("media_resource_id= ?",mr_id).map(&:group_id)
        (existing_gp_group_ids - affected_group_ids).each do |gid|
          Grouppermission.where("media_resource_id= ?",mr_id).where("group_id = ?",gid).first.destroy
        end
      end

      # create or update grouppermission 
      media_resource_ids.each do |mr_id| 
        params[:groups].each do |newup| 
          uid= newup[:id].to_i
          up = Grouppermission.where("media_resource_id= ?",mr_id) \
            .where("group_id = ?",uid).first || (Grouppermission.new group_id: uid, media_resource_id: mr_id)
          up.update_attributes! newup.select{|k,v| v == true || v == false}
        end
      end

      #update public permissions
      if params[:public] 
        media_resource_ids.each do |mr_id|
          MediaResource.find(mr_id).update_attributes! \
            params[:public].select{|k,v| (Constants::ACTIONS.include? k.to_sym) and (v == true or v == false)}
        end
      end

      #update owner
      if owner_id= (params[:owner] and params[:owner].to_i)
        media_resource_ids.each do |mr_id|
          MediaResource.find(mr_id).update_attributes! user_id: owner_id
        end
      end


    end

    respond_to do |format|
      format.html 
      format.json { render :json => {} }
    end

  end

end
