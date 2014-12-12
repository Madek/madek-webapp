class CreateCustomUrls < ActiveRecord::Migration
  include MigrationHelper

  def change
    create_table :custom_urls, id: false  do |t|
      t.string :id
      t.boolean :is_primary, default: false, null: false
      t.uuid :media_resource_id, null: false
      t.index :media_resource_id
      t.uuid :creator_id, null: false
      t.index :creator_id
      t.uuid :updator_id, null: false
      t.index :updator_id
      t.timestamps null: false
    end

    add_foreign_key :custom_urls, :media_resources, dependent: :delete
    add_foreign_key :custom_urls, :users, column: :creator_id
    add_foreign_key :custom_urls, :users, column: :updator_id

    reversible do |dir|
      dir.up do
        set_timestamps_defaults :custom_urls
        execute %q< ALTER TABLE custom_urls ADD CONSTRAINT custom_urls_id_format CHECK (id ~ '^[a-z][a-z0-9\-\_]+$'); >
        execute " ALTER TABLE custom_urls ADD CONSTRAINT custom_urls_id_is_not_uuid  CHECK (NOT id ~* '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'); "
        execute 'ALTER TABLE custom_urls ADD PRIMARY KEY (id)'
      end
    end
  end

end
