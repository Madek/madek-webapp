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

  def hash_for_media_file
    to_hash
  end

  def hash_for_media_entry
    to_hash
  end

  def sanitize(hash)
    # remove whitespaces from keys
    hash
      .map { |k, v| [k.gsub(/\s+/, ''), v] }
      .to_h
  end
end
