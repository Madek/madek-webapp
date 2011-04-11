class Filter

  def initialize(filter_attributes)
    @filters = filter_attributes
  end
  
  def to_query_filter
    options = {}
    @filters.each_pair do |filter, specs|
      if specs.is_a?(Hash)
        next if specs[:value].blank?
        options[filter.to_sym] = comparison_with_operator(specs[:value], specs[:operator])
      else
        options[filter.to_sym] = specs
      end
    end
    return options
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

end