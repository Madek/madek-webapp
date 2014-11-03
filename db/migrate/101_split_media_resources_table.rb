class SplitMediaResourcesTable < ActiveRecord::Migration
  include MigrationHelper

  class ::MigrationMediaResource < ActiveRecord::Base
    self.table_name= 'media_resources'
    self.inheritance_column= nil
    store :settings
  end

  class ::MigrationMediaResourceArc < ActiveRecord::Base
    self.table_name= 'media_resource_arcs'
    belongs_to  :child, :class_name => "MigrationMediaResource",  :foreign_key => :child_id
    belongs_to  :parent, :class_name => "MigrationMediaResource",  :foreign_key => :parent_id
  end

  class ::MigrationMediaEntry < ActiveRecord::Base
    self.table_name= 'media_entries'
  end

  class ::MigrationMediaSet < ActiveRecord::Base
    self.table_name= 'media_sets'
  end

  class ::MigrationFilterSet < ActiveRecord::Base
    self.table_name= 'filter_sets'
  end

  class ::MigrationEntrySetArc < ActiveRecord::Base
    self.table_name= 'entry_set_arcs'
  end

  class ::MigrationSetSetArc < ActiveRecord::Base
    self.table_name= 'set_set_arcs'
  end
  class ::MigrationFilterSetSetArc < ActiveRecord::Base
    self.table_name= 'filter_set_set_arcs'
  end



  def change

    ### change types on media_resources #######################################

    reversible do |dir|
      dir.up do 
        execute "UPDATE media_resources SET type = 'MediaResourceEntry' WHERE type = 'MediaEntry'"
        execute "UPDATE media_resources SET type = 'MediaResourceEntryIncomplete' WHERE type = 'MediaEntryIncomplete'"
        execute "UPDATE media_resources SET type = 'MediaResourceSet' WHERE type = 'MediaSet'"
        execute "UPDATE media_resources SET type = 'MediaResourceFilterSet' WHERE type = 'FilterSet'"
        
        valid_types_string= %w(MediaResourceEntry MediaResourceEntryIncomplete MediaResourceSet MediaResourceFilterSet).map{|s|"'#{s}'"}.join(', ') 
        execute %[ALTER TABLE media_resources ADD CONSTRAINT valid_media_resource_type CHECK 
            ( type IN (#{ valid_types_string }));]

      end
      dir.down do
        execute %[ ALTER TABLE media_resources DROP CONSTRAINT valid_media_resource_type ]
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

    add_foreign_key :media_entries, :media_resources, column: 'id'


    ### create a media_entry for each media_resource of type MediaResourceEntry #########
  
    reversible do |dir|
      dir.up do 
        ::MigrationMediaResource.where(type: 'MediaResourceEntry').find_each do |mre|
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
        add_foreign_key :media_files, :media_resources, column: :media_entry_id
      end
    end


    ###########################################################################
    ### media_sets ## #########################################################
    ###########################################################################

    create_table :media_sets, id: :uuid do |t|
      t.timestamps null: false
    end
    reversible{|d|d.up{ set_timestamps_defaults :media_sets }}

    reversible do |dir|
      dir.up do 
        ::MigrationMediaResource.where(type: 'MediaResourceSet').find_each do |mrs|
          ::MigrationMediaSet.create! id: mrs.id, 
            created_at: mrs.created_at,
            updated_at: mrs.updated_at
        end
      end
    end

    add_foreign_key :media_sets, :media_resources, column: 'id'


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
        ::MigrationMediaResource.where(type: 'MediaResourceFilterSet').find_each do |mrfs|
          ::MigrationFilterSet.create! id: mrfs.id, 
            created_at: mrfs.created_at,
            updated_at: mrfs.updated_at,
            filter: mrfs.settings["filter"]
        end
      end
    end

    add_foreign_key :filter_sets, :media_resources, column: 'id'


###############################################################################
####### arcs ##################################################################
###############################################################################
     
    ###########################################################################
    ### entry_set_arcs ########################################################
    ###########################################################################

  
    create_table :entry_set_arcs, id: :uuid do |t| 
      t.uuid :media_entry_id, null: false
      t.index :media_entry_id

      t.uuid :media_set_id, null: false
      t.index :media_set_id

      t.index [:media_set_id,:media_entry_id], unique: true
      t.index [:media_entry_id,:media_set_id]

      t.boolean :highlight, default: false
      t.boolean :cover    
    end

    add_foreign_key :entry_set_arcs, :media_entries, dependent: :delete
    add_foreign_key :entry_set_arcs, :media_sets, dependent: :delete


    ###########################################################################
    ### filter_set_set_arcs ###################################################
    ###########################################################################

    create_table :filter_set_set_arcs, id: :uuid do |t| 
      t.uuid :filter_set_id, null: false
      t.index :filter_set_id

      t.uuid :media_set_id, null: false
      t.index :media_set_id

      t.index [:media_set_id,:filter_set_id], unique: true
      t.index [:filter_set_id,:media_set_id]
    end

    add_foreign_key :filter_set_set_arcs, :filter_sets, dependent: :delete
    add_foreign_key :filter_set_set_arcs, :media_sets, dependent: :delete


    ###########################################################################
    ### set_set_arcs ##########################################################
    ###########################################################################

    create_table :set_set_arcs, id: :uuid do |t| 
      t.uuid :child_id, null: false
      t.index :child_id

      t.uuid :parent_id, null: false
      t.index :parent_id

      t.index [:parent_id,:child_id], unique: true
      t.index [:child_id,:parent_id]
    end

    add_foreign_key :set_set_arcs, :media_sets, column: 'child_id', dependent: :delete
    add_foreign_key :set_set_arcs, :media_sets, column: 'parent_id', dependent: :delete


    reversible do |dir|
      dir.up do 
        MigrationMediaResourceArc.find_each do |arc|
          if arc.child.type == 'MediaResourceEntry' and arc.parent.type == 'MediaResourceSet'
            MigrationEntrySetArc.create! media_set_id: arc.parent_id, 
              media_entry_id:  arc.child_id, highlight: arc.highlight, cover: arc.cover
          elsif arc.child.type == 'MediaResourceSet' and arc.parent.type == 'MediaResourceSet'
            MigrationSetSetArc.create! parent_id: arc.parent_id, child_id: arc.child_id
          elsif arc.child.type == 'MediaResourceFilterSet' and arc.parent.type == 'MediaResourceSet'
            MigrationFilterSetSetArc.create! media_set_id: arc.parent_id, filter_set_id: arc.child_id
          else
            raise ["Unknown Arc Type", arc.attributes]
          end
        end
      end
    end

    drop_table :media_resource_arcs 

    remove_column :media_resources, :settings, :text

  end
end
