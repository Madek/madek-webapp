module MigrationHelper
    extend ActiveSupport::Concern

  def create_trgm_index t,c
    execute "CREATE INDEX ON #{t.to_s} USING gin(#{c.to_s} gin_trgm_ops);"
  end

  def create_text_index t,c
    execute "CREATE INDEX ON #{t.to_s} USING gin(to_tsvector('english',#{c.to_s}));"
  end

  def set_timestamps_defaults table_name
    execute "ALTER TABLE #{table_name} ALTER COLUMN created_at SET DEFAULT now()";
    execute "ALTER TABLE #{table_name} ALTER COLUMN updated_at SET DEFAULT now()";
  end

end
