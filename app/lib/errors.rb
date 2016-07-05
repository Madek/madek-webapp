# add app error classes
module Errors
  class UnauthorizedError < StandardError
    # If the request requires a login, but user is not logged in.
  end

  class ForbiddenError < StandardError
    # If user is logged in, but access is denied.
  end

  class InvalidParameterValue < StandardError
    # If a value for a request parameter has is invalid
  end

  # map custom errors to HTTP status codes:
  def self.rescue_responses
    {
      'Errors::InvalidParameterValue' => :bad_request, # 400
      'Errors::UnauthorizedError' => :unauthorized, # 401
      'Errors::ForbiddenError' => :forbidden # 403
    }
  end

  # act as a Rails plugin so we can do configuration:
  class Railtie < Rails::Railtie
    config.before_configuration do
      # add our error/http mappings:
      ActionDispatch::ExceptionWrapper.rescue_responses
        .merge!(Errors.rescue_responses)
    end
  end
end
