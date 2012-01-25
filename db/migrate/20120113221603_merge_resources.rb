class MergeResources < ActiveRecord::Migration
  include MigrationHelpers
  
  def up
    ############################################################################
    # Clean Null References

    sql = <<-SQL
      DELETE t FROM favorites AS t LEFT JOIN media_entries AS q ON t.media_entry_id = q.id
                     LEFT JOIN upload_sessions AS u ON q.upload_session_id = u.id
               WHERE q.id IS NULL OR u.is_complete = false;
    SQL

    [:edit_sessions, :full_texts, :meta_data, :permissions].each do |table|
      sql << <<-SQL
        DELETE t FROM #{table} AS t LEFT JOIN media_sets AS q ON t.resource_id = q.id
                  WHERE t.resource_type = 'Media::Set' AND q.id IS NULL;
                  
        DELETE t FROM #{table} AS t LEFT JOIN snapshots AS q ON t.resource_id = q.id
                  WHERE t.resource_type = 'Snapshot' AND q.id IS NULL;
        
        DELETE t FROM #{table} AS t LEFT JOIN media_entries AS q ON t.resource_id = q.id
                  WHERE t.resource_type = 'MediaEntry' AND q.id IS NULL;
      SQL
    end

    if SQLHelper.adapter_is_mysql?
      sql.split(/;\s*$/).each {|cmd| execute cmd}
    elsif SQLHelper.adapter_is_postgresql?
      # do nothing for pg, no data there
    end 

    ############################################################################

    sql = <<-SQL
      DROP VIEW media_resources;
    SQL
    if SQLHelper.adapter_is_mysql?
      sql.split(/;\s*$/).each {|cmd| execute cmd}
    elsif SQLHelper.adapter_is_postgresql?
      execute sql
    end 
    
    remove_fkey_constraint :media_set_arcs, :parent_id, :media_sets 
    remove_fkey_constraint :media_set_arcs, :child_id, :media_sets 
    remove_index :media_set_arcs, [:parent_id, :child_id]
    remove_index :media_entries_media_sets, :name => :index_albums_media_entries_on_album_id_and_media_entry_id 

    create_table    :media_resources do |t|
      t.integer     :old_id                # to be dropped  
      t.string      :type                  # STI (single table inheritance)
      t.belongs_to  :user 
      t.belongs_to  :upload_session        # for media_entry
      t.belongs_to  :media_file            # for media_entry
      t.belongs_to  :media_entry           # for snapshot
      t.timestamps
    end

    sql = <<-SQL
      INSERT INTO media_resources (old_id, type, user_id, created_at, updated_at)
        SELECT id, 'Media::Set' AS type, user_id, created_at, updated_at FROM media_sets;

      INSERT INTO media_resources (old_id, type, user_id, upload_session_id, media_file_id, created_at, updated_at)
        SELECT me.id, 'MediaEntry' AS type, us.user_id, upload_session_id, media_file_id, me.created_at, me.updated_at
          FROM media_entries AS me JOIN upload_sessions AS us ON me.upload_session_id = us.id AND us.is_complete = true;

      INSERT INTO media_resources (old_id, type, user_id, upload_session_id, media_file_id, created_at, updated_at)
        SELECT me.id, 'MediaEntryIncomplete' AS type, us.user_id, upload_session_id, media_file_id, me.created_at, me.updated_at
          FROM media_entries AS me JOIN upload_sessions AS us ON me.upload_session_id = us.id AND us.is_complete = false;
        
      INSERT INTO media_resources (old_id, type, media_entry_id, media_file_id, created_at, updated_at)
        SELECT id, 'Snapshot', media_entry_id, media_file_id, created_at, updated_at FROM snapshots;
        
      UPDATE favorites LEFT JOIN media_resources
        ON favorites.media_entry_id = media_resources.old_id AND media_resources.type="MediaEntry"
        SET favorites.media_entry_id = media_resources.id;

      UPDATE media_resources AS mr1 LEFT JOIN media_resources AS mr2
        ON mr1.media_entry_id = mr2.old_id AND mr2.type="MediaEntry" AND mr1.type="Snapshot"
        SET mr1.media_entry_id = mr2.id;      

      UPDATE media_set_arcs LEFT JOIN media_resources
        ON media_set_arcs.parent_id = media_resources.old_id AND media_resources.type="Media::Set"
        SET media_set_arcs.parent_id = media_resources.id;

      UPDATE media_set_arcs LEFT JOIN media_resources
        ON media_set_arcs.child_id = media_resources.old_id AND media_resources.type="Media::Set"
        SET media_set_arcs.child_id = media_resources.id;

      UPDATE media_entries_media_sets LEFT JOIN media_resources
        ON media_entries_media_sets.media_set_id = media_resources.old_id AND media_resources.type="Media::Set"
        SET media_entries_media_sets.media_set_id = media_resources.id;

      UPDATE media_entries_media_sets LEFT JOIN media_resources
        ON media_entries_media_sets.media_entry_id = media_resources.old_id AND media_resources.type="MediaEntry"
        SET media_entries_media_sets.media_entry_id = media_resources.id;
      DELETE FROM media_entries_media_sets WHERE media_entry_id IS NULL;

      UPDATE media_sets_meta_contexts LEFT JOIN media_resources
        ON media_sets_meta_contexts.media_set_id = media_resources.old_id AND media_resources.type="Media::Set"
        SET media_sets_meta_contexts.media_set_id = media_resources.id;

    SQL
    if SQLHelper.adapter_is_mysql?
      sql.split(/;\s*$/).each {|cmd| execute cmd}
    elsif SQLHelper.adapter_is_postgresql?
      # do nothing for postgres
    end 

    rename_column :favorites, :media_entry_id, :media_resource_id

    ############################################################################

    [:edit_sessions, :full_texts, :meta_data, :permissions].each do |table|
      change_table    table do |t|
        t.belongs_to  :media_resource
      end

      sql = <<-SQL
        UPDATE #{table} AS t INNER JOIN media_resources AS mr
          ON (t.resource_id, t.resource_type) = (mr.old_id, CASE 
                                                              WHEN (mr.type IN ('MediaEntryIncomplete'))  THEN  'MediaEntry'
                                                              ELSE mr.type
                                                            END)
          SET t.media_resource_id = mr.id;
      SQL
      if SQLHelper.adapter_is_mysql?
        sql.split(/;\s*$/).each {|cmd| execute cmd}
      elsif SQLHelper.adapter_is_postgresql?
        # do nothing
      end 
    end
    
    change_table    :edit_sessions do |t|
      t.remove      :resource_id
      t.remove      :resource_type
      t.index       :media_resource_id
    end
    
    change_table      :full_texts do |t|
      t.remove_index  [:resource_id, :resource_type]
      t.remove        :resource_id
      t.remove        :resource_type
      t.index         :media_resource_id
    end

    table_name = :meta_data
    existing_indexes = indexes(table_name).map(&:name)
    [:index_meta_data_on_resource_id_and_resource_type_and_meta_key_id, :id_type_key_idx_on_meta_data].each do |index_name|
      remove_index table_name, :name => index_name if existing_indexes.include? index_name.to_s 
    end
  
    change_table      :meta_data do |t|
      t.remove        :resource_id
      t.remove        :resource_type
      t.index         [:media_resource_id, :meta_key_id]
    end
    
    change_table      :permissions do |t|
      t.remove_index  :name => :index_permissions_on_resource__and_subject
      t.remove        :resource_id
      t.remove        :resource_type
      t.index         [:media_resource_id, :subject_id, :subject_type], :name => :index_permissions_on_resource_and_subject
    end

    ############################################################################

    [:featured_set_id, :splashscreen_slideshow_set_id].each do |k|
      if (old_id = AppSettings.send(k))
        new_id = MediaResource.select(:id).where(:old_id => old_id).first.id
        AppSettings.send("#{k}=", new_id)
      end
    end

    ############################################################################

    execute "UPDATE media_resources SET type='MediaSet' WHERE type='Media::Set'"

    change_table    :media_resources do |t|
      t.index       :type
      t.index       :user_id
      t.index       :upload_session_id
      t.index       :media_file_id
      t.index       :updated_at
      t.index       [:media_entry_id, :created_at]
      t.remove      :old_id
    end
  
    drop_table :media_entries
    drop_table :snapshots
    drop_table :media_sets

    add_index :media_set_arcs, [:parent_id, :child_id], :unique => true
    add_index :media_entries_media_sets, [:media_set_id, :media_entry_id], :unique => true, :name => :index_on_media_set_id_and_media_entry_id 

    ############################################################################
    # Add Contraints

    fkey_cascade_on_delete :media_set_arcs, :media_resources, :parent_id
    fkey_cascade_on_delete :media_set_arcs, :media_resources, :child_id

    fkey_cascade_on_delete :media_entries_media_sets, :media_resources, :media_set_id 
    fkey_cascade_on_delete :media_entries_media_sets, :media_resources, :media_entry_id 
    fkey_cascade_on_delete :media_sets_meta_contexts, :media_resources, :media_set_id

    [:edit_sessions, :full_texts, :meta_data, :permissions, :favorites].each do |table|
      fkey_cascade_on_delete table, :media_resources, :media_resource_id
    end

  end

  def down
  end
end
