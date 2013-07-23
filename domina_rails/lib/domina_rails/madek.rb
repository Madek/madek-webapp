require 'domina_rails'
require 'domina_rails/system'

module DominaRails
  module Madek
    ROOT = DominaRails::APP_ROOT
    ENV['RAILS_ENV']='test' unless ENV['RAILS_ENV']
    load "#{ROOT}/config/directories_config.rb"
    DOWNLOAD_STORAGE_DIR  = DirectoriesConfig::DOWNLOAD_STORAGE_DIR 
    FILE_STORAGE_DIR      = DirectoriesConfig::FILE_STORAGE_DIR
    THUMBNAIL_STORAGE_DIR = DirectoriesConfig::THUMBNAIL_STORAGE_DIR
    ZIP_STORAGE_DIR       = DirectoriesConfig::ZIP_STORAGE_DIR 

    class << self

      def setup_madek_dirs
        [DOWNLOAD_STORAGE_DIR,FILE_STORAGE_DIR,THUMBNAIL_STORAGE_DIR,ZIP_STORAGE_DIR].each do |dir|
          DominaRails::System.execute_cmd! %Q[rm -rf #{dir}; mkdir -p #{dir}]
        end
        [FILE_STORAGE_DIR,THUMBNAIL_STORAGE_DIR].each do |dir|
          (0..15).map{|x| x.to_s(16)}.each do |sub_dir|
            DominaRails::System.execute_cmd! %Q[mkdir -p "#{dir}/#{sub_dir}"]
          end
        end
      end

    end

  end
end
