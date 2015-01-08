class RenameAdminUsersToAdmins < ActiveRecord::Migration
  def change
    rename_table :admin_users, :admins
  end
end
