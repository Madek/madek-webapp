module FileConversion
  def self.convert(file, outfile, width, height)
    raise "Input file doesn't exist!" unless File.exist?(file)

    cmd = "convert '#{file}'[0] " \
          "-auto-orient -thumbnail '#{width}x#{height}' " \
          "-flatten -unsharp 0x.5 '#{outfile}'"

    Rails.logger.info "CREATING THUMBNAIL `#{cmd}`"
    `#{cmd}`
  end
end
