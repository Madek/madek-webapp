class UuidAsPkeyForMediaResource < ActiveRecord::Migration

  def up
    enable_extension 'uuid-ossp'

    remove_column :media_resources, :media_entry_id

    add_column :media_resources, :uuid, :uuid, null: false, default: 'uuid_generate_v4()'

    add_column :media_resource_arcs, :parent_uuid, :uuid
    execute %[ UPDATE media_resource_arcs 
                SET parent_uuid = media_resources.uuid 
                FROM media_resources
                WHERE media_resources.id = media_resource_arcs.parent_id ]
    remove_column :media_resource_arcs, :parent_id
    rename_column :media_resource_arcs, :parent_uuid, :parent_id
    add_index :media_resource_arcs, :parent_id

    add_column :media_resource_arcs, :child_uuid, :uuid
    execute %[ UPDATE media_resource_arcs 
                SET child_uuid = media_resources.uuid 
                FROM media_resources
                WHERE media_resources.id = media_resource_arcs.child_id ]
    remove_column :media_resource_arcs, :child_id
    rename_column :media_resource_arcs, :child_uuid, :child_id
    add_index :media_resource_arcs, :child_id

    add_column :edit_sessions, :media_resource_uuid, :uuid
    execute %[ UPDATE edit_sessions
                SET media_resource_uuid = media_resources.uuid 
                FROM media_resources
                WHERE media_resources.id = edit_sessions.media_resource_id ] 
    remove_column :edit_sessions, :media_resource_id 
    rename_column :edit_sessions, :media_resource_uuid, :media_resource_id
    add_index :edit_sessions, :media_resource_id

    add_column :app_settings, :splashscreen_slideshow_set_uuid, :uuid
    execute %[ UPDATE app_settings
                SET splashscreen_slideshow_set_uuid = media_resources.uuid 
                FROM media_resources
                WHERE media_resources.id = app_settings.splashscreen_slideshow_set_id ] 
    remove_column :app_settings, :splashscreen_slideshow_set_id 
    rename_column :app_settings, :splashscreen_slideshow_set_uuid, :splashscreen_slideshow_set_id

    add_column :app_settings, :catalog_set_uuid, :uuid
    execute %[ UPDATE app_settings
                SET catalog_set_uuid = media_resources.uuid 
                FROM media_resources
                WHERE media_resources.id = app_settings.catalog_set_id ] 
    remove_column :app_settings, :catalog_set_id 
    rename_column :app_settings, :catalog_set_uuid, :catalog_set_id

    add_column :app_settings, :featured_set_uuid, :uuid
    execute %[ UPDATE app_settings
                SET featured_set_uuid = media_resources.uuid 
                FROM media_resources
                WHERE media_resources.id = app_settings.featured_set_id ] 
    remove_column :app_settings, :featured_set_id 
    rename_column :app_settings, :featured_set_uuid, :featured_set_id

    add_column :favorites, :media_resource_uuid, :uuid
    execute %[ UPDATE favorites
                SET media_resource_uuid = media_resources.uuid 
                FROM media_resources
                WHERE media_resources.id = favorites.media_resource_id ] 
    remove_column :favorites, :media_resource_id 
    rename_column :favorites, :media_resource_uuid, :media_resource_id
    add_index :favorites, :media_resource_id

    add_column :full_texts, :media_resource_uuid, :uuid
    execute %[ UPDATE full_texts
                SET media_resource_uuid = media_resources.uuid 
                FROM media_resources
                WHERE media_resources.id = full_texts.media_resource_id ] 
    remove_column :full_texts, :media_resource_id 
    rename_column :full_texts, :media_resource_uuid, :media_resource_id
    add_index :full_texts, :media_resource_id

    add_column :meta_data, :media_resource_uuid, :uuid
    execute %[ UPDATE meta_data
                SET media_resource_uuid = media_resources.uuid 
                FROM media_resources
                WHERE media_resources.id = meta_data.media_resource_id ] 
    remove_column :meta_data, :media_resource_id 
    rename_column :meta_data, :media_resource_uuid, :media_resource_id
    add_index :meta_data, :media_resource_id

    add_column :userpermissions, :media_resource_uuid, :uuid
    execute %[ UPDATE userpermissions
                SET media_resource_uuid = media_resources.uuid 
                FROM media_resources
                WHERE media_resources.id = userpermissions.media_resource_id ] 
    remove_column :userpermissions, :media_resource_id 
    rename_column :userpermissions, :media_resource_uuid, :media_resource_id
    add_index :userpermissions, :media_resource_id


    add_column :grouppermissions, :media_resource_uuid, :uuid
    execute %[ UPDATE grouppermissions
                SET media_resource_uuid = media_resources.uuid 
                FROM media_resources
                WHERE media_resources.id = grouppermissions.media_resource_id ] 
    remove_column :grouppermissions, :media_resource_id 
    rename_column :grouppermissions, :media_resource_uuid, :media_resource_id
    add_index :grouppermissions, :media_resource_id


    add_column :media_files, :media_entry_uuid, :uuid
    execute %[ UPDATE media_files
                SET media_entry_uuid = media_resources.uuid 
                FROM media_resources
                WHERE media_resources.id = media_files.media_entry_id ] 
    remove_column :media_files, :media_entry_id
    rename_column :media_files, :media_entry_uuid, :media_entry_id
    add_index :media_files, :media_entry_id

    add_column :media_sets_meta_contexts, :media_set_uuid, :uuid
    execute %[ UPDATE media_sets_meta_contexts
                SET media_set_uuid = media_resources.uuid 
                FROM media_resources
                WHERE media_resources.id = media_sets_meta_contexts.media_set_id ] 
    remove_column :media_sets_meta_contexts, :media_set_id
    rename_column :media_sets_meta_contexts, :media_set_uuid, :media_set_id
    add_index :media_sets_meta_contexts, :media_set_id


    execute %[ALTER TABLE media_resources DROP CONSTRAINT media_resources_pkey ]
    rename_column :media_resources, :id, :previous_id
    change_column :media_resources, :previous_id, :integer, null: true, default: nil
    execute %[ drop sequence media_resources_id_seq ]
    add_index :media_resources, :previous_id


    rename_column :media_resources, :uuid, :id
    execute %[ALTER TABLE media_resources ADD PRIMARY KEY (id)]


    add_index :media_resource_arcs, [:parent_id,:child_id], unique: true

    add_foreign_key :media_resource_arcs, :media_resources, column: :child_id, dependent: :delete
    add_foreign_key :media_resource_arcs, :media_resources, column: :parent_id, dependent: :delete

    add_foreign_key :edit_sessions, :media_resources, dependent: :delete

    add_foreign_key :app_settings, :media_resources, column: :featured_set_id
    add_foreign_key :app_settings, :media_resources, column: :splashscreen_slideshow_set_id
    add_foreign_key :app_settings, :media_resources, column: :catalog_set_id

    add_foreign_key :favorites, :media_resources, dependent: :delete

    add_foreign_key :full_texts, :media_resources, dependent: :delete

    add_foreign_key :meta_data, :media_resources, dependent: :delete

    add_foreign_key :userpermissions, :media_resources, dependent: :delete 

    add_foreign_key :grouppermissions, :media_resources, dependent: :delete

    add_foreign_key :media_files, :media_resources, column: :media_entry_id

    add_foreign_key :media_sets_meta_contexts, :media_resources, column: :media_set_id, dependent: :delete

    # the visualization has id's stored; but is is just a cache anyways
    execute %[ DELETE FROM visualizations ]

  end

  def down
  end

end
