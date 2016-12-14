module Concerns
  module RedirectBackOr
    # extend ActiveSupport::Concern

    def redirect_back_or(default, flash_hash = {})
      # does a redirect and searches target in this order
      # - the referer of the request (prefered!)
      # - route given in argument (as fallback, therefore required)
      # - a target manually set in the session (used as last resort for edge cases)
      redirect_to \
        session[:return_to] || request.referer || default, flash: flash_hash
      session[:return_to] = nil # clear this in any case
    end

  end
end
