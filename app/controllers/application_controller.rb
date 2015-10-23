require 'application_responder'

class ApplicationController < ActionController::Base
  include Concerns::ControllerHelpers
  include Concerns::MadekCookieSession
  include Concerns::RespondersSetup
  include Errors
  include Pundit

  # this Pundit error is generic and means basically 'access denied'
  rescue_from Pundit::NotAuthorizedError, with: :error_according_to_login_state
  rescue_from Errors::UnauthorizedError, with: :error_according_to_login_state

  # Give views access to these methods:
  helper_method :current_user, :settings

  # UI Elements
  append_view_path(Rails.root.join('app', 'ui_elements'))

  protect_from_forgery

  def root
    redirect_to(my_dashboard_path) if authenticated?
  end

  def settings
    Pojo.new(
      Settings.to_h # from static files
      .merge(AppSettings.first.attributes)) # from DB
  end

  def current_user
    validate_services_session_cookie_and_get_user
  end

  private

  def authenticated?
    not current_user.nil?
  end

  def error_according_to_login_state
    if authenticated?
      raise Errors::ForbiddenError, 'Acces Denied!'
    else
      raise Errors::UnauthorizedError, 'Please log in!'
    end
  end
end
