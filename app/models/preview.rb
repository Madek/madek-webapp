# -*- encoding : utf-8 -*-
class Preview < ActiveRecord::Base
  belongs_to :media_file

  before_create :set_media_type

  def set_media_type
    self.media_type = Concerns::MediaType.map_to_media_type(self.content_type)
  end

  def file_path
    "#{::THUMBNAIL_STORAGE_DIR}/#{filename.first}/#{filename}"
  end

  after_destroy do
    begin
      File.delete(file_path)
    rescue Errno::ENOENT => e
      # might not be an error in some cases
      Rails.logger.warn e
    end
  end

end
