module System
  class << self

    def execute_cmd!(cmd)
      output = `#{cmd}`
      raise "ERROR executing #{cmd}" if $?.exitstatus != 0
      output
    end

  end
end
