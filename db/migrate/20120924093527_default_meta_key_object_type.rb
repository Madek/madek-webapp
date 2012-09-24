class DefaultMetaKeyObjectType < ActiveRecord::Migration

  def change
    change_column :meta_keys, :meta_datum_object_type, :string, null: false, default: "MetaDatumString"
  end

end
