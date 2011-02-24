# -*- encoding : utf-8 -*-
class CreateMediaFiles < ActiveRecord::Migration
  def self.up
    create_table :media_files do |t|
      t.string      :guid
      t.text        :meta_data

      t.string  :content_type
      t.string  :filename
      t.integer :size
      t.integer :height # should not be here
      t.integer :width  # should not be here
      t.string  :job_id

      t.timestamps
    end
  end

  def self.down
    drop_table :media_files
  end
end
