# -*- encoding : utf-8 -*-
class CreateCopyrights < ActiveRecord::Migration
  def up

    create_table :copyrights do |t|
      t.boolean :is_default, :default => false
      t.boolean :is_custom, :default => false
      t.string :label

      t.belongs_to :parent  
      t.integer :lft        
      t.integer :rgt        

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

  def down
    drop_table :copyrights
  end

end
