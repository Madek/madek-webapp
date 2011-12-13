require 'sql_helper'

module MigrationHelpers
  include ::SQLHelper
  extend ::SQLHelper
  extend self
 

  # we are patching the index_name function here, 
  # do it explicitly so limit the impact to only when it is needed

  def patch_index_name
    ActiveRecord::ConnectionAdapters::SchemaStatements.class_eval do
      def index_name(table_name, options) #:nodoc:
        if Hash === options # legacy support
          if options[:column]
            MigrationHelpers.shorten_schema_names("index_#{table_name}_on_#{Array.wrap(options[:column]) * '_and_'}")
          elsif options[:name]
            options[:name]
          else
            raise ArgumentError, "You must specify the index name"
          end
        else
          MigrationHelpers.shorten_schema_names(index_name(table_name, :column => options))
        end
      end
    end
  end


  def ref_id model
    model.table_name.singularize + "_id"
  end

  def add_check table_name, check
    execute_sql "ALTER TABLE #{table_name} ADD CHECK #{check} ;"
  end

  def fkey_cascade_on_delete from_table, from_column, to_table
    name = "#{from_table}_#{from_column}_#{to_table}_fkey"
    execute_sql "ALTER TABLE #{from_table} ADD CONSTRAINT #{name} FOREIGN KEY (#{from_column}) REFERENCES #{to_table} (id) ON DELETE CASCADE;"
  end

  def create_del_referenced_trigger source, target
    source_table_name = source.class == String ? source : source.table_name
    target_table_name = target.class == String ? target : target.table_name

    fkey = target_table_name.singularize + "_id"
    fun_name = "delref_fkey_#{target_table_name}_#{source_table_name}_#{fkey}"

    if SQLHelper.adapter_is_postgresql?
      execute create_del_referenced_trigger_pgsql  source_table_name, target_table_name, fkey, fun_name
    else
      # TODO warn
    end
  end


  def drop_del_referenced_trigger source, target

    source_table_name = source.class == String ? source : source.table_name
    target_table_name = target.class == String ? target : target.table_name
    fkey = target_table_name.singularize + "_id"
    fun_name = "delref_fkey_#{target_table_name}_#{source_table_name}_#{fkey}"


    if SQLHelper.adapter_is_postgresql?
      execute drop_del_referenced_trigger_pgsql  fun_name, source_table_name
    else
      # TODO warn
    end
  end

#  private 

  def shorten_schema_names fun_name
    if fun_name.size > 63
      fun_name.slice(0,20) + (Digest::SHA1.hexdigest fun_name) 
    else
      fun_name
    end
  end

  def drop_del_referenced_trigger_pgsql fun_name, table_name
    fun_name = shorten_schema_names fun_name
    <<-SQL
      DROP TRIGGER #{fun_name} ON #{table_name};
      DROP FUNCTION #{fun_name}();
    SQL
  end

  def create_del_referenced_trigger_pgsql source_table, target_table, fkey, fun_name

    fun_name = shorten_schema_names fun_name

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
