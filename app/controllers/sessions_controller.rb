class SessionsController < ActionController::Base
  include Concerns::SetSession

  def sign_in
    begin 
      @user = User.find_by login: params[:login].try(&:downcase)
      unless @user.authenticate params[:password] 
        raise "Password didn't match"
      else
        set_madek_session @user
        redirect_to my_dashboard_path, flash: {success: "Sie haben sich angemeldet."}
      end
    rescue Exception => e
      redirect_to root_path, flash: {error: "Falscher Benutzername/Passwort."} 
    end
  end

  def sign_out
    reset_session
    flash[:notice] = "Sie haben sich abgemeldet." 
    redirect_to root_path
  end

end
