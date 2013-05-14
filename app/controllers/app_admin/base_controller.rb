#encoding: utf-8

class AppAdmin::BaseController < ApplicationController
  before_filter :authenticate_admin_user!
  layout 'app_admin'

  def enter_uberadmin
    session[:act_as_uberadmin] = true
    redirect_to :back, flash: {warning: "Sie sind nun im Überadmin-Modus."}
  end

  def exit_uberadmin 
    session[:act_as_uberadmin] = false
    redirect_to :back, flash: {success: "Sie haben den Überadmin-Modus verlassen."}
  end

end
