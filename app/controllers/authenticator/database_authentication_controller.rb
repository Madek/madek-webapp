require 'digest/sha1'

# This authenticator is an evil hack, mostly to enable testing with Cucumber
# since we can't use the ZHdK Authentication Gateway then.
# Must build a person for each user that is to be valid.


class Authenticator::DatabaseAuthenticationController < ApplicationController

  def login
    if request.post?
      crypted_password = Digest::SHA1.hexdigest(params[:password])
      user = User.where(:login => params[:login], :password => crypted_password).first
      if user
        session[:user_id] = user.id
        redirect_to root_path
      else
        flash[:notice] = _("Invalid username/password")
        render :layout => false
      end
    else
      render :layout => false
    end


  end
  
  def logout
    reset_session
    flash[:notice] = "Du hast dich abgemeldet." 
    redirect_to root_path
  end

  
#   def change_password
#     if request.post?
#       d = DatabaseAuthentication.find_or_create_by_login(params[:dbauth])
#       d.update_attributes(params[:dbauth])
#       d.password_confirmation = d.password
#       unless d.save
#         flash[:error] = d.errors.full_messages
#       else
#         flash[:notice] = _("Password changed")
#       end
#       render :update do |page|
#         page.replace_html 'flash', flash_content
#         flash.discard
#       end
#     end
# 
#   end

end

