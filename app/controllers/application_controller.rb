class ApplicationController < ActionController::Base

  protect_from_forgery

  def root
  end

  def current_user
    User.find session[:user_id]
  end

end
