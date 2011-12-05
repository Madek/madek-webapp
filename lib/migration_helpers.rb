
module MigrationHelpers

  def fkey_cascade_on_delete from_table, from_column, to_table
    name = "#{from_table}_#{from_column}_#{to_table}_fkey"
    execute "ALTER TABLE #{from_table} ADD CONSTRAINT #{name} FOREIGN KEY (#{from_column}) REFERENCES #{to_table} (id) ON DELETE CASCADE;"
  end


end
