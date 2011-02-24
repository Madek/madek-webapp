# -*- encoding : utf-8 -*-
class Favorites < ActiveRecord::Migration
  def self.up
    create_table :favorites, :id => false do |t|
      t.belongs_to :user
      t.belongs_to :media_entry
    end
    change_table :favorites do |t|
      t.index [:user_id, :media_entry_id], :unique => true
    end
  end

  def self.down
    drop_table :favorites
  end
end
