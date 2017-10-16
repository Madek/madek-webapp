class MigrateFieldsDataToJson < ActiveRecord::Migration[5.0]

  class MigrationField < ActiveRecord::Base
    self.table_name = 'fields'
    serialize :data, JSON
  end

  def change
    add_column :fields, :data_jsonb, :jsonb, :default => {}

    MigrationField.reset_column_information

    MigrationField.all.each do |field|
      field.data_jsonb = field.data
      field.data = nil
      field.save!
    end

    remove_column :fields, :data
    rename_column :fields, :data_jsonb, :data
  end
end
