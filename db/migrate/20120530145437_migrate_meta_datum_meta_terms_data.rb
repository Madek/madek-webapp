class MigrateMetaDatumMetaTermsData < ActiveRecord::Migration
  def up
    MigrationHelpers::MetaDatum.migrate_meta_datum_meta_terms
  end

  def down
    # raise "this is a irreversible migration"
  end
end
