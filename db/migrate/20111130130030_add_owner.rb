class AddOwner < ActiveRecord::Migration

  def up
    sql= <<-SQL

      ALTER TABLE media_sets ADD COLUMN owner_id integer;
      UPDATE media_sets SET owner_id = user_id;
      ALTER TABLE media_sets ADD CONSTRAINT owner_id_fkey FOREIGN KEY (owner_id) REFERENCES users (id);
      ALTER TABLE media_sets ALTER COLUMN owner_id SET NOT NULL;


      ALTER TABLE media_entries ADD COLUMN owner_id integer;
      UPDATE media_entries 
        SET owner_id = (SELECT upload_sessions.user_id as user_id
                      FROM upload_sessions
                      INNER JOIN  media_entries as me ON  upload_sessions.id = me.upload_session_id
                      WHERE media_entries.id = me.id);
      ALTER TABLE media_entries ADD CONSTRAINT owner_id_fkey FOREIGN KEY (owner_id) REFERENCES users (id);
      ALTER TABLE media_entries ALTER COLUMN owner_id SET NOT NULL;


    SQL

    sql.split(/;\s*$/).each {|cmd| execute cmd} if SQLHelper.adapter_is_mysql?
    execute sql if SQLHelper.adapter_is_postgresql?


  end

  def down
    sql= <<-SQL
      ALTER TABLE media_sets DROP COLUMN owner_id;
      ALTER TABLE media_entries DROP COLUMN owner_id;
    SQL
    sql.split(/;\s*$/).each {|cmd| execute cmd} if SQLHelper.adapter_is_mysql?
    execute sql if SQLHelper.adapter_is_postgresql?


  end
end
