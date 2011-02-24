# -*- encoding : utf-8 -*-
#=MetaField
# provides a (serialized) container for meta_key_definitions
# 
class MetaField

  attr_accessor :is_required, # boolean
                :length_min,  # integer
                :length_max,  # integer
                :options,     # Meta::Term ids array ## TODO remove after migration 20100610103525
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

  # expected
  # {:id1 => {:en_GB => ..., :de_CH => ...}, :id2 => {:en_GB => ..., :de_CH => ..., :id => ...}, ...}
  # ["string 1", "string 2", ...]
  def options=(values) ## TODO remove after migration 20100610103525
    #old# values = values.split(/\n/) if values.is_a? String

    if values.is_a? Hash
      values.each_pair {|k,v| v[:id] = k.to_i if k.to_i > 0 } # add id to hash values
      values = values.values # ignore the hash keys
    end
    
    @options = Array(values).collect do |h|
      h = {:en_GB => h, :de_CH => h} if h.is_a? String
      
      id = h.delete(:id)
      term = Meta::Term.where(:id => id).first if id
      if term
        term.update_attributes(h)
        term.id
      else
        get_term(h).try(:id)
      end
    end.compact
    remove_instance_variable(:@options) if @options.blank?
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

  def options ## TODO remove after migration 20100610103525
    @options = Meta::Term.find(@options) if @options.is_a? Array and @options.all? {|x| x.is_a? Integer }
    @options
  end

end
