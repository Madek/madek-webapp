module Formatter
  class << self
    def error_to_s e, n = nil
      e.message.to_s + "\n" + 
        (n.nil? ?  e.backtrace : e.backtrace.take(n)).join("\n")
    end
  end
end
