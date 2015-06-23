module Concerns
  module MediaType
    extend ActiveSupport::Concern

    def self.map_to_media_type(content_type)
      content_type ||= nil
      case content_type
      when /^image/
        'image'
      when /^video/
        'video'
      # TODO: other media types
      # when /^audio/
      #   'audio'
      # when /^text/
      #   'document'
      # when /^application/
      #   'document'
      else
        'other'
      end
    end

    def set_media_type
      self.media_type = Concerns::MediaType.map_to_media_type(self.content_type)
    end
  end
end
