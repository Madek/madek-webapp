module MigrationHelpers
  extend self

  def fkey_cascade_on_delete from_table, from_column, to_table
    name = "#{from_table}_#{from_column}_#{to_table}_fkey"
    execute "ALTER TABLE #{from_table} ADD CONSTRAINT #{name} FOREIGN KEY (#{from_column}) REFERENCES #{to_table} (id) ON DELETE CASCADE;"
  end

  def create_del_referenced_trigger source_model, target_model
    fkey = target_model.table_name.singularize + "_id"
    source_table = source_model.table_name
    target_table = target_model.table_name
    fun_name = "delref_fkey_#{target_table}_#{source_table}_#{fkey}"

    if SQLHelper.adapter_is_postgresql?
      execute create_del_referenced_trigger_pgsql  source_table, target_table, fkey, fun_name
    else
      # TODO warn
    end
  end


  def drop_del_referenced_trigger source_model, target_model
    fun_name = "delref_fkey_#{target_table}_#{source_table}_#{fkey}"

    if SQLHelper.adapter_is_postgresql?
      execute drop_del_referenced_trigger_pgsql  fun_name
    else
      # TODO warn
    end
  end

#  private 

  def shorten_pg_fun_names fun_name
    if fun_name.size > 63
      fun_name.slice(0,20) + (Digest::SHA1.hexdigest fun_name) 
    else
      fun_name
    end
  end

  def drop_del_referenced_trigger_pgsql fun_name
    fun_name = shorten_pg_fun_names fun_name
    <<-SQL
      DROP TRIGGER #{fun_name};
      DROP FUNCTION #{fun_name}();
    SQL
  end

  def create_del_referenced_trigger_pgsql source_table, target_table, fkey, fun_name

    fun_name = shorten_pg_fun_names fun_name

    <<-SQL
      CREATE FUNCTION #{fun_name}() 
      RETURNS trigger
      AS $$
      DECLARE
      BEGIN
        PERFORM DELETE FROM #{target_table} WHERE id = OLD.#{fkey};
        RETURN OLD;
      END $$
      LANGUAGE PLPGSQL;

      CREATE TRIGGER #{fun_name}
        AFTER DELETE
        ON #{source_table}
        FOR EACH ROW execute procedure #{fun_name}();
      SQL
  end
end
