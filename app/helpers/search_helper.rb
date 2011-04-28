module SearchHelper
  
  def display_meta_data_checkboxes(media, meta_key, filter, label)
    all_words = []
    media.each do |m| 
      words = m.meta_data.with_labels[meta_key]
      all_words << words.split(', ') if words
    end
    all_words = all_words.flatten.uniq
    unless all_words.empty?
      a = ''
      a += content_tag :h3, :class => "filter_category clearfix" do
        b = content_tag(:span, nil, :class => "ui-icon ui-icon-triangle-1-e")
        b += link_to label, "#", :class => "filter_category_link"
        b += link_to "(zurücksetzen)", "#", :class => "reset_filter"
      end
      a += content_tag :div, :class => "filter_content" do
        b = content_tag :ul do
          c = ''
          all_words.each do |word|
            c += content_tag :li do
              form_params = filter.options[:conditions][meta_key.parameterize('_').to_sym]
              d = check_box_tag "media_entries[#{meta_key.parameterize('_')}][]", word, form_params && form_params.include?(word)
              d += word
            end
          end
          c.html_safe
        end
      end
      return a.html_safe
    end
  end
  
  
end