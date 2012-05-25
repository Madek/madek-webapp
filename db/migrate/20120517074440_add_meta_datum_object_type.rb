class AddMetaDatumObjectType < ActiveRecord::Migration
  
  def up
    add_column :meta_keys, :meta_datum_object_type, :string

    execute <<-SQL
      UPDATE meta_keys
        SET meta_datum_object_type = 'MetaDatumString'
        WHERE object_type is NULL OR object_type = 'MetaCountry';
    SQL

    execute <<-SQL
      UPDATE meta_keys
        SET meta_datum_object_type = 'MetaDatumDate'
        WHERE object_type = 'MetaDate';
    SQL

  end

  def down
    remove_column :meta_keys, :meta_datum_object_type
  end

end
