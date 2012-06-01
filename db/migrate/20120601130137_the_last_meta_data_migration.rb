class TheLastMetaDataMigration < ActiveRecord::Migration

  def up

    execute %Q{
      UPDATE meta_keys SET meta_datum_object_type = 'MetaDatumDate'  WHERE object_type = 'Date';
    }

    remove_column :meta_keys, :object_type

  end

  def down

    add_column :meta_keys, :object_type, :string

    execute %Q{
      UPDATE meta_keys SET object_type = 'Date' WHERE meta_datum_object_type = 'MetaDatumDate'  ;
    }

  end
end
