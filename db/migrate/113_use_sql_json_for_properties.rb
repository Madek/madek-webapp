class UseSqlJsonForProperties < ActiveRecord::Migration[4.2]

  class HashSerializerForOldYamlStuff

    def self.dump(hash)
      YAML.dump(hash || {})
    end

    def self.load(hash)
      hash = YAML.load(hash || '') if hash.is_a?(String)
      (hash || {}).with_indifferent_access
    end
  end


  class MigrationItemUp < ActiveRecord::Base
    self.table_name = 'items'
    serialize :properties, HashSerializerForOldYamlStuff
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
