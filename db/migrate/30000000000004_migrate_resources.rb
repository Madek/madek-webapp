class MigrateResources < ActiveRecord::Migration
  include MigrationHelpers
  include Constants

  def up

    drop_table :media_sets
    drop_table :media_entries

  end

  def down

  end

end
