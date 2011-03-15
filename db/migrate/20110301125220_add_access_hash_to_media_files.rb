class AddAccessHashToMediaFiles < ActiveRecord::Migration
  def self.up
    add_column :media_files, :access_hash, :text
  end

  def self.down
    remove_column :media_files, :access_hash
  end
end
