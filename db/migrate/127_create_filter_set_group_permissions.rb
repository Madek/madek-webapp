class CreateFilterSetGroupPermissions < ActiveRecord::Migration

  def change
    create_table :filter_set_group_permissions, id: :uuid do |t|

      t.boolean :get_metadata_and_previews, null: false, default: false, index: true
      t.boolean :edit_metadata_and_filter, null: false, default: false, index: true

      t.uuid :filter_set_id, null: false
      t.index :filter_set_id

      t.uuid :group_id, null: false
      t.index :group_id

      t.uuid :updator_id
      t.index :updator_id

      t.index [:filter_set_id, :group_id], unique: true, name: 'idx_colgrpp_on_filter_set_id_and_group_id'

      t.timestamps null: false

    end
  end

end
