# -*- encoding : utf-8 -*-
#=MetaContext
# A MetaContext is a representation of a set of meta-data requirements for a particular domain.
# for example, we start with a base set ("Core") that has approximately 7 definitions.
# Further contexts may 'inherit' from the Core defintions (actually, it's a nested set)
# MetaContexts were originally intended to provide assistance selecting the right keys to be exported to a given external system
# However, they are quite flexible, and may also be used for managing meta-data upon import.
class MetaContext < ActiveRecord::Base

  self.primary_key = :name
  
  belongs_to :meta_context_group

  has_many :meta_key_definitions, foreign_key: :meta_context_name, :dependent => :destroy
  has_many :meta_keys, lambda{order("meta_key_definitions.position ASC")}, through: :meta_key_definitions
  has_many :meta_data, through: :meta_keys
  has_and_belongs_to_many :media_sets, join_table: 'media_sets_meta_contexts', foreign_key: :meta_context_name

##################################################################

  validates_presence_of :name, :label

  # compares two objects in order to sort them
  def <=>(other)
    self.name <=> other.name
  end

##################################################################

  scope :for_interface, ->{where(:is_user_interface => true)}
  scope :for_import_export, ->{where(:is_user_interface => false)}

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
    accessible_media_entry_ids = MediaResource.filter(current_user, {:type => :media_entries, :meta_context_names => [name]}).pluck("media_resources.id")
    min_media_entries ||= accessible_media_entry_ids.size.to_f * 50 / 100
    meta_key_ids = meta_keys.for_meta_terms.where(MetaKey.arel_table[:id].not_in(MetaKey.dynamic_keys)).pluck("meta_keys.id") 

    h = {} 
    mds = MetaDatum.where(:meta_key_id => meta_key_ids, :media_resource_id => accessible_media_entry_ids)
    mds.each do |md|
      h[md.meta_key_id] ||= [] 
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
      accessible_media_entry_ids = MediaEntry.accessible_by_user(current_user,:view).pluck(:id)
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

  # try to hunt the bug with this if there are regressions
  #def self.method_missing(*args)
  #  raise "DEPRECATED" if where("name ilike ?",args.first.to_s).first
  #  super
  #end


end
