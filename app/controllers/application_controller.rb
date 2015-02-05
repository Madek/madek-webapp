class ApplicationController < ActionController::Base

  # Give views access to these methods:
  helper_method :current_user

  protect_from_forgery

  class AuthorizationError < StandardError # 401 - Not Authorized
  end
  rescue_from AuthorizationError, with: :user_unauthorized_error

  class ForbiddenError < StandardError # 403 - Forbidden
  end
  rescue_from ForbiddenError, with: :user_forbidden_error

  before_action :authenticate, except: [:root, :login, :login_successful]

  def root
    redirect_to(my_dashboard_path) if authenticated?
  end

  # private # <- would be nice but breaks test

  def current_user
    User.find_by_id session[:user_id]
  end

  def authenticated?
    not current_user.nil?
  end

  def authenticate
    authenticated? \
      or redirect_to :root, flash: {
        error: 'Bitte loggen Sie sich ein!'
      }
  end

  private

  def user_unauthorized_error
    render 'public/401.html', status: 401, layout: false
  end

  def user_forbidden_error
    render 'public/403.html', status: 403, layout: false
  end
end
