class AddMetaKeyUniquenessToMetaData < ActiveRecord::Migration
  def change
    change_table :meta_data do |t|
      t.index [:media_entry_id, :meta_key_id], unique: :true
      t.index [:collection_id, :meta_key_id], unique: :true
      t.index [:filter_set_id, :meta_key_id], unique: :true
    end
  end
end
