# -*- encoding : utf-8 -*-
#=MetaContext
# A MetaContext is a representation of a set of meta-data requirements for a particular domain.
# for example, we start with a base set ("Core") that has approximately 7 definitions.
# Further contexts may 'inherit' from the Core defintions (actually, it's a nested set)
# MetaContexts were originally intended to provide assistance selecting the right keys to be exported to a given external system
# However, they are quite flexible, and may also be used for managing meta-data upon import.
class MetaContext < ActiveRecord::Base
  
  has_many :meta_key_definitions, :dependent => :destroy
  has_many :meta_keys, :through => :meta_key_definitions, :order => :position

  validates_presence_of :name

  # NOTE the overridden method MUST come BEFORE the serialize statement or IT WILL FAIL ON LINUX!!
  def meta_field=(hash = {})
    f = meta_field || MetaField.new
    f.update_attributes(hash)
    write_attribute(:meta_field, f)
  end
  serialize     :meta_field, MetaField

##################################################################

  scope :for_interface, where(:is_user_interface => true)
  scope :for_import_export, where(:is_user_interface => false)

##################################################################

  def to_s
    "#{meta_field.try(:label)}"
  end

  def next_position
    meta_key_definitions.maximum(:position).try(:next).to_i
  end

##################################################################

  def self.defaults
    [media_content, media_object, copyright, zhdk_bereich]
  end

  def self.method_missing(*args)
    # TODO identity_map for MetaContext similar to MetaKey ??
    # @contexts ||= {} # doesn't reflect updated meta_keys position order
    @contexts = {}
    @contexts[args.first] ||= where(:name => args.first.to_s).first
    @contexts[args.first] || super
  end

end
