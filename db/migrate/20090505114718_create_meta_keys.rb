# -*- encoding : utf-8 -*-
class CreateMetaKeys < ActiveRecord::Migration

  def self.up
    create_table  :meta_keys, :force => true do |t|
      t.string    :label
      t.string    :object_type
      t.boolean   :is_dynamic, :null => true
    end
    change_table    :meta_keys do |t|
      t.index       :label, :unique => true
    end
  end

  def self.down
    drop_table :meta_keys
  end

end
