# -*- encoding : utf-8 -*-

class MediaResource < ActiveRecord::Base
  include MediaResourceModules::Arcs
  include MediaResourceModules::MetaData
  include MediaResourceModules::Permissions
  include MediaResourceModules::Filter

###############################################################

  belongs_to :user

  has_many  :edit_sessions, :dependent => :destroy, :readonly => true
  has_many  :editors, :through => :edit_sessions, :source => :user

  validates_presence_of :user

  has_one :full_text, :dependent => :destroy
  after_save { reindex } # OPTIMIZE
  
########################################################

  def reindex
    ft = full_text || build_full_text
    new_text = meta_data.concatenated
    [:user].each do |method|
      new_text << " #{send(method)}" if respond_to?(method)
    end
    ft.update_attributes(:text => new_text)
  end

##########################################################################################################################
##########################################################################################################################
   
  # ORDERINGS
  
  scope :ordered_by, lambda {|x|
    x ||= :updated_at 
    case x.to_sym
      when :author
        joins(meta_data: :meta_key).where("meta_keys.label = ?", x)
        .joins('INNER JOIN meta_data_people ON meta_data.id = meta_data_people.meta_datum_id')
        .joins('INNER JOIN people ON meta_data_people.person_id = people.id')
        .order('people.lastname, people.firstname ASC')
      when :title
        joins(meta_data: :meta_key).where("meta_keys.label = ?", x).order("meta_data.string ASC")
      when :updated_at, :created_at
        order("media_resources.#{x} DESC")
      when :random
        if SQLHelper.adapter_is_mysql?
          order("RAND()")
        elsif SQLHelper.adapter_is_postgresql? 
          order("RANDOM()")
        else
          raise "SQL Adapter is not supported" 
        end
    end
  }

  ################################################################

  scope :media_entries_or_media_entry_incompletes, where(:type => ["MediaEntry", "MediaEntryIncomplete"])
  scope :media_entries, where(:type => "MediaEntry")
  scope :media_sets, where(:type => ["MediaSet", "FilterSet"])

  ###############################################################
  
  scope :by_user, lambda {|user| where(["media_resources.user_id = ?", user]) }
  scope :not_by_user, lambda {|user| where(["media_resources.user_id <> ?", user]) }

  ################################################################

  scope :search, lambda { |q|
    sql = joins("LEFT JOIN full_texts ON media_resources.id = full_texts.media_resource_id")
    q.split.each do |x|
      sql = sql.where(["text #{SQLHelper.ilike} ?", "%#{q}%"])
    end
    sql
  }

  ################################################################

  def self.by_collection(user_id, cid)
    Rails.cache.read(user: user_id, collection: cid) || raise("Collection not found")
  end

  ################################################################
  

  def self.reindex
    all.map(&:reindex).uniq
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
