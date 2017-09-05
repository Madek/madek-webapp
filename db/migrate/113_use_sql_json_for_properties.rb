class UseSqlJsonForProperties < ActiveRecord::Migration[4.2]

  class MigrationItemUp < ActiveRecord::Base
    self.table_name = 'items'
    store :properties
  end

  def up
    add_column :items, :properties_jsonb, :jsonb, :default => {}  

    MigrationItemUp.reset_column_information

    MigrationItemUp.unscoped.each do |item|
      item.properties_jsonb = item.properties
      item.properties = nil
      item.save!
    end

    remove_column :items, :properties
    rename_column :items, :properties_jsonb, :properties
  end
end
