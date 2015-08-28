module Concerns
  module MediaResources
    module ShowAction
      extend ActiveSupport::Concern

      def show
        authorize_and_respond_with_respective_presenter
      end
    end
  end
end
