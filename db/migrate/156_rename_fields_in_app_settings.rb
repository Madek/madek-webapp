class RenameFieldsInAppSettings < ActiveRecord::Migration
  def change
    rename_column :app_settings, :title, :site_title
    rename_column :app_settings, :brand, :brand_text
    rename_column :app_settings, :logo_url, :brand_url
    rename_column :app_settings, :welcome_title, :title
    rename_column :app_settings, :welcome_subtitle, :subtitle
    rename_column :app_settings, :footer_links, :sitemap
  end
end
