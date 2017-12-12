class ExtendAdminSettingsAddLogoLink < ActiveRecord::Migration[4.2]
  def change
    add_column :settings, :logo_link, :text, default: ''
  end
end
