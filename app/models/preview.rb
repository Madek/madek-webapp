# -*- encoding : utf-8 -*-
class Preview < ActiveRecord::Base
  include Concerns::MediaType

  belongs_to :media_file

  before_create :set_media_type

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
