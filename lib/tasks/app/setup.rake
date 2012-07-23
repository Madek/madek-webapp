namespace :app do
  namespace :setup do

    # CONSTANTS used here are in production.rb
    desc "Create needed directories"
    task :make_directories, [:reset] => :environment do |t,args|
      full_reset = args[:reset] == "reset"
      # If any of the paths are either nil or set to ""...
      if [FILE_STORAGE_DIR, THUMBNAIL_STORAGE_DIR, DOWNLOAD_STORAGE_DIR, ZIP_STORAGE_DIR].map{|path| path.to_s}.uniq == ""
        puts "DANGER, EXITING: The file storage paths are not defined! You need to define FILE_STORAGE_DIR, THUMBNAIL_STORAGE_DIR, DOWNLOAD_STORAGE_DIR, ZIP_STORAGE_DIR in your config/application.rb"
        exit        
      else
        if full_reset and (File.exist?(FILE_STORAGE_DIR) and File.exist?(THUMBNAIL_STORAGE_DIR))
          puts "Deleting #{FILE_STORAGE_DIR} and #{THUMBNAIL_STORAGE_DIR}"
          system "rm -rf '#{FILE_STORAGE_DIR}' '#{THUMBNAIL_STORAGE_DIR}'"         
        end
      
        [ '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f' ].each do |h|
          puts "Creating #{FILE_STORAGE_DIR}/#{h} and #{THUMBNAIL_STORAGE_DIR}/#{h}"
          system "mkdir -p #{FILE_STORAGE_DIR}/#{h} #{THUMBNAIL_STORAGE_DIR}/#{h}"
        end
      
        [DOWNLOAD_STORAGE_DIR, ZIP_STORAGE_DIR].each do |path|
          if full_reset
            puts "Removing #{path}"
            system "rm -rf '#{path}'"
          end
          puts "Creating #{path}"
          system "mkdir -p #{path}"
        end
      end
    end
    
  end
end


