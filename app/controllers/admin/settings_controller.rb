# -*- encoding : utf-8 -*-
class Admin::SettingsController < Admin::AdminController

  def dropbox
    if request.post?
      AppSettings.dropbox_root_dir = params[:dropbox_root_dir]
      AppSettings.ftp_dropbox_server = params[:ftp_dropbox_server]
      AppSettings.ftp_dropbox_user = params[:ftp_dropbox_user]
      AppSettings.ftp_dropbox_password = params[:ftp_dropbox_password]
      flash[:notice] = "Updated"
    end
  end
  
  def authentications
    if request.post?
      AppSettings.authentication_systems = Array(params[:authentication_systems]).map{|x| x.to_sym}
      flash[:notice] = "Updated"
    end
  end

end
