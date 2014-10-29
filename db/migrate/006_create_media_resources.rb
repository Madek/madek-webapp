# -*- encoding : utf-8 -*-
class CreateMediaResources < ActiveRecord::Migration
  include MigrationHelper


  def change
    create_table :media_resources, id: :uuid do |t|

      t.integer :previous_id 
      t.index :previous_id

      t.boolean :download ,null: false, default: false
      t.boolean :edit     ,null: false, default: false
      t.boolean :manage   ,null: false, default: false
      t.boolean :view     ,null: false, default: false


      t.uuid :user_id, null: false
      t.index :user_id

      t.text :settings  

      t.string  :type
      t.index :type

      t.timestamps null: false
    end

    reversible do |dir|
      dir.up do 
        set_timestamps_defaults :media_resources
        execute "ALTER TABLE media_resources ADD CONSTRAINT edit_on_publicpermissions_is_false CHECK (edit = false); "
        execute "ALTER TABLE media_resources ADD CONSTRAINT manage_on_publicpermissions_is_false CHECK (manage = false); "
      end
    end

    add_index :media_resources, :updated_at
    add_index :media_resources, :created_at

    add_foreign_key :media_resources, :users 

    add_foreign_key :media_files, :media_resources, column: :media_entry_id

  end

end

