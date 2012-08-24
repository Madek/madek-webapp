class CreateMetaContexts < ActiveRecord::Migration
  def up
    create_table :meta_contexts do |t|

      t.integer :label_id, null: false
      t.integer :description_id
      t.integer :meta_context_group_id

      t.boolean :is_user_interface, default: false
      t.integer :position
      t.string  :name

    end

    add_index :meta_contexts, :name, unique: true
    add_index :meta_contexts, :position

    add_foreign_key :meta_contexts, :meta_context_groups
    add_foreign_key :meta_contexts, :meta_terms, column: :description_id
    add_foreign_key :meta_contexts, :meta_terms, column: :label_id

  end
 
  def down
    drop_table :meta_contexts
  end
end
