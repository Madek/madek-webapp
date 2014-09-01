class RenameMetaDepartmentsToInstitutionalGroups < ActiveRecord::Migration
  def up
    rename_table :meta_data_meta_departments, :meta_data_institutional_groups
    rename_column :meta_data_institutional_groups, :meta_department_id, :institutional_group_id
    execute "UPDATE groups SET type = 'InstitutionalGroup' WHERE type = 'MetaDepartment'"
  end

  def down
    rename_table :meta_data_institutional_groups, :meta_data_meta_departments
    rename_column :meta_data_institutional_groups, :institutional_group_id, :meta_department_id
    execute "UPDATE groups SET type = 'MetaDepartment' WHERE type = 'InstitutionalGroup'"
  end
end
