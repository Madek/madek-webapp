# -*- encoding : utf-8 -*-
class AddLogLinkToAppSettings < ActiveRecord::Migration
  def change
    add_column :app_settings, :logo_url, :string, null: false, default: '/assets/inserts/image-logo-zhdk.png'
    add_column :app_settings, :brand, :string, null: false, default: "Zürcher Hochschule der Künste"
  end
end
