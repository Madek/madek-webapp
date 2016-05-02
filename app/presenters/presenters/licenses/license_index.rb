module Presenters
  module Licenses
    class LicenseIndex < Presenters::Shared::AppResource
      delegate_to_app_resource :label, :usage

      def url
       prepend_url_context(license_path(@app_resource.id))
      end

      def external_url
        @app_resource.url
      end
    end
  end
end
