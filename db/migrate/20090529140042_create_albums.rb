# -*- encoding : utf-8 -*-
class CreateAlbums < ActiveRecord::Migration
  def self.up
    create_table    :albums do |t|
      t.belongs_to  :user
      t.string      :query
      t.boolean     :is_collection, :default => false
      t.timestamps
    end
    change_table    :albums do |t|
      t.index :user_id
      t.index :is_collection
    end

    create_table    :albums_media_entries, :id => false do |t|
      t.belongs_to  :album
      t.belongs_to  :media_entry
    end
    change_table    :albums_media_entries do |t|
      t.index [:album_id, :media_entry_id], :unique => true
    end

    # acts_as_dag
    create_table :album_links do |t|
      t.integer :ancestor_id
      t.integer :descendant_id
      t.boolean :direct
      t.integer :count
    end
    change_table    :album_links do |t|
      t.index       :ancestor_id
      t.index       :descendant_id
    end    

  end

  def self.down
    drop_table :albums_links
    drop_table :albums_media_entries
    drop_table :albums
  end
end
