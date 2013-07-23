# The defined directories are configured here in order to be accessible w.o. rails
module DirectoriesConfig

  RAILS_ENV = if defined? Rails 
                Rails.env
              else
                ENV['RAILS_ENV'] || 'development'
              end
  RAILS_ROOT = File.expand_path('../../', __FILE__)

  ZIP_STORAGE_DIR      = "#{RAILS_ROOT}/tmp/zipfiles" 
  DOWNLOAD_STORAGE_DIR = "#{RAILS_ROOT}/tmp/downloads" 
  FILE_STORAGE_DIR     = "#{RAILS_ROOT}/db/media_files/#{RAILS_ENV}/attachments"
  THUMBNAIL_STORAGE_DIR= "#{RAILS_ROOT}/db/media_files/#{RAILS_ENV}/attachments"

end
