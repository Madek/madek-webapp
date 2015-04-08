class ApplicationController < ActionController::Base
  include Concerns::MadekSession

  # Give views access to these methods:
  helper_method :current_user

  # UI Elements
  append_view_path(Rails.root.join('app', 'ui_elements'))

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

  # NOTE: This is just a simple way to 'dump' any Presenter as JSON/YAML.
  # For now, it's internal use only;
  # if this gets more serious or complicate, use the 'responders' gem.
  def respond_with_presenter_formats
    if defined?(@get) and @get.is_a?(Presenter)
      respond_to do |format|
        format.html # implicit, picks the right view etc.
        format.json { render json: JSON.pretty_generate(@get.dump) }
        format.yaml { render plain: @get.dump.as_json.to_yaml(line_width: -1) }
      end
    end
  end

  # private # <- would be nice but breaks test

  def current_user
    validate_services_session_cookie_and_get_user
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
    render file: 'public/401.html', status: 401, layout: false
  end

  def user_forbidden_error
    render file: 'public/403.html', status: 403, layout: false
  end
end
