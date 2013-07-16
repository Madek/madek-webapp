class DeleteMediaFilesWoMediaEntry < ActiveRecord::Migration

  class ::MyMediaFile < ActiveRecord::Base
    self.table_name = :media_files
    has_many :previews, foreign_key: 'media_file_id',dependent:  :destroy 

    def shard
      self.guid[0..0]
    end

    after_commit on: :destroy do
      File.delete(file_storage_location)
    end

    def file_storage_location
      File.join(FILE_STORAGE_DIR, shard, guid)
    end

  end

  def up
    to_be_destroyed = MyMediaFile.where <<-SQL 
        NOT EXISTS 
          ( SELECT id FROM media_resources WHERE media_resources.media_file_id = media_files.id )
    SQL
    to_be_destroyed.destroy_all
  end

  def down
  end

end
