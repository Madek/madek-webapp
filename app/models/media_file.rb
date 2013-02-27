# -*- encoding : utf-8 -*-
# require 'digest'

class MediaFile < ActiveRecord::Base
  has_one :media_entry
  has_many :zencoder_jobs

  def most_recent_zencoder_job
    zencoder_jobs.reorder("zencoder_jobs.created_at DESC").limit(1).first
  end

  before_create do
    self.guid = UUIDTools::UUID.random_create.hexdigest
    self.access_hash = SecureRandom.uuid 
    
    #TODO - check for zip files and process accordingly
    unless importable_zipfile?
      set_filename
    else
      explode_and_import(uploaded_data)
      # do the explode and import in the background
    end
  end
  
  after_create do
    # Move the file out to storage
    FileUtils.mv uploaded_data.tempfile.path, file_storage_location

    # NOTE: chmod no longer necessary because we are sending the file with the right umask through
    # vsftpd (umask 022)
    # chmod so that Apache's X-Sendfile gets access to this file, even though it is running under
    # a different user.
    if File.stat(file_storage_location).uid == Process.uid # Only do this if we have permission to do so (= are the owner of the file)
      File.chmod(0755, file_storage_location)
    end
    import if meta_data.blank? # TODO in background?
    make_thumbnails
  end

  after_destroy do
    # TODO ensure that the media file is not still being used by another media_entry
    File.delete(file_storage_location)
  end

#########################################################

  validates_presence_of :uploaded_data, :on => :create

  attr_accessor :uploaded_data

  serialize     :meta_data, Hash

  has_many      :media_entries # TODO validation: at least one media_entry (even empty) 
  has_many      :previews, :dependent => :destroy # TODO - the eventual resting place of all preview files derived from the original (e.g. thumbnails)

  scope :original, where(:parent_id => nil)

