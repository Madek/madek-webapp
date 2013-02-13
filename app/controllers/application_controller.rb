# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  #FE# before_filter { headers['Access-Control-Allow-Origin'] = '*' }

  protect_from_forgery # See ActionController::RequestForgeryProtection for details

##############################################
# Authentication

  before_filter :set_gettext_locale, :login_required, :except => [:login, :login_successful, :logout, :feedback, :login_and_return_here] # TODO :help

  helper_method :current_user, :logged_in? 

  def logged_in?
    !!current_user
  end

  def current_user
    @current_user ||= login_from_session
  end

########################################################
# Admin Authentication 

  def authenticate_admin_user!
    unless current_user and Group.find_by_name("Admin").users.include? current_user
      flash[:error] = "Sie sind kein Administrator."
      redirect_to root_path
    else
      true
    end
  end

  def set_gettext_locale
    I18n.locale = "de_CH".to_sym
  end


##############################################

  def root
    if logged_in? and not current_user.is_guest?
      if @already_redirected
        # do nothing
      elsif session[:return_to]
        redirect_back_or_default('/')
      else
        redirect_to my_dashboard_path
      end
    else
      @splashscreen_set = MediaSet.splashscreen
      @splashscreen_set_children = @splashscreen_set.child_media_resources.accessible_by_user(current_user).shuffle if @splashscreen_set
      @featured_set = MediaSet.featured
      @featured_set_children = @featured_set.child_media_resources.accessible_by_user(current_user).ordered_by(:updated_at).limit(6) if @featured_set
      @catalog_set = MediaSet.catalog
      @catalog_set_categories = @catalog_set.categories.accessible_by_user(current_user).limit(3) if @catalog_set
      @latest_media_entries = MediaResource.media_entries.accessible_by_user(current_user).ordered_by(:created_at).limit(12)
    end
  end

  def help
  end

  def feedback
    @title = "Medienarchiv der Künste: Feedback & Support"
    @disable_search = true
  end

  def login_and_return_here
    store_location URI::parse(request.referrer).request_uri
    redirect_to login_path
  end

##############################################
  protected

  def not_authorized!
    msg = "Sie haben nicht die notwendige Zugriffsberechtigung." #"You don't have appropriate permission to perform this operation."
    respond_to do |format|
      format.html { flash[:error] = msg
                    redirect_to (request.env["HTTP_REFERER"] ? :back : my_dashboard_path)
                  }
      format.json { render :json => {error: msg}, :status => 500}
    end
  end

##############################################
  private

  def login_required
    unless logged_in?
      store_location
      flash[:error] = "Bitte melden Sie sich an."
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
      self.current_user = user = User.find_by_id(session[:user_id])

      # request format can be nil!
      if not (request[:controller] == "media_resources" and request[:action] == "image") and (request.format and request.format.to_sym != :json)
        check_usage_terms_accepted 
      end

    elsif request.format.to_sym == :json or
          (request[:controller] == "media_resources" and request[:action] == "image") or 
          (request[:controller] == "media_resources" and request[:action] == "show") or
          (request[:controller] == "media_resources" and request[:action] == "index") or
          (request[:controller] == "explore") or 
          (request[:controller] == "application" and request[:action] == "root") or 
          (request[:controller] == "media_entries" and request[:action] == "show") or
          (request[:controller] == "media_entries" and request[:action] == "parents") or
          (request[:controller] == "media_entries" and request[:action] == "context_group") or
          (request[:controller] == "media_entries" and request[:action] == "more_data") or
          (request[:controller] == "media_sets" and request[:action] == "show") or 
          (request[:controller] == "media_sets" and request[:action] == "abstract") or
          (request[:controller] == "media_sets" and request[:action] == "parents") or
          (request[:controller] == "media_sets" and request[:action] == "vocabulary") or
          (request[:controller] == "keywords" and request[:action] == "index") or 
          (request[:controller] == "meta_contexts" and request[:action] == "show") or
          (request[:controller] == "search")
      @current_user = user = User.new

    end
    user
  end

  def check_usage_terms_accepted
    return if request[:action].to_sym == :usage_terms # OPTIMIZE
    unless current_user.usage_terms_accepted?
      redirect_to usage_terms_user_path(current_user)
      @already_redirected = true # OPTIMIZE prevent DoubleRenderError
    end
  end

  def store_location(path = nil)
    session[:return_to] = path ? path : request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def do_not_cache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

end
