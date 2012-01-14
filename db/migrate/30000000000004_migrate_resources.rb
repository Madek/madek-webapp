class MigrateResources < ActiveRecord::Migration
  include MigrationHelpers
  include Constants

  def up

    if adapter_is_postgresql?
      execute_sql <<-SQL
      ALTER TABLE media_set_arcs DROP CONSTRAINT media_set_arcs_parent_id_media_sets_fkey;
      ALTER TABLE media_set_arcs DROP CONSTRAINT media_set_arcs_child_id_media_sets_fkey;
      SQL
    end

    drop_table :media_sets
    drop_table :media_entries

    cascade_on_delete :media_set_arcs,  :media_resources, :parent_id
    cascade_on_delete :media_set_arcs, :media_resources, :child_id


   end

  def down

  end

end
