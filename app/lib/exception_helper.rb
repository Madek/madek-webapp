module ExceptionHelper 

  class << self

    def log_and_supress!
      begin 
        yield
      rescue Exception => e
        Rails.logger.warn Formatter.exception_to_log_s(e)
      end
    end

    def log_and_reraise
      begin 
        yield
      rescue Exception => e
        Rails.logger.error Formatter.exception_to_log_s(e)
        raise e
      end
    end

  end
end
