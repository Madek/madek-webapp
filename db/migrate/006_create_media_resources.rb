# -*- encoding : utf-8 -*-
class CreateMediaResources < ActiveRecord::Migration

  def up
    create_table :media_resources do |t|

      t.boolean :download ,null: false, default: false
      t.boolean :edit     ,null: false, default: false
      t.boolean :manage   ,null: false, default: false
      t.boolean :view     ,null: false, default: false

      t.integer :media_entry_id 
      t.integer :media_file_id  
      t.integer :user_id, null: false

      t.string  :settings  
      t.string  :type

      t.timestamps
    end

    add_index :media_resources, [:media_entry_id, :created_at]
    add_index :media_resources, :media_file_id
    add_index :media_resources, :type
    add_index :media_resources, :updated_at
    add_index :media_resources, :user_id

    add_foreign_key :media_resources, :users 
    add_foreign_key :media_resources, :media_files, dependent: :delete
    add_foreign_key :media_resources, :media_resources, column: :media_entry_id, dependent: :delete

  end

  def down
    drop_table :media_resources
  end

end

