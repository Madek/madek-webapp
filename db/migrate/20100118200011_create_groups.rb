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
  end

  def self.down
    drop_table :groups_users
    drop_table :groups
  end
end
