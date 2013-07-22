class ReverseMediaFileMediaEntryRelation < ActiveRecord::Migration
  def up
    add_column :media_files, :media_entry_id, :integer
    add_foreign_key :media_files, :media_resources, column: :media_entry_id

    execute <<-SQL
      UPDATE media_files
      SET media_entry_id = media_resources.id
      FROM media_resources
      WHERE media_resources.media_file_id = media_files.id
    SQL
    add_index :media_files, :media_entry_id
    remove_column :media_resources, :media_file_id
  end

  def down
    raise "Irreversible migration" 
  end
end
