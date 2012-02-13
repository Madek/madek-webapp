# -*- encoding : utf-8 -*-
class Admin::MediaEntriesController < Admin::AdminController

  def import
  end

  def dropbox
    if request.post?
      AppSettings.dropbox_root_dir = params[:root_dir]
      flash[:notice] = "Updated"
    end
    @dropbox_root_dir = AppSettings.dropbox_root_dir
  end

end
