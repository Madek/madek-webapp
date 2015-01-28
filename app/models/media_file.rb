# -*- encoding : utf-8 -*-
# require 'digest'

class MediaFile < ActiveRecord::Base

  # include MediaFileModules::FileStorageManagement
  # include MediaFileModules::Previews
  # include MediaFileModules::MetaDataExtraction

  belongs_to :media_entry, foreign_key: :media_entry_id
  has_many :zencoder_jobs, dependent: :destroy
  belongs_to :uploader, class_name: 'User'

  validates_presence_of :uploader

  before_create do
    self.guid ||= UUIDTools::UUID.random_create.hexdigest
    self.access_hash ||= SecureRandom.uuid
  end

  after_commit :delete_files, on: :destroy

  serialize :meta_data, Hash

  def delete_files
    begin
      File.delete(file_storage_location)
    rescue Exception => e
      Rails.logger.warn Formatter.exception_to_log_s(e)
    end
  end

  has_many :previews, -> { order(:created_at, :id) }, dependent: :destroy

  scope :incomplete_encoded_videos, lambda{
    where(media_type: 'video').where %{
      NOT EXISTS (SELECT NULL FROM media_files as mf
                  INNER JOIN previews ON previews.media_file_id = mf.id
                  WHERE mf.id = media_files.id
                  AND previews.media_type = 'video')
    }
  }

  ################################################################################

  def preview(size)
    previews.find_by(thumbnail: size)
  end

end
