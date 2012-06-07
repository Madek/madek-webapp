class TheLastMetaDataMigration < ActiveRecord::Migration

  def up
    MetaKey.update_all({meta_datum_object_type: 'MetaDatumDate'},
                       {object_type: 'Date'})

    remove_column :meta_keys, :object_type
  end

  def down
    add_column :meta_keys, :object_type, :string

    MetaKey.update_all({object_type: 'Date'},
                       {meta_datum_object_type: 'MetaDatumDate'})
  end
end
