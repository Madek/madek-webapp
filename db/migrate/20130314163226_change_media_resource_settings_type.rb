class ChangeMediaResourceSettingsType < ActiveRecord::Migration
  def self.up
   change_column :media_resources, :settings, :text
  end

  def self.down
   change_column :media_resources, :settings, :string
  end
end
