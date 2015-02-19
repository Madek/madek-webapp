# Note: git blame, most if not all of this was copied over
module MediaFileModules
  module Previews
    extend ActiveSupport::Concern
    module ClassMethods
    end

    def get_preview(size = nil, type = nil)
      _previews = previews
      if size
        _previews = _previews.where(:thumbnail => size)
      end
      if type
        _previews = _previews.where(:content_type => type)
      end
      _previews.first
    end

    def previews_creatable? 
      ['image'].include? media_type or \
        ['application/pdf'].include? content_type
    end

    def recreate_image_previews!
      raise "Previews can only be recreated for images and pdfs" unless previews_creatable?
      previews.destroy_all
      create_previews!
    end

    def create_previews!
      if previews_creatable? 
        create_jpeg_previews_for_file file_storage_location
      end
    end

    def create_jpeg_previews_for_file file 
      raise "Input file doesn't exist!" unless File.exist?(file)
      THUMBNAILS.each do |thumb_size,value|
        tmparr = thumbnail_storage_location
        tmparr += "_#{thumb_size.to_s}"
        outfile = [tmparr, 'jpg'].join('.')
        value ||= "#{width}x#{height}" if thumb_size == :maximum
        cmd= %Q<convert "#{file}"[0] -auto-orient -thumbnail "#{value}" -flatten -unsharp 0x.5 "#{outfile}">
        Rails.logger.info "CREATING THUMBNAIL `#{cmd}`"
        `#{cmd}`
        if File.exists?(outfile) 
          x,y = `identify -format "%wx%h" "#{outfile}"`.split('x')
          if x and y
            previews.create(:content_type => 'image/jpeg', :filename => outfile.split('/').last, :height => y, :width => x, :thumbnail => thumb_size.to_s )
          end
        else
          Rails.logger.warn "Failed to create preview #{thumb_size} #{file} " 
        end
      end
    end

    def thumb_base64(size = :small)
      size = size.to_sym

      preview = case content_type
                when /video/ then
                  # Get the video's covershot that we've extracted/thumbnailed on import
                  get_preview(size) || "Video"
                when /audio/ then
                  "Audio"
                when /image/, /pdf/ then
                  get_preview(size) || "Image"
                else 
                  "Doc"
                end

      unless preview.is_a? String
        file = File.join(THUMBNAIL_STORAGE_DIR, shard, preview.filename)
        if File.exist?(file)
          output = File.read(file)
          return "data:#{preview.content_type};base64,#{Base64.encode64(output)}"
        else
          preview = "Image"
        end
      end

      output = thumb_placeholder(size)
      "data:#{content_type};base64,#{Base64.encode64(output)}"
    end

    def thumb_placeholder(size)
      dir = File.join(Rails.root, "app/assets/images/thumbnails")
      @@placeholders ||= Dir.glob(File.join(dir, "*"))
      extension = File.extname(filename).downcase
      if extension.blank? 
        case size
        when :small
          file_path = File.join(dir, "document_small_unknown.png")
        else
          file_path = File.join(dir, "document_unknown.png")
        end
      else
        if size == :small
          file_path = @@placeholders.detect {|x| x =~ /_small#{extension}\.png$/ }
          file_path ||= File.join(dir, "document_small_unknown.png")
        else
          file_path = @@placeholders.detect {|x| x =~ /#{extension}\.png$/ and not x =~ /_small/ }
          file_path ||= File.join(dir, "document_unknown.png")
        end
      end
      File.read file_path
    end

  end
end
