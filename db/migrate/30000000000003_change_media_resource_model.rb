class ChangeMediaResourceModel < ActiveRecord::Migration
  include MigrationHelpers
  include Constants

  def up

    change_table :media_resources do |t| 
      t.references :permissionset, null: false, unique: true
      t.index :created_at
      t.index :permissionset_id
    end
    
  end

  def down

    change_table :media_resources do |t| 
      t.remove_index :created_at
      t.remove_index :permissionset_id
      t.remove :permissionset
    end

  end

end
