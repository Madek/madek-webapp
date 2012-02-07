# -*- encoding : utf-8 -*-
class PermissionsController < ApplicationController

  before_filter :pre_load

  layout "meta_data"

  def index
    respond_to do |format|
      format.js { render :layout => (params[:layout] != "false") }
    end
  end


  def edit_multiple
    
    permissions =  {}

    permissions[:public] = {:name => "Öffentlich", :type => 'nil'}.merge(
      Constants::Actions.inject({}) do |acc,action|
      acc.merge( (Constants::Actions.new2old action) => (@resource.send action))
      end)

    permissions["Group"] = @resource.grouppermissions.map do |grouppermission|
      {name: grouppermission.group.name, id: grouppermission.group.id, type: "Group"}.merge(
      Constants::Actions.inject({}) do |acc,action|
        acc.merge( (Constants::Actions.new2old action) => (grouppermission.send action))
      end)
    end

    permissions["User"] = @resource.userpermissions.map do |userpermission|
      {name: userpermission.user.name, id: userpermission.user.id, type: "User"}.merge(
        Constants::Actions.inject(Hash.new) do |acc,action|
        acc.merge( (Constants::Actions.new2old action) => (userpermission.send action))
        end)
    end

    @permissions_json = permissions.to_json

    respond_to do |format|
      format.html
      format.js { render :partial => "edit_multiple" }
    end
  end


  # NOTE by Tom: we delete everything and recreated it with new permissions,
  # this is apparently not very smart; However, the clientside is involved and
  # I just keep it this way for now
  def update_multiple
    ActiveRecord::Base.transaction do
      @resources.each do |resource|

        params[:subject]["nil"].each do |s_action,s_bool| 
          resource.send("#{Constants::Actions.old2new(s_action)}=",s_bool == "true")
        end
        resource.save!

        resource.userpermissions.destroy_all
        params[:subject][:User] and  params[:subject][:User].each do |s_id,s_actions|
          Userpermission.create media_resource: resource, user: (User.find s_id), 
            view: (s_actions[:view] == "true"), download: (s_actions[:hi_res] == "true"), edit: (s_actions[:edit] == "true")
        end

        resource.grouppermissions.destroy_all
        params[:subject][:Group] and  params[:subject][:Group].each do |s_id,s_actions|
          Grouppermission.create media_resource: resource, group: (Group.find s_id),  
            view: (s_actions[:view] == "true"), download: (s_actions[:hi_res] == "true"), edit: (s_actions[:edit] == "true")
        end

      end
      flash[:notice] = "Die Zugriffsberechtigungen wurden erfolgreich gespeichert."  
    end

    if (@resources.size == 1)
      redirect_to @resources.first
    else
      redirect_back_or_default(resources_path)
    end
  end



  private

  def pre_load
    action = case request[:action].to_sym
      when :index
        :view
      when :edit_multiple, :update_multiple
        :manage
    end

    begin
      if (not params[:media_entry_id].blank?) and (not params[:media_entry_id].to_i.zero?)
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

end
