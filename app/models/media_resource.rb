# -*- encoding : utf-8 -*-

require 'media_resource/arcs' # for arcs, parents, and children 
require 'media_resource/permissions'


class MediaResource < ActiveRecord::Base

  after_create do
    if is_a? Snapshot
      group = Group.find_or_create_by_name("MIZ-Archiv") 
      grouppermissions.create(group: group, view: true, edit: true, download: true, manage: true)
    end
  end

###############################################################

  belongs_to :user   # TODO remove down and set missing user for snapshots
  belongs_to :media_file  # TODO remove 

 # TODO observe bulk changes and reindex once
  has_many :meta_data, :dependent => :destroy do #working here#7 :include => :meta_key
    def get(key_id, build_if_not_found = true)
      #TODO: handle the case when key_id is a MetaKey object
      key_id = MetaKey.find_by_label(key_id.downcase).id unless key_id.is_a?(Fixnum)
      r = where(:meta_key_id => key_id).first # OPTIMIZE prevent find if is_dynamic meta_key
      r ||= build(:meta_key_id => key_id) if build_if_not_found
      r
    end

    def get_value_for(key_id)
      get(key_id).to_s
    end

    def get_for_labels(labels)
      joins(:meta_key).where(:meta_keys => {:label => labels})
    end

    #def with_labels
    #  h = {}
    #  all.each do |meta_datum|
    #    next unless meta_datum.meta_key # FIXME inconsistency: there are meta_data referencing to not existing meta_key_ids [131, 135]
    #    h[meta_datum.meta_key.label] = meta_datum.to_s
    #  end
    #  h
    #end
    def concatenated
      all.map(&:to_s).join('; ')
    end
  end
  accepts_nested_attributes_for :meta_data, :allow_destroy => true,
                                             :reject_if => proc { |attributes| attributes['value'].blank? and attributes['_destroy'].blank? }
                                             # NOTE the check on _destroy should be automatic, check Rails > 3.0.3

  def self.find_by_title(title)
    MediaResource.joins(:meta_data => :meta_key).
      where(:meta_data => {:meta_keys => {:label => "title"}, :value => title.to_yaml})
  end
  
#temp#
#    # enforce meta_key uniqueness updating existing meta_datum
#    # also useful for bulk meta_data updates such as Copyright, Organizer forms,...
#    before_validation(:on => :update) do |record|
#      new_meta_data = record.meta_data.select{|md| md.new_record? }
#      new_meta_data.each do |new_md|
#        old_md = record.meta_data.detect{|md| !md.new_record? and md.meta_key_id == new_md.meta_key_id }
#        if old_md
#          old_md.value = new_md.value
#          record.meta_data.delete(new_md)
#        end
#      end
#    end

  has_many  :edit_sessions, :dependent => :destroy, :readonly => true
  has_many  :editors, :through => :edit_sessions, :source => :user do
    def latest
      first
    end
  end

  validates_presence_of :user, :unless => Proc.new { |record| record.is_a?(Snapshot) }

  def update_attributes_with_pre_validation(attributes, current_user = nil)
    # we need to deep copy the attributes for batch edit (multiple resources)
    dup_attributes = Marshal.load(Marshal.dump(attributes)).deep_symbolize_keys

    if dup_attributes[:meta_data_attributes]
      # To avoid overriding at batch update: remove from attribute hash if :keep_original_value and value is blank
      dup_attributes[:meta_data_attributes].delete_if { |key, attr| attr[:keep_original_value] and attr[:value].blank? }
  
      dup_attributes[:meta_data_attributes].each_pair do |key, attr|
        if attr[:value].is_a? Array and attr[:value].all? {|x| x.blank? }
          attr[:value] = nil
        end
  
        # find existing meta_datum, if it exists
        if attr[:id].blank?
          if attr[:meta_key_label]
            attr[:meta_key_id] ||= MetaKey.find_by_label(attr.delete(:meta_key_label)).try(:id)
          end
          if (md = meta_data.where(:meta_key_id => attr[:meta_key_id]).first)
            attr[:id] = md.id
          end
        else
          attr.delete(:meta_key_label)
        end
  
        # get rid of meta_datum if value is blank
        if !attr[:id].blank? and attr[:value].blank?
          attr[:_destroy] = true
          #old# attr[:value] = "." # NOTE bypass the validation
        end
      end
    end

    self.editors << current_user if current_user # OPTIMIZE group by user ??
    self.updated_at = Time.now # OPTIMIZE touch
    update_attributes_without_pre_validation(dup_attributes)
  end
  alias_method_chain :update_attributes, :pre_validation

  has_one :full_text, :dependent => :destroy
  after_save { reindex } # OPTIMIZE


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
      # TODO Tom ask: why is this called from here and not when the meta_key_definitions are updated? 
      Exiftool.generate_exiftool_config if MetaContext.io_interface.meta_key_definitions.maximum("updated_at").to_i > File.stat(EXIFTOOL_CONFIG).mtime.to_i

      resout = `#{EXIFTOOL_PATH} #{tags} "#{path}"`
      FileUtils.rm("#{path}_original") if resout.include?("1 image files updated") # Exiftool backs up the original before editing. We don't need the backup.
      return path.to_s
    rescue 
      # "No such file or directory" ?
      logger.error "copy failed with #{$!}"
      return nil
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
    s = ""
    s += "#{title} (#{user})"
  end
  
