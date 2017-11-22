class DisableFieldSupplyCategory < ActiveRecord::Migration[5.0]

  class MigrationField < ActiveRecord::Base
    self.table_name = 'fields'
  end

  def change
    MigrationField.reset_column_information
    supply_category = MigrationField.where(id: 'properties_anschaffungskategorie').first
    if supply_category
      supply_category.data[:required] = false
      supply_category.active = false
      supply_category.save!
    end
  end
end
