class AddMetaDatumObjectType < ActiveRecord::Migration
  
  def up
    add_column :meta_keys, :meta_datum_object_type, :string
  end

  def down
    remove_column :meta_keys, :meta_datum_object_type
  end

end
