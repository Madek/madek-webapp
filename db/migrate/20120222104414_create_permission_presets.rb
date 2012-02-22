class CreatePermissionPresets < ActiveRecord::Migration
  def change
    create_table :permission_presets do |t|
      t.string :name
      t.boolean :download
      t.boolean :view
      t.boolean :edit
      t.boolean :manage
    end
  end
end
