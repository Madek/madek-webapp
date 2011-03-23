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

  def create
    subject = if params[:user_id]
      User.find(params[:user_id])
    elsif params[:group_id]
      Group.find(params[:group_id])
    else
      nil
    end

    if subject.nil? or Permission.cached_permissions_by(@resource).collect(&:subject).include?(subject) #tmp# @resource.permissions
      respond_to do |format|
        format.js { render :nothing => true, :status => 204 }
      end
    else
      permission = @resource.permissions.build(:subject => subject)
      permission.set_actions({:view => true, :edit => false, :hi_res => false})
      respond_to do |format|
        format.js { render :partial => "/permissions/edit", :object => permission, :as => :permission }
      end
    end
  end

  def update
    value = case params[:checked]
    when "true"
      case params[:value]
        when "logged_in_users"
          :logged_in_users
        else
          true
      end
    else
      false
    end
    @permission.set_actions({params[:key].to_sym => value})
    respond_to do |format|
      format.js #{ render :nothing => true } # TODO :status => (... ? 200 : 500)
    end
  end

  def destroy
    @permission.destroy
    respond_to do |format|
      format.js { render :nothing => true, :status => (@permission.destroyed? ? 200 : 500) } #{ render :partial => 'index', :locals => {:resource => @resource} }
    end
  end
  
#################################################################

  def edit_multiple
    respond_to do |format|
      format.html
      format.js { render :layout => (params[:layout] != "false") }
    end
  end

  def update_multiple
    default_params = {:view => false, :edit => false}
    params.reverse_merge!(default_params)

    view_action, edit_action = case params[:view].to_sym
                                  when :private
                                    [default_params[:view], default_params[:edit]]
                                  when :logged_in_users
                                    [:logged_in_users, (!!params[:edit] ? :logged_in_users : false)]
                                  when :public
                                    [true, !!params[:edit]]
                                  else
                                    [default_params[:view], default_params[:edit]]
                                end

    @resource.default_permission.set_actions({:view => view_action, :edit => edit_action})
    flash[:ajax_notice] = "Änderungen gespeichert"

    respond_to do |format|
#      format.html { redirect_to @resource }
      format.js {
        render :action => :edit_multiple, :layout => false
      }
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
    elsif not params[:media_set_id].blank?
      @resource = Media::Set.find(params[:media_set_id]) 
    else
      redirect_to root_path
    end

    params[:permission_id] ||= params[:id]
    @permission = @resource.permissions.find(params[:permission_id]) unless params[:permission_id].blank?
  end

end
