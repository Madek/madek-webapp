class HexToIntFunction < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION hex_to_int(hexval varchar) RETURNS bigint AS $$
      DECLARE
        result bigint;
      BEGIN
        EXECUTE 'SELECT x''' || hexval || '''::bigint' INTO result;
        RETURN result;
      END;
      $$ LANGUAGE plpgsql IMMUTABLE STRICT;
    SQL
  end

  def down
    execute <<-SQL
      DROP FUNCTION hex_to_int(character varying);
    SQL
  end
end
