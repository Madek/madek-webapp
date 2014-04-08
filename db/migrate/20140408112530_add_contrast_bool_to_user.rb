class AddContrastBoolToUser < ActiveRecord::Migration
  def change
    add_column :users, :contrast_mode, :boolean, null: false, default: false
  end
end
