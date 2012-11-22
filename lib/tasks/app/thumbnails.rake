namespace :app do

  namespace :thumbnails do
    
    desc "generate base thumbnails with extensions described in config/mime_icons.yml" 
    task :generate do
      dir = File.join(Rails.root, "app/assets/images/thumbnails")
      types = YAML.load File.read(File.join(Rails.root, "config/mime_icons.yml"))
      types["icons"].each do |type|
        type["extensions"].each do |extension|
          source_file = File.join(dir, type["icon"])
          base_extension = File.extname(type["icon"])
          target_file = File.join(dir, [File.basename(type["icon"], base_extension), ".", extension, base_extension].join)
          pointsize = extension.size > 4 ? 100 / extension.size : 25
          `convert "#{source_file}" -pointsize #{pointsize} -gravity North -fill '#777777' -annotate +0+15 '#{extension}' "#{target_file}"`
        end
      end
    end
    
    namespace :generate do
      desc "generate base thumbnails for redesign with extensions described in config/mime_icons.yml" 
      task :redesign do
        dir = File.join(Rails.root, "app/assets/images/redesign/thumbnails")
        types = YAML.load File.read(File.join(Rails.root, "config/mime_icons.yml"))
        types["icons"].each do |type|
          type["extensions"].each do |extension|
            source_file = File.join(dir, type["icon"])
            base_extension = File.extname(type["icon"])
            target_file = File.join(dir, [File.basename(type["icon"], base_extension), ".", extension, base_extension].join)
            pointsize = extension.size > 4 ? 60 / extension.size : 16
            offset = extension.size > 4 ? 2 : 0
            `convert "#{source_file}" -pointsize #{pointsize} -gravity North -font 'lib/fonts/OpenSans-Regular.ttf' -fill '#767676' -annotate +0+#{49+offset} '#{extension}' "#{target_file}"`
          end
        end
      end
    end

  end
  
end
