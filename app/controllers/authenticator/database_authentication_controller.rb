require 'digest/sha1'

# This authenticator is an evil hack, mostly to enable testing with Cucumber
# since we can't use the ZHdK Authentication Gateway then.
# Must build a person for each user that is to be valid.


class Authenticator::DatabaseAuthenticationController < ApplicationController

  def login
    if request.post?
      if user = User.where(login: params[:login].try(&:downcase)).first and user.authenticate(params[:password])
        session[:user_id] = user.id
      else
        flash[:error] = "Falscher Benutzername/Passwort."
      end
      redirect_to root_path
    else
      render :layout => false
    end
  end
  
  def logout
    reset_session
    flash[:notice] = "Sie haben sich abgemeldet." 
    redirect_to root_path
  end

end

