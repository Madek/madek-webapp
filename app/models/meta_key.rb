# -*- encoding : utf-8 -*-
#= MetaKey
#
# Holds the set of basic meta data keys
class MetaKey < ActiveRecord::Base

  has_many :meta_data
  has_many :media_entries, :through => :meta_data, :uniq => true
  has_many :meta_key_definitions do
    def for_context(context)
      scoped_by_meta_context_id(context).first
    end
  end
  has_many :meta_contexts, :through => :meta_key_definitions

  has_many :meta_key_meta_terms
  has_many :meta_terms, :through => :meta_key_meta_terms, :order => :position
  accepts_nested_attributes_for :meta_terms, :reject_if => proc { |attributes| LANGUAGES.all? {|l| attributes[l].blank? } } #old# , :allow_destroy => true

  validates_uniqueness_of :label

  #old#precedence problem# default_scope order(:label)
  scope :with_meta_data, joins(:meta_data).group(:id)
  scope :for_meta_terms, where(:meta_datum_object_type => "MetaDatumMetaTerms") 
  
########################################################

  before_update do
    if meta_datum_object_type_changed?
      case meta_datum_object_type
        when "MetaDatumMetaTerms"
          self.is_extensible_list = true
          meta_data.each {|md| md.update_attributes(:value => md.value) }
        # TODO when... else
      end
    end
  end

  def to_s
    label
  end

  def all_context_labels
    meta_key_definitions.collect {|d| d.label.to_s if d.key_map.blank? }.compact.uniq.join(', ')
  end

########################################################

  #working here#9
  def key_map_for(context)
    d = meta_key_definitions.for_context(context)
    d.key_map if d
  end

########################################################

# Return a meta_key matching the provided key-map
#
# args: a keymap (fully namespaced)
# returns: a meta_key
#
# NB: If no meta_key matching the key-map is found, it is created 
# along with a new meta_key_definition (albeit with minimal label and description data)
  def self.meta_key_for(key_map) # TODO, context = nil)
    # do we really need to find by context here?
#    mk =  if context.nil?
#            MetaKeyDefinition.find_by_key_map(key_map).try(:meta_key)
#          else
#            context.meta_key_definitions.find_by_key_map(key_map).try(:meta_key)
#          end

    mk = MetaKeyDefinition.where("key_map #{SQLHelper.ilike} ?", "%#{key_map}%").first.try(:meta_key)

    if mk.nil?
      entry_name = key_map.split(':').last.underscore.gsub(/[_-]/,' ')
      mk = MetaKey.find_by_label(entry_name)
    end
      # we have to create the meta key, since it doesnt exist
    if mk.nil?
      mk = MetaKey.find_or_create_by_label(entry_name)
      mc = MetaContext.io_interface
      mk.meta_key_definitions.create( :meta_context => mc,
                                      :label => {:en_gb => "", :de_ch => ""},
                                      :description => {:en_gb => "", :de_ch => ""},
                                      :key_map => key_map,
                                      :key_map_type => nil,
                                      :position => mc.meta_key_definitions.maximum("position") + 1 )
    end
    mk
  end

  def self.object_types
    # NOTE in development mode we need to preload
    # FIXME
    if Rails.env == "development"
      # Dir.glob(File.join(Rails.root, "app/models/meta_datum_*.rb")).each {|model_file| require model_file } if Rails.env == "development"
      ["MetaDatumCopyright", "MetaDatumDate", "MetaDatumDepartments", "MetaDatumKeywords",
       "MetaDatumMetaTerms", "MetaDatumPeople", "MetaDatumString", "MetaDatumUsers"]
    else
      MetaDatum.descendants.map(&:name).sort
    end
  end
  
########################################################

  # TODO refactor to association has_many :used_meta_terms, :through ...
  def used_term_ids
    meta_data.flat_map(&:value).map(&:id).uniq.compact if meta_datum_object_type == "MetaDatumMetaTerms"
  end
  
  def is_deletable?
    meta_key_definitions.empty? and meta_data.empty?
  end

end
