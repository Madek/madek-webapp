# -*- encoding : utf-8 -*-
class MetaDatum < ActiveRecord::Base

  UUID_V4_REGEXP= /^\w{8}-\w{4}-4\w{3}-\w{4}-\w{12}$/

  class << self
    def new_with_cast(*args, &block)
      if (h = args.first.try(:symbolize_keys)).is_a?(Hash) and
          (meta_key = h[:meta_key] || (h[:meta_key_id] ? MetaKey.find_by_id(h[:meta_key_id]) : nil)) and
          (klass = meta_key.meta_datum_object_type.constantize)
            #raise "#{klass.name} must be a subclass of #{self.name}" unless klass < self
            # NOTE the value setter has to be invoked after the instanciation (not during)
            value = args.first.delete("value") || args.first.delete(:value)
            r = klass.new_without_cast(*args, &block)
            r.value = value if value
            r
      elsif self < MetaDatum
        new_without_cast(*args, &block)
      else
        raise "MetaDatum is abstract; instatiate a subclass"
      end
    end
    alias_method_chain :new, :cast

    def value_type_name klass_or_string
      if klass_or_string.is_a? String
        klass_or_string
      else
        klass_or_string.name
      end 
      .gsub(/^MetaDatum/,"").underscore
    end
  end


  ########################################

  # NOTE this is here because we use eager loader preload(:keywords) on MetaDatum
  # but it's effectively used only by MetaDatumKeywords
  has_many :keywords

  belongs_to :media_resource
  belongs_to :meta_key

  ########################################

  validates_uniqueness_of :meta_key_id, :scope => :media_resource_id
  
  attr_accessor :keep_original_value

  scope :for_meta_terms, lambda{ joins(:meta_key).where(:meta_keys => {:meta_datum_object_type => "MetaDatumMetaTerms"})}

########################################

  def same_value?(other_value)
    # TODO raise "this method must be implemented in the derived class"
    
    # Can the value be iterated?
    if value.respond_to? :each
      
      # What is the first element?
      case value.first
      when NilClass
        # just compare, other is either also Nil or different.
        value === other_value
      when Keyword
        # just compare as a list of strings.
        value.sort.uniq.map(&:to_s) === other_value.sort.uniq.map(&:to_s)

      when Person, MetaTerm, Group
        value.sort.uniq.map(&:id) === other_value.sort.uniq.map(&:id)

      else
        raise "Unknown Meta-Data List Comparison!"
      end
      
    # if the value can NOT be iterated…
    else
      case value
      when String, false, true
        value == other_value
      when Copyright
        value.id == other_value.id
      when NilClass
        other_value.blank?
      else
        Rails.logger.warn "Unsafe meta-data comparison, add the following to the cases: #{value} #{value.class}"
        value.id == other_value.id
      end
    end

  end

########################################

  def context_warnings(context = Context.find("core"))
    # TODO raise "this method must be implemented in the derived class"
    
    definition = meta_key.meta_key_definitions.for_context(context)
    r = []
    r << "can't be blank" if value.blank? and definition.is_required
    r << "is too short (min is #{definition.length_min} characters)" if definition.length_min and (value.blank? or value.size < definition.length_min)
    r << "is too long (maximum is #{definition.length_max} characters)" if value and definition.length_max and value.size > definition.length_max
    # TODO options
    r
  end

  def context_valid?(context = Context.find("core"))
    # TODO raise "this method must be implemented in the derived class"

    context_warnings(context).empty?
  end

end

