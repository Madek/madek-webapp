# -*- encoding : utf-8 -*-
class Admin::CopyrightsController < Admin::AdminController

  before_filter do
    unless (params[:copyright_id] ||= params[:id]).blank?
      @copyright = Copyright.find(params[:copyright_id])
    end
  end

#####################################################

  def index
    @copyrights = Copyright.all
  end

  def new
    @copyright = Copyright.new
    respond_to do |format|
      format.js
    end
  end

  def create
    Copyright.create(params[:copyright])
    redirect_to admin_copyrights_path
  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def update
    @copyright.update_attributes(params[:copyright])
    respond_to do |format|
      format.js { render partial: "show", locals: {copyright: @copyright} }
    end
  end

  def destroy
    @copyright.destroy    
    redirect_to admin_copyrights_path
  end

end
