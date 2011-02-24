# -*- encoding : utf-8 -*-
class CreateSnapshots < ActiveRecord::Migration
  def self.up
    create_table :snapshots do |t|
      t.belongs_to :media_entry
      t.belongs_to :media_file

      t.timestamps
    end
    change_table :snapshots do |t|
      t.index [:media_entry_id, :created_at]
      t.index :media_file_id
    end
  end

  def self.down
    drop_table :snapshots
  end
end
