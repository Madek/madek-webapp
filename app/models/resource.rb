# -*- encoding : utf-8 -*-
module Resource
  
  TS_FIELDS = [:user]
  TS_ATTRIBUTE_DEFINITIONS = [['sphinx_internal_id', 'int'], ['class_crc', 'int'], ['sphinx_deleted', 'int', '0'], # required by thinking sphinx
                              ['user_id', 'int'], # association attributes
                              ['updated_at', 'timestamp'], ['media_type', 'int']]
  
  def self.included(base)
   # TODO observe bulk changes and reindex once
    base.has_many :meta_data, :as => :resource, :dependent => :destroy do #working here#7 :include => :meta_key
      def all_cached
        # OPTIMIZE since we are using the cache_key, we dont' actually need the expires_in, but let's keep it just for safety
        Rails.cache.fetch("#{proxy_owner.class}/#{proxy_owner.cache_key}/meta_data", :expires_in => 10.minutes) do
          all
        end
      end

      def get(key_id)
        # unless ... and !!v.match(/\A[+-]?\d+\Z/) # TODO path to String#is_numeric? method
        #key_id = MetaKey.find_by_label(key_id.downcase).id unless key_id.is_a?(Fixnum)
        #TODO: handle the case when key_id is a MetaKey object
        key_id = MetaKey.all_cached.detect {|mk| mk.label == key_id.downcase }.id unless key_id.is_a?(Fixnum)

        #r = where(:meta_key_id => key_id).first # OPTIMIZE prevent find if is_dynamic meta_key
        r = all_cached.detect {|md| md.meta_key_id == key_id}

        r ||= build(:meta_key_id => key_id)
      end

      def get_value_for(key_id)
        get(key_id).to_s
      end

      # indexing to sphinx
      def with_labels
        h = {}
        all_cached.each do |meta_datum|
          next unless meta_datum.meta_key # FIXME inconsistency: there are meta_data referencing to not existing meta_key_ids [131, 135]
          h[meta_datum.meta_key.label] = meta_datum.to_s
        end
        h
      end
    end
    base.accepts_nested_attributes_for :meta_data, :allow_destroy => true,
                                               :reject_if => proc { |attributes| attributes['value'].blank? and attributes['_destroy'].blank? }
                                               # NOTE the check on _destroy should be automatic, check Rails > 3.0.3

