class SessionsController < ActionController::Base
  include Concerns::MadekSession

  def sign_in
    @user = User.find_by(login: params[:login].try(&:downcase))

    if @user and @user.authenticate params[:password]
      set_madek_session @user, params[:remember_me].present?
      redirect_back_or_default my_dashboard_path,
                               flash: { success: 'Sie haben sich angemeldet.' }
    else
      destroy_madek_session
      redirect_to root_path, flash: { error: 'Falscher Benutzername/Passwort.' }
    end
  end

  def sign_out
    destroy_madek_session
    reset_session
    flash[:notice] = 'Sie haben sich abgemeldet.'
    redirect_to root_path
  end

  private

  def redirect_back_or_default(default, flash_hash)
    redirect_to session[:return_to] || default, flash_hash
    session[:return_to] = nil
  end

end
