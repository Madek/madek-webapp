module Presenters
  module Licenses
    class LicenseIndex < Presenters::Shared::AppResource
      delegate_to_app_resource :label,
                               :usage,
                               :url
    end
  end
end
