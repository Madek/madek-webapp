class AddPositionToPermissionPreset < ActiveRecord::Migration
  def change
    add_column :permission_presets, :position, :float
    PermissionPreset.all.each_with_index do |p, i|
      p.update_attribute(:position, i+1)
    end
  end
end
