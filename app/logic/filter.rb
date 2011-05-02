class Filter

  attr_accessor :options, :filters
  def initialize(filter_attributes)
    @filters = filter_attributes
    @options = {:with => {}, :conditions => {}, :per_page => (2**30)}
  end
  
  def to_query_filter
    ts_classes = [MediaEntry, Media::Set] # ThinkingSphinx.context.indexed_models.collect { |model| model.constantize } # can't use that since it includes Person
    @filters.each_pair do |filter, values|
      all_ts_attributes = ts_classes.map {|model| model::TS_ATTRIBUTE_DEFINITIONS.map {|a| a.first.to_sym } }.flatten.uniq
      key = all_ts_attributes.include?(filter.to_sym) ? :with : :conditions
      adjusted_value = adjust_values_to_key(key, values)
      next unless adjusted_value
      options[key][filter.to_sym] = adjusted_value
    end
    return options
  end
  
  def active_filters
    @options[:with].keys + @options[:conditions].keys
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
  
  protected
  
  def adjust_values_to_key(key, values)
    if values.is_a?(Hash)
      return nil if values[:value].blank?
      comparison_with_operator(values[:value], values[:operator])
    elsif values.is_a?(Array)
      if key == :with && values.all? {|v| string_like?(v) }
        values.map {|v| v.to_crc32}
      elsif key == :conditions
        # need to contain terms with spaces or dashes in (escaped) double quotes
        escaped_values = values.map {|val| val =~ /[\s-]/ ? "\"#{val}\"" : val }
        escaped_values.join("|")
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