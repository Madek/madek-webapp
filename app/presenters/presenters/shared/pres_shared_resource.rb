module Presenters
  module Shared
    class PresSharedResource < Presenter

      def initialize(resource)
        @resource = resource
      end

      def title
        _resource_title(@resource)
      end
    end
  end
end
