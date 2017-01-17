module Presenters
  module CustomUrls
    class ResourceEditCustomUrls < Presenters::Shared::AppResource

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
    end
  end
end
