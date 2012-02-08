module Exiftool

  class << self

    # parses the passed in file reference for the requested tag groups
    # returns an array of arrays of meta-data for the group tags requested

    #==== Depends on:
    # [external] exiftool meta-data manipulation perl library.

    def parse_metadata(media, tags = nil)
      result_set = []
      parse_hash = JSON.parse(`#{EXIFTOOL_PATH} -s "#{media}" -a -u -G1 -D -j`).first
      # TODO ?? parse_hash.delete_if {|k,v| v.is_a?(String) and not v.valid_encoding? }
      #binding.pry
      tags.each do |tag_group|
        result_set << parse_hash.select {|k,v| k.include?(tag_group)}.sort
      end
      result_set
    end

  end

end
