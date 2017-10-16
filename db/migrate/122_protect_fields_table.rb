class ProtectFieldsTable < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL.strip_heredoc
      CREATE OR REPLACE FUNCTION restrict_operations_on_fields_function()
      RETURNS TRIGGER AS $$
      BEGIN
        RAISE EXCEPTION 'The fields table does not allow INSERT or DELETE or TRUNCATE!';
        RETURN NULL;
      END;
      $$ LANGUAGE 'plpgsql';

      CREATE TRIGGER trigger_restrict_operations_on_fields_function
      BEFORE INSERT OR DELETE
      ON fields
      FOR EACH STATEMENT EXECUTE PROCEDURE restrict_operations_on_fields_function();
    SQL
  end

  def down
    execute <<-SQL.strip_heredoc
      DROP TRIGGER IF EXISTS trigger_restrict_operations_on_fields_function ON fields;
      DROP FUNCTION IF EXISTS restrict_operations_on_fields_function();
    SQL
  end
end
