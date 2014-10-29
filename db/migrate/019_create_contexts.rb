class CreateContexts < ActiveRecord::Migration
  def change
    create_table :contexts, id: :string do |t|

      t.string :label, null: false, default: ''
      t.text :description, null: false, default: ''

      t.uuid :context_group_id
      t.index :context_group_id

      t.integer :position
      t.index :position


    end

    add_foreign_key :contexts, :context_groups

  end
 
end
