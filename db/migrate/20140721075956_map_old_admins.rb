class MapOldAdmins < ActiveRecord::Migration
  def up
    (group= Group.find_by(name: 'Admin')) and group..users.each do |user|
      AdminUser.create!(user: user)
    end
  end

  def down
    admin_group = Group.find_by(name: 'Admin')
    AdminUser.all.each do |admin_user|
      admin_group.users << admin_user.user
    end
    AdminUser.delete_all
  end
end
