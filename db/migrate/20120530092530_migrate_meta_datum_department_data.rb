class MigrateMetaDatumDepartmentData < ActiveRecord::Migration
  def up
    MigrationHelpers::MetaDatum.migrate_meta_datum_departments
  end

  def down
    # raise "this is a irreversible migration"
  end
end
