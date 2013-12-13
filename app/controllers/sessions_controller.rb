class SessionsController < ActionController::Base

  def sign_in
    begin 
      @user = User.find_by login: params[:login].try(&:downcase)
      unless @user.authenticate params[:password] 
        raise "Password didn't match"
      else
        session[:user_id] = @user.id
        redirect_to my_dashboard_path, flash: {success: "Sie haben sich abgemeldet."}
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
