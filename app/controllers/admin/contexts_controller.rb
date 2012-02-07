# -*- encoding : utf-8 -*-
class Admin::ContextsController < Admin::AdminController

  before_filter :pre_load

  def index
    hard_sort = %w(io_interface tms core upload media_content media_object copyright zhdk_bereich media_set)
    @contexts = MetaContext.all.sort {|a,b| (hard_sort.index(a.name) || a.id) <=> (hard_sort.index(b.name) || b.id) }
  end

  def new
    @context = MetaContext.new
    respond_to do |format|
      format.js
    end
  end

  def create
    MetaContext.create(params[:meta_context])
    redirect_to admin_contexts_path
  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def update
    @context.update_attributes(params[:meta_context])
    redirect_to admin_contexts_path
  end

  def destroy
    @context.destroy    
    redirect_to admin_contexts_path
  end
  
#####################################################

  private

  def pre_load
    unless (params[:context_id] ||= params[:id]).blank?
      @context = MetaContext.find(params[:context_id])
    end
  end

end
