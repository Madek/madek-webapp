class NormalizeProcurementSettings < ActiveRecord::Migration[5.0]

  KEYS = %w(contact_url)
  class OldSetting < ActiveRecord::Base
    self.table_name = 'procurement_settings'
    validates_presence_of :key, :value
    validates_uniqueness_of :key
    def self.all_as_hash
      h = {}
      KEYS.each do |k|
        h[k] = nil
      end
      all.order(key: :asc).each do |s|
        h[s.key] = s.value
      end
      h
    end
  end

  class MigrationSettings < ActiveRecord::Base
    self.table_name = 'procurement_settings'
  end

  def up
    old_settings = OldSetting.all_as_hash
    fail 'invalid data!' unless old_settings.keys == KEYS

    drop_table :procurement_settings

    create_table :procurement_settings, id: false  do |t|
      t.integer :id, primary_key: true, default: 0
      t.timestamps null: false
      t.string :contact_url
    end
    execute "ALTER TABLE procurement_settings ALTER COLUMN created_at SET DEFAULT now()"
    execute "ALTER TABLE procurement_settings ALTER COLUMN updated_at SET DEFAULT now()"
    execute 'ALTER TABLE procurement_settings ADD CONSTRAINT oneandonly CHECK (id = 0)'
    MigrationSettings.reset_column_information

    # put back old settings
    MigrationSettings.create!(old_settings)
  end

end
