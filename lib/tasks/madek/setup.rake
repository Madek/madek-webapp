namespace :madek do
  namespace :setup do
    task dirs: :environment do
      [FILE_STORAGE_DIR,THUMBNAIL_STORAGE_DIR,DOWNLOAD_STORAGE_DIR,ZIP_STORAGE_DIR].each do |dir|
        ::System.execute_cmd! %Q[mkdir -p #{dir}]
      end
      [FILE_STORAGE_DIR,THUMBNAIL_STORAGE_DIR].each do |dir|
        (0..15).map{|x| x.to_s(16)}.each do |sub_dir|
          ::System.execute_cmd! %Q[mkdir -p "#{dir}/#{sub_dir}"]
        end
      end
    end
  end
end

