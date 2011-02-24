# -*- encoding : utf-8 -*-
class CreateEditSessions < ActiveRecord::Migration
  def self.up
    create_table    :edit_sessions, :force => true do |t|
      t.belongs_to  :resource, :polymorphic => true
      t.belongs_to  :user
      t.timestamps # TODO t.datetime    :created_at
    end
  
    change_table    :edit_sessions do |t|
      t.index       [:resource_id, :resource_type, :created_at], :name => "index_on_resource_and_created_at"
      t.index       :user_id
    end
  end

  def self.down
    drop_table      :edit_sessions
  end
end
