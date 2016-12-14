module Concerns
  module MediaResources
    module CrudActions
      extend ActiveSupport::Concern
      include Concerns::ControllerHelpers

      def show
        represent
      end

      def index
        resources = auth_policy_scope(current_user, model_klass)
        @get = presenterify(resources, nil)
        respond_with @get
      end
    end
  end
end
