class RemoveDeltaColumns < ActiveRecord::Migration
  def up
    change_table :media_entries do |t|
      t.remove :delta
    end

    change_table :media_sets do |t|
      t.remove :delta
    end

    change_table :people do |t|
      t.remove :delta
    end
  end

  def down
    change_table :media_entries do |t|
      t.boolean :delta, :null => false, :default => true 
    end

    change_table :media_sets do |t|
      t.boolean :delta, :null => false, :default => true 
    end

    change_table :people do |t|
      t.boolean :delta, :null => false, :default => true 
    end
  end
end
