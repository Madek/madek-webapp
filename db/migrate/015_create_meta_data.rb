class CreateMetaData < ActiveRecord::Migration

  def up

    create_table :meta_data do |t|

      t.integer :copyright_id      
      t.integer :media_resource_id, null: false
      t.integer :meta_key_id, null: false      

      t.string  :type              
      t.text :string           

    end

    change_table :meta_data do |t| 
      t.index :copyright_id
      t.index [:media_resource_id, :meta_key_id]
      t.index :meta_key_id
    end

    add_foreign_key :meta_data, :media_resources, dependent: :delete
    add_foreign_key :meta_data, :meta_keys 

  end

  def down
    drop_table :meta_data
  end

end
