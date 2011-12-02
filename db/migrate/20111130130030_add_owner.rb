class AddOwner < ActiveRecord::Migration

  # TODO the updated doesn't work in MySQL
  def up

    # add owner column
    pg_sql= <<-SQL
      ALTER TABLE media_sets ADD COLUMN owner_id integer;
      ALTER TABLE media_sets ADD CONSTRAINT owner_id_fkey FOREIGN KEY (owner_id) REFERENCES users (id);
      UPDATE media_sets SET owner_id = user_id;

      ALTER TABLE media_entries ADD COLUMN owner_id integer;
      ALTER TABLE media_entries ADD CONSTRAINT owner_id_fkey FOREIGN KEY (owner_id) REFERENCES users (id); 
    SQL
    execute pg_sql if SQLHelper.adapter_is_postgresql?

    my_sql= <<-SQL
      ALTER TABLE media_sets ADD COLUMN owner_id integer;
      UPDATE media_sets SET owner_id = user_id;
      ALTER TABLE media_entries ADD COLUMN owner_id integer;
    SQL
    my_sql.split(/;\s*$/).each {|cmd| execute cmd} if SQLHelper.adapter_is_mysql?


    
    # set the owner, aka migrate the data
    pg_sql= <<-SQL
      UPDATE media_sets SET owner_id = user_id;

      UPDATE media_entries 
        SET owner_id = (SELECT upload_sessions.user_id as user_id
                      FROM upload_sessions
                      INNER JOIN  media_entries as me ON  upload_sessions.id = me.upload_session_id
                      WHERE media_entries.id = me.id);
    SQL

    execute pg_sql if SQLHelper.adapter_is_postgresql?

    if SQLHelper.adapter_is_mysql?
      MediaEntry.all.each do |me|
        me.owner = me.upload_session.user
        me.save!
      end
    end


    # constraints 

    pg_sql= <<-SQL
      ALTER TABLE media_entries ALTER COLUMN owner_id SET NOT NULL;
      ALTER TABLE media_sets ALTER COLUMN owner_id SET NOT NULL;
    SQL
    execute pg_sql if SQLHelper.adapter_is_postgresql?

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
