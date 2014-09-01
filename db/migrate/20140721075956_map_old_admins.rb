class MapOldAdmins < ActiveRecord::Migration
  class ::Group < ActiveRecord::Base
    self.inheritance_column= nil
    has_and_belongs_to_many :users
    def self.reset_users_count
      ::Group.all.each do |group|
        group.update_attributes(users_count: group.users.count)
      end
    end
  end


  def up
    (group= Group.find_by(name: 'Admin')) and group.users.each do |user|
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
