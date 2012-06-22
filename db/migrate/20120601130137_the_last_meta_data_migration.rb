class TheLastMetaDataMigration < ActiveRecord::Migration

  def up
    MetaKey.update_all({meta_datum_object_type: 'MetaDatumDate'},
                       {object_type: 'Date'})

    remove_column :meta_keys, :object_type
    remove_column :meta_data, :value

    MetaDatumString.joins(meta_key: :meta_key_definitions)
      .where(meta_key_definitions: {meta_context_id: MetaContext.io_interface})
      .where("string like '%Binary%'")
      .delete_all

  end

  def down
    add_column :meta_data, :value, :text
    add_column :meta_keys, :object_type, :string

    MetaKey.update_all({object_type: 'Date'},
                       {meta_datum_object_type: 'MetaDatumDate'})
  end
end
