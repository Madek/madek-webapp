module Formatter
  class << self

    def error_to_s e
      e.message.to_s + "\n\n" + e.backtrace.join("\n")
    end

    def exception_to_log_s e
      e.message.to_s + "\n" + 
        e.backtrace.select{|l| l =~ Regexp.new(Rails.root.to_s)}
      .reject{|l| l =~ Regexp.new(Rails.root.join("vendor").to_s)}.join("\n") 
    end


  end
end
