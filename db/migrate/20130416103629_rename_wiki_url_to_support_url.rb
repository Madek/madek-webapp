class RenameWikiUrlToSupportUrl < ActiveRecord::Migration
  def change
    rename_column :app_settings, :wiki_url, :support_url
  end
end
