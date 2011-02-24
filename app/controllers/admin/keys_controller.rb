# -*- encoding : utf-8 -*-
class Admin::KeysController < Admin::AdminController

  before_filter :pre_load

  def index
    @keys = MetaKey.order(:label)
  end

  def new
    @key = MetaKey.new
    respond_to do |format|
      format.js
    end
  end

  def create
    MetaKey.create(params[:meta_key])
    redirect_to admin_keys_path    
  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def update
    @key.update_attributes(params[:meta_key])
    redirect_to admin_keys_path
  end

  def destroy
    @key.destroy if @key.meta_key_definitions.empty?
    redirect_to admin_keys_path
  end

#####################################################

  def mapping
    @graph = MetaKeyDefinition.keymapping_graph
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

#####################################################

  private

  def pre_load
      params[:key_id] ||= params[:id]
      @key = MetaKey.find(params[:key_id]) unless params[:key_id].blank?
  end

end
