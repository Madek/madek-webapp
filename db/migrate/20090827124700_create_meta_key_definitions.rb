# -*- encoding : utf-8 -*-
class CreateMetaKeyDefinitions < ActiveRecord::Migration
  def self.up
    create_table    :meta_key_definitions do |t|
      t.belongs_to  :meta_context
      t.belongs_to  :meta_key
      t.text        :field      # serialized
      t.integer     :position, :null => false
      t.string      :key_map
      t.string      :key_map_type
      t.timestamps
    end
    change_table    :meta_key_definitions do |t|
      t.index [:meta_context_id, :position], :unique => true
      t.index :meta_key_id
    end    
  end

  def self.down
    drop_table :meta_key_definitions
  end
end
