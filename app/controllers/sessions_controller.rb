class SessionsController < ActionController::Base
  include Concerns::SetSession
  
  class PasswordMismatch < Exception
  end

  def sign_in
    begin 
      @user = User.find_by login: params[:login].try(&:downcase)
      unless @user.try(:authenticate, params[:password])
        raise PasswordMismatch
      else
        set_madek_session @user
        redirect_back_or_default my_dashboard_path, flash: {success: "Sie haben sich angemeldet."}
      end
    rescue PasswordMismatch
      redirect_to root_path, flash: {error: "Falscher Benutzername/Passwort."} 
    end
  end

  def sign_out
    reset_session
    flash[:notice] = "Sie haben sich abgemeldet." 
    redirect_to root_path
  end

  def redirect_back_or_default(default, flash)
    redirect_to session[:return_to] || default, flash: flash
    session[:return_to] = nil
  end

end
