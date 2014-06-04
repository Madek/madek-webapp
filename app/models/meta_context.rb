# -*- encoding : utf-8 -*-
#=MetaContext
# A MetaContext is a representation of a set of meta-data requirements for a particular domain.
# for example, we start with a base set ("Core") that has approximately 7 definitions.
# Further contexts may 'inherit' from the Core defintions (actually, it's a nested set)
# MetaContexts were originally intended to provide assistance selecting the right keys to be exported to a given external system
# However, they are quite flexible, and may also be used for managing meta-data upon import.
class MetaContext < ActiveRecord::Base

  include Concerns::MetaContext::Vocabulary

  attr_accessor :inherited, :enabled

  self.primary_key = :name
  
  belongs_to :meta_context_group

  has_many :meta_key_definitions, foreign_key: :meta_context_name, :dependent => :destroy
  has_many :meta_keys, lambda{order("meta_key_definitions.position ASC")}, through: :meta_key_definitions
  has_many :meta_data, through: :meta_keys
  has_and_belongs_to_many :media_sets, join_table: 'media_sets_meta_contexts', foreign_key: :meta_context_name

  accepts_nested_attributes_for :meta_key_definitions

  before_save do |meta_context|
    meta_context.meta_context_group_id = nil if meta_context.meta_context_group_id.blank?
  end

  before_destroy do |meta_context|
    meta_context.media_sets.each do |media_set|
      media_set.individual_contexts.delete(meta_context)
    end
  end
  
##################################################################

  # compares two objects in order to sort them
  def <=>(other)
    self.name <=> other.name
  end

##################################################################

  scope :for_interface, ->{where(:is_user_interface => true)}
  scope :for_import_export, ->{where(:is_user_interface => false)}

##################################################################

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

  # TODO @TOM: still senseful?
  
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
