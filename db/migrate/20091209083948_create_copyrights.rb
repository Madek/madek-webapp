# -*- encoding : utf-8 -*-
class CreateCopyrights < ActiveRecord::Migration
  def self.up
    create_table :copyrights do |t|
      t.boolean :is_default, :default => false
      t.boolean :is_custom, :default => false
      t.string :label
 # TODO     t.string :definition # TODO serialize ??

      t.belongs_to :parent  # acts_as_nested_set
      t.integer :lft        # acts_as_nested_set
      t.integer :rgt        # acts_as_nested_set

      t.string    :usage
      t.string    :url
    end
    change_table :copyrights do |t|
      t.index :is_default
      t.index :is_custom
      t.index :label, :unique => true
      t.index :parent_id
      t.index [:lft, :rgt]
    end

  end

  def self.down
    drop_table :copyrights
  end
end
