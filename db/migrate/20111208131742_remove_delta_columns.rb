class RemoveDeltaColumns < ActiveRecord::Migration
  def up
    remove_column(:media_entries, :delta)
    remove_column(:media_sets, :delta)
    remove_column(:people, :delta)

  end

  def down
    add_column(:media_entries, :delta, :null => false, :default => true)
    add_column(:media_sets, :delta, :null => false, :default => true)
    add_column(:people, :delta, :null => false, :default => true)
    
  end
end
