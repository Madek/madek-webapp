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
    end
  end
end
