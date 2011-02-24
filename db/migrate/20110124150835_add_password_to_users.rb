class AddPasswordToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :password, :string
  end

  def self.down
    remove_column :users, :password
  end
end