#########################################################

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

  def import
    case content_type
      when /image/ then
        import_image_metadata(file_storage_location) if previews.empty? # TODO why?
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

  # String with the UNIX path to the sharded location of this media file.
  # Files should *not* be in a publicly-accessible location, instead, they are served through
  # some X-Sendfile implementation of your web server.
  #
  # Basing the shard on (some non-zero) part of the guid gives us a trivial 'storage balancer' which completely ignores
  # any size attributes of the file, and distributes amongst directories pseudorandomly (which in practice averages out in the long-term).
  #
  # @return [String] UNIX path to the media file.
  # @example
  #   "/home/rails/madek/releases/20120920155659/db/media_files/attachments/b/bcd1eb0a90d9404b8e8ac689b18b45bd"
  
  def file_storage_location
    File.join(FILE_STORAGE_DIR, shard, guid)
  end

  # The first portion of the UNIX path to the sharded location of the thumbnail for this media file.
  # Thumbnails should be in a publicly-accessible location so that e.g. Apache can serve them up.
  # Thumbnail sare also thought of as "previews", so consider that this might be a 200 MB video file as well as tiny PNGs.
  # @return [String] Beginning of the UNIX path to potential thumbnails, ending in the guid of the file.
  # @example
  #   "/home/rails/madek/releases/20120920155659/public/previews/b/bcd1eb0a90d9404b8e8ac689b18b45bd"
  def thumbnail_storage_location
    File.join(THUMBNAIL_STORAGE_DIR, shard, guid)
  end

  # set some attributes, for use when storing the file.
  # NB Depending on if we are being called from a rake task or the webserver, we either get a tempfile or an array.
  def set_filename
    self.filename = uploaded_data.original_filename
    self.size = uploaded_data.size

    # Mac OS X is untrustworthy and often provides wrong MIME types, e.g. for PDFs and QuickTime .mov files. Therefore we must distrust
    # everyone else as well and find our own MIME types.
    self.content_type = Rack::Mime.mime_type(File.extname(filename))
    self.extension = File.extname(self.filename).downcase.gsub(/^\./,'')
    self.media_type = MediaFile.media_type(self.content_type)
  end


  def shard
    self.guid[0..0]
  end

  def make_thumbnails(sizes = nil)
    case content_type
      when /image/, /pdf/ then
        thumbnail_jpegs_for(file_storage_location, sizes)
    end
  end

  
  def thumbnail_jpegs_for(file, sizes = nil)
    return unless File.exist?(file)
    THUMBNAILS.each do |thumb_size,value|
      next if sizes and !sizes.include?(thumb_size)
      tmparr = thumbnail_storage_location
      tmparr += "_#{thumb_size.to_s}"
      outfile = [tmparr, 'jpg'].join('.')
      value ||= "#{width}x#{height}" if thumb_size == :maximum
      `convert "#{file}"[0] -auto-orient -thumbnail "#{value}" -flatten -unsharp 0x.5 "#{outfile}"`
      if File.exists?(outfile)
        x,y = `identify -format "%wx%h" "#{outfile}"`.split('x')
        if x and y
          previews.create(:content_type => 'image/jpeg', :filename => outfile.split('/').last, :height => y, :width => x, :thumbnail => thumb_size.to_s )
        end
      else
        # if convert failed, we need to take or delegate off some rescue action, ideally.
        # but for the moment, lets just imply no-thumbnail need be made for this size
      end
    end
  end

  def thumb_base64(size = :small)
    size = size.to_sym

    # TODO give access to the original one?
    # available_sizes = THUMBNAILS.keys #old# ['small', 'medium']
    # size = 'small' unless available_sizes.include?(size)

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

    # OPTIMIZE
    unless preview.is_a? String
      file = File.join(THUMBNAIL_STORAGE_DIR, shard, preview.filename)
      if File.exist?(file)
       output = File.read(file)
       return "data:#{preview.content_type};base64,#{Base64.encode64(output)}"
      else
        preview = "Image" # OPTIMIZE
      end
    end

    # nothing found, we show then a placeholder icon
    case Rails.env
      when false # "development"
        self.class.thumb_lorempixum_url id, size
      else
        # TODO remove code related to preview as string
        #size = (size == :large ? :medium : :small)
        output = thumb_placeholder(size)
        "data:#{content_type};base64,#{Base64.encode64(output)}"
    end
  end
  
  def thumb_placeholder(size)
    dir = File.join(Rails.root, "app/assets/images/thumbnails")
    @@placeholders ||= Dir.glob(File.join(dir, "*"))
    extension = File.extname(filename).downcase
    if size == :small
      file_path = @@placeholders.detect {|x| x =~ /_small#{extension}\.png$/ }
      file_path ||= File.join(dir, "document_small_unknown.png")
    else
      file_path = @@placeholders.detect {|x| x =~ /#{extension}\.png$/ and not x =~ /_small/ }
      file_path ||= File.join(dir, "document_unknown.png")
    end
    File.read file_path
  end

  class << self
    def thumb_lorempixum_url(id, size = :small)
      w, h = THUMBNAILS[size].split('x').map(&:to_i)
      categories = %w(abstract food people technics animals nightlife nature transport city fashion sports)
      cat = categories[id % categories.size]
      n = (id % 10) + 1
      "http://lorempixum.com/#{w}/#{h}/#{cat}/#{n}"
    end
  end

######################################################################

  def importable_zipfile?
    uploaded_data.original_filename.include?('__IMPORT__') and uploaded_data.original_filename.include?('.zip')
  end


# IMAGES 
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
    # FIXME - We are inserting image-specific data into a model that is generic in intent, for the convenience of it all.
    # Apparently IFD0 is not the best fit (some files don't contain it), perhaps we should use the Composite:ImageSize tag, till we get rid of these columns..
    img_x, img_y = exif_hash["Composite:ImageSize"].split("x")
    update_attributes(:width => img_x, :height => img_y)
  end

#####################################################################################################################

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
  
# This kind of thing REALLY needs to happen of elsewhere asynchronously, otherwise we move inexorably towards the day the site gets DOS'd. 
# ie when a user uploads a malevolent zip that unpacks to some ridiculous storage-busting size..
# TODO - explode and import the contents of a zip file
# this may be a rag-tag collection of any old rubbish, so we need to try and impose a few minimal rules on the proceedings.
# - contains some kind of media file (as per madek media types list)
# - optionally contains an xml metadata file, conforming to the Dublin Core XML schema, or other agreed schemas
  def explode_and_import(full_path_file)

    racer_x = rand(Time.now.to_i).to_s
    Dir.mkdir("#{Rails.root}/tmp/unzipfiles/#{racer_x}")
    # logger.info "inspect: #{full_path_file[:tempfile].inspect}"
    # logger.info "full_path_file[:tempfile] stat=#{full_path_file[:tempfile].stat.inspect}"
    # logger.info "full_path_file[:tempfile] path=#{full_path_file[:tempfile].path.inspect}"
    z = Zip::ZipFile.open(full_path_file[:tempfile].path)
    mf = []
    # logger.info { "*****************************************************************" }
    # logger.info { "ZIPFLE HAS #{z.entries.size} ENTRIES" }
    destination = "#{Rails.root}/tmp/unzipfiles/#{racer_x}/" # TODO configurable
    z.each do |ent|
      next if ent.name =~ /__MACOSX/ or ent.name =~ /\.DS_Store/ or !ent.file?
      # logger.info "ZIPFLE Entry #{ent}"
      f_path=File.join(destination, ent.name)
      # logger.info "f_path=#{f_path}"
      FileUtils.rm_rf f_path if File.exist?(f_path)
      # logger.info "remove pth"
      FileUtils.mkdir_p(File.dirname(f_path))
      # logger.info "made directory"
      z.extract(ent, f_path)
      # logger.info "just extracted #{ent} to #{f_path}"
      mimetype = `#{FILE_UTIL_PATH} "#{Rails.root}/tmp/unzipfiles/#{racer_x}/#{ent}"`.gsub(/\n/,"")
      # logger.info "mimetype=#{mimetype}"

      #TODO something intelligent and asynchronous here, to allow us to go through the files in the zip and insert them, optionally adding any yaml metadata we find that relate to media.
      # mf << MediaFile.create(:uploaded_data => ActionController::TestUploadedFile.new("#{Rails.root}/tmp/unzipfiles/#{racer_x}/#{ent}", mimetype))
    end
    resout = `rake madek:importer:import[#{full_path_file["current_user"]}, "#{Rails.root}/tmp/unzipfiles/#{racer_x}/"]`
    res = $?
  end


  def import_document_metadata(full_path_file)
    #TODO - specifically for other non-zipped documents (e.g. source code, application binary, etc)
  end
 
  def self.media_type(content_type)
    unless content_type
      "other"
    else
      case content_type
      when /^image/
        "image"
      when /^video/
        "video"
      when /^audio/
        "audio"
      when /^text/
        "document"
      when /^application/
        "document"
      else
        "other"
      end
    end

  end
  
  # OPTIMIZE
  def meta_data_without_binary
    r = meta_data.reject{|k,v| ["!binary |", "Binary data"].any?{|x| v.to_yaml.include?(x)}}
    r.map {|x| x.map{|y| y.to_s.dup.force_encoding('utf-8') } }
  end
  
  def to_s
    "MediaFile: #{id}"
  end

end
