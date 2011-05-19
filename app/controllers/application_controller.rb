# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base

  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  layout "main"

##############################################  
# Authentication

  before_filter :login_required, :except => [:root, :login, :login_successful, :logout, :feedback, :usage_terms] # TODO :help

  helper_method :current_user, :logged_in?, :_

  def logged_in?
    !!current_user
  end
    
  def current_user
    @current_user ||= login_from_session
  end

##############################################  

  # TODO i18n
  def _(s)
    s
  end

##############################################  

  def root
    if logged_in?
      if session[:return_to]
        redirect_back_or_default('/')
      else
        # TODO refactor to UsersController#show and dry with MediaEntriesController#index
        params[:per_page] ||= PER_PAGE.first
        viewable_ids = current_user.accessible_resource_ids
        @disabled_paginator = true # OPTIMIZE
  
        search_options = {:per_page => (2**30), :star => true }
        paginate_options = {:page => params[:page], :per_page => params[:per_page].to_i}
        all_ids = MediaEntry.by_user(current_user).search_for_ids search_options
        @my_media_entries_paginated_ids = (all_ids & viewable_ids).paginate(paginate_options)
        @my_media_entries_json = Logic.data_for_page(@my_media_entries_paginated_ids, current_user).to_json
        all_ids = MediaEntry.not_by_user(current_user).search_for_ids search_options
        @accessible_media_entries_paginated_ids = (all_ids & viewable_ids).paginate(paginate_options)
        @accessible_media_entries_json = Logic.data_for_page(@accessible_media_entries_paginated_ids, current_user).to_json
        
        respond_to do |format|
          format.html { render :template => "/users/show" }
          format.js { render :partial => "media_entries/index" }
        end
      end
    else
      render :layout => false
    end
  end

  def help
  end

  def feedback
    @title = "Medienarchiv der Künste: Feedback & Support"
    @disable_search = true
  end

  def catalog
  end

##############################################  
  protected

  def not_authorized!
    msg = "Sie haben nicht die notwendige Zugriffsberechtigung." #"You don't have appropriate permission to perform this operation."
    respond_to do |format|
      format.html { flash[:error] = msg
                    redirect_to (request.env["HTTP_REFERER"] ? :back : root_path)
                  } 
      format.js { render :text => msg }
    end
  end

##############################################  
  private
  
  def login_required
    unless logged_in?
      store_location
      flash[:error] = "Bitte anmelden."
      redirect_to root_path
    end
  end

  def current_user=(new_user)
    session[:user_id] = new_user ? new_user.id : nil
    @current_user = new_user || false
  end

  def login_from_session
    user = nil
    if session[:user_id]
      # TODO use find without exception: self.current_user = User.find(session[:user_id])
      self.current_user = user = User.where(:id => session[:user_id]).first
      check_usage_terms_accepted
    end
    user
  end

  def check_usage_terms_accepted
    return if request[:action].to_sym != :usage_terms
    redirect_to usage_terms_user_path(current_user) unless current_user.usage_terms_accepted?
  end
  
  def store_location
    session[:return_to] = request.fullpath.gsub(/\?.*/, "")
    
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

end
