class FinalizeMetaTermsToVocables < ActiveRecord::Migration
  def change

    remove_foreign_key :meta_data, :meta_keys
    add_foreign_key :meta_data, :meta_keys, dependent: :delete

    remove_foreign_key :meta_key_definitions, :meta_keys
    add_foreign_key :meta_key_definitions, :meta_keys, dependent: :delete

    execute "DROP TABLE meta_keys_meta_terms CASCADE"
    execute "DROP TABLE meta_terms CASCADE"

    MetaKey.where(meta_datum_object_type: 'MetaDatum::Vocables', vocabulary_id: nil).delete_all

  end
end
