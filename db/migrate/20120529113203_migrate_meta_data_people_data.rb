class MigrateMetaDataPeopleData < ActiveRecord::Migration
  def up
    MigrationHelpers::MetaDatum.migrate_meta_people
  end

  def down
    # raise "this is a irreversible migration"
  end

end
