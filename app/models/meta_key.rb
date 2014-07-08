# -*- encoding : utf-8 -*-
#= MetaKey
#
# Holds the set of basic meta data keys
class MetaKey < ActiveRecord::Base
  self.primary_key= 'id'

  has_many :meta_data, dependent: :destroy
  has_and_belongs_to_many :media_entries,
    join_table: :meta_data,
    association_foreign_key: :media_resource_id

  has_many :io_mappings, dependent: :destroy
  
  has_many :meta_key_definitions, dependent: :destroy do
    def for_context(context)
      where(context_id: context.id).first
    end
  end
  has_many :contexts, through: :meta_key_definitions

  has_many :meta_key_meta_terms, dependent: :destroy
  has_many :meta_terms, ->{order("meta_keys_meta_terms.position ASC")}, through: :meta_key_meta_terms
  accepts_nested_attributes_for :meta_terms, reject_if: proc { |attributes| attributes[:term].blank? }

  scope :with_meta_data, lambda{joins(:meta_data).group(:id)}
  scope :for_meta_terms, lambda{where(meta_datum_object_type: "MetaDatumMetaTerms")}
  scope :with_context,   lambda{ |context_label| joins(:contexts).where('contexts.label' => context_label)}
  
  scope :used, ->(is_used = true){
    condition = is_used ? 'EXISTS' : 'NOT EXISTS'
    operator  = is_used ? 'OR'     : 'AND'
    where(%Q<
      #{condition} (SELECT NULL FROM "meta_data" 
                      WHERE "meta_keys"."id" = "meta_data"."meta_key_id") 
      #{operator}
      #{condition} (SELECT NULL FROM "meta_key_definitions" 
                      WHERE "meta_keys"."id" = "meta_key_definitions"."meta_key_id")
      #{operator}
      #{condition} (SELECT NULL FROM "meta_keys_meta_terms"
                      WHERE "meta_keys"."id" = "meta_keys_meta_terms"."meta_key_id") >) }

  after_update :sort_meta_terms

  def self.search_with(term)
    joins("LEFT OUTER JOIN meta_key_definitions ON meta_keys.id = meta_key_definitions.meta_key_id") \
      .where("meta_keys.id LIKE :label OR meta_key_definitions.label LIKE :label", label: "%#{term}%") \
      .group("meta_keys.id")
  end

  def label
    id
  end

  def get_meta_datum_class
    Kernel.const_get(meta_datum_object_type)
  end
########################################################

  before_update do
    if meta_datum_object_type_changed?
      case meta_datum_object_type
        when "MetaDatumMetaTerms"
          self.is_extensible_list = true
          meta_data.each {|md| md.update_attributes(value: md.value) }
        # TODO when... else
      end
    end
  end

  def to_s
    id
  end

  def all_context_labels contexts=nil
    if contexts
      meta_key_definitions.where(context_id: contexts)
    else  
      meta_key_definitions
    end.collect {|d| d.label.to_s}.compact.uniq.join(', ')
  end

  def used?
    !meta_key_definitions.empty? || !meta_data.empty? || !meta_key_meta_terms.empty?
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
  def self.meta_key_for(key_map) 

    mk = IoMapping.where("key_map ilike ?", "%#{key_map}%").first.try(:meta_key)

    if mk.nil?
      entry_name = key_map.split(':').last.underscore.gsub(/[_-]/,' ')
      mk = MetaKey.find_by_id(entry_name)
    end
      # we have to create the meta key, since it doesnt exist
    if mk.nil?
      mk= MetaKey.find_or_create_by(id: entry_name)
      io_interface= IoInterface.find("default")
      mk.io_mappings.create \
        io_interface: io_interface,
        key_map: key_map
    end
    mk
  end

  def self.object_types
    # NOTE in development mode we need to preload
    # FIXME
    if Rails.env.development? || Rails.env.test?
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

########################################################

  def is_not_writable?
    self.class.not_writable.include?(id)
  end

  def self.not_writable
    not_writable_hash.values.flatten
  end
  
  def self.not_writable_hash
    {
      "MetaDatumUsers"  => ["owner"],
      "MetaDatumDate"   => ["uploaded at"],
      "MetaDatumString" => ["public access", "media type", "parent media_resources", "child media_resources"]
    }
  end

  def is_dynamic?
    self.class.dynamic_keys.include?(id)
  end

  def self.dynamic_keys
    dynamic_keys_hash.values.flatten
  end

  def self.dynamic_keys_hash
    h = not_writable_hash
    h["MetaDatumString"] += ["copyright usage", "copyright url"]
    h
  end

  def sort_meta_terms
    if meta_terms_alphabetical_order
      ActiveRecord::Base.transaction do
        meta_terms.reorder('term').to_a.each_with_index do |meta_term, index|
          meta_term_to_update = meta_key_meta_terms.find_by(meta_term_id: meta_term.id)
          meta_term_to_update.update_attribute(:position, index)
        end
      end
    end
  end

  def to_param
    id.gsub('/', '@')
  end

end
