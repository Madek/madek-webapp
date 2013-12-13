# -*- encoding : utf-8 -*-

class MediaResource < ActiveRecord::Base

  include MediaResourceModules::Arcs
  extend MediaResourceModules::Graph
  include MediaResourceModules::MetaData
  include MediaResourceModules::Permissions
  include Concerns::ResourcesThroughPermissions
  include MediaResourceModules::Filter

###############################################################

  belongs_to :user

################################################################

  # only entries have media_files, this is to enable eager loading
  has_one :media_file, foreign_key: :media_entry_id

###############################################################

  has_many  :edit_sessions, :dependent => :destroy
  has_many  :editors, through: :edit_sessions, source: :user

  validates_presence_of :user

  has_one :full_text, dependent: :destroy
  after_save { reindex } # OPTIMIZE

########################################################

  def reindex
    ft = full_text || build_full_text
    new_text = meta_data.concatenated
    [:user].each do |method|
      new_text << " #{send(method)}" if respond_to?(method)
    end
    ft.update_attributes(text: new_text)
  end

########################################################

  def has_location?
    not (media_file.meta_data["GPS:GPSLatitude"].blank? or media_file.meta_data["GPS:GPSLongitude"].blank?)
  end

  ##########################################################################################################################
  ##########################################################################################################################

  # ORDERINGS
  
  scope :ordered_by, lambda {|x|
    case x.try(:to_sym)
    when :author
      joins(meta_data: :meta_key).where("meta_keys.id = ?", x)
      .joins('INNER JOIN meta_data_people ON meta_data.id = meta_data_people.meta_datum_id')
      .joins('INNER JOIN people ON meta_data_people.person_id = people.id')
      .order('people.last_name, people.first_name ASC')
    when :title
      joins(meta_data: :meta_key).where("meta_keys.id = ?", x).order("meta_data.string ASC")
    when :updated_at, :created_at
      order(arel_table[x.to_sym].desc)
    else
      order("media_resources.updated_at DESC")
    end
  }

  ################################################################

  scope :media_entries_or_media_entry_incompletes, lambda{where(type: ["MediaEntry", "MediaEntryIncomplete"])}
  scope :media_sets, lambda{where(type: "MediaSet")}
  scope :filter_sets, lambda{where(type: "FilterSet")}
  scope :media_entries, lambda{where(type: "MediaEntry")}


  ###############################################################
  
  scope :not_by_user, lambda {|user|
    x = user.is_a?(User) ? user.id : user
    where(arel_table[:user_id].not_eq(x))
  }

  ################################################################

  scope :search, lambda { |query|
    ar = joins("LEFT JOIN full_texts ON media_resources.id = full_texts.media_resource_id")
    query.split.map{|s| "%#{s}%"}.each do |term| 
      ar = ar.where("full_texts.text ilike ?",term)
    end
    ar
  }

  ################################################################

  def self.by_collection(collection_id)
    Rails.cache.read(collection_id) || raise("Collection not found")
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
    MetaContext.find("io_interface").meta_key_definitions.collect do |definition|
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
