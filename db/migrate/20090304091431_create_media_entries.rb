# -*- encoding : utf-8 -*-
  class CreateMediaEntries < ActiveRecord::Migration
  def self.up
    create_table    :media_entries, :force => true do |t|
      t.belongs_to  :upload_session
      t.belongs_to  :media_file
      
      t.boolean     :delta, :null => false, :default => true 
      t.timestamps
    end
    
    change_table    :media_entries do |t|
      t.index       :upload_session_id
      t.index       :media_file_id
    end
  end

  def self.down
    drop_table      :media_entries
  end
end
