# -*- encoding : utf-8 -*-
class MetaDataController < ApplicationController

  layout "meta_data"

  before_filter do
    unless (params[:media_resource_id] ||= params[:media_entry_id] || params[:media_set_id] || params[:snapshot_id]).blank?
      action = case request[:action].to_sym
        when :index, :objective
          :view
        when :edit, :update, :edit_multiple, :update_multiple
          :edit
      end
      
      begin
        @resource = MediaResource.accessible_by_user(current_user, action).find(params[:media_resource_id])
      rescue
        not_authorized!
      end
    end
    
    @context = MetaContext.find(params[:context_id]) unless params[:context_id].blank?
    @context ||= MetaContext.core
  end

#################################################################
  

  def index
    @meta_data = @resource.meta_data_for_context(@context, false)
    respond_to do |format|
      format.js { render :layout => (params[:layout] != "false") }
      format.json { render :template => 'meta_data/index.json.rjson' }
    end
  end

  def objective
    @meta_data = @resource.media_file.meta_data_without_binary.sort
  end

### 
  
  def update 
    @meta_datum = MetaDatum.find(params[:id])

    respond_to do |format|
      if @meta_datum.update_attributes(params[:meta_datum])
        format.json { head :ok }
      else
        format.json { render json: @meta_datum.errors, status: :unprocessable_entity }
      end
    end

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

end
