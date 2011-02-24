# -*- encoding : utf-8 -*-
module MediaEntriesHelper
 
  def thumb_for(media_entry, size = :small, options = {})
    tag :img, options.merge({:src => media_entry.thumb_base64(size)})
  end

  def recent_uploads
    me = current_user.media_entries
    s = me.size
    return ( s > 6 ? me[s-6..s].reverse : me.reverse )
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
        "? x ?"
    end
  end
  
  def file_format_for(media_file)
    case media_file.content_type
      when /image/ then
        format = media_file.content_type.gsub(/image\//, '')
      # other media formats ....
    else
      "?"
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

