class CaseInsensitiveInventoryCodeForItems < ActiveRecord::Migration[4.2]

  class MigrationItem < ActiveRecord::Base
    self.table_name = 'items'
  end

  def up
    MigrationItem.select("count(*) as c, lower(inventory_code) AS lic") \
      .group("lower(inventory_code)").having("count(*) > 1").map(&:lic).each do |lic|
      MigrationItem.where("lower(inventory_code) = ?", lic).each_with_index do |mi,idx|
        mi.update_attributes! inventory_code: "#{mi.inventory_code}_#{idx}"
      end
    end
    execute <<-SQL
      CREATE UNIQUE INDEX case_insensitive_inventory_code_for_items
        ON items (lower(inventory_code));
    SQL
  end

end
