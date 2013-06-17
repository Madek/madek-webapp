class UseNameAsPkeyOnMetaContexts < ActiveRecord::Migration

  def up

    # meta_key_definitions 

    #rename_column :meta_key_definitions, :meta_context_id, :old_meta_context_id
    add_column :meta_key_definitions, :meta_context_name, :string
    add_index :meta_key_definitions, :meta_context_name

    execute <<-SQL
      UPDATE meta_key_definitions 
      SET meta_context_name= meta_contexts.name
      FROM meta_contexts
      WHERE meta_key_definitions.meta_context_id = meta_contexts.id
    SQL
    remove_column :meta_key_definitions, :meta_context_id

    # media_sets_meta_contexts

    # rename_column :media_sets_meta_contexts, :meta_context_id, :old_meta_context_id
    add_column :media_sets_meta_contexts, :meta_context_name, :string
    add_index :media_sets_meta_contexts, :meta_context_name

    execute <<-SQL
      UPDATE media_sets_meta_contexts 
      SET meta_context_name= meta_contexts.name
      FROM meta_contexts
      WHERE media_sets_meta_contexts.meta_context_id = meta_contexts.id
    SQL
    remove_column :media_sets_meta_contexts, :meta_context_id


    # remove id from meta_contexts ad set fkeys
    remove_column :meta_contexts, :id
    execute "ALTER TABLE meta_contexts ADD PRIMARY KEY (name)"
    add_foreign_key :meta_key_definitions, :meta_contexts, column: :meta_context_name, primary_key: 'name'
    add_foreign_key :media_sets_meta_contexts, :meta_contexts,column: :meta_context_name, primary_key: 'name'

  end

  def down
    raise "irreversible migration"
  end


end
