module SearchHelper
  
  def get_result_count(facets, type)
    count = facets[:class][type]
    count.blank? ? 0 : count
  end
  
end