class SessionsController < ActionController::Base
  include Concerns::MadekCookieSession
  include Concerns::RedirectBackOr
  include Concerns::LangParams

  def sign_in
    @user = User.find_by(login: params[:login].try(&:downcase))

    if @user and @user.authenticate params[:password]
      set_madek_session @user, params[:remember_me].present?
      redirect_back_or my_dashboard_path, success: 'Sie haben sich angemeldet.'
    else
      destroy_madek_session
      redirect_back_or root_path, error: 'Falscher Benutzername/Passwort.'
    end
  end

  def shib_sign_in
    unless Settings.shibboleth_sign_in_enabled == true
      render status: :forbidden, text: 'Sibboleth sign in is not enabled!'
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
    redirect_back_or root_path(shib_extra_params), error:
      'Shibboleth authentication data is incomplete. ' \
      'SURNAME, GIVENNAME and EMAIL are required fields! '
  end

  def perform_shibboleth_sign_in
    @user = User.find_or_initialize_by email: @email
    @user.password ||= SecureRandom.base64
    @person = shib_sign_in_person
    @person.update_attributes! last_name: @last_name, first_name: @first_name
    @user.update_attributes! person: @person, email: @email
    set_madek_session @user, true
    redirect_to(
      my_dashboard_path(shib_extra_params), success: 'Sie haben sich angemeldet.')
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
