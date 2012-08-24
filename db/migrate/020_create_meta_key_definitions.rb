class CreateMetaKeyDefinitions < ActiveRecord::Migration
  def up
    create_table :meta_key_definitions do |t|

      t.integer :description_id  
      t.integer :hint_id         
      t.integer :label_id        

      t.integer :meta_context_id, null: false
      t.integer :meta_key_id, null: false     

      t.boolean :is_required , default: false 
      t.integer :length_max      
      t.integer :length_min            
      t.integer :position , null: false
      t.string  :key_map           
      t.string  :key_map_type          

      t.timestamps
    end

    add_index :meta_key_definitions, [:meta_context_id,:position], unique: true
    add_index :meta_key_definitions, :meta_key_id

    add_foreign_key :meta_key_definitions, :meta_keys
    add_foreign_key :meta_key_definitions, :meta_terms, column: :description_id
    add_foreign_key :meta_key_definitions, :meta_terms, column: :hint_id
    add_foreign_key :meta_key_definitions, :meta_terms, column: :label_id

  end

  def down
    drop_table :meta_key_definitions
  end
end
