require Rails.root.join "db","migrate","uuid_migration_helper"
class UuidAsPkeyForMediaResource < ActiveRecord::Migration
  include ::UuidMigrationHelper


  def up
    enable_extension 'uuid-ossp'

    remove_column :media_resources, :media_entry_id

    # the visualization has id's stored; but is is just a cache anyways
    execute %[ DELETE FROM visualizations ]


    prepare_table 'media_resources'

    migrate_foreign_key 'app_settings', 'media_resources', true, 'catalog_set_id'
    migrate_foreign_key 'app_settings', 'media_resources', true, 'featured_set_id'
    migrate_foreign_key 'app_settings', 'media_resources', true, 'splashscreen_slideshow_set_id'
    migrate_foreign_key 'edit_sessions', 'media_resources'
    migrate_foreign_key 'full_texts', 'media_resources'
    migrate_foreign_key 'grouppermissions', 'media_resources'
    migrate_foreign_key 'media_files', 'media_resources', true, 'media_entry_id'
    migrate_foreign_key 'media_resource_arcs', 'media_resources', false, 'child_id'
    migrate_foreign_key 'media_resource_arcs', 'media_resources', false, 'parent_id'
    migrate_foreign_key 'media_sets_meta_contexts', 'media_resources', false, 'media_set_id'
    migrate_foreign_key 'meta_data', 'media_resources'
    migrate_foreign_key 'userpermissions', 'media_resources'
    migrate_foreign_key 'favorites', 'media_resources'

    execute %[ALTER TABLE media_resources DROP CONSTRAINT media_resources_pkey ]
    rename_column :media_resources, :id, :previous_id
    change_column :media_resources, :previous_id, :integer, null: true, default: nil
    execute %[ drop sequence media_resources_id_seq ]
    add_index :media_resources, :previous_id

    rename_column :media_resources, :uuid, :id
    execute %[ALTER TABLE media_resources ADD PRIMARY KEY (id)]

    add_foreign_key 'app_settings', 'media_resources', column: 'catalog_set_id',  options: 'ON DELETE SET NULL' 
    add_foreign_key 'app_settings', 'media_resources', column: 'featured_set_id',  options: 'ON DELETE SET NULL' 
    add_foreign_key 'app_settings', 'media_resources', column: 'splashscreen_slideshow_set_id',  options: 'ON DELETE SET NULL' 
    add_foreign_key 'edit_sessions', 'media_resources', dependent: :delete
    add_foreign_key 'full_texts', 'media_resources', dependent: :delete
    add_foreign_key 'grouppermissions', 'media_resources', dependent: :delete
    add_foreign_key 'media_files', 'media_resources', column: 'media_entry_id'
    add_foreign_key 'media_resource_arcs', 'media_resources', column: 'child_id', dependent: :delete
    add_foreign_key 'media_resource_arcs', 'media_resources', column: 'parent_id', dependent: :delete
    add_foreign_key 'media_sets_meta_contexts', 'media_resources', column: 'media_set_id', dependent: :delete
    add_foreign_key 'meta_data', 'media_resources', dependent: :delete
    add_foreign_key 'userpermissions', 'media_resources', dependent: :delete
    add_foreign_key 'favorites', 'media_resources', dependent: :delete

  end

  def down
  end

end
