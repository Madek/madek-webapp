module SearchHelper
  
  def display_meta_data_checkboxes(media, meta_key, label)
    all_words = []
    #TODO: # this will only fetch the meta_data for the items on the current page. We would need the unique meta data for all search results over all pages
    # something like MetaData.where(:resource_id => all_resource_ids, :resource_type => type, :meta_key => meta_key).all.map {|md| md.deserialized_value}
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
      type = media.first.class.base_class.name
      a += content_tag :div, :class => "filter_content", :style => display_style(type, meta_key) do
        b = content_tag :ul do
          c = ''
          all_words.each do |word|
            c += content_tag :li do
              d = check_box_tag "#{type}[#{meta_key.parameterize('_')}][]", word, should_be_checked?(meta_key, word, type)
              d += word
            end
          end
          c.html_safe
        end
      end
      return a.html_safe
    end
  end
  
  def display_style(type, meta_key)
    if (type == @active_filter_type) && filter_for_type(@active_filter_type).active_filters.include?(meta_key.parameterize('_').to_sym)
      "display: block;" 
    else
      "display: none;"
    end
  end
  
  def should_be_checked?(meta_key, word, type)
    return false unless type == @active_filter_type
    filter = filter_for_type(@active_filter_type)
    # here we're using filter.filters method (instead of filter.options), since the former maps directly to form params
    form_params = filter.filters[meta_key.parameterize('_').to_sym]
    if form_params && form_params.is_a?(Array)
      form_params.include?(word)
    elsif form_params
      form_params == word
    end
  end
  
  def filter_for_type(type)
    case type
    when "MediaEntry"
      @media_entry_filter
    when "Media::Set"
      @media_set_filter
    when "Media::Project"
      @project_filter
    end
  end
  
  
end