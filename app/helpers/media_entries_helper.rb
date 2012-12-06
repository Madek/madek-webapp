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
 
  def thumb_for(resource, size = :small_125, options = {})
    size = size.to_sym

    return "" unless (media_file = resource.get_media_file(current_user))
    
    # Give a video preview if there is one, otherwise revert to a preview
    # image that was extracted from the video file.
    if media_file.content_type =~ /video/ && size == :large
      media_file.assign_video_thumbnails_to_preview
      video_preview_webm = media_file.previews.where(:content_type => 'video/webm', :thumbnail => 'large').last
      video_preview_apple = media_file.previews.where(:content_type => 'video/mp4', :thumbnail => 'large').last
      # Since we don't have a video preview, we also don't have any thumbnails, since those are generated while
      # encoding the video.
      if video_preview_webm.nil?
        if !media_file.encode_job_finished?
          # TODO: Display a nicer box with this information, not just dump the text there
          "<p>Diese Videodatei wird gerade fürs Web konvertiert. Die Konvertierung ist zu %.2f Prozent abgeschlossen. Sobald sie ganz abgeschlossen ist, finden Sie hier eine abspielbare Version. Laden Sie diese Seite neu, um den aktuellsten Stand zu erfahren.</p>" % media_file.encode_job_progress_percentage 
        else
          tag :img, options.merge({:src => media_file.thumb_base64(size)})  
        end
      else
        content_tag :video, {:width => video_preview_webm.width, :height => video_preview_webm.height, :autoplay => '', :controls => 'controls'} do
          # This src points to a symlink to the actual file, so that Apache serves it. This lets us support
          # seeking, partial content (HTTP status code 206) and request ranges without any additional work.
          unless video_preview_apple.nil?
            # Apple uses a nonstandard, patent-emcumbered codec (H.264) that is the only one supported in their browsers
            tag :source, {:type => video_preview_apple.content_type, :src => "/previews/#{video_preview_apple.filename}"}
          end
          unless video_preview_webm.nil?
            # Everyone else uses an open codec (WebM)
            tag :source, {:type => video_preview_webm.content_type, :src => "/previews/#{video_preview_webm.filename}"}
          end
        end
      end

    elsif media_file.content_type =~ /audio/ && size == :large
      media_file.assign_audio_previews
      tag :audio,  options.merge({:src => "/download?id=#{resource.id}&audio_preview=true",
                                  :autoplay => 'autoplay', :controls => 'controls'})
    # All kinds of office documents (and PDF). Maybe put this mess somewhere separate?
    elsif size == :large && ["application/pdf","application/x-pdf","application/vnd.openxmlformats-officedocument.wordprocessingml.document", 
           "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", 
           "application/vnd.openxmlformats-officedocument.presentationml.presentation", 
           "application/vnd.ms-powerpoint", "application/msword", "application/vnd.oasis.opendocument.text", 
           "application/vnd.oasis.opendocument.presentation"].include?(media_file.content_type)
      # ENCODING_BASE_URL isn't just for encoding in this case, it's also to allow the Google Docs Viewer access
      # to the file without authenticating.
      url = "#{ENCODING_BASE_URL}/media_files/#{media_file.id}?access_hash=#{media_file.access_hash}"
      # This does NOT work! We seem to have found a bug in HAML or in the 'tag' method
      #tag :div, :class => 'iframe', :type => 'text/html', :width => 620, :height => 463, :src => "http://docs.google.com/viewer?url=#{CGI::escape(url)}&embedded=true"
      "<div class='iframe' type='text/html' width='620' height='463' src='http://docs.google.com/viewer?url=#{CGI::escape(url)}&embedded=true'></div>"
    else
      tag :img, options.merge({:src => media_file.thumb_base64(size)})
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
    case media_file.content_type
      when /image/ then
        format = media_file.content_type.gsub(/image\//, '')
      # other media formats ....
    else
      media_file.content_type
    end
  end

  def show_warnings(warnings)
    content_tag :ul, :class => "error" do
      a = "".html_safe
      warnings.each_pair do |k, v|
        a += content_tag :li do
          b = content_tag :label do
            "#{k}: "
          end
          b += v.join(', ')
        end
      end
      a
    end
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

