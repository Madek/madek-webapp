# -*- encoding : utf-8 -*-
class CreateUploadSessions < ActiveRecord::Migration
  def self.up
    create_table    :upload_sessions, :force => true do |t|
      t.belongs_to  :user
      t.timestamps # TODO t.datetime    :created_at
    end
  
    change_table    :upload_sessions do |t|
      t.index       :user_id
    end
  end

  def self.down
    drop_table      :upload_sessions
  end
end
