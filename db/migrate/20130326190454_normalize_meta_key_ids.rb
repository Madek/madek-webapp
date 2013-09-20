class NormalizeMetaKeyIds < ActiveRecord::Migration

  def up

    add_column :meta_key_definitions, :meta_key_label, :string
    add_column :meta_keys_meta_terms, :meta_key_label, :string
    add_column :meta_data, :meta_key_label, :string

    execute <<-SQL
      UPDATE meta_key_definitions SET meta_key_label = meta_keys.label
        FROM meta_keys
        WHERE meta_keys.id = meta_key_id;

      UPDATE meta_keys_meta_terms SET meta_key_label = meta_keys.label
        FROM meta_keys
        WHERE meta_keys.id = meta_key_id;
        
      UPDATE meta_data SET meta_key_label = meta_keys.label
        FROM meta_keys
        WHERE meta_keys.id = meta_key_id;
    SQL


    remove_foreign_key :meta_key_definitions, :meta_keys
    remove_foreign_key :meta_data, :meta_keys
    remove_foreign_key :meta_keys_meta_terms, :meta_keys

    remove_column :meta_key_definitions, :meta_key_id
    remove_column :meta_keys_meta_terms, :meta_key_id
    remove_column :meta_data, :meta_key_id
    remove_column :meta_keys, :id

    rename_column :meta_keys, :label, :id
    execute "ALTER TABLE meta_keys ADD PRIMARY KEY (id)"

    rename_column :meta_key_definitions, :meta_key_label, :meta_key_id
    add_index :meta_key_definitions, :meta_key_id

    rename_column :meta_keys_meta_terms, :meta_key_label, :meta_key_id
    add_index :meta_keys_meta_terms, :meta_key_id

    rename_column :meta_data, :meta_key_label, :meta_key_id
    add_index :meta_data, :meta_key_id

    add_foreign_key :meta_key_definitions, :meta_keys
    add_foreign_key :meta_data, :meta_keys
    add_foreign_key :meta_keys_meta_terms, :meta_keys
  end

  def down
    raise "Irreversible migration"
  end
end
