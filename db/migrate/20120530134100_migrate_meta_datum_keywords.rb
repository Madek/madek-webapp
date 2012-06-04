class MigrateMetaDatumKeywords < ActiveRecord::Migration
  def up
    MigrationHelpers::MetaDatum.migrate_meta_datum_keywords
  end

  def down
    # raise "this is a irreversible migration"
  end
end
