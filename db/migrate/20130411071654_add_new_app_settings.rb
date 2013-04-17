class AddNewAppSettings < ActiveRecord::Migration

  class OldSettings < ActiveRecord::Base
    set_table_name :settings
    serialize :value
  end

  class AppSettings < ActiveRecord::Base
  end

  def up
    create_table :app_settings, id: false  do |t|
      t.integer :id, null: false
      t.integer :featured_set_id
      t.integer :splashscreen_slideshow_set_id
      t.integer :catalog_set_id

      t.string  :dropbox_root_dir
      t.string  :ftp_dropbox_server
      t.string  :ftp_dropbox_user
      t.string  :ftp_dropbox_password

      t.string  :title 
      t.string  :wiki_url
      t.string  :welcome_title
      t.string  :welcome_subtitle

      t.timestamps 
    end

    execute "ALTER TABLE app_settings ADD PRIMARY KEY (id)"
    execute "ALTER TABLE app_settings ADD CONSTRAINT oneandonly CHECK (id = 0)"

    add_foreign_key :app_settings, :media_resources, column: :featured_set_id
    add_foreign_key :app_settings, :media_resources, column: :splashscreen_slideshow_set_id
    add_foreign_key :app_settings, :media_resources, column: :catalog_set_id


    execute 'INSERT INTO app_settings (id,created_at,updated_at) values (0,NOW(),NOW());'

    AppSettings.reset_column_information

    AppSettings.first.update_attributes title: "The Title"

    ["featured_set_id", "splashscreen_slideshow_set_id", "dropbox_root_dir", "ftp_dropbox_server",
      "ftp_dropbox_user", "ftp_dropbox_password", "catalog_set_id", "title", "wiki_url",
      "welcome_title", "welcome_subtitle"].each do |attr|
      begin 
        AppSettings.first.update_attributes attr =>  OldSettings.find_by_var(attr).value
      rescue
      end
      end

    drop_table :settings
  end

  def down
    raise 'irreversible'
  end

end
