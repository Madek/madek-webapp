class RemoveMediaEntryIncomplete < ActiveRecord::Migration
  def change
    add_column :media_entries, :is_published, :bool, default: false, nil: false
    execute %{ UPDATE media_entries SET "is_published" = true WHERE type = 'MediaEntry' }
    remove_column :media_entries, :type
  end
end