########################################################

  def as_json(options={})
    with_thumb = options[:with_thumb]
    more_json = {}
    
    if user = options[:user]
      #TODO Dont do this behaviour on default
      is_public = is_public?
      is_private = (is_public ? false : is_private?(user))
      flags = { :is_public => is_public,
                :is_private => is_private,
                :is_shared => (not is_public and not is_private),
                :is_editable => user.authorized?(:edit, self),
                :is_manageable => user.authorized?(:manage, self),
                :is_favorite => user.favorite_ids.include?(id) }
      more_json.merge! flags
      
      ##################
      core_info = Hash.new
      labels = ["title", "author"]
      labels.each do |label|
        core_info[label.gsub(' ', '_')] = ""
      end
      meta_data.get_for_labels(labels).each do |md|
        core_info[md.meta_key.label.gsub(' ', '_')] = md.to_s
      end
      if with_thumb
        mf = if self.is_a?(MediaSet)
          media_entries.accessible_by_user(user).order("media_resources.updated_at DESC").first.try(:media_file)
        else
          self.media_file
        end
        core_info["thumb_base64"] = mf.thumb_base64(:small_125) if mf
      else
        #1+n http-requests#
        core_info["thumb_base64"] = "/media_resources/%d/image?size=small_125" % id
      end
      ##################
      more_json.merge! core_info
    end

    default_options = {:only => :id}
    json = super(default_options.deep_merge(options))
    
    if(with = options[:with])
      if(with[:media_resource])
        if with[:media_resource].has_key?(:image) and (with[:media_resource][:image].is_a?(Hash) or not with[:media_resource][:image].to_i.zero?)
          size = with[:media_resource][:image][:size] || :small
          
          json[:image] = case with[:media_resource][:image][:as]
            when "base64"
              mf = if self.is_a?(MediaSet)
                media_entries.accessible_by_user(options[:current_user]).order("media_resources.updated_at DESC").first.try(:media_file)
              else
                self.media_file
              end
              mf ? mf.thumb_base64(size) : nil
            else # default return is a url to the image
              "/media_resources/%d/image?size=%s" % [id, size]
          end            
        end
        if with[:media_resource].has_key?(:title) and (with[:media_resource][:title].is_a?(Hash) or not with[:media_resource][:title].to_i.zero?)
          json[:title] = meta_data.get_value_for("title")
        end
        if with[:media_resource].has_key?(:author) and (with[:media_resource][:author].is_a?(Hash) or not with[:media_resource][:author].to_i.zero?)
          json[:author] = meta_data.get_value_for("author")
        end
        if with[:media_resource].has_key?(:type) and (with[:media_resource][:type].is_a?(Hash) or not with[:media_resource][:type].to_i.zero?)
          json[:type] = type.underscore
        end
      end
    end
    
    json.merge(more_json)
  end

########################################################

  # TODO move down to Snapshot class
  def self.to_tms_doc(resources, context = MetaContext.tms)
    xml = ::Builder::XmlMarkup.new
    xml.instruct!
    xml.madek(:version => RELEASE_VERSION) do
      Array(resources).each do |resource|
        resource.to_tms(xml, context)
      end
    end
  end
  
