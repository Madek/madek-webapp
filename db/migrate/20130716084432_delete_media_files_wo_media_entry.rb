class DeleteMediaFilesWoMediaEntry < ActiveRecord::Migration

  def up
    to_be_destroyed = MediaFile.where <<-SQL 
        NOT EXISTS 
          ( SELECT id FROM media_resources WHERE media_resources.media_file_id = media_files.id )
    SQL
    to_be_destroyed.destroy_all
  end

  def down
  end

end
