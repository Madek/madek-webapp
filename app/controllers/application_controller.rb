# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  #FE# before_filter { headers['Access-Control-Allow-Origin'] = '*' }

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
      if @already_redirected
        # do nothing
      elsif session[:return_to]
        redirect_back_or_default('/')
      else
        # TODO refactor to UsersController#show and dry with ResourcesController#index
        params[:per_page] ||= PER_PAGE.first

        paginate_options = {:page => params[:page], :per_page => params[:per_page].to_i}
        resources = current_user.viewable_media_resources
        
        my_resources = resources.by_user(current_user).paginate(paginate_options)
        @my_media_entries = { :pagination => { :current_page => my_resources.current_page,
                                              :per_page => my_resources.per_page,
                                              :total_entries => my_resources.total_entries,
                                              :total_pages => my_resources.total_pages },
                             :entries => my_resources.as_json(:user => current_user, :with_thumb => true) } 
        
        other_resources = resources.not_by_user(current_user).paginate(paginate_options)
        @other_media_entries = { :pagination => { :current_page => other_resources.current_page,
                                                  :per_page => other_resources.per_page,
                                                  :total_entries => other_resources.total_entries,
                                                  :total_pages => other_resources.total_pages },
                                 :entries => other_resources.as_json(:user => current_user, :with_thumb => true) } 

        respond_to do |format|
          format.html { render :template => "/users/show" }
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
      format.js { render :json => {error: msg}, :status => 500}
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

    # TODO remove this when public open
    elsif (request[:controller] == "media_sets" and request[:action] == "show") or
          (request[:controller] == "media_entries" and request[:action] == "image")
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
  
  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

end
