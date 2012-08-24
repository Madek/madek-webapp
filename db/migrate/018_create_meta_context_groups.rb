class CreateMetaContextGroups < ActiveRecord::Migration

  def up 
    create_table :meta_context_groups do |t|
      t.string :name
      t.integer :position, null: false, default: 0
    end

    add_index :meta_context_groups, :name, unique: true
    add_index :meta_context_groups, :position

  end

  def down 
    drop_table :meta_context_groups
  end

end
