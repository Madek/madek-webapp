# -*- encoding : utf-8 -*-
class CreatePreviews < ActiveRecord::Migration
  def self.up
    create_table :previews, :force => true do |t|
      t.belongs_to :media_file
      t.string     :filename
      t.string     :content_type
      t.integer    :height
      t.integer    :width
      t.string    :thumbnail
      t.timestamps
    end
    change_table :previews do |t|
      t.index :media_file_id
    end

  end

  def self.down
    drop_table :previews
  end
end
