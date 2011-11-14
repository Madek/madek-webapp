# -*- encoding : utf-8 -*-
class ResourcesController < ApplicationController

  # TODO cancan # load_resource #:class => "MediaResource"

  def index
    params[:per_page] ||= PER_PAGE.first

    resources = MediaResource.accessible_by_user(current_user)
    resources = resources.by_user(@user) if params[:user_id] and (@user = User.find(params[:user_id]))
    resources = resources.not_by_user(current_user) if params[:not_by_current_user]
    resources = resources.favorites_for_user(current_user) if request.fullpath =~ /favorites/
    resources = resources.search(params[:query]) unless params[:query].blank?
    resources = resources.paginate(:page => params[:page], :per_page => params[:per_page].to_i)

    @resources = { :pagination => { :current_page => resources.current_page,
                                   :per_page => resources.per_page,
                                   :total_entries => resources.total_entries,
                                   :total_pages => resources.total_pages },
                  :entries => resources.as_json(:user => current_user) } 

    respond_to do |format|
      format.html
      format.js { render :json => @resources }
    end
  end
  
  def filter_panel
    resources = MediaResource.accessible_by_user(current_user)
    @_media_entry_ids = resources.search(params[:query]).media_entries.map(&:id)

    respond_to do |format|
      format.js { render :layout => false}
    end
  end

end
