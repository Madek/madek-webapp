class AddUsersCountToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :users_count, :integer, default: 0, null: false

    Group.reset_users_count
  end
end