########################################################

  def reindex
    ft = full_text || build_full_text
    new_text = meta_data.concatenated
    [:user].each do |method|
      new_text << " #{send(method)}" if respond_to?(method)
    end
    ft.update_attributes(:text => new_text)
  end

########################################################

  def meta_data_for_context(context = MetaContext.core, build_if_not_exists = true)
    meta_keys = context.meta_keys
    
    mds = meta_data.where(:meta_key_id => meta_keys)
    
    (meta_keys - mds.map(&:meta_key)).select{|x| x.is_dynamic? }.each do |key|
      mds << meta_data.build(:meta_key => key) 
    end

    (context.meta_key_ids - mds.map(&:meta_key_id)).each do |key_id|
      mds << meta_data.build(:meta_key_id => key_id)
    end if build_if_not_exists
    
    mds.sort_by {|md| context.meta_key_ids.index(md.meta_key_id) } 
  end

  def context_warnings(context = MetaContext.core)
    r = {}
    
    meta_data_for_context(context).each do |meta_datum|
      w = meta_datum.context_warnings(context)
      unless w.blank?
        r[meta_datum.meta_key.label] ||= []
        r[meta_datum.meta_key.label] << w
      end
    end

    r
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
      self.type.gsub(/Media/, '')
    end    
  end

##########################################################################################################################
##########################################################################################################################
  
  scope :media_entries_or_media_entry_incompletes, where(:type => ["MediaEntry", "MediaEntryIncomplete"])

  ################################################################

  scope :by_user, lambda {|user| where(["media_resources.user_id = ?", user]) }
  scope :not_by_user, lambda {|user| where(["media_resources.user_id <> ?", user]) }

  ################################################################


  scope :search, lambda {|q|
    sql = joins("LEFT JOIN full_texts ON media_resources.id = full_texts.media_resource_id")
    where_clause= 
      if SQLHelper.adapter_is_postgresql?
        q.split.map{|x| "text ILIKE '%#{x}%'" }.join(' AND ')
      elsif SQLHelper.adapter_is_mysql? 
        q.split.map{|x| "text LIKE '%#{x}%'" }.join(' AND ')
      else
        raise "you sql adapter is not yet supported"
      end
    sql.where(where_clause)
  }

  ################################################################

  def self.by_collection(user_id, cid)
    Rails.cache.read(user: user_id, collection: cid) || raise("Collection not found")
  end

  ################################################################
  

  def self.reindex
    all.map(&:reindex).uniq
  end
  
  def self.filter_media_file(options = {})
    sql = media_entries.joins("RIGHT JOIN media_files ON media_resources.media_file_id = media_files.id")
    
    if options[:width] and not options[:width][:value].blank?
      operator = case options[:width][:operator]
        when "gt"
          ">"
        when "lt"
          "<"
        else
          "="
      end
      sql = sql.where("media_files.width #{operator} ?", options[:width][:value])
    end

    if options[:height] and not options[:height][:value].blank?
      operator = case options[:height][:operator]
        when "gt"
          ">"
        when "lt"
          "<"
        else
          "="
      end
      sql = sql.where("media_files.height #{operator} ?", options[:height][:value])
    end

    unless options[:orientation].blank?
      operator = case options[:orientation].to_i
        when 0
          "<"
        when 1
          ">"
      end
      sql = sql.where("media_files.height #{operator} media_files.width")
    end

    sql    
  end


  private

  # returns the meta_data for a particular resource, so that it can written into a media file that is to be exported.
  # NB: this is exiftool specific at present, but can be refactored to take account of other tools if necessary.
  # NB: In this case the 'export' in 'get_data_for_export' also means 'download' 
  #     (since we write meta-data to the file anyway regardless of if we do a download or an export)
  def to_metadata_tags
    MetaContext.io_interface.meta_key_definitions.collect do |definition|
      definition.key_map.split(',').collect do |km|
        km.strip!
        case definition.key_map_type
          when "Array"
            value = meta_data.get(definition.meta_key_id).deserialized_value
            vo = ["-#{km}= "]
            vo += value.collect {|m| "-#{km}='#{(m.respond_to?(:strip) ? m.strip : m)}'" } if value
            vo
          else
            value = meta_data.get(definition.meta_key_id).to_s
            "-#{km}='#{value}'"          
        end
      end
    end.join(" ")
  end

end
