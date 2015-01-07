class RemoveColumnsGroupUsersCount < ActiveRecord::Migration
  def change
    remove_column :groups, :users_count, :integer
  end
end
