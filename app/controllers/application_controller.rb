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
  helper_method :current_user, :settings, :use_js

  # UI Elements
  append_view_path(Rails.root.join('app', 'ui_elements'))

  protect_from_forgery

  # enable the mini profiler for admins in production
  before_action do
    if defined?(Rack::MiniProfiler) && current_user.try(:admin)
      Rack::MiniProfiler.authorize_request
    end
  end

  def root
    skip_authorization # as we are doing our own auth here
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

  # NOTE: js can be disabled per request for testing
  def use_js
    !((params[:nojs] == '1') || (/NOJSPLZ/.match request.env['HTTP_USER_AGENT']))
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

  # AFTER ACTION HANDLING ############################################

  def verify_authorized_with_special_cases_exclusion
    unless self.class == ConfigurationManagementBackdoorController
      verify_authorized_without_special_cases_exclusion
    end
  end
  alias_method_chain :verify_authorized, :special_cases_exclusion
  after_action :verify_authorized
end
