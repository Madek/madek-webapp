require 'application_responder'

class ApplicationController < ActionController::Base
  include AuthorizationSetup
  include Modules::VerifyAuthorized
  include Concerns::ControllerHelpers
  include Concerns::MadekCookieSession
  include Concerns::RespondersSetup
  include Errors

  before_action :set_locale_for_app

  # use pundit to make sure all actions are authorized
  after_action :verify_authorized, except: :index
  # TODO: after_action :verify_policy_scoped

  # check if logged in user has accepted the most recent usage terms
  before_action :verify_usage_terms_accepted!

  # this Pundit error is generic and means basically 'access denied'
  rescue_from Pundit::NotAuthorizedError, with: :error_according_to_login_state
  rescue_from Errors::UnauthorizedError, with: :error_according_to_login_state

  # Give views access to these methods:
  helper_method :current_user, :settings, :use_js

  # UI Elements
  append_view_path(Rails.root.join('app', 'ui_elements'))

  # CRSF protection with explicit Error raising, otherwise it looks like "no user"
  protect_from_forgery with: :exception

  # i18n setup:
  # for all generated URLs, set language param if it's not the default
  def default_url_options(options = {})
    return options if I18n.locale == I18n.default_locale
    { lang: I18n.locale }.merge(options)
  end

  # this is always run first (`before_action` hook)
  def set_locale_for_app
    Rails.configuration.i18n.default_locale = AppSetting.default_locale
    Rails.configuration.i18n.available_locales = AppSetting.available_locales
    I18n.locale = params[:lang] || I18n.default_locale
    # presenters need to know about set default_url_options from controller
    Presenter.instance_eval do
      def default_url_options(options = {})
        return options if I18n.locale == I18n.default_locale
        { lang: I18n.locale }.merge(options)
      end
    end

    # TMP: data for application layout.
    #      it's already a presenter, but we can't `include` it everyhwere yet
    @app_layout_data = Presenters::AppView::LayoutData.new(user: current_user)
  end

  def root
    skip_authorization # as we are doing our own auth here
    if authenticated?
      redirect_to(my_dashboard_path)
    else
      @get = Presenters::Explore::ExploreLoginPage.new(
        current_user, settings, show_login: true)
      respond_with @get
    end
  end

  def status
    skip_authorization
    render plain: 'OK, but we need to provide memory usage info ' \
                  'as Inshape is no longer compatible'
  end

  def settings
    @_settings ||= Pojo.new(
      Settings.to_h # from static files
      .merge(AppSettings.first.try(:attributes).to_h)) # from DB
  end

  def current_user
    return @_current_user if defined?(@_current_user)
    if (user = validate_services_session_cookie_and_get_user)
      # reflect uberadmin mode in user.admin object instance var (Presenters etc)
      if user.admin?
        user.admin.webapp_session_uberadmin_mode = session[:uberadmin_mode]
      end
    end
    @_current_user = user
    user
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

  Madek::UserPrecaching.start_pre_caching_loop

end
