module Concerns
  module MediaType
    extend ActiveSupport::Concern

    def self.map_to_media_type(content_type)
      unless content_type
        'other'
      else
        case content_type
        when /^image/
          'image'
        when /^video/
          'video'
        when /^audio/
          'audio'
        when /^text/
          'document'
        when /^application/
          'document'
        else
          'other'
        end
      end
    end
  end
end
