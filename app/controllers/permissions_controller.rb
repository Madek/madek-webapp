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

#################################################################

  private

  def authorized?
    action = request[:action].to_sym
    case action
      when :index
        action = :view
      else
        action = :manage
    end
    
    # OPTIMIZE if member of a group
    resource = @resource
    not_authorized! unless Permission.authorized?(current_user, action, resource) # TODO super ??
  end

  def pre_load
    # OPTIMIZE remove blank params
    
    if not params[:media_entry_id].blank?
      @resource = MediaEntry.find(params[:media_entry_id])
    else
      redirect_to root_path
    end

    params[:permission_id] ||= params[:id]
    @permission = @resource.permissions.find(params[:permission_id]) unless params[:permission_id].blank?
  end

end
