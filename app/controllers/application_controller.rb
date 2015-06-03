require 'application_responder'

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html, :json, :yaml # TODO: is this safe for all controllers?

  include Concerns::MadekSession
  include Errors
  include Pundit

  # this Pundit error is generic and means basically 'access denied'
  rescue_from Pundit::NotAuthorizedError,
              with: :reraise_according_to_login_state

  # Give views access to these methods:
  helper_method :current_user

  # UI Elements
  append_view_path(Rails.root.join('app', 'ui_elements'))

  protect_from_forgery

  def root
    redirect_to(my_dashboard_path) if authenticated?
  end

  # private # <- would be nice but breaks test

  def current_user
    validate_services_session_cookie_and_get_user
  end

  def authenticated?
    not current_user.nil?
  end

  def reraise_according_to_login_state
    raise (current_user ? Errors::ForbiddenError : Errors::UnauthorizedError)
  end
end
