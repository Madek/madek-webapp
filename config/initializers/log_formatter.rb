class ActiveSupport::Logger::SimpleFormatter
  def call(severity, _time, _progname, msg)
    "[#{severity.center(5)}] #{msg}\n"
  end
end
