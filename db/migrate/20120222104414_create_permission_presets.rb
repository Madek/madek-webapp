class CreatePermissionPresets < ActiveRecord::Migration
  include Constants

  def change

    create_table :permission_presets do |t|
      t.string :name
      Actions.each do |action|
        t.boolean action, null: false, default: false
      end
    end

    # this is mainly to provide a hard condition on uniqueness 
    add_index :permission_presets, [:view,:edit,:download,:manage], unique: true, name: :idx_bools_unique
    add_index :permission_presets, :name, unique: true, name: :idx_name_unique

  end
end
