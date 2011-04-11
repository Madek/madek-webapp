# !! Mostly pseudo code here. WIP

class Filter

  attr_accessor :options, :filters
  def initialize(filter_attributes)
    @filters = filter_attributes
    @options = {:with => {}, :conditions => {}}
  end
  
  def to_query_filter
    @filters.each_pair do |filter, specs|
      key = filter_or_attribute(filter)
      if specs.is_a?(Hash)
        next if specs[:value].blank?
        options[key][filter.to_sym] = comparison_with_operator(specs[:value], specs[:operator])
      else
        options[key][filter.to_sym] = specs
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
  
  def filter_or_attribute(filter_name)
    classes = ThinkingSphinx.context.indexed_models.collect { |model| model.constantize }
    
    # does not work because of xmlpipe2 data source
    # classes.select { |model|
    #   model.sphinx_indexes.first.attributes.any? { |attribute|
    #     attribute.unique_name == filter_name
    #   }
    # }
  end

end