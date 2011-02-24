# -*- encoding : utf-8 -*-
class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.belongs_to  :subject, :polymorphic => true
      t.belongs_to  :resource, :polymorphic => true
      t.text        :actions_object # serialized
      t.timestamps
    end

    change_table :permissions do |t|
      t.index [:resource_id, :resource_type, :subject_id, :subject_type], :unique => true, :name => "index_permissions_on_resource__and_subject"
      t.index [:subject_id, :subject_type]
      t.index :created_at
    end
    
  end

  def self.down
    drop_table :permissions
  end
end
