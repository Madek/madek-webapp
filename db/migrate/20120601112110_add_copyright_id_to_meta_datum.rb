class AddCopyrightIdToMetaDatum < ActiveRecord::Migration
  include MigrationHelpers
  
  def up
    add_column :meta_data, :copyright_id, :integer
    add_index :meta_data, :copyright_id

    fkey_cascade_on_delete ::MetaDatum, ::Copyright
  end


  def down
    remove_column :meta_data, :copyright_id
  end

end
