# -*- encoding : utf-8 -*-

class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name
    end
    create_table :groups_users, :id => false do |t|
      t.belongs_to :group
      t.belongs_to :user
    end
    change_table :groups_users do |t|
      t.index [:group_id, :user_id], :unique => true
      t.index :user_id
    end

    sql = <<-SQL
      ALTER TABLE groups_users ADD CONSTRAINT group_id_fkey
        FOREIGN KEY (group_id) REFERENCES groups (id) ON DELETE CASCADE; 
      ALTER TABLE groups_users ADD CONSTRAINT user_id_fkey
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE; 
    SQL
    sql.split(/;\s*$/).each {|cmd| execute cmd} if SQLHelper.adapter_is_mysql?
    execute sql if SQLHelper.adapter_is_postgresql?

  end

  def self.down
    drop_table :groups_users
    drop_table :groups
  end
end
