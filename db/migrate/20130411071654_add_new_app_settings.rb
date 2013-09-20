class AddNewAppSettings < ActiveRecord::Migration


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

    drop_table :settings
  end

  def down
    raise 'irreversible'
  end

end
