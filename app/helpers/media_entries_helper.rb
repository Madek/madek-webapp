# -*- encoding : utf-8 -*-
module MediaEntriesHelper
 
  def meta_data(media_entry)

    meta_context_group_data = []

    MetaContextGroup.all.each do |meta_context_group|
      meta_contexts = []
      # TODO check permissions for individual contexts (through media_sets)
      (meta_context_group.meta_contexts & (MetaContext.defaults + media_entry.individual_contexts)).collect do |meta_context|
        meta_contexts << display_meta_data_for(media_entry, meta_context)
      end

      meta_context_group_data << {meta_context_group: meta_context_group, meta_contexts: meta_contexts} unless meta_contexts.empty?
    end

    [MetaContextGroup.new(name: _("Karte"))].each do |meta_context_group|
      meta_context_group_data << {meta_context_group: meta_context_group, link: url_for([:map, media_entry])}
    end if media_entry.media_file.meta_data and media_entry.media_file.meta_data["GPS:GPSLatitude"] and media_entry.media_file.meta_data["GPS:GPSLongitude"]

    # OPTIMIZE this is now hardcoded
    # TODO includes activities (edit_sessions) 
    [MetaContextGroup.new(name: _("Weitere Daten"))].each do |meta_context_group|
      meta_contexts = []
      meta_contexts << display_objective_meta_data_for(media_entry)
      meta_contexts << display_activities_for(media_entry)

      meta_context_group_data << {meta_context_group: meta_context_group, meta_contexts: meta_contexts}
    end

    capture_haml do
      meta_context_group_data.each do |mcgd|
        meta_context_group = mcgd[:meta_context_group]
        meta_contexts = mcgd[:meta_contexts] || []
        link = mcgd[:link]
        
        haml_tag :div, class: "meta_context_group", id:  meta_context_group.id.to_s, "data-name" => meta_context_group.name.to_s do
          haml_tag :h5, :"data-link" => link do
            haml_tag :div, :class => "toggler-arrow"
            haml_tag :span, meta_context_group.name.to_s
          end
          meta_contexts.each_slice(4) do |slice|
            slice.each_with_index do |entry, index|
              haml_tag :div, :class => "col" do
                haml_concat slice[index]
              end
            end
            haml_tag :hr
          end
        end
      end
    end

  end
 
  def select_dimensions_header_for_entry(media_entry)
    media_file = media_entry.media_file
    unless media_file.nil?
      case media_file.content_type
        when /audio/ then
          header = "Dauer"
        # when /video/ then
        #   
        # when /image/ then
        else
          header = "Dimensionen (Format)"
      end
    end
    return header
  end
  
  # NOTE: media_file argument could also be a preview object
  def dimensions_for(media_file)
    case media_file.content_type
      when /image/ then
        "#{media_file.width} x #{media_file.height} px"
      when /video/ then
        "#{media_file.width} x #{media_file.height} px"
      when /audio/ then
        "hh:mm:ss"
      else
        nil
    end
  end
  
  def file_format_for(media_file)
    media_file.content_type.gsub(/^.*?\//, '')
  end

  def resource_sizes(resource)
    content_tag :div do
      a = "".html_safe
      a += dimensions_for(resource.media_file)
      a += tag :br
      a += number_to_human_size(resource.media_file.size)
    end
  end

end

