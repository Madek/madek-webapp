# -*- encoding : utf-8 -*-
class Preview < ActiveRecord::Base

  after_destroy :delete_file

  belongs_to :media_file

  def full_path
    File.join(THUMBNAIL_STORAGE_DIR, filename[0,1], filename)    
  end

  def size
    File.size(full_path)
  end

  def delete_file
    begin
      File.delete(full_path)
    rescue Errno::ENOENT
      puts "Can't delete #{full_path}, file does not exist."
    end
  end

end
