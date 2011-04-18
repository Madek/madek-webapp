# !! Mostly pseudo code here. WIP

class Filter

  attr_accessor :options, :filters, :ts_classes
  def initialize(filter_attributes)
    @filters = filter_attributes
    @options = {:with => {:viewable => true}, :conditions => {}, :classes => ts_classes}
  end
  
  def to_query_filter
    @filters.each_pair do |filter, values|
      key = filter_or_attribute(filter)
      adjusted_value = adjust_values_to_key(key, values)
      options[key][filter.to_sym] = adjusted_value
    end
    return options
  end
  
  def ts_classes 
    #@ts_classes ||= ThinkingSphinx.context.indexed_models.collect { |model| model.constantize } # can't use that since it includes Person
    @ts_classes ||= [MediaEntry, Media::Set]
  end
  
  def all_ts_attributes
    ts_classes.map {|model| model::TS_ATTRIBUTES.keys }.flatten.uniq
  end
  
  def all_ts_fields
    (ts_classes.map {|model| model::TS_FIELDS.keys }.flatten.uniq + MetaKey.with_meta_data.map {|key| key.label.parameterize.to_sym}).flatten
  end
  
  def comparison_with_operator(val, operator)
    # less than x --> 0..x
    # greater than x --> x..upper_limit (TODO: upper limit needs to be determined on a case by case basis)
    case operator
      when "gt"
        val.to_i..100000
      when "lt"
        0..val.to_i
      else
        val.to_i
    end
  end
  
  def filter_or_attribute(filter_name)
    if all_ts_attributes.include?(filter_name.to_sym)
      :with
    else
      :conditions
    end
  end
  
  protected
  
  def adjust_values_to_key(key, values)
    if values.is_a?(Hash)
      next if values[:value].blank?
      comparison_with_operator(values[:value], values[:operator])
    elsif values.is_a?(Array)
      if key == :with && values.all? {|v| string_like?(v) }
        values.map {|v| v.to_crc32}
      elsif key == :conditions
        values.join("|")
      else
        values
      end
    else
      (key == :with && string_like?(values)) ? values.to_crc32 : values
    end
  end
  
  def string_like?(str)
    str.is_a?(String) && (str =~ /^\d+$/).nil?
  end

end