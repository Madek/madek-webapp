class RemoveDropboxFromAppSettings < ActiveRecord::Migration
  def change
    remove_column :app_settings, :dropbox_root_dir
    remove_column :app_settings, :ftp_dropbox_server 
    remove_column :app_settings, :ftp_dropbox_user
    remove_column :app_settings, :ftp_dropbox_password
  end
end
