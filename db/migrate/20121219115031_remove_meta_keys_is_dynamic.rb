class RemoveMetaKeysIsDynamic < ActiveRecord::Migration
  def change
    remove_column :meta_keys, :is_dynamic
  end
end
