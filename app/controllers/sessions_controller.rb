class SessionsController < ActionController::Base
  include MadekCookieSession
  include RedirectBackOr
  include LangParams

  def sign_in
    @user = User.find_by(login: params[:login].try(&:downcase))

    if @user and @user.authenticate params[:password]
      set_madek_session @user, 
        AuthSystem.find_by!(id: 'password'), 
        params[:remember_me].present?
      redirect_back_or my_dashboard_path, success: I18n.t(:app_notice_logged_in)
    else
      destroy_madek_session
      redirect_back_or root_path, error: I18n.t(:app_notice_wrong_credentials)
    end
  end

  def shib_sign_in
    unless Settings.shibboleth_sign_in_enabled == true
      render status: :forbidden, text: I18n.t(:app_notice_shibboleth_not_enabled)
    else
      @last_name = request.env['HTTP_SURNAME'].presence
      @first_name = request.env['HTTP_GIVENNAME'].presence
      @email = request.env['HTTP_MAIL'].try(&:downcase).presence
      unless @last_name && @first_name && @email
        deny_shibboleth_sign_in
      else
        perform_shibboleth_sign_in
      end
    end
  end

  def sign_out
    destroy_madek_session
    reset_session
    redirect_to root_path, notice: I18n.t(:app_notice_logged_out)
  end

  def redirect_for_get_methods
    # sometime users GET the `sign_*` actions due to browser behaviour (refresh, …)
    # redirect instead of showing weird error
    redirect_back_or my_dashboard_path
  end

  private

  def deny_shibboleth_sign_in
    destroy_madek_session
    redirect_back_or(
      root_path(shib_extra_params),
      error: I18n.t(:app_notice_shibboleth_missing_fields))
  end

  def perform_shibboleth_sign_in
    @user = User.find_or_initialize_by email: @email
    @user.password ||= SecureRandom.base64
    @person = shib_sign_in_person
    @person.update! last_name: @last_name, first_name: @first_name
    @user.update! person: @person, email: @email
    auth_system = AuthSystem.find_or_create_by(id: "shibboleth") do |auth_system|
      auth_system.name = "Shibboleth"
    end
    set_madek_session @user, auth_system
    redirect_to(
      my_dashboard_path(shib_extra_params), success: I18n.t(:app_notice_logged_in))
  end

  def shib_sign_in_person
    if @user.persisted?
      @user.person
    else
      Person.find_or_initialize_by \
        last_name: @last_name,
        first_name: @first_name, subtype: 'Person'
    end
  end

  def shib_extra_params
    { lang: params['lang'] }
  end

end
