# -*- encoding : utf-8 -*-
class MetaDataController < ApplicationController

  before_filter :pre_load
  before_filter :authorized?

  layout "meta_data"

  def index
    @meta_data = @resource.meta_data_for_context(@context, false)
    respond_to do |format|
      format.js { render :layout => (params[:layout] != "false") }
    end
  end

  def objective
    @meta_data = @resource.media_file.meta_data_without_binary.sort
  end

#################################################################

  def edit_multiple
    meta_data = @resource.meta_data_for_context(@context)
    respond_to do |format|
      format.js { render :partial => "edit_multiple_without_form", :locals => {:context => @context, :meta_data => meta_data } }
    end
  end

  def update_multiple
    if @resource.update_attributes(params[:resource], current_user)
      flash[:notice] = "Die Änderungen wurden gespeichert."
    else
      flash[:error] = "Die Änderungen wurden nicht gespeichert."
    end

    respond_to do |format|
      format.html {
        if @resource.is_a? Snapshot
          redirect_to snapshots_path
        else
          redirect_to @resource
        end
      }
    end
  end

#################################################################

  private

  def authorized?
    true
    action = request[:action].to_sym
    case action
      when :index, :objective
        action = :view
      when :edit, :update, :edit_multiple, :update_multiple
        action = :edit
    end
    resource = @resource
    not_authorized! unless Permissions.authorized?(current_user, Constants::Actions.old2new(action), resource) # TODO super ??
  end

  def pre_load
      @resource = if not params[:media_entry_id].blank?
                    MediaEntry.find(params[:media_entry_id])
                  elsif not params[:media_set_id].blank?
                    MediaSet.find(params[:media_set_id])
                  elsif not params[:snapshot_id].blank?
                    Snapshot.find(params[:snapshot_id])
                  end
      
      @context = MetaContext.find(params[:context_id]) unless params[:context_id].blank?
      @context ||= MetaContext.core
  end

end
