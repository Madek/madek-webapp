class SessionsController < ActionController::Base
  include Concerns::MadekSession

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

  def sign_out
    destroy_madek_session
    reset_session
    redirect_to root_path, notice: 'Sie haben sich abgemeldet.'
  end

  private

  def redirect_back_or(default, flash_hash = {})
    # does a redirect and searches target in this order
    # - the referer of the request (prefered!)
    # - route given in argument (as fallback, therefore required)
    # - a target manually set in the session (used as last resort for edge cases)
    redirect_to \
      session[:return_to] || request.referer || default, flash: flash_hash
    session[:return_to] = nil # clear this in any case
  end

end
