module Formatter
  class << self
    def error_to_s e
      e.message.to_s + "\n\n" + e.backtrace.join("\n")
    end
  end
end
