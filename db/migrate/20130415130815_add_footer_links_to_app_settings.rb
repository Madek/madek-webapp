class AddFooterLinksToAppSettings < ActiveRecord::Migration
  class AppSettings < ActiveRecord::Base
    serialize :footer_links, JsonSerializer
  end

  def up
    add_column :app_settings, :footer_links, :text

    AppSettings.reset_column_information

    AppSettings.first.update_attributes footer_links: {
      "About the project" => "http://www.zhdk.ch/?madek",
      "Impressum" => "http://www.zhdk.ch/index.php?id=12970",
      "Contact" => "http://www.zhdk.ch/index.php?id=49591",
      "Help" =>  "http://wiki.zhdk.ch/madek-hilfe",
      "Terms of Use" => "https://wiki.zhdk.ch/madek-hilfe/doku.php?id=terms",
      "Archivierungsrichtlinien ZHdK" => "http://www.zhdk.ch/?archivierung"}
  end

  def down
    remove_column :app_settings, :footer_links
  end

end

