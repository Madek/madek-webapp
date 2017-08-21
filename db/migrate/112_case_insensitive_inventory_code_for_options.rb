class CaseInsensitiveInventoryCodeForOptions < ActiveRecord::Migration[4.2]

  class ::MigrationInventoryPool < ActiveRecord::Base
    self.table_name = 'inventory_pools'
    has_many :migration_options, class_name: '::MigrationOption',
      foreign_key: "inventory_pool_id"
  end

  class ::MigrationOption < ActiveRecord::Base
    self.table_name = 'options'
    belongs_to :migration_inventory_pool, class_name: '::MigrationInventoryPool',
      foreign_key: "inventory_pool_id"
  end

  def up

    MigrationInventoryPool.where(
      name: [ 'Fachrichtung Film',
              'Vertiefung CAST',
              'zx_Ausleihe Florhofgasse',
              'zx_AV-Ausleihe',
              'ZHdK-Inventar']
    ).each do |mp|
      mp.migration_options.each do |mo|
        mo.update_attributes! inventory_code: "#{mp.name} / #{mo.inventory_code}"
      end
    end

    MigrationOption.where("inventory_code ~ '^\s*$'").each do |mo|
      mo.update_attributes! inventory_code: nil
    end

    MigrationOption.where("inventory_code IS NULL").each_with_index do |mo, idx|
      message = "Updating inventory_code from NULL to #{sprintf('%05d',idx)}"
      Rails.logger.warn message
      puts message
      mo.update_attributes! inventory_code: sprintf('%05d',idx)
    end

    MigrationOption.select("lower(inventory_code) AS lic") \
      .group("lower(inventory_code)").having("count(*) > 1").map(&:lic).each do |lic|
      MigrationOption.where("lower(inventory_code) = ?", lic).each_with_index do |mo,idx|
        message = "Updating inventory_code of '#{mo.product}' in '#{mo.migration_inventory_pool.name}' from '#{mo.inventory_code}' to  '#{mo.inventory_code}_#{idx}'"
        Rails.logger.warn message
        puts message
        mo.update_attributes! inventory_code: "#{mo.inventory_code}_#{idx}"
      end
    end

    execute <<-SQL
      ALTER TABLE options ALTER COLUMN inventory_code SET NOT NULL;
      ALTER TABLE options ALTER COLUMN inventory_code SET default uuid_generate_v4()::text;
      CREATE UNIQUE INDEX case_insensitive_inventory_code_for_options
        ON options (lower(inventory_code));
    SQL

  end
end
