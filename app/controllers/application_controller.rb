# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  #FE# before_filter { headers['Access-Control-Allow-Origin'] = '*' }

  protect_from_forgery # See ActionController::RequestForgeryProtection for details

##############################################
# Redesign Switcher
  layout Proc.new { |controller| if redesign? then "redesign" else "main" end }

  def render(options = nil, extra_options = {}, &block)
    if redesign? and request.format == "text/html"
      unless options.has_key?(:template)
        options[:template] = "/redesign/#{params[:controller]}/#{params[:action]}"
      else
        options[:template] = "/redesign#{options[:template]}"
      end
    end
    super(options, extra_options, &block)
  end

  def redesign?
    if params.has_key?(:redesign)
      session[:design] = :redesign
    elsif params.has_key?(:resetdesign)
      session.delete :design
    end
    params.has_key?(:redesign) or session[:design] == :redesign
  end

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
        # TODO refactor to UsersController#show as Dashboard
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

##############################################  
  protected

  def not_authorized!
    msg = "Sie haben nicht die notwendige Zugriffsberechtigung." #"You don't have appropriate permission to perform this operation."
    respond_to do |format|
      format.html { flash[:error] = msg
                    redirect_to (request.env["HTTP_REFERER"] ? :back : root_path)
                  } 
      format.json { render :json => {error: msg}, :status => 500}
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
      self.current_user = user = User.find_by_id(session[:user_id])
      check_usage_terms_accepted

    # TODO remove this when public open OR logged in through API
    elsif request.format.to_sym == :json or
          (request[:controller] == "media_resources" and request[:action] == "image")
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

  # send_file() as above seems to be broken in Rails 3.1.3 and onwards?
  # The Rack::Sendfile#call method never seems to receive a body that respons to :to_path, even though it SHOULD,
  # therefore Sendfile is never triggered (!!), that's why we need this hacked Sendfile header implementation
  def fixed_send_file(path, options = {})
    headers["Content-Type"] = options[:type]
    headers["Content-Disposition"] = "attachment; filename=\"#{options[:filename]}\""
    headers["X-Sendfile"] = path.to_s
    headers["Content-Length"] = '0'
    render :nothing => true
  end


end
