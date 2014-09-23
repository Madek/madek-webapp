class RenameMetaDatumDepartmentsToMetaDatumInstitutionalGroups < ActiveRecord::Migration
  def up
    execute "UPDATE meta_data SET type = 'MetaDatumInstitutionalGroups' WHERE type = 'MetaDatumDepartments'"
    execute %Q{
      UPDATE meta_keys SET meta_datum_object_type = 'MetaDatumInstitutionalGroups'
      WHERE meta_datum_object_type = 'MetaDatumDepartments'
    }
  end

  def down
    execute "UPDATE meta_data SET type = 'MetaDatumDepartments' WHERE type = 'MetaDatumInstitutionalGroups'"
    execute %Q{
      UPDATE meta_keys SET meta_datum_object_type = 'MetaDatumDepartments'
      WHERE meta_datum_object_type = 'MetaDatumInstitutionalGroups'
    }
  end
end
