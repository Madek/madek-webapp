# not as bad as the preview module, needs cleanup however 
# no time to care about this as part of madek-v3 ;-O
# TODO TODO TODO
#
#
# Note: git blame, most if not all of this was copied over
#
# this module is used to extract meta_data from an imported
# file and set the meta_data attribute for the media_file
#
# this code as (almost) nothing to do with the MetaData model related
# to a MediaResource
#
# there is a similar named module used with media_entry_incomplete to 
# set actual MetaData 
#
module MediaFileModules
  module MetaDataExtraction
    extend ActiveSupport::Concern
    module ClassMethods
    end

    def import_meta_data
      case content_type
      when /image/ then
        import_image_metadata(file_storage_location) 
      when /video/ then
        import_audio_video_metadata(file_storage_location)
      when /audio/ then
        import_audio_metadata(file_storage_location)
      when /application/ then
        import_document_metadata(file_storage_location)
      else
        # TODO implement other content_types
      end
      update_attributes(:meta_data => meta_data)
    end


    def meta_data_without_binary
      r = meta_data.reject{|k,v| ["!binary |", "Binary data"].any?{|x| v.to_yaml.include?(x)}}
      r.map {|x| x.map{|y| y.to_s.dup.force_encoding('utf-8') } }
    end


    def import_image_metadata(full_path_file)
      self.meta_data ||= {}
      group_tags = ['File:', 'Composite:', 'IFD', 'ICC-','ICC_Profile','XMP-exif', 'XMP-xmpMM', 'XMP-aux', 'XMP-tiff', 'Photoshop:', 'ExifIFD:', 'JFIF', 'IFF:', 'GPS:', 'PNG:' ] #'System:' leaks system info
      ignore_fields = ['UserComment','ImageDescription', 'ProfileCopyright', 'System:']
      exif_hash = {}

      blob = Exiftool.parse_metadata(full_path_file, group_tags)
      blob.each do |tag_array_entry|
        tag_array_entry.each do |entry|
          exif_hash[entry[0]]=entry[1] unless ignore_fields.any? {|w| entry[0].include? w }
        end
        meta_data.merge!(exif_hash)
      end
      # Use ImageMagick to get dimensions; exiftool turned out to be unreliable 
      # HACK: working around a bug where ImageMagick exits which error even if only warning were issued (issue reported upstream)
      #original:# img_x, img_y= System.execute_cmd!("identify -format '%w %h' #{full_path_file}").split
      output= `identify -format '%w %h' #{full_path_file}`
      begin
        img_x, img_y= output.split
      rescue
        raise "ImageMagick: No sizes found!"
      end
      update_attributes(:width => img_x, :height => img_y)
    end

    def import_audio_video_metadata(full_path_file)
      # TODO: merge with import_image_metadata, make fields configurable in :options hash
      self.meta_data ||= {}

      # The Tracks: entries describe video, audio or subtitle tracks present in the container. We extract 10
      # because we think no one would be mad enough to have more.
      tracks = []
      [1..10].each do |n|
        tracks << "Track#{n}:"
      end

      group_tags = ['File:', 'Composite:', 'IFD', 'ICC-','ICC_Profile','XMP-exif', 'XMP-xmpMM', 'XMP-aux', 'XMP-tiff', 'Photoshop:', 'ExifIFD:', 'JFIF', 'IFF:', 'GPS:', 'PNG:', 'QuickTime:'] + tracks #'System:' leaks system info
      ignore_fields = ['UserComment','ImageDescription', 'ProfileCopyright', 'System:']
      exif_hash = {}

      blob = Exiftool.parse_metadata(full_path_file, group_tags)
      blob.each do |tag_array_entry|
        tag_array_entry.each do |entry|
          exif_hash[entry[0]]=entry[1] unless ignore_fields.any? {|w| entry[0].include? w }
        end
        meta_data.merge!(exif_hash)
      end

      # Exiftool couldn't get the dimensions. Let's try with ffmpeg
      if exif_hash["Composite:ImageSize"].nil?
        img_x, img_y = get_sizes_from_ffmpeg(full_path_file)
      else
        img_x, img_y = exif_hash["Composite:ImageSize"].split("x")
      end
      update_attributes(:width => img_x, :height => img_y)
    end

    def get_sizes_from_ffmpeg(path)
      out = `ffmpeg -i #{path} 2>&1`
      out.split("\n").each do |line|
        if line =~ /.*Stream.*Video.*/
          x, y = line.scan(/\d+x\d+/).first.split("x")
          return [x, y]
        end
      end
    end

    def import_audio_metadata(full_path_file)

      # TODO refactor to use ffmpeg, some id3 tag extractor, etc.
    end

    def import_document_metadata(full_path_file)
      #TODO - specifically for other non-zipped documents (e.g. source code, application binary, etc)
    end

  end
end
