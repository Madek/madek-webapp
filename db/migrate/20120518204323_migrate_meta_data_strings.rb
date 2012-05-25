require 'migration_helpers/meta_datum'
class MigrateMetaDataStrings < ActiveRecord::Migration

  def up
    MigrationHelpers::MetaDatum.migrate_meta_strings
  end

  def down
    # raise "this is a irreversible migration"
  end


end
