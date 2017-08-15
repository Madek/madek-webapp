class CaseInsensitiveInventoryCodeForOptions < ActiveRecord::Migration[4.2]
  def up
    execute <<-SQL
      CREATE UNIQUE INDEX case_insensitive_inventory_code_for_options
        ON options (lower(inventory_code));
    SQL
  end
end
