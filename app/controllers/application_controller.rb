require 'application_responder'

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html, :json, :yaml # TODO: is this safe for all controllers?

  include Concerns::MadekSession
  include Errors

  # Give views access to these methods:
  helper_method :current_user

  # UI Elements
  append_view_path(Rails.root.join('app', 'ui_elements'))

  protect_from_forgery

  before_action :authenticate_user!, except: [:root, :login, :login_successful]

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

  private

  def authenticate_user!
    unless authenticated?
      flash[:error] = 'Bitte loggen Sie sich ein!'
      raise Errors::UnauthorizedError, 'Not logged in'
    end
  end
end
