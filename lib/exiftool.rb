# -*- encoding : utf-8 -*-
module Exiftool

  class << self


    def extract_madek_subjective_metadata file, content_type
      group_tags = case content_type
                   when /image/ 
                     #NOTE - these two really don't bring much to the party, except broken character encodings.. # 'IPTC:', 'IPTC2']
                     ['XMP-madek', 'XMP-dc', 'XMP-photoshop', 'XMP-iptcCore', 'XMP-xmpRights', 'XMP-expressionmedia', 'XMP-mediapro']
                   when /video/
                     ['QuickTime', 'Track', 'Composite', 'RIFF', 'BMP', 'Flash', 'M2TS', 'AC3', 'H264' ] # OPTIMIZE - some of these may move to Objective Metadata
                   when /audio/ 
                     ['MPEG', 'ID3', 'Track', 'Composite', 'ASF', 'FLAC', 'Vorbis' ] # OPTIMIZE - some of these may move to Objective Metadata
                   when /application/
                     ['FlashPix', 'PDF', 'XMP-', 'PostScript', 'Photoshop', 'EXE', 'ZIP' ] # OPTIMIZE - some of these may move to Objective Metadata
                   when /text/
                     ['HTML' ]  # and inevitably more..
                   end
      Exiftool.parse_metadata(file, group_tags)
    end

    def filter_unwanted_fields meta_data_array, content_type

      ignore_fields = case content_type
                      when /image/
                        [/^XMP-photoshop:ICCProfileName$/,/^XMP-photoshop:LegacyIPTCDigest$/, /^XMP-expressionmedia:(?!UserFields)/, /^XMP-mediapro:(?!UserFields)/]
                      when /video/
                        []
                      when /audio/
                        []
                      when /application/
                        []
                      when /text/
                        []
                      end

      meta_data_array.map do |l1|
        l1.map do |entry|
          key,value = entry
          if ignore_fields.find {|m| key =~ m}
            []
          else
            entry
          end
        end
      end

    end


    # parses the passed in file reference for the requested tag groups
    # returns an array of arrays of meta-data for the group tags requested

    #==== Depends on:
    # [external] exiftool meta-data manipulation perl library.

    def parse_metadata(file, tags = nil)
      result_set = []
      parse_hash = JSON.parse(`#{EXIFTOOL_PATH} -s "#{file}" -a -u -G1 -D -j`).first
      parse_hash.delete_if {|k,v| v.is_a?(String) and not v.valid_encoding? }
      tags.each do |tag_group|
        result_set << parse_hash.select {|k,v| k.include?(tag_group)}.sort
      end
      result_set
    end

  end

end
