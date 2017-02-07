module Presenters
  module TransferResponsibility
    class ResourceEditTransferResponsibility < Presenters::Shared::AppResource

      def initialize(resource, user)
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
