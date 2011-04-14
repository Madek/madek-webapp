# !! Mostly pseudo code here. WIP

class Filter

  attr_accessor :options, :filters, :ts_classes
  def initialize(filter_attributes)
    @filters = filter_attributes
    @options = {:with => {:viewable => true}, :conditions => {}, :classes => ts_classes}
  end
  
  def to_query_filter
    @filters.each_pair do |filter, specs|
      key = filter_or_attribute(filter)
      if specs.is_a?(Hash)
        next if specs[:value].blank?
        options[key][filter.to_sym] = comparison_with_operator(specs[:value], specs[:operator])
      elsif specs.is_a?(Array)
        options[key][filter.to_sym] = specs.join("|")
      else
        options[key][filter.to_sym] = specs
      end
    end
    return options
  end
  
  def ts_classes 
    #@ts_classes ||= ThinkingSphinx.context.indexed_models.collect { |model| model.constantize } # can't use that since it includes Person
    @ts_classes ||= ["MediaEntry".constantize, "Media::Set".constantize]
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

end