# -*- encoding : utf-8 -*-
# require 'digest'

class MediaFile < ActiveRecord::Base

  include MediaFileModules::FileStorageManagement
  include MediaFileModules::Previews
  include MediaFileModules::MetaDataExtraction

  belongs_to :media_entry, foreign_key: :media_entry_id
  has_many :zencoder_jobs, dependent: :destroy

  def most_recent_zencoder_job
    zencoder_jobs.reorder("zencoder_jobs.created_at DESC").limit(1).first
  end

  before_create do
    self.guid ||= UUIDTools::UUID.random_create.hexdigest
    self.access_hash ||= SecureRandom.uuid 
  end
  
  after_commit :delete_files, on: :destroy

  def delete_files
    begin 
      File.delete(file_storage_location)
    rescue Exception => e
      Rails.logger.warn Formatter.exception_to_log_s(e)
    end
  end

#########################################################

  serialize     :meta_data, Hash

  has_many :previews, lambda{order(created_at: :asc)}, :dependent => :destroy 

#########################################################
   
  scope :incomplete_encoded_videos, lambda{
    where(media_type: 'video').where %{

        NOT EXISTS  (SELECT true FROM media_files as mf
                        INNER JOIN previews ON previews.media_file_id = mf.id
                        WHERE mf.id = media_files.id
                        AND previews.content_type  = 'video/mp4')
      OR 

        NOT EXISTS  (SELECT true FROM media_files as mf
                      INNER JOIN previews ON previews.media_file_id = mf.id
                      WHERE mf.id = media_files.id
                      AND previews.content_type  = 'video/webm')
    }
  }

  def to_s
    "MediaFile[#{id}]"
  end

  def self.media_type(content_type)
    unless content_type
      "other"
    else
      case content_type
      when /^image/
        "image"
      when /^video/
        "video"
      when /^audio/
        "audio"
      when /^text/
        "document"
      when /^application/
        "document"
      else
        "other"
      end
    end
  end

  def video_type?
    media_type == 'video'
  end

end
