class AddUsersCountToGroups < ActiveRecord::Migration

  class ::Group < ActiveRecord::Base
    self.inheritance_column= nil
    has_and_belongs_to_many :users
    def self.reset_users_count
      ::Group.all.each do |group|
        group.update_attributes(users_count: group.users.count)
      end
    end
  end

  def change
    add_column :groups, :users_count, :integer, default: 0, null: false

    Group.reset_users_count
  end
end
