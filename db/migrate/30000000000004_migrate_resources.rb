class MigrateResources < ActiveRecord::Migration
  include MigrationHelpers
  include Constants

  def up

    execute_sql <<-SQL
      ALTER TABLE media_set_arcs DROP CONSTRAINT media_set_arcs_parent_id_media_sets_fkey;
      ALTER TABLE media_set_arcs DROP CONSTRAINT media_set_arcs_child_id_media_sets_fkey;
    SQL

    drop_table :media_sets
    drop_table :media_entries


   end

  def down

  end

end
