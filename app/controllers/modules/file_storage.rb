module Modules
  module FileStorage
    extend ActiveSupport::Concern

    def store_file!(origin, location)
      check_origin! origin
      check_location! location
      FileUtils.mv(origin, location)
    end

    def check_origin!(path)
      raise "Temp file doesn't exist!" unless File.exists?(path)
      true
    end

    def check_location!(path)
      raise 'Target file already exists!' if File.exists?(path)
      true
    end

    def extension(filename)
      # strip '.' from the beginning
      File.extname(filename)[1..-1].downcase
    end
  end
end
