# -*- encoding : utf-8 -*-
class CreateMetaContexts < ActiveRecord::Migration
  def self.up
    create_table :meta_contexts do |t|
      t.string  :label
      t.boolean :is_user_interface, :default => false
    end
    change_table    :meta_contexts do |t|
      t.index       :label
    end

  end

  def self.down
    drop_table :meta_contexts
  end
end
