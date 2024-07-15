module Modules
  module FileStorage
    extend ActiveSupport::Concern

    def store_file!(origin, location)
      check_origin! origin
      check_location! location
      FileUtils.mv(origin, location)
      # ensure read/write permissions for user (so deletion works),
      # read permissions for others (for sendfile serving by another user
      # of for zencoder)
      FileUtils.chmod('u=rw,g=,o=r', location)
    end

    def check_origin!(path)
      raise "Temp file doesn't exist!" unless File.exist?(path)
      true
    end

    def check_location!(path)
      raise 'Target file already exists!' if File.exist?(path)
      true
    end

    def extension(filename)
      # strip '.' from the beginning
      File.extname(filename)[1..-1].downcase
    end
  end
end
