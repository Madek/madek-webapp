# -*- encoding : utf-8 -*-

class MediaResource < ActiveRecord::Base
  include MediaResourceModules::Arcs
  include MediaResourceModules::MetaData
  include MediaResourceModules::Permissions

###############################################################

  belongs_to :user   # TODO remove down and set missing user for snapshots
  belongs_to :media_file  # TODO remove 

  
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
  has_many  :editors, :through => :edit_sessions, :source => :user

  validates_presence_of :user, :unless => Proc.new { |record| record.is_a?(Snapshot) }

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

  def get_media_file(user = nil)
    media_file
  end
  
########################################################

  # TODO move down to Snapshot class
  def self.to_tms_doc(resources, context = MetaContext.tms)
    require 'active_support/builder' unless defined?(::Builder)
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

  def media_type
    if respond_to?(:media_file) and media_file
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
   
  # ORDERINGS
  
  scope :ordered_by_title, joins(meta_data: :meta_key).where("meta_keys.label = ?",:title).order("meta_data.string ASC")
  scope :ordered_by_author, joins(meta_data: :meta_key).where("meta_keys.label = ?",:author)
    .joins('INNER JOIN meta_data_people ON meta_data.id = meta_data_people.meta_datum_id')
    .joins('INNER JOIN people ON meta_data_people.person_id = people.id')
    .order('people.lastname, people.firstname ASC')


  ################################################################

  scope :media_entries_or_media_entry_incompletes, where(:type => ["MediaEntry", "MediaEntryIncomplete"])
  scope :media_entries, where(:type => "MediaEntry")
  scope :media_sets, where(:type => "MediaSet")

  ###############################################################
  
  scope :by_user, lambda {|user| where(["media_resources.user_id = ?", user]) }
  scope :not_by_user, lambda {|user| where(["media_resources.user_id <> ?", user]) }

  ################################################################

  scope :search, lambda { |q|
    joins("LEFT JOIN full_texts ON media_resources.id = full_texts.media_resource_id") \
      .where(q.split.map{|x| "text #{SQLHelper.ilike} '%#{x}%'" }.join(' AND '))
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
  
    # OPTIMIZE this is mutual exclusive in case of many media_types  
    options[:media_type].each do |x|
      sql = sql.where("media_files.content_type #{SQLHelper.ilike} ?", "%#{x}%")
    end
    
    [:width, :height].each do |x|
      if options[x] and not options[x][:value].blank?
        operator = case options[x][:operator]
          when "gt"
            ">"
          when "lt"
            "<"
          else
            "="
        end
        sql = sql.where("media_files.#{x} #{operator} ?", options[x][:value])
      end
    end

    unless options[:orientation].blank?
      operator = if options[:orientation].size == 2
        "="
      else
        case options[:orientation].to_i
          when 0
            "<"
          when 1
            ">"
        end
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
            value = meta_data.get(definition.meta_key_id).value
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
