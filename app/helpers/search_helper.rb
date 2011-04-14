module SearchHelper
  
  def get_result_count(facets, type)
    if !facets.empty?
      count = facets[:class][type]
      count.blank? ? 0 : count
    else
      type == "MediaEntry" ? @media.total_entries : 0
    end
  end
  
  def display_meta_data_checkboxes(media, meta_datum)
    all_words = []
    media.each do |m| 
      words = m.meta_data.with_labels[meta_datum]
      all_words << words.split(', ') if words
    end
    unless all_words.empty?
      a = ''
      all_words.flatten.uniq.each do |word|
        a += content_tag :li do
          form_params = @filter ? @filter.filters[meta_datum] : nil
          b = check_box_tag "filter[#{meta_datum}][]", word, form_params && form_params.include?(word)
          b += word
        end
      end
      return a.html_safe
    end
  end
  
  
end