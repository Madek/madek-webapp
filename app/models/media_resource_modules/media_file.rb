# -*- encoding : utf-8 -*-

module MediaResourceModules
  module MediaFile

    # NOTE this is defined up in MediaResource because eager loading
    #def self.included(base)
    #  base.class_eval do
    #    belongs_to :media_file #, :include => :previews # TODO validates_presence # TODO on destroy, also destroy the media_file if this is the only related media_entry
    #  end
    #end

    # Instance method to update a copy (referenced by path) of a media file with the meta_data tags provided
    # args: blank_all_tags = flag indicating whether we clean all the tags from the file, or update the tags in the file
    # returns: the path and filename of the updated copy or nil (if the copy failed)
    def updated_resource_file(blank_all_tags = false, size = nil)
      begin
        source_filename, content_type = if size
          p = media_file.get_preview(size)
          [p.full_path, p.content_type]
        else
          [media_file.file_storage_location, media_file.content_type]
        end
        FileUtils.cp( source_filename, DOWNLOAD_STORAGE_DIR )
        # remember we want to handle the following:
        # include all madek tags in file
        # remove all (ok, as many as we can) tags from the file.
        cleaner_tags = (blank_all_tags ? "-All= " : "-IPTC:All= ") + "-XMP-madek:All= -IFD0:Artist= -IFD0:Copyright= -IFD0:Software= " # because we do want to remove IPTC tags, regardless
        tags = cleaner_tags + (blank_all_tags ? "" : to_metadata_tags)
  
        path = File.join(DOWNLOAD_STORAGE_DIR, File.basename(source_filename))
        # TODO Tom ask: why is this called from here and not when the meta_key_definitions are updated? 
        Exiftool.generate_exiftool_config if MetaContext.io_interface.meta_key_definitions.maximum("updated_at").to_i > File.stat(EXIFTOOL_CONFIG).mtime.to_i
  
        resout = `#{EXIFTOOL_PATH} #{tags} "#{path}"`
        FileUtils.rm("#{path}_original") if resout.include?("1 image files updated") # Exiftool backs up the original before editing. We don't need the backup.
        return [path.to_s, content_type]
      rescue 
        # "No such file or directory" ?
        logger.error "copy failed with #{$!}"
        return [nil, nil]
      end
    end
      
    def get_media_file(user = nil)
      media_file
    end

    def media_type
      if media_file_id
        case media_file.content_type
          when /video/ then 
            "Video"
          when /audio/ then
            "Audio"
          when /image/ then
            "Image"
          else 
            "Doc"
        end 
      else
        self.type.gsub(/Media/, '')
      end    
    end

  end
end



