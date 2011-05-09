module SearchHelper
  
  def display_meta_data_checkboxes(resource_ids, type)
    resources = type.constantize.find(resource_ids) # TODO ?? include(:meta_data)

    meta_key_labels = [ ["keywords", "Schlagworte"], # TODO get german title through definitions: meta_key = MetaKey.where(:label => label).first, etc...
                        ["type", "Gattung"],
                        ["academic year", "Studienjahr"],
                        ["project type", "Projekttyp"],
                        ["institutional affiliation", "Bereich ZHdK"] ]

    capture_haml do
      meta_key_labels.each do |label, title|
        meta_terms_h = {}
        resources.each do |r|
          terms = case label
            when "keywords"
              r.meta_data.get(label).deserialized_value.collect(&:meta_term)
            else
              case type
                when "MediaEntry"
                  r.meta_data.get(label).deserialized_value
                else
                  next
              end
          end
          terms.each do |term|
            meta_terms_h[term] ||= []
            meta_terms_h[term] << r.id # TODO include r.type
          end
        end

        h = {}
        all_words = meta_terms_h.sort {|a,b| [b[1].count, a[0].to_s] <=> [a[1].count, b[0].to_s] }

        unless all_words.empty?
          haml_tag :h3, :class => "filter_category clearfix" do
            haml_tag :span, "", :class => "ui-icon ui-icon-triangle-1-e"
            haml_concat link_to title, "#", :class => "filter_category_link"
            haml_concat link_to "(zurücksetzen)", "#", :class => "reset_filter"
          end
          haml_tag :div, :class => "filter_content", :style => display_style(type, label) do
            haml_tag :ul do
              all_words.each do |word|
                haml_tag :li do
                  haml_concat check_box_tag "filter_ids[]", word.last.join(','), should_be_checked?(label, word.first, type)
                  haml_concat "#{word.first} (#{word.last.count})"
                end
              end
            end
          end
        end
      end
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