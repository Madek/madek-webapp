class CreateMetaContextGroups < ActiveRecord::Migration
  include MigrationHelpers

  def up 
    create_table :meta_context_groups do |t|
      t.string :name
    end
    add_column :meta_contexts, :meta_context_group_id, :integer
    add_index :meta_context_groups, :name, unique: true
    add_fkey_referrence_constraint MetaContext, MetaContextGroup
  end

  def down 
    remove_column :meta_contexts, :meta_context_group_id
    drop_table :meta_context_groups
  end

end
