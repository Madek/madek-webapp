class OptimizingIndexes < ActiveRecord::Migration
  def self.up

    change_table :media_entries do |t|
      t.index :updated_at
      t.index :delta
    end

    change_table :media_sets do |t|
      t.index :updated_at
    end

    change_table :meta_keys do |t|
      t.index :object_type
    end

    change_table :people do |t|
      t.index :firstname
      t.index :lastname
      t.index :delta
    end

    change_table :upload_sessions do |t|
      t.index :created_at
    end

  end

  def self.down
  end
end
