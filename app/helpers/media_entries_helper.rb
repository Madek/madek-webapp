# -*- encoding : utf-8 -*-
module MediaEntriesHelper
 
  
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

end

