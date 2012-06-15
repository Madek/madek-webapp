namespace :madek do
  namespace :meta_data do

    desc "Export MetaData Presets" 
    task :export_presets  => :environment do

      data_hash = DevelopmentHelpers::MetaDataPreset.create_hash

      date_string = DateTime.now.to_s.gsub(":","-")
      file_path = "tmp/#{date_string}_meta_data.yml"

      File.open(file_path, "w"){|f| f.write data_hash.to_yaml } 
      puts "the file has been saved to #{file_path}"
      puts "you might want to copy it to features/data/minimal_meta.yml"
    end

    desc "Import MetaData Presets" 
    task :import_presets => :environment do
      DevelopmentHelpers::MetaDataPreset.load_minimal_yaml
    end

  end
end

