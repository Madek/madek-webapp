class SessionsController < ActionController::Base

  include Concerns::SetSession

  def sign_in
    @user = User.find_by login: params[:login].try(&:downcase)

    if @user.authenticate params[:password]
      set_madek_session @user
      redirect_back_or_default my_dashboard_path, flash: { success: 'Sie haben sich angemeldet.' }
    else
      redirect_to root_path, flash: { error: 'Falscher Benutzername/Passwort.' }
    end
  end

  def sign_out
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
