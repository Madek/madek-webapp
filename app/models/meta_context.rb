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
  has_many :meta_data, :through => :meta_keys
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

  def individual_context?
    media_sets.exists?
  end

##################################################################

  # TODO dry with MediaSet#abstract  
  def abstract(current_user = nil, min_media_entries = nil)
    accessible_media_entry_ids = MediaResource.filter(current_user, {:type => :media_entries, :meta_context_ids => [id]}).pluck("media_resources.id")
    min_media_entries ||= accessible_media_entry_ids.size.to_f * 50 / 100
    meta_key_ids = meta_keys.for_meta_terms.where(MetaKey.arel_table[:label].not_in(MetaKey.dynamic_keys)).pluck("meta_keys.id") # TODO get all related meta_key_ids ?? 

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
    return b.compact
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

##################################################################

  def self.defaults
    # FIXME this is a quickfix, should we maybe have a default MetaContextGroup ??
    MetaContextGroup.first.try(:meta_contexts) || []
  end

  def self.method_missing(*args)
    where("name #{SQLHelper.ilike} ?",args.first.to_s).first || super
  end

end
