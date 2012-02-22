# -*- encoding : utf-8 -*-
class ChangeUploadSessions < ActiveRecord::Migration
  def self.up
    change_table :upload_sessions do |t|
      t.boolean :is_complete, :default => false
      t.index   :is_complete
    end
  end

  def self.down
    change_table :upload_sessions do |t|
      t.remove_index  :is_complete
      t.remove        :is_complete
    end
  end
end
