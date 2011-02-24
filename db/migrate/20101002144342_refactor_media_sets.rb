class RefactorMediaSets < ActiveRecord::Migration
  def self.up
    
    drop_table :media_entries_media_groups if table_exists? :media_entries_media_groups
    drop_table :media_groups if table_exists? :media_groups

    #######

    rename_table :album_links, :media_set_links
    rename_table :albums_media_entries, :media_entries_media_sets
    rename_table :albums, :media_sets
    
    change_table :media_entries_media_sets do |t|
      t.rename :album_id, :media_set_id
      t.index :media_entry_id
    end
    
    change_table :media_sets do |t|
      t.remove :is_collection
      t.string :type, :null => false, :default => 'Media::Set'   # STI (single table inheritance)
    end

    #######
    
    MetaContext.update_all({:name => "media_set"}, {:name => "album"})
    EditSession.update_all({:resource_type => "Media::Set"}, {:resource_type => "Album"})
    MetaDatum.update_all({:resource_type => "Media::Set"}, {:resource_type => "Album"})
    Permission.update_all({:resource_type => "Media::Set"}, {:resource_type => "Album"})

    #######

    create_table :media_projects_meta_contexts, :id => false do |t|
      t.belongs_to :media_project
      t.belongs_to :meta_context
    end
    change_table :media_projects_meta_contexts do |t|
      t.index [:media_project_id, :meta_context_id], :unique => true, :name => "index_on_projects_and_contexts"
    end
    
  end

  def self.down
    rename_table :media_sets, :albums
    rename_table :media_entries_media_sets, :albums_media_entries
    rename_table :media_set_links, :album_links

    change_table :albums do |t|
      t.boolean :is_collection, :default => false
      t.remove :type
      t.index :is_collection
    end
  end
end
