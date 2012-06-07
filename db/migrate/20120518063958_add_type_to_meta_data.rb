class AddTypeToMetaData < ActiveRecord::Migration

  def up
    add_column :meta_data, :type, :string
  end

  def down
    remove_column :meta_data, :type
  end

end
