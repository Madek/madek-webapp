# -*- encoding : utf-8 -*-
#=MetaField
# provides a (serialized) container for meta_key_definitions
# 
class MetaField

  attr_accessor :is_required, # boolean
                :length_min,  # integer
                :length_max,  # integer
                :label,       # Meta::Term id
                :description, # Meta::Term id
                :hint         # Meta::Term id

  def update_attributes(attributes)
    attributes.each_pair do |key, value|
      self.send("#{key}=", value)
    end
  end

### TODO generic getter and setter
### TODO find_or_create just on before_save of MetaKeyDefinition ??
  def label=(h)
    @label = get_term(h).try(:id)
    remove_instance_variable(:@label) if @label.blank?
  end

  def description=(h)
    @description = get_term(h).try(:id)
    remove_instance_variable(:@description) if @description.blank?
  end

  def hint=(h)
    @hint = get_term(h).try(:id)
    remove_instance_variable(:@hint) if @hint.blank?
  end
  
  # OPTIMIZE 2210 uniqueness
  def get_term(h)
    if h.is_a? Integer
      Meta::Term.where(:id => h).first
    elsif h.values.any? {|x| not x.blank? }
      Meta::Term.find_or_create_by_en_GB_and_de_CH(h)
    end
  end

### OPTIMIZE
  def label
    @label = Meta::Term.find(@label) if @label.is_a? Integer
    @label
  end

  def description
    @description = Meta::Term.find(@description) if @description.is_a? Integer
    @description
  end

  def hint
    @hint = Meta::Term.find(@hint) if @hint.is_a? Integer
    @hint
  end

end
