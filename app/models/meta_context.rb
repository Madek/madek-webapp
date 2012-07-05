# -*- encoding : utf-8 -*-
#=MetaContext
# A MetaContext is a representation of a set of meta-data requirements for a particular domain.
# for example, we start with a base set ("Core") that has approximately 7 definitions.
# Further contexts may 'inherit' from the Core defintions (actually, it's a nested set)
# MetaContexts were originally intended to provide assistance selecting the right keys to be exported to a given external system
# However, they are quite flexible, and may also be used for managing meta-data upon import.
class MetaContext < ActiveRecord::Base
  
  belongs_to :meta_context_group

  has_many :meta_key_definitions, :dependent => :destroy
  has_many :meta_keys, :through => :meta_key_definitions, :order => :position

  has_and_belongs_to_many :media_sets

##################################################################

  validates_presence_of :name, :label

  # compares two objects in order to sort them
  def <=>(other)
    self.name <=> other.name
  end

##################################################################

  scope :for_interface, where(:is_user_interface => true)
  scope :for_import_export, where(:is_user_interface => false)

##################################################################

  [:label, :description].each do |name|
    belongs_to name, :class_name => "MetaTerm"
    define_method "#{name}=" do |h|
      write_attribute("#{name}_id", MetaTerm.find_or_create(h).try(:id))
    end
  end

##################################################################

  def to_s
    "#{label}"
  end

  def next_position
    meta_key_definitions.maximum(:position).try(:next).to_i
  end
  
##################################################################

  # TODO dry with MediaSet#abstract  
  def abstract(current_user = nil, min_media_entries = nil)
    accessible_media_entry_ids = media_entries(current_user).pluck("media_resources.id")
    min_media_entries ||= accessible_media_entry_ids.size.to_f * 50 / 100
    meta_key_ids = meta_keys.where(:is_dynamic => nil).pluck("meta_keys.id") # TODO get all related meta_key_ids ?? 

    h = {} #1005# TODO upgrade to Ruby 1.9 and use ActiveSupport::OrderedHash.new
    mds = MetaDatum.where(:meta_key_id => meta_key_ids, :media_resource_id => accessible_media_entry_ids)
    mds.each do |md|
      h[md.meta_key_id] ||= [] # TODO md.meta_key
      h[md.meta_key_id] << md.value
    end
    h.delete_if {|k, v| v.size < min_media_entries }
    h.each_pair {|k, v| h[k] = v.flatten.group_by {|x| x}.delete_if {|k, v| v.size < min_media_entries }.keys }
    h.delete_if {|k, v| v.blank? }
    #1005# return h.collect {|k, v| meta_data.build(:meta_key_id => k, :value => v) }
    b = []
    h.each_pair {|k, v| b[meta_key_ids.index(k)] = MetaDatum.new(:meta_key_id => k, :value => v) }

    return b.compact.map do |meta_datum|
      meta_datum.meta_key.reload #tmp# TODO remove this line, is an Identity Map problem ??
      definition = meta_datum.meta_key.meta_key_definitions.for_context(self)
      { :meta_key_id => meta_datum.meta_key_id,
        :meta_key_label => definition.label.to_s,
        :meta_terms => meta_datum.value.map do |meta_term|
          { :id => meta_term.id,
            :label => meta_term.to_s
          }
        end 
      }
    end
  end

  # TODO dry with MediaSet#used_meta_term_ids  
  def used_meta_term_ids(current_user = nil)
    meta_key_ids = meta_keys.for_meta_terms.pluck("meta_keys.id")

    mds = if current_user
      accessible_media_entry_ids = MediaEntry.accessible_by_user(current_user).pluck(:id)
      MetaDatum.where(:meta_key_id => meta_key_ids, :media_resource_id => accessible_media_entry_ids)
    else
      MetaDatum.where(:meta_key_id => meta_key_ids)
    end

    mds.flat_map(&:meta_term_ids).uniq
  end

  # chainable query
  def media_entries(current_user = nil)
    sql = if current_user
      MediaEntry.accessible_by_user(current_user).joins("INNER JOIN meta_data ON media_resources.id = meta_data.media_resource_id")
    else
      MediaEntry.joins(:meta_data)
    end
    sql.group("meta_data.media_resource_id").where(:meta_data => {:meta_key_id => meta_key_ids})
  end

##################################################################

  def self.defaults
    [media_content, media_object, copyright, zhdk_bereich]
  end

  def self.method_missing(*args)
    where(:name => args.first.to_s).first || super
  end

end
