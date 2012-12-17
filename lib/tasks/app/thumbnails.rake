namespace :app do

  namespace :thumbnails do
    
    desc "generate base thumbnails with extensions described in config/mime_icons.yml" 
    task :generate do
      dir = File.join(Rails.root, "app/assets/images/thumbnails")
      yaml = YAML.load File.read(File.join(Rails.root, "config/mime_icons.yml"))
      yaml["icons"].each do |type|
        type["extensions"].each do |extension|
          source_file = File.join(dir, "base", type["icon"])
          base_extension = File.extname(type["icon"])
          target_file = File.join(dir, [File.basename(type["icon"], base_extension), ".", extension, base_extension].join)

          # MEDIUM
          size = 26
          pointsize = extension.size > 4 ? size*2 / extension.size : size
          offset = extension.size > 4 ? 2 : 0
          `convert "#{source_file}" -pointsize #{pointsize} -gravity North -font 'lib/fonts/OpenSans-Regular.ttf' -fill '#767676' -annotate +0+#{50+offset} '#{extension}' "#{target_file}"`

          # SMALL
          source_file = source_file.gsub(/\.png$/, "_small.png")
          target_file = File.join(dir, [File.basename(type["icon"], base_extension), "_small", ".", extension, base_extension].join)
          pointsize = extension.size > 4 ? 55 / extension.size : 14
          offset = extension.size > 4 ? 1 : 0
          `convert "#{source_file}" -pointsize #{pointsize} -gravity North -font 'lib/fonts/OpenSans-Regular.ttf' -fill '#767676' -annotate +0+#{21+offset} '#{extension}' "#{target_file}"`

        end
      end

      # UNKNOWN
      yaml["unknown"].each do |type|

        # MEDIUM
        source_file = File.join(dir, "base", "#{type}.png")
        output_file = File.join(dir, "#{type}_unknown.png")
        `convert #{source_file} -distort Affine '0,0 0,12' "#{output_file}"`

        # SMALL
        source_file = File.join(dir, "base", "#{type}_small.png")
        output_file = File.join(dir, "#{type}_small_unknown.png")
        `convert #{source_file} -distort Affine '0,0 0,6' "#{output_file}"`

      end

    end

  end
  
end
