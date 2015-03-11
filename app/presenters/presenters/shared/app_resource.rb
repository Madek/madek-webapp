module Presenters
  module Shared
    class AppResource < Presenter
      def initialize(resource)
        @resource = resource
      end

      def uuid
        @resource.id
      end

      def inspect
        "#<#{self.class} resource_id: \"#{id}\">"
      end
    end
  end
end
