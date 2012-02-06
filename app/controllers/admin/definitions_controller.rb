# -*- encoding : utf-8 -*-
class Admin::DefinitionsController < Admin::AdminController

  before_filter :pre_load

  def index
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def new
    @definition = @context.meta_key_definitions.build
    respond_to do |format|
      format.js
    end
  end

  def create
    # OPTIMIZE define position on MetaKeyDefinition#before_save
    @context.meta_key_definitions.create(params[:meta_key_definition].merge(:position => @context.next_position))
    redirect_to admin_contexts_path
  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def update
    @definition.update_attributes(params[:meta_key_definition])
    redirect_to admin_contexts_path
  end

  def destroy
    @definition.destroy
    redirect_to admin_contexts_path
  end

#####################################################

  def reorder
    MetaKeyDefinition.transaction do
      # OPTIMIZE workaround for the mysql uniqueness [meta_context_id, position]
      @context.meta_key_definitions.update_all("position = (position*-1)", ["id IN (?)", params[:definition]])
      
      # using update_all (instead of update) to avoid instantiating (and validating) the object
      params[:definition].each_with_index do |id, index|
        @context.meta_key_definitions.update_all(["position = ?", index+1], ["id = ?", id])
      end
    end

    respond_to do |format|
      format.js { render :nothing => true }
    end
  end

#####################################################

  private

  def pre_load
    @context = MetaContext.find(params[:context_id])
    unless (params[:definition_id] ||= params[:id]).blank?
      @definition = @context.meta_key_definitions.find(params[:definition_id])
    end
  end

end
