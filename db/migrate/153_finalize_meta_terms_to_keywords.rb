class FinalizeMetaTermsToKeywords< ActiveRecord::Migration
  def change

    ActiveRecord::Base.transaction do
      execute "SET session_replication_role = REPLICA"

      execute "UPDATE meta_data" \
        " SET type = 'MetaDatum::Keywords'" \
        " WHERE type = 'MetaDatum::Vocables' "

      execute "UPDATE meta_keys" \
        " SET meta_datum_object_type = 'MetaDatum::Keywords'" \
        " WHERE meta_datum_object_type = 'MetaDatum::Vocables' "

      execute "SET session_replication_role = DEFAULT"
    end

    remove_foreign_key :meta_data, :meta_keys
    add_foreign_key :meta_data, :meta_keys, on_delete: :cascade

    remove_foreign_key :meta_key_definitions, :meta_keys
    add_foreign_key :meta_key_definitions, :meta_keys, on_delete: :cascade

    execute "UPDATE keyword_terms" \
      " SET meta_key_id = 'core:keywords'" \
      " WHERE meta_key_id IS NULL"

    change_column :keyword_terms, :meta_key_id, :string, null: false 

    execute "DROP TABLE meta_keys_meta_terms CASCADE"
    execute "DROP TABLE meta_terms CASCADE"

    MetaKey.where(meta_datum_object_type: 'MetaDatum::Vocables', vocabulary_id: nil).delete_all

  end
end
