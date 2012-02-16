# -*- encoding : utf-8 -*-
class Admin::MediaEntriesController < Admin::AdminController

  def import
  end

  def dropbox
    if request.post?
      AppSettings.dropbox_root_dir = params[:dropbox_root_dir]
      AppSettings.ftp_dropbox_server = params[:ftp_dropbox_server]
      AppSettings.ftp_dropbox_login = params[:ftp_dropbox_login]
      AppSettings.ftp_dropbox_password = params[:ftp_dropbox_password]
      flash[:notice] = "Updated"
    end
  end

end
