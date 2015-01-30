class AddColumnsToMetaKeys < ActiveRecord::Migration

  def change

    add_column :meta_keys, :label, :text
    add_column :meta_keys, :description, :text
    add_column :meta_keys, :enabled_for_media_entries, :bool, null: false, default: false
    add_column :meta_keys, :enabled_for_collections, :bool, null: false, default: false
    add_column :meta_keys, :enabled_for_filters_sets, :bool, null: false, default: false

  end

end
