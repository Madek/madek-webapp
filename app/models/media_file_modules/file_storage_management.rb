# Note: git blame, most if not all of this was copied over
module MediaFileModules
  module FileStorageManagement
    extend ActiveSupport::Concern
    module ClassMethods
    end


    def move_temp_file_to_storage_location! tmp_file_path
      raise "Temp file doesn't exist!" unless  File.exists? tmp_file_path
      raise "Target file already exists!" if File.exists? file_storage_location
      FileUtils.mv tmp_file_path, file_storage_location
    end

    def file_storage_location
      File.join(FILE_STORAGE_DIR, shard, guid)
    end

    def thumbnail_storage_location
      File.join(THUMBNAIL_STORAGE_DIR, shard, guid)
    end

    def delete_files
      begin 
        File.delete(file_storage_location)
      rescue Exception => e
        Rails.logger.warn Formatter.exception_to_log_s(e)
      end
    end

    def shard
      self.guid[0..0]
    end

  end
end
