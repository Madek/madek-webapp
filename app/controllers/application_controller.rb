class ApplicationController < ActionController::Base
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

  private

  def authenticate_user!
    unless authenticated?
      flash[:error] = 'Bitte loggen Sie sich ein!'
      raise Errors::UnauthorizedError, 'Not logged in'
    end
  end
end
