require 'application_responder'
require 'inshape'

class ApplicationController < ActionController::Base
  include Concerns::ControllerHelpers
  include Concerns::MadekCookieSession
  include Concerns::RespondersSetup
  include Errors
  include Pundit
  include Modules::VerifyAuthorized

  # this Pundit error is generic and means basically 'access denied'
  rescue_from Pundit::NotAuthorizedError, with: :error_according_to_login_state
  rescue_from Errors::UnauthorizedError, with: :error_according_to_login_state

  # Give views access to these methods:
  helper_method :current_user, :settings, :use_js

  # UI Elements
  append_view_path(Rails.root.join('app', 'ui_elements'))

  # CRSF protection with explicit Error raising, otherwise it looks like "no user"
  protect_from_forgery with: :exception

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

  def status
    skip_authorization
    memory_status = InShape::Memory.status
    render json: { memory: memory_status.content }, \
           status: memory_status.is_ok ? 200 : 499
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

  def id_param
    params.require(:id)
  end
end
