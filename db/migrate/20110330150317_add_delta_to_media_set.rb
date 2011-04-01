class AddDeltaToMediaSet < ActiveRecord::Migration
  def self.up
    add_column :media_sets, :delta, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :media_sets, :delta
  end
end
