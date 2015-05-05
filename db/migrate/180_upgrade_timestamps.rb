require Rails.root.join('db', 'migrate', 'migration_helper.rb')

class UpgradeTimestamps < ActiveRecord::Migration
  include MigrationHelper

  def change
    tables_with_timestamps.each do |table_name|
      add_auto_timestamps(table_name)
    end
  end

  def tables_with_timestamps
    database_name = Rails.configuration.database_configuration[Rails.env]['database']

  select_values("SELECT DISTINCT table_name
                FROM information_schema.columns
                WHERE column_name IN ('created_at', 'updated_at')
                AND table_catalog = '#{database_name}'")
  end
end
