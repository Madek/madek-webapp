module Presenters
  module CustomUrls
    class ResourceCustomUrls < Presenters::Shared::AppResource

      def initialize(user, resource)
        super(resource)
        @user = user
      end

      def resource
        name = @app_resource.class.name
        presenter_name = "Presenters::#{name.pluralize}::#{name}Index"
        presenter_name.constantize.new(
          @app_resource,
          @user
        )
      end

      def custom_urls
        return [] unless @app_resource.custom_urls
        @app_resource.custom_urls.map do |custom_url|
          Presenters::CustomUrls::CustomUrl.new(custom_url)
        end
      end
    end
  end
end
