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

  class UsageTermsNotAcceptedError < StandardError
    # If a user is logged in, but has not accepted latest usage terms.
    # NOTE: This Error needs to show more data, define it here since it's static
    def self.data
      latest_usage_term = UsageTerms.order(created_at: :DESC).first
      Presenters::UsageTerms::UsageTerm.new(latest_usage_term)
    end
  end

  # add custom HTTPS status codes:
  def self.custom_status_codes
    {
      usage_terms_not_accepted: 499 # "Nein, Nein!"
    }
  end

  # map custom errors to HTTP status codes:
  def self.rescue_responses
    {
      'Errors::InvalidParameterValue' => :bad_request, # 400
      'Errors::UnauthorizedError' => :unauthorized, # 401
      'Errors::ForbiddenError' => :forbidden, # 403
      'Errors::UsageTermsNotAcceptedError' => :usage_terms_not_accepted # 499
    }
  end

  # act as a Rails plugin so we can do configuration:
  class Railtie < Rails::Railtie
    config.before_configuration do
      # add add custom HTTPS status codes:
      Rack::Utils::SYMBOL_TO_STATUS_CODE.merge!(Errors.custom_status_codes)
      # add our error/http mappings:
      ActionDispatch::ExceptionWrapper.rescue_responses
        .merge!(Errors.rescue_responses)
    end
  end
end
