class AddPositionToMetaContextGroupsAndMetaContexts < ActiveRecord::Migration
  def self.up
    change_table :meta_context_groups do |t|
      t.integer :position, :null => false, :default => 0
      t.index :position
    end
    change_table :meta_contexts do |t|
      t.integer :position
      t.index :position
    end
  end

  def self.down
    change_table :meta_context_groups do |t|
      t.remove :position
    end
    change_table :meta_contexts do |t|
      t.remove :position
    end
  end
end
