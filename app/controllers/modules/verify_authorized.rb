module Modules
  module VerifyAuthorized
    extend ActiveSupport::Concern

    included do

      def verify_authorized_with_special_cases_exclusion
        if Madek::Constants::Webapp::VERIFY_AUTH_SKIP_CONTROLLERS.all? do |sc|
          self.class != sc
        end
          verify_authorized_without_special_cases_exclusion
        end
      end
      alias_method :verify_authorized_without_special_cases_exclusion, :verify_authorized
      alias_method :verify_authorized, :verify_authorized_with_special_cases_exclusion

      def verify_usage_terms_accepted!
        if current_user \
            and current_user.accepted_usage_terms != UsageTerms.most_recent
          raise Errors::UsageTermsNotAcceptedError
        end
      end

    end
  end
end
