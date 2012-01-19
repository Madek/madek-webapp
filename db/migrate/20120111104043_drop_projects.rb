class DropProjects < ActiveRecord::Migration
  def up

    sql= <<-SQL
      DROP VIEW media_resources;
    SQL
    sql.split(/;\s*$/).each {|cmd| execute cmd} if SQLHelper.adapter_is_mysql?
    execute sql if SQLHelper.adapter_is_postgresql?

    rename_column :media_projects_meta_contexts, :media_project_id, :media_set_id
    rename_table :media_projects_meta_contexts, :media_sets_meta_contexts
    remove_column :media_sets, :type

    sql= <<-SQL 
      CREATE VIEW media_resources AS 
              (SELECT id, 'MediaSet' AS type, user_id, NULL AS upload_session_id, NULL AS media_file_id, created_at, updated_at FROM media_sets)
              UNION 
              (SELECT me.id, 'MediaEntry' AS type, us.user_id, upload_session_id, media_file_id, me.created_at, me.updated_at
               FROM media_entries AS me JOIN upload_sessions AS us ON me.upload_session_id = us.id AND us.is_complete = true);
    SQL
    sql.split(/;\s*$/).each {|cmd| execute cmd} if SQLHelper.adapter_is_mysql?
    execute sql if SQLHelper.adapter_is_postgresql?

  end

  def down

    sql= <<-SQL
      DROP VIEW media_resources;
    SQL
    sql.split(/;\s*$/).each {|cmd| execute cmd} if SQLHelper.adapter_is_mysql?
    execute sql if SQLHelper.adapter_is_postgresql?
    
    change_table :media_sets do |t|
      t.string :type, :null => false, :default => 'MediaSet'
    end
    rename_table :media_sets_meta_contexts, :media_projects_meta_contexts
    rename_column :media_projects_meta_contexts, :media_set_id, :media_project_id

    sql= <<-SQL 
      CREATE VIEW media_resources AS 
              (SELECT id, type, user_id, NULL AS upload_session_id, NULL AS media_file_id, created_at, updated_at FROM media_sets)
              UNION 
              (SELECT me.id, 'MediaEntry' AS type, us.user_id, upload_session_id, media_file_id, me.created_at, me.updated_at
               FROM media_entries AS me JOIN upload_sessions AS us ON me.upload_session_id = us.id AND us.is_complete = true);
    SQL
    sql.split(/;\s*$/).each {|cmd| execute cmd} if SQLHelper.adapter_is_mysql?
    execute sql if SQLHelper.adapter_is_postgresql?

  end
end
