class RenameMetaDataGroupsAssociationTable < ActiveRecord::Migration
  def up

    remove_foreign_key :meta_data_institutional_groups, :institutional_groups
    remove_foreign_key :meta_data_institutional_groups, :meta_data

    rename_table :meta_data_institutional_groups, :meta_data_groups 
    rename_column :meta_data_groups, :institutional_group_id, :group_id

    add_foreign_key :meta_data_groups, :meta_data, on_delete: :cascade
    add_foreign_key :meta_data_groups, :groups, column: :group_id, on_delete: :cascade

  end
end
