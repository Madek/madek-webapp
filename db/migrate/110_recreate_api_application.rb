class RecreateApiApplication < ActiveRecord::Migration
  include MigrationHelper

  def change

    create_table :api_clients, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.string :name, null: false
      t.index :name, unique: true
      t.text :description
      t.uuid :secret, default: 'uuid_generate_v4()'
      t.timestamps null: false
    end

    set_timestamps_defaults :applications
    execute %q< ALTER TABLE api_clients ADD CONSTRAINT name_format CHECK (name ~ '^[a-z][a-z0-9\-\_]+$'); >

    execute "DROP TABLE applications CASCADE"

  end
end
