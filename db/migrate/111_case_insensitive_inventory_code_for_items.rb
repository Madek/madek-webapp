class CaseInsensitiveInventoryCodeForItems < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE UNIQUE INDEX case_insensitive_inventory_code_for_items
        ON items (lower(inventory_code));
    SQL
  end
end
