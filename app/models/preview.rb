# -*- encoding : utf-8 -*-
class Preview < ActiveRecord::Base
  belongs_to :media_file

  after_destroy do
    begin
      File.delete(full_path)
    rescue Errno::ENOENT
      puts "Can't delete #{full_path}, file does not exist."
    end
  end

  def full_path
    File.join(THUMBNAIL_STORAGE_DIR, filename[0,1], filename)    
  end

  def size
    File.size(full_path)
  end

  def create_symlink
    link = (Rails.root.join("public","previews").to_s + '/') \
      .gsub(/releases\/\d+/,"current") + filename
    path = full_path.to_s.gsub(/releases\/\d+/,"current")
    File.symlink(path,link) unless File.exists?(link)
  end

  def apache_url_for_symlink
    "/previews/#{filename}"
  end

end
