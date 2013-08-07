# TODO rails4 
# class ActiveSupport::Logger::SimpleFormatter
class Logger::SimpleFormatter
  def call(severity, time, progname, msg)
    "[#{severity.center(5)}] #{msg}\n"
  end
end

