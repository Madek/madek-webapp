class CreateAppSettings < ActiveRecord::Migration
  include MigrationHelper

  def change
    create_table :app_settings, id: false  do |t|

      t.integer :id, primary_key: true

      t.uuid :featured_set_id
      t.uuid :splashscreen_slideshow_set_id
      t.uuid :catalog_set_id

      t.string :title
      t.string :support_url
      t.string :welcome_title
      t.string :welcome_subtitle

      t.uuid :teaser_set_id

      t.timestamps null: false
    end

    add_column :app_settings, :logo_url, :string, null: false, default: '/assets/inserts/image-logo-zhdk.png'
    add_column :app_settings, :brand, :string, null: false, default: 'Zürcher Hochschule der Künste'
    add_column :app_settings, :footer_links, :text

    add_column :app_settings, :second_displayed_context_id, :string
    add_foreign_key :app_settings, :contexts, column: :second_displayed_context_id
    add_column :app_settings, :third_displayed_context_id, :string
    add_foreign_key :app_settings, :contexts, column: :third_displayed_context_id

    reversible do |dir|
      dir.up do
        set_timestamps_defaults :app_settings
        execute 'ALTER TABLE app_settings ADD CONSTRAINT oneandonly CHECK (id = 0)'
      end
    end

    add_foreign_key :app_settings, :media_resources, column: :featured_set_id
    add_foreign_key :app_settings, :media_resources, column: :splashscreen_slideshow_set_id
    add_foreign_key :app_settings, :media_resources, column: :catalog_set_id
  end

end
