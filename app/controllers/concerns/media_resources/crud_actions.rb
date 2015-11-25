module Concerns
  module MediaResources
    module CrudActions
      extend ActiveSupport::Concern
      include Concerns::ControllerHelpers

      def show
        represent
      end

      def index
        resources = policy_scope(model_klass)
        @get = presenterify(resources)
        respond_with @get
      end
    end
  end
end
