class AddCopyrightIdToMetaDatum < ActiveRecord::Migration
  def change
    add_column :meta_data, :copyright_id, :integer
    add_index :meta_data, :copyright_id
  end
end