#temp#
#    # enforce meta_key uniqueness updating existing meta_datum
#    # also useful for bulk meta_data updates such as Copyright, Organizer forms,...
#    base.before_validation(:on => :update) do |record|
#      new_meta_data = record.meta_data.select{|md| md.new_record? }
#      new_meta_data.each do |new_md|
#        old_md = record.meta_data.detect{|md| !md.new_record? and md.meta_key_id == new_md.meta_key_id }
#        if old_md
#          old_md.value = new_md.value
#          record.meta_data.delete(new_md)
#        end
#      end
#    end

    base.has_many  :permissions, :as => :resource, :dependent => :destroy
    base.before_validation { permissions.delete_if {|p| p.new_record? and p.subject.nil? and p.invalid? } } #2904# OPTIMIZE
    base.after_create :generate_permissions

    base.has_many  :edit_sessions, :as => :resource, :dependent => :destroy, :readonly => true, :limit => 5
    base.has_many  :editors, :through => :edit_sessions, :source => :user do
      def latest
        first
      end
    end

    base.validates_presence_of :user, :if => Proc.new { |record| record.respond_to?(:user_id) }

    def update_attributes_with_pre_validation(attributes, current_user = nil)
      # we need to deep copy the attributes for batch edit (multiple resources)
      dup_attributes = Marshal.load(Marshal.dump(attributes))

      # To avoid overriding at batch update: remove from attribute hash if :keep_original_value and value is blank
      dup_attributes[:meta_data_attributes].delete_if { |key, attr| attr[:keep_original_value] and attr[:value].blank? }

      dup_attributes[:meta_data_attributes].each_pair do |key, attr|
        if attr[:value].is_a? Array and attr[:value].all? {|x| x.blank? }
          attr[:value] = nil
        end

        # find existing meta_datum, if it exists
        if attr[:id].blank? and (md = meta_data.all_cached.detect {|md| md.meta_key_id == attr[:meta_key_id].to_i}) #(md = meta_data.where(:meta_key_id => attr[:meta_key_id]).first)
          attr[:id] = md.id
        end

        # get rid of meta_datum if value is blank
        if !attr[:id].blank? and attr[:value].blank?
          attr[:_destroy] = true
          #old# attr[:value] = "." # NOTE bypass the validation
        end
      end if dup_attributes[:meta_data_attributes]

      self.editors << current_user if current_user # OPTIMIZE group by user ??
      self.updated_at = Time.now # used for cache invalidation and sphinx reindex # OPTIMIZE touch or sphinx_touch ??

      # OPTIMIZE this fix is a workaround, related to the updated_at used by cache_key
      Rails.cache.delete("#{self.class}/#{self.cache_key}/meta_data")
      
      update_attributes_without_pre_validation(dup_attributes)
    end
    base.alias_method_chain :update_attributes, :pre_validation

    base.scope :accessible_by, lambda { |subject, action|
      ids = subject.accessible_resource_ids(action, base)
      base.where(:id => ids)
    }

    def base.to_sphinxpipe(delta = 0)
      update_all(:delta => 0) if delta == 0

      xml = Builder::XmlMarkup.new
      xml.instruct!

      xml.tag!("sphinx:docset") do
        xml.tag!("sphinx:schema") do
            MetaKey.with_meta_data.each do |key|
              xml.tag!("sphinx:field", :name => key.label.parameterize('_'))
            end

            self::TS_FIELDS.each do |field|
              xml.tag!("sphinx:field", :name => field)
            end

             self::TS_ATTRIBUTE_DEFINITIONS.each do |attr|
                args = {:name => attr[0], :type => attr[1]}
                args[:default] = attr[2] if attr.size > 2
                xml.tag!("sphinx:attr", args)
            end
         end 

          resources = if self.respond_to?(:upload_session)
            self.joins(:upload_session).where(:delta => delta, :upload_sessions => {:is_complete => true})
          else
            self.where(:delta => delta)
          end

          resources.each do |resource|
            # TODO: check whether sphinx:document id needs to be unique
            xml.tag!("sphinx:document", :id => resource.id) do
              resource.meta_data.with_labels.each_pair do |key, value|
                xml.tag!(key.parameterize('_'), value)
              end
              
              self::TS_FIELDS.each do |field|
                xml.tag!(field, resource.send(field))
              end
              
              self::TS_ATTRIBUTE_DEFINITIONS.each do |attr|
                a = attr.first
                next if a == 'sphinx_deleted'
                v = resource.send(a)
                next if v.blank?
                xml.tag!(a, adjust_attr_value_for_sphinx(v))
              end

            end
          end
        end

      puts xml.target!
    end
  
    def base.adjust_attr_value_for_sphinx(val)
      case val
        when ActiveSupport::TimeWithZone
          val.to_i
        when String
          val.to_crc32
        else # Integer
          val
      end
    end
  end

  def default_permission
    Permission.resource_default(self)
  end

  # returns the meta_data for a particular resource, so that it can written into a media file that is to be exported.
  # NB: this is exiftool specific at present, but can be refactored to take account of other tools if necessary.
  # NB: In this case the 'export' in 'get_data_for_export' also means 'download' 
  #     (since we write meta-data to the file anyway regardless of if we do a download or an export)
  def to_metadata_tags
    MetaContext.io_interface.meta_key_definitions.collect do |definition|
      value = meta_data.get(definition.meta_key_id).deserialized_value
      
      definition.key_map.split(',').collect do |km|
        km.strip!
        case definition.key_map_type
          when "Array"
            vo = ["-#{km}= "]
            vo += value.collect {|m| "-#{km}='#{(m.respond_to?(:strip) ? m.strip : m)}'" } if value
            vo
          else
            "-#{km}='#{value}'"          
        end
      end
      
    end.join(" ")
  end

  # Instance method to update a copy (referenced by path) of a media file with the meta_data tags provided
  # args: blank_all_tags = flag indicating whether we clean all the tags from the file, or update the tags in the file
  # returns: the path and filename of the updated copy or nil (if the copy failed)
  def updated_resource_file(blank_all_tags = false, size = nil)
    begin
      source_filename = if size
        media_file.get_preview(size).full_path
      else
        media_file.file_storage_location
      end
      FileUtils.cp( source_filename, DOWNLOAD_STORAGE_DIR )
      # remember we want to handle the following:
      # include all madek tags in file
      # remove all (ok, as many as we can) tags from the file.
      cleaner_tags = (blank_all_tags ? "-All= " : "-IPTC:All= ") + "-XMP-madek:All= -IFD0:Artist= -IFD0:Copyright= -IFD0:Software= " # because we do want to remove IPTC tags, regardless
      tags = cleaner_tags + (blank_all_tags ? "" : to_metadata_tags)

      path = File.join(DOWNLOAD_STORAGE_DIR, File.basename(source_filename))
      # TODO - robustification
      generate_exiftool_config if MetaContext.io_interface.meta_key_definitions.maximum("updated_at").to_i > File.stat(EXIFTOOL_CONFIG).mtime.to_i

      resout = `#{EXIFTOOL_PATH} #{tags} "#{path}"`
      FileUtils.rm("#{path}_original") if resout.include?("1 image files updated") # Exiftool backs up the original before editing. We don't need the backup.
      return path.to_s
    rescue 
      # "No such file or directory" ?
      logger.error "MediaFile#update_file_metadata, copy failed with #{$!}"
      return nil
    end
  end

  # ad-hoc method that generates a new exiftool config file, when it is sensed that there are new keys/key_defs that should be saved in a file
  # using the XMP-madek metadata namespace.
  # TODO refactor the use of exiftool, so that for each media file/entry it is only called once, 
  # entrys' contents cached, and obj/subj meta-data extracted as necessary  
    def generate_exiftool_config
      exiftool_keys = MetaContext.io_interface.meta_key_definitions.collect {|e| "#{e.key_map.split(":").last} => {#{e.key_map_type == "Array" ? " List => 'Bag'" : nil} },"}
  
      skels = Dir.glob("#{METADATA_CONFIG_DIR}/ExifTool_config.skeleton.*")
  
      exif_conf = File.open(EXIFTOOL_CONFIG, 'w')
      exif_conf.puts IO.read(skels.first)
      exiftool_keys.sort.each do |k|
        exif_conf.puts "\t#{k}\n"
      end
      exif_conf.puts IO.read(skels.last)
      exif_conf.close
    end
    
    
    # NEW and experimental for batch processes 
    def get_basic_info(extended_keys = [])
      core_keys = ["title", "author"]
      core_info = Hash.new
      
      (core_keys + extended_keys).each do |key|
        core_info[key.gsub(' ', '_')] = meta_data.get_value_for(key)
      end
      core_info["thumb_base64"] = thumb_base64(:small_125)
      core_info
    end

    def thumb_base64(size = :small)
      media_file = if self.is_a?(Media::Set)
        self.media_entries.first.try(:media_file)
      else
        self.media_file
      end

      # TODO give access to the original one?
      # available_sizes = THUMBNAILS.keys #old# ['small', 'medium']
      # size = 'small' unless available_sizes.include?(size)

      if media_file
        preview = case media_file.content_type
                    when /video/ then
                      # Get the video's covershot that we've extracted/thumbnailed on import
                      media_file.get_preview(size) || "Video"
                    when /audio/ then
                      "Audio"
                    when /image/ then
                      media_file.get_preview(size) || "Image"
                    else 
                      "Doc"
                  end

        # OPTIMIZE
        unless preview.is_a? String
          file = File.join(THUMBNAIL_STORAGE_DIR, media_file.shard, preview.filename)
          if File.exist?(file)
           output = File.read(file)
           return "data:#{preview.content_type};base64,#{Base64.encode64(output)}"
          else
            preview = "Image" # OPTIMIZE
          end
        end

        # nothing found, we show then a placeholder icon
        size = if size == :large
          :medium
        else
          :small
        end
        output = File.read("#{Rails.root}/public/images/#{preview}_#{size}.png")
        return "data:#{media_file.content_type};base64,#{Base64.encode64(output)}"      
      end
    end
    

