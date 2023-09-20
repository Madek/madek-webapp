module Presenters
  module UsageTerms
    class UsageTerm < Presenters::Shared::AppResource

      delegate_to_app_resource \
        :title, :version, :intro, :body

      def actions
        {
          accept: { method: :POST, url: accepted_usage_terms_user_path },
          reject: { method: :POST, url: '/auth/sign-out' }
        }
      end

    end
  end
end
