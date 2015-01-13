class ApplicationController < ActionController::Base

  protect_from_forgery

  class AuthorizationError < StandardError # 401 - Not Authorized
  end
  rescue_from AuthorizationError, with: :user_unauthorized_error

  class ForbiddenError < StandardError # 403 - Forbidden
  end
  rescue_from ForbiddenError, with: :user_forbidden_error

  before_action :authenticated?, except: :root

  def root
  end

  def current_user
    User.find_by_id session[:user_id]
  end

  def authenticated?
    current_user or redirect_to :root
  end

  private

  def user_unauthorized_error
    render 'public/401.html', status: 401, layout: false
  end

  def user_forbidden_error
    render 'public/403.html', status: 403, layout: false
  end
end