########################################################

  # OPTIMIZE
#  scope :without_meta_data, :select => "media_entries.*",
#                                  #:joins => "LEFT JOIN items ON items.model_id = models.id",
#                                  #:conditions => ['items.model_id IS NULL']

  def title
    t = meta_data.get_value_for("title")
    t = "Ohne Titel" if t.blank?
    t
  end

  def title_and_user
    "#{title} (#{user})"
  end
  
########################################################

  def self.to_tms_doc(resources, context = MetaContext.tms)
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.madek(:version => RELEASE_VERSION) do
      Array(resources).each do |resource|
        resource.to_tms(xml, context)
      end
    end
  end
  
########################################################
### For Sphinx  
  
  def sphinx_internal_id
    id
  end

  def class_crc
    self.class.base_class.to_crc32 #old#.to_s
  end

########################################################
# TODO cache methods results

  def meta_data_for_context(context = MetaContext.core, build_if_not_exists = true)
    @meta_data_for_context ||= {}
    # OPTIMIZE cache for build_if_not_exists
    #unless @meta_data_for_context[context.id]
      @meta_data_for_context[context.id] = []

      context.meta_keys.each do |key|
        md = key.meta_data.scoped_by_resource_type_and_resource_id(self.class.base_class.name, self.id).first  # OPTIMIZE eager loading
        if md
          @meta_data_for_context[context.id] << md
        elsif build_if_not_exists or key.is_dynamic?
          @meta_data_for_context[context.id] << meta_data.build(:meta_key => key)
        end
      end if context
    #end
    return @meta_data_for_context[context.id]
  end

  def context_warnings(context = MetaContext.core)
    @context_warnings ||= {}
    unless @context_warnings[context.id]
      @context_warnings[context.id] = {}
      meta_data_for_context(context).each do |meta_datum|
        w = meta_datum.context_warnings(context)
        unless w.blank?
          @context_warnings[context.id][meta_datum.meta_key.label] ||= []
          @context_warnings[context.id][meta_datum.meta_key.label] << w
        end
      end
    end
    return @context_warnings[context.id]
  end

  def context_valid?(context = MetaContext.core)
    meta_data_for_context(context).all? {|meta_datum| meta_datum.context_valid?(context) }
  end

########################################################

  def media_type
    if respond_to?(:media_file)
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
      self.type.gsub(/Media::/, '')
    end    
  end

########################################################
# ACL

  def acl?(action, scope, subject = nil)
    case scope
      when :all
        # TODO ?? use :permissions association
        Permission.authorized?(nil, action, self)
      when :only
        Permission.resource_viewable_only_by_user?(self, subject)
    end
  end

private

  def generate_permissions
    # OPTIMIZE
    unless self.class == Snapshot
      subject = self.user
    else
      #1504#
      h = media_entry.default_permission.actions
      permissions.build(:subject => nil).set_actions(h) unless h.blank?
      subject = Group.find_or_create_by_name("MIZ-Archiv") # Group.scoped_by_name("MIZ-Archiv").first
    end

    # TODO solve inconsistency between search 'by_user' sphinx_scope and the actual permissions
    # TODO validates presence of the owner's permissions?
    if subject
     user_default_permissions = {:view => true, :edit => true, :manage => true}
     user_default_permissions[:hi_res] = true if self.class == MediaEntry
     permissions.build(:subject => subject).set_actions(user_default_permissions)  
    end # OPTIMIZE
  end

end
