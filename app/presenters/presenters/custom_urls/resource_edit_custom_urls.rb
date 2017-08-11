module Presenters
  module CustomUrls
    class ResourceEditCustomUrls < Presenters::Shared::AppResource

      def initialize(user, resource, confirmation)
        super(resource)
        @user = user
        @confirmation = confirmation
      end

      def resource
        name = @app_resource.class.name
        presenter_name = "Presenters::#{name.pluralize}::#{name}Index"
        presenter_name.constantize.new(
          @app_resource,
          @user
        )
      end

      attr_reader :confirmation

      def custom_urls_url
        send "custom_urls_#{@app_resource.model_name.singular}_path",
             @app_resource
      end
    end
  end
end
