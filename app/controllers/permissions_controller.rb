# -*- encoding : utf-8 -*-
class PermissionsController < ApplicationController

  before_filter :pre_load
  before_filter :authorized?

  layout "meta_data"

  def index
    respond_to do |format|
      format.js { render :layout => (params[:layout] != "false") }
    end
  end
  
#################################################################

  def edit_multiple
    theme "madek11"
    permissions = Permission.cached_permissions_by(@resource)
    @permissions_json = {}
    
    permissions.group_by {|p| p.subject_type }.collect do |type, type_permissions|
      unless type.nil?
        @permissions_json[type] = type_permissions.map {|p| {:id => p.subject.id, :name => p.subject.to_s, :type => type, :view => p.actions[:view], :edit => p.actions[:edit], :hi_res => p.actions[:hi_res] }}
      else
        p = type_permissions.first
        @permissions_json["public"] = {:name => "Öffentlich", :type => 'nil', :view => p.actions[:view], :edit => p.actions[:edit], :hi_res => p.actions[:hi_res] }
      end
    end
    @permissions_json = @permissions_json.to_json
    
    respond_to do |format|
      format.html
      format.js { render :partial => "edit_multiple" }
    end
  end

  def update_multiple
    @resources.each do |resource|
      resource.permissions.delete_all
  
      actions = params[:subject]["nil"]
      resource.permissions.build(:subject => nil).set_actions(actions)

      ["User", "Group"].each do |key|
        params[:subject][key].each_pair do |subject_id, actions|
          resource.permissions.build(:subject_type => key, :subject_id => subject_id).set_actions(actions)
        end if params[:subject][key]
      end
      
      # FIXME it's not sure that the current_user is the owner (manager) of the current resource 
      resource.permissions.where(:subject_type => current_user.class.base_class.name, :subject_id => current_user.id).first.set_actions({:manage => true})
    end

    flash[:notice] = "Die Zugriffsberechtigungen wurden erfolgreich gespeichert."  
    if (@resources.size == 1)
      redirect_to @resources.first
    else
      redirect_back_or_default(media_entries_path)
    end
  end

#################################################################

  private

  def authorized?
    action = request[:action].to_sym
    case action
      when :index
        action = :view
      when :edit_multiple
        action = :manage
      when :update_multiple
        not_authorized! if @resources.empty?
        return
    end
    
    # OPTIMIZE if member of a group
    resource = @resource
    not_authorized! unless Permission.authorized?(current_user, action, resource) # TODO super ??
  end

  def pre_load
    # OPTIMIZE remove blank params
    
    if (not params[:media_entry_id].blank?) and (not params[:media_entry_id].to_i.zero?)
      @resource = MediaEntry.find(params[:media_entry_id])
    elsif not params[:media_entry_ids].blank?
      selected_ids = params[:media_entry_ids].split(",").map{|e| e.to_i }
      manageable_ids = Permission.accessible_by_user(MediaEntry, current_user, :manage)
      @resources = MediaEntry.where(:id => (selected_ids & manageable_ids))
    elsif not params[:media_set_id].blank? # TODO accept multiple media_set_ids ?? 
      selected_ids = [params[:media_set_id].to_i]
      manageable_ids = Permission.accessible_by_user(Media::Set, current_user, :manage)
      @resources = Media::Set.where(:id => (selected_ids & manageable_ids))
    else
      flash[:error] = "Sie haben keine Medieneinträge ausgewählt."
      redirect_to :back
    end

    params[:permission_id] ||= params[:id]
    @permission = @resource.permissions.find(params[:permission_id]) unless params[:permission_id].blank?
  end

end
