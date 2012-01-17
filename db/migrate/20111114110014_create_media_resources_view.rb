class CreateMediaResourcesView < ActiveRecord::Migration
  def up

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

  def down

    sql= <<-SQL
      DROP VIEW media_resources;
    SQL

    sql.split(/;\s*$/).each {|cmd| execute cmd} if SQLHelper.adapter_is_mysql?
    execute sql if SQLHelper.adapter_is_postgresql?

  end
end
