class ApplicationController < ActionController::Base

  protect_from_forgery

  before_filter :authenticated?, except: :root

  def root
  end

  def current_user
    User.find_by_id session[:user_id]
  end

  def authenticated?
    current_user or redirect_to :root
  end

end
