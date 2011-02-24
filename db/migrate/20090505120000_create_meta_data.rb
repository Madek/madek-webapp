# -*- encoding : utf-8 -*-
class CreateMetaData < ActiveRecord::Migration
  def self.up
    create_table    :meta_data do |t|
      t.belongs_to  :resource, :polymorphic => true
      t.belongs_to  :meta_key
      t.text        :value # serialized
    end
    change_table  :meta_data do |t|
      t.index [:resource_id, :resource_type, :meta_key_id], :unique => true
      t.index :meta_key_id
    end
    
  end
  
  def self.down
    drop_table :meta_data
  end
end
