class RenameMetaDataGroupsAssociationTable < ActiveRecord::Migration
  def up

    execute "ALTER TABLE meta_data_institutional_groups DROP CONSTRAINT meta_data_institutional_groups_institutional_group_id_fk"
    execute "ALTER TABLE meta_data_institutional_groups DROP CONSTRAINT meta_data_institutional_groups_meta_datum_id_fk"

    rename_table :meta_data_institutional_groups, :meta_data_groups 
    rename_column :meta_data_groups, :institutional_group_id, :group_id

    add_foreign_key :meta_data_groups, :meta_data, dependent: :delete
    add_foreign_key :meta_data_groups, :groups, column: :group_id, dependent: :delete

  end
end
