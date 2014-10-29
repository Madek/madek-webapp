# -*- encoding : utf-8 -*-
class CreatePreviews < ActiveRecord::Migration
  include MigrationHelper

  def change
    create_table :previews, id: :uuid do |t|

      t.uuid :media_file_id, null: false
      t.index :media_file_id

      t.integer    :height
      t.integer    :width
      t.string     :content_type
      t.string     :filename
      t.string     :thumbnail

      t.timestamps null: false

      t.string :media_type, null: false
      t.index :media_type

    end

    add_index :previews, :created_at

    reversible do |dir|
      dir.up do 
        set_timestamps_defaults :media_resources
      end
    end

    add_foreign_key :previews, :media_files , dependent: :delete
  end
end
