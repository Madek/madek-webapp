class AddTypeToMetaData < ActiveRecord::Migration

  def up
    add_column :meta_data, :type, :string
    execute "UPDATE meta_data SET type = 'MetaDatum'";
  end

  def down
    remove_column :meta_data, :type
  end

end
