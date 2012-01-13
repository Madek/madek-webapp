# -*- encoding : utf-8 -*-
class MetaContextsController < ApplicationController

  before_filter :pre_load

  def index
    @contexts = MetaContext.all
  end

  def show
  end

  def abstract
    @_media_entry_ids = @context.media_entries(current_user).map(&:id)
    respond_to do |format|
      format.js { render :layout => false }
    end
  end

#################################################################

  private

  def pre_load
    params[:context_id] ||= params[:id]
    @context = MetaContext.find(params[:context_id]) unless params[:context_id].blank?
  end

end
