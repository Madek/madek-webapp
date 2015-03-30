module MigrationHelper
  extend ActiveSupport::Concern

  def create_trgm_index(t, c)
    execute "CREATE INDEX ON #{t} USING gin(#{c} gin_trgm_ops);"
  end

  def create_text_index(t, c)
    reversible do |dir| 
      dir.up do 
        execute "CREATE INDEX ON #{t} USING gin(to_tsvector('english',#{c}));"
      end
    end
  end

  def add_auto_timestamps(table_name)
    reversible do |dir| 
      dir.up do 
        add_timestamps table_name, null: false

        execute "ALTER TABLE #{table_name} ALTER COLUMN created_at SET DEFAULT now()"
        execute "ALTER TABLE #{table_name} ALTER COLUMN updated_at SET DEFAULT now()"
        execute "ALTER TABLE #{table_name} ALTER COLUMN created_at SET NOT NULL"
        execute "ALTER TABLE #{table_name} ALTER COLUMN updated_at SET NOT NULL"

        execute %{
          CREATE OR REPLACE FUNCTION update_updated_at_column()
          RETURNS TRIGGER AS $$
          BEGIN
             NEW.updated_at = now(); 
             RETURN NEW;
          END;
          $$ language 'plpgsql';
        }

        execute "
          CREATE TRIGGER update_updated_at_column_of_#{table_name} 
          BEFORE UPDATE ON #{table_name} FOR EACH ROW 
          WHEN (OLD.* IS DISTINCT FROM NEW.*)
          EXECUTE PROCEDURE 
          update_updated_at_column(); 
        "
      end

      dir.down do
        execute " DROP TRIGGER update_updated_at_column_of_#{table_name} ON #{table_name} "
        remove_timestamps table_name
      end
    end
  end

end
