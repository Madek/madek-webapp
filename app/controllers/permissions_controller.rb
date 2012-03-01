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
  # @example_response {"public":{"view":[],"edit":[],"download":[]},"you":{"view":[1],"edit":[1],"download":[1],"manage":[1]}} This response asserts that the public cannot view the MediaResources (with id 1,2 and three) but that you can view the MediaResource with id 1
  #
  # @example_request {"media_resources_ids": [1,2,3], "with": {"users": true}} Request the setted permissions for the media resources with id 1,2 and 3. This Request adds all users to the respond that have the same permissions than you 
  # @example_response
  # 
  # @example_request {"media_resources_ids": [1,2,3], "with": {"users": true, "groups": true}} Request the setted permissions for the media resources with id 1,2 and 3. This Request adds all users to the respond that have the same permissions than you 
  # @example_response 
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


=begin oldcode      
#old#  layout "meta_data"

  before_filter do
    action = case request[:action].to_sym
      when :index
        :view
      when :edit_multiple, :update_multiple
        :manage
    end

    begin
      if request.fullpath == "/upload/permissions"
        @resources = current_user.incomplete_media_entries
        @layout = "upload"
      elsif (not params[:media_entry_id].blank?) and (not params[:media_entry_id].to_i.zero?)
        @resource = MediaEntry.accessible_by_user(current_user, action).find(params[:media_entry_id])
      elsif not params[:media_entry_ids].blank?
        selected_ids = params[:media_entry_ids].split(",").map{|e| e.to_i }
        @resources = MediaEntry.accessible_by_user(current_user, action).find(selected_ids)
      elsif not params[:media_set_id].blank? # TODO accept multiple media_set_ids ?? 
        selected_ids = [params[:media_set_id].to_i]
        @resources = MediaSet.accessible_by_user(current_user, action).find(selected_ids)
        @resource = @resources.first # OPTIMIZE
      else
        flash[:error] = "Sie haben keine Medieneinträge ausgewählt."
        redirect_to :back
      end
    rescue
      not_authorized!
    end

    unless (params[:permission_id] ||= params[:id]).blank?
      @permission = @resource.permissions.find(params[:permission_id])
    end

  end

#########################################################

  # TODO refactor to index action
  def edit_multiple
    if @resource
      permissions =  {}
  
      permissions[:public] = {:name => "Öffentlich", :type => 'nil'}.merge(
        Constants::Actions.inject({}) do |acc,action|
          acc.merge( action => (@resource.send action))
        end)
  
      permissions["Group"] = @resource.grouppermissions.map do |grouppermission|
        {name: grouppermission.group.name, id: grouppermission.group.id, type: "Group"}.merge(
        Constants::Actions.inject({}) do |acc,action|
          acc.merge( action => (grouppermission.send action))
        end)
      end
  
      permissions["User"] = @resource.userpermissions.map do |userpermission|
        {name: userpermission.user.name, id: userpermission.user.id, type: "User"}.merge(
          Constants::Actions.inject(Hash.new) do |acc,action|
            acc.merge( action => (userpermission.send action))
          end)
      end
  
      @permissions_json = permissions.to_json
  
      respond_to do |format|
        format.html
        format.js { render :partial => "edit_multiple" }
      end

    elsif @resources

      @permissions_json = begin 
        actions = [:view, :edit, :download, :manage]
        combined_permissions = {"User" => [], "Group" => [], "public" => {}}
        combined_permissions.keys.each do |type|
          case type
            when "User"
              subject_permissions = @resources.flat_map(&:userpermissions)
              subject_permissions.map(&:user).uniq.each do |subject|
                subject_info = {:id => subject.id, :name => subject.to_s, :type => type}
                actions.each do |key|
                  subject_info[key] = case subject_permissions.select {|p| p.user_id == subject.id and p.send(key) }.size #1504#
                    when @resources.size
                      true
                    when 0
                      false
                    else
                      :mixed
                  end  
                end
                combined_permissions[type] << subject_info
              end
            when "Group"
              subject_permissions = @resources.flat_map(&:grouppermissions)
              subject_permissions.map(&:group).uniq.each do |subject|
                subject_info = {:id => subject.id, :name => subject.to_s, :type => type}
                actions.each do |key|
                  subject_info[key] = case subject_permissions.select {|p| p.group_id == subject.id and p.send(key) }.size #1504#
                    when @resources.size
                      true
                    when 0
                      false
                    else
                      :mixed
                  end  
                end
                combined_permissions[type] << subject_info
              end
            else
              combined_permissions[type][:type] = "nil"
              combined_permissions[type][:name] = "Öffentlich"
              actions.each do |key|
                combined_permissions[type][key] = if @resources.all? {|x| x.send(key) }
                  true
                elsif @resources.any? {|x| x.send(key) }    
                  :mixed
                else
                  false
                end  
              end
          end
        end
        combined_permissions.to_json
      end
  
      @resources_json = @resources.map do |r|
        r.attributes.merge!(r.get_basic_info(current_user))
      end.to_json

      respond_to do |format|
        format.html { render :action => "edit_batch", :layout => (@layout || true) }
      end
    end
  end


  # NOTE by Tom: we delete everything and recreated it with new permissions,
  # this is apparently not very smart; However, the clientside is involved and
  # I just keep it this way for now
  def update_multiple
    ActiveRecord::Base.transaction do
      @resources.each do |resource|

        params[:subject]["nil"].each do |s_action,s_bool| 
          resource.send("#{s_action}=", s_bool == "true")
        end
        resource.save!

        resource.userpermissions.destroy_all
        params[:subject][:User] and  params[:subject][:User].each do |s_id,s_actions|
          Userpermission.create media_resource: resource, user: (User.find s_id), 
            view: (s_actions[:view] == "true"), download: (s_actions[:download] == "true"), edit: (s_actions[:edit] == "true")
        end

        resource.grouppermissions.destroy_all
        params[:subject][:Group] and  params[:subject][:Group].each do |s_id,s_actions|
          Grouppermission.create media_resource: resource, group: (Group.find s_id),  
            view: (s_actions[:view] == "true"), download: (s_actions[:download] == "true"), edit: (s_actions[:edit] == "true")
        end

      end
      flash[:notice] = "Die Zugriffsberechtigungen wurden erfolgreich gespeichert." unless @resources.any? {|x| x.is_a? MediaEntryIncomplete }
    end

    if @resources.any? {|x| x.is_a? MediaEntryIncomplete }
      redirect_to edit_upload_path
    elsif (@resources.size == 1)
      redirect_to @resources.first
    else
      redirect_back_or_default(resources_path)
    end
  end
=end

end
