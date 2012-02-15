# -*- encoding : utf-8 -*-
class Admin::MediaSetsController < Admin::AdminController
  
  before_filter do
    unless (params[:media_set_id] ||= params[:id]).blank?
      @set = MediaSet.find(params[:media_set_id])
    end
  end

#####################################################

  def index
    @sets = MediaSet.all
  end

  def new
    @set = MediaSet.new
    respond_to do |format|
      format.js
    end
  end

  def create
    type = params[:media_set].delete(:type)
    set = MediaSet.create(:user => current_user)
    set.update_attributes(params[:media_set])
    redirect_to admin_media_sets_path
  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def update
    if params[:individual_contexts] and @set.respond_to? :individual_contexts
      @set.individual_contexts = MetaContext.find(params[:individual_contexts])
    end
    
    @set.update_attributes(params[:media_set])
    
    unless params[:new_manager_user_id].blank?
      user = User.find(params[:new_manager_user_id])
      Permission.assign_manage_to(user, @set, !!params[:with_media_entries])
    end
    
    redirect_to admin_media_sets_path
  end

  def destroy
    @set.destroy if @set.media_entries.empty?
    redirect_to admin_media_sets_path
  end

#####################################################

  def special
    if request.post?
      AppSettings.featured_set_id = params[:featured_set_id].to_i
      AppSettings.splashscreen_slideshow_set_id = params[:splashscreen_slideshow_set_id].to_i
      redirect_to special_admin_media_sets_path
    else
      @featured_set_id = AppSettings.featured_set_id
      @splashscreen_slideshow_set_id = AppSettings.splashscreen_slideshow_set_id
      @media_sets = MediaSet.where(:view => true)
    end
  end
  
end
