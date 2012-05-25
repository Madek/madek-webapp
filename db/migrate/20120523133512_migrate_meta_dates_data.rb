require 'migration_helpers/meta_datum'
class MigrateMetaDatesData < ActiveRecord::Migration

  def up
    MigrationHelpers::MetaDatum.migrate_meta_dates
  end

  def down
    # raise "this is a irreversible migration"
  end

end
