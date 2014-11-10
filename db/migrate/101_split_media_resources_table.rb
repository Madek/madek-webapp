require Rails.root.join "db","migrate","media_resource_migration_models"

class SplitMediaResourcesTable < ActiveRecord::Migration
  include MigrationHelper
  include MediaResourceMigrationModels


  def change

    ### change types on resources #######################################
    
    rename_table :media_resources, :resources
    rename_column :edit_sessions, :media_resource_id, :resource_id
    rename_column :favorites, :media_resource_id, :resource_id
    rename_column :userpermissions, :media_resource_id, :resource_id
    rename_column :grouppermissions, :media_resource_id, :resource_id
    rename_column :applicationpermissions, :media_resource_id, :resource_id


    reversible do |dir|
      dir.up do 
        execute "UPDATE resources SET type = 'MediaEntryResource' WHERE type = 'MediaEntry'"
        execute "UPDATE resources SET type = 'MediaEntryIncompleteResource' WHERE type = 'MediaEntryIncomplete'"
        execute "UPDATE resources SET type = 'CollectionResource' WHERE type = 'MediaSet'"
        execute "UPDATE resources SET type = 'FilterSetResource' WHERE type = 'FilterSet'"
        
        valid_types_string= %w(MediaEntryResource MediaEntryIncompleteResource CollectionResource FilterSetResource).map{|s|"'#{s}'"}.join(', ') 
        execute %[ALTER TABLE resources ADD CONSTRAINT valid_media_resource_type CHECK 
            ( type IN (#{ valid_types_string }));]

      end
      dir.down do
        execute %[ ALTER TABLE resources DROP CONSTRAINT valid_media_resource_type ]
      end
    end

    ###########################################################################
    ### media_entries #########################################################
    ###########################################################################

    create_table :media_entries, id: :uuid do |t|
      t.timestamps null: false
      t.string :type, default: 'MediaEntry'
    end

    reversible{|d|d.up{ set_timestamps_defaults :media_entries}}

    add_foreign_key :media_entries, :resources, column: 'id'


    ### create a media_entry for each media_resource of type MediaEntryResource #########
  
    reversible do |dir|
      dir.up do 
        ::MigrationResource.where(type: 'MediaEntryResource').find_each do |mre|
          ::MigrationMediaEntry.create! id: mre.id, 
            created_at: mre.created_at,
            updated_at: mre.updated_at
        end
      end
    end

    ### repoint the media_entry_id of media_file ##############################
    # we just need to recreate the key
    reversible do |dir|
      dir.up do 
        remove_foreign_key :media_files, name: 'media_files_media_entry_id_fk'
        add_foreign_key :media_files, :media_entries
      end
      dir.down do 
        remove_foreign_key :media_files, :media_entries
        add_foreign_key :media_files, :resources, column: :media_entry_id
      end
    end


    ###########################################################################
    ### collections ## #########################################################
    ###########################################################################

    create_table :collections, id: :uuid do |t|
      t.timestamps null: false
    end
    reversible{|d|d.up{ set_timestamps_defaults :collections }}

    reversible do |dir|
      dir.up do 
        ::MigrationResource.where(type: 'CollectionResource').find_each do |mrs|
          ::MigrationCollection.create! id: mrs.id, 
            created_at: mrs.created_at,
            updated_at: mrs.updated_at
        end
      end
    end

    add_foreign_key :collections, :resources, column: 'id'


    ###########################################################################
    ### filter_sets ###########################################################
    ###########################################################################

    create_table :filter_sets, id: :uuid do |t|
      t.timestamps null: false

      t.json :filter, null: false, default: '{}'
    end
    reversible{|d|d.up{ set_timestamps_defaults :filter_sets }}


    reversible do |dir|
      dir.up do 
        ::MigrationResource.where(type: 'FilterSetResource').find_each do |mrfs|
          ::MigrationFilterSet.create! id: mrfs.id, 
            created_at: mrfs.created_at,
            updated_at: mrfs.updated_at,
            filter: mrfs.settings["filter"] || {}
        end
      end
    end

    add_foreign_key :filter_sets, :resources, column: 'id'


###############################################################################
####### arcs ##################################################################
###############################################################################
     
    ###########################################################################
    ### collection_media_entry_arcs ###########################################
    ###########################################################################

  
    create_table :collection_media_entry_arcs, id: :uuid do |t| 
      t.uuid :media_entry_id, null: false
      t.index :media_entry_id

      t.uuid :collection_id, null: false
      t.index :collection_id

      t.index [:collection_id,:media_entry_id], unique: true, name: 'index_collection_media_entry_arcs_on_collection_id_and_media_entry_id'[0..62]
      t.index [:media_entry_id,:collection_id], name: 'index_collection_media_entry_arcs_on_media_entry_id_and_collection_id'[0..62]

      t.boolean :highlight, default: false
      t.boolean :cover    
    end

    add_foreign_key :collection_media_entry_arcs, :media_entries, dependent: :delete
    add_foreign_key :collection_media_entry_arcs, :collections, dependent: :delete


    ###########################################################################
    ### collection_filter_set_arcs ############################################
    ###########################################################################

    create_table :collection_filter_set_arcs, id: :uuid do |t| 
      t.uuid :filter_set_id, null: false
      t.index :filter_set_id

      t.uuid :collection_id, null: false
      t.index :collection_id

      t.index [:collection_id,:filter_set_id], unique: true, name: 'index_collection_filter_set_arcs_on_collection_id_and_filter_set_id'[0..62]
      t.index [:filter_set_id,:collection_id], name: 'index_collection_filter_set_arcs_on_filter_set_id_and_collection_id'[0..62]
    end

    add_foreign_key :collection_filter_set_arcs, :filter_sets, dependent: :delete
    add_foreign_key :collection_filter_set_arcs, :collections, dependent: :delete


    ###########################################################################
    ### collection_collection_arcs ############################################
    ###########################################################################

    create_table :collection_collection_arcs, id: :uuid do |t| 
      t.uuid :child_id, null: false
      t.index :child_id

      t.uuid :parent_id, null: false
      t.index :parent_id

      t.index [:parent_id,:child_id], unique: true
      t.index [:child_id,:parent_id]
    end

    add_foreign_key :collection_collection_arcs, :collections, column: 'child_id', dependent: :delete
    add_foreign_key :collection_collection_arcs, :collections, column: 'parent_id', dependent: :delete


    reversible do |dir|
      dir.up do 
        MigrationResourceArc.find_each do |arc|
          if arc.child.type == 'MediaEntryResource' and arc.parent.type == 'CollectionResource'
            MigrationEntrySetArc.create! collection_id: arc.parent_id, 
              media_entry_id:  arc.child_id, highlight: arc.highlight, cover: arc.cover
          elsif arc.child.type == 'CollectionResource' and arc.parent.type == 'CollectionResource'
            MigrationSetSetArc.create! parent_id: arc.parent_id, child_id: arc.child_id
          elsif arc.child.type == 'FilterSetResource' and arc.parent.type == 'CollectionResource'
            MigrationFilterSetSetArc.create! collection_id: arc.parent_id, filter_set_id: arc.child_id
          else
            raise ["Unknown Arc Type", arc.attributes]
          end
        end
      end
    end


    reversible do |dir|
      dir.up do
        drop_table :media_resource_arcs 
      end
      dir.down do
        create_table :media_resource_arcs, id: :uuid do |t|
          t.uuid :parent_id, null: false
          t.uuid :child_id, null: false
          t.boolean :highlight, default: false
          t.boolean :cover
        end
        add_index :media_resource_arcs, [:parent_id,:child_id], unique: true
        add_index :media_resource_arcs, [:child_id,:parent_id], unique: true
        add_index :media_resource_arcs, :cover
        add_index :media_resource_arcs, :parent_id
        add_index :media_resource_arcs, :child_id
        add_foreign_key :media_resource_arcs, :resources, column: :child_id, dependent: :delete
        add_foreign_key :media_resource_arcs, :resources, column: :parent_id, dependent: :delete
        execute "ALTER TABLE media_resource_arcs  ADD CHECK (parent_id <> child_id);"
      end
    end


    remove_column :resources, :settings, :text

  end
end
