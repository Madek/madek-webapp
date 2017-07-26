class MetadataExtractor
  attr_reader :data

  EXIFTOOL_CMD_LINE_OPTIONS = '-s -a -u -G1'
  Exiftool.command += " #{EXIFTOOL_CMD_LINE_OPTIONS}"

  def initialize(file_path)
    @file_path = file_path
    @data = Exiftool.new(file_path)
  end

  def to_hash
    sanitize(@data.to_display_hash)
  end

  def sanitize(hash)
    hash
      .map { |k, v| [k.gsub(/\s+/, ''), v] }
      .map do |k, v|
        next [k, v] unless v.is_a?(String)
        unless v.include?("\x00") || \
            (!v.ascii_only? && !v.force_encoding('utf-8').valid_encoding?)
          [k, v.unicode_normalize(:nfc)]
        end
      end
      .compact
      .to_h
  end
end
